/*
 * Box artifact.
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org).
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL).
 *
 * OFL is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * OFL is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with OFL.  If not, see <http: //www.gnu.org/licenses/>.
 */

include <OFL/foundation/unsafe_defs.scad>
include <OFL/foundation/incs.scad>
include <OFL/vitamins/incs.scad>

include <NopSCADlib/lib.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

FILAMENT_UPPER  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
FILAMENT_LOWER  = "SteelBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Supported verbs] */

// adds shapes to scene.
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a box representing the payload of the shape
PLOAD     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Parts] */

UPPER_PART  = true;
LOWER_PART  = true;

/* [Box] */

// thickness 
T         = 2.5;
// inner radius for rounded angles (square if undef)
RADIUS    = 1.1;
EXPLODE   = 7.5;
TOLERANCE = 0.3;
FILLET    = false;

// Internal payload size
PAY_SIZE  = [100,60,40];

/* [Hidden] */

module __test__() {
  direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
  octant    = PLACE_NATIVE  ? undef : OCTANT;
  verbs=[
    if (ADD!="OFF")       FL_ADD,
    if (ASSEMBLY!="OFF")  FL_ASSEMBLY,
    if (AXES!="OFF")      FL_AXES,
    if (BBOX!="OFF")      FL_BBOX,
    if (PLOAD!="OFF")     FL_PAYLOAD,
  ];
  $FL_ADD       = ADD;
  $FL_ASSEMBLY  = ASSEMBLY;
  $FL_AXES      = AXES;
  $FL_BBOX      = BBOX;
  $FL_PAYLOAD   = PLOAD;

  radius  = RADIUS!=0 ? RADIUS : undef;

  PARTS = (LOWER_PART && UPPER_PART) ? "all" 
        : LOWER_PART ? "lower" 
        : UPPER_PART ? "upper"
        : "none";

  TREAL = T + TOLERANCE;

  Tpl=fl_T([TREAL,TREAL,T+TOLERANCE]);

  size  = PAY_SIZE+[2*TREAL,2*TREAL,2*TREAL];

  fl_trace("$FL_ADD",$FL_ADD);
  fl_trace("external size",size);
  // fl_placeIf(!PLACE_NATIVE,octant=OCTANT,bbox=[-size/2,+size/2])
  fl_box(verbs,psize=PAY_SIZE,thick=T,radius=radius,parts=PARTS,material_upper=FILAMENT_UPPER,material_lower=FILAMENT_LOWER,tolerance=TOLERANCE,fillet=FILLET,octant=octant,direction=direction,
  $FL_PAYLOAD=PLOAD);
}

// engine for generating boxes
module fl_box(
  verbs           = FL_ADD,
  preset,                   // preset profiles
  size,                     // dimensioni del profilato [w,h,d]. Uno scalare s indica [s,s,s]
  psize,                    // internal payload size
  thick,                    // sheet thickness
  radius,                   // fold internal radius (square if undef)
  parts,                    // "all","upper","lower"
  tolerance       = 0.3,
  material_upper,           // upper side color
  material_lower,           // lower side color
  fillet          = true,
  direction,                // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant                    // when undef native positioning is used
) {
  assert((size==undef && psize!=undef) || (size!=undef && psize==undef));
  assert(thick!=undef);
  
  fl_trace("$FL_ADD",$FL_ADD);
  fl_trace("$FL_PAYLOAD",$FL_PAYLOAD);

  axes    = fl_list_has(verbs,FL_AXES);
  verbs   = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  Treal   = thick + tolerance;
  deltas  = [2*Treal,2*Treal,2*Treal];  // deltas = size - payload
  sz      = size!=undef ? size : psize + deltas;
  psz     = psize!=undef ? psize : sz - deltas;
  sz_low  = sz;
  sz_up   = [sz.x,sz.y-2*Treal,sz.z-Treal];
  bbox    = [-sz/2,+sz/2];
  knut    = FL_KNUT_M3x8x5;
  screw   = M3_cs_cap_screw;
  holder_sz = fl_bb_size(knut)+[3,3,-2*FL_NIL];
  Mknut   = T([0,sz.y/2-thick-tolerance,sz_up.z/2-(holder_sz.y+thick-tolerance)/2]);
  Mholder = Mknut * Rx(90);
  D       = direction ? fl_direction(direction=direction,default=[+Z,+X])  : I;
  M       = octant    ? fl_octant(octant=octant,bbox=bbox)            : I;

  fl_trace("size",size);
  fl_trace("psize",psize);
  fl_trace("sz",sz);
  fl_trace("bounding box",bbox);
  
  module do_fillet(r) {
    delta = thick - r;
    for(i=[-1,1])
      translate([0,i*(delta + thick - sz.y/2),-sz.z/2 + delta + thick])
        fl_fillet(r=r,h=sz_low.x,octant=[1,1,0],direction=[FL_X,-45+i*135]);
  }

  module holder() {
    difference() {
      translate(fl_Z(FL_NIL)) fl_cube(FL_ADD,size=holder_sz,octant=+FL_Z);
      knut(FL_DRILL,knut);
    }
  }

  module lower() {
    difference() {
      intersection() {
        rotate([90,0,90]) 
          fl_profile(FL_ADD,type="U",size=[sz_low.y,sz_low.z,sz_low.x],thick=thick,radius=undef,material=material_lower);
        if (radius!=undef)
          rotate(-90,FL_X)
            fl_bentPlate(FL_FOOTPRINT,type="U",size=[sz_low.x,sz_low.z,sz_low.y],thick=thick,radius=radius,material=material_lower);
      }
      translate(+Y(Treal+FL_NIL))
        multmatrix(Mknut) 
          knut(FL_LAYOUT,knut,direction=[+Y,0],octant=-Z) 
            fl_metaScrew(screw,10);
    }
    if (fillet) 
      fl_color(material_lower) do_fillet(thick);
  }

  module upper() {
    difference() {
      translate(+fl_Z(Treal/2))
        rotate(-90,FL_X)
          fl_bentPlate(FL_ADD,type="U",size=[sz_up.x,sz_up.z,sz_up.y],thick=thick,radius=radius,material=material_upper);
      if (fillet)
        do_fillet(thick-tolerance);
    }
    multmatrix(Mholder) {
      fl_color(material_upper) holder();
    }
  }

  module do_assembly() {
    if (parts=="all" || parts=="upper")
      multmatrix(Mknut) 
        knut([FL_ADD,FL_AXES],knut,direction=[+Y,0],octant=-Z) ;
    if (parts=="all" || parts=="lower")
      translate(+Y(Treal+FL_NIL))
        multmatrix(Mknut) 
          knut(FL_LAYOUT,knut,direction=[+Y,0],octant=-Z) 
            screw(screw,10);
  }

  module do_add() {
    if (parts=="all" || parts==("upper")) upper();
    if (parts=="all" || parts==("lower")) lower();
  }

  module do_pload() {
    fl_cube(size=psz,octant=[0,0,0]);
  }

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_add();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_cube(size=sz, octant=[0,0,0]);
      } else if ($verb==FL_ASSEMBLY) {
        fl_modifier($FL_ASSEMBLY) do_assembly();
      } else if ($verb==FL_PAYLOAD) {
        fl_trace("$FL_PAYLOAD",$FL_PAYLOAD);
        fl_modifier($FL_PAYLOAD) do_pload();
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=sz);
  }
}

__test__();
