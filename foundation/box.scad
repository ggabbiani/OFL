/*
 * Created on Wed Jul 14 2021.
 *
 * Copyright © 2021 Giampiero Gabbiani.
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

include <../vitamins/knurl_nuts.scad>

use <3d.scad>
use <arrange.scad>
use <profile.scad>
use <util.scad>

include <defs.scad>

include <NopSCADlib/lib.scad>

$fn       = 50;           // [3:50]
$FL_TRACE    = false;
$FL_RENDER   = false;
$FL_DEBUG    = false;

AXES      = false;
ASSEMBLY  = false;
BBOX      = false;
PLOAD     = false;

FILAMENT_UPPER  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
FILAMENT_LOWER  = "SteelBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Direction] */

DIR_NATIVE  = true;
DIR_Z       = "FL_Z";  // [FL_X,-FL_X,FL_Y,-FL_Y,FL_Z,-FL_Z]
DIR_R       = 0;    // [-270,-180,-90,0,90,180,270]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Parts] */

UPPER_PART  = true;
LOWER_PART  = true;

/* [Box] */

// thickness 
T         = 2.5;
SIZE      = [60,100,40]; 
// radius for rounded angles (square if undef)
RADIUS    = 1.1;
EXPLODE   = 7.5;
TOLERANCE = 0.3;
FILLET    = false;

/* [Payload] */

// Enables the internal payload test
PAY_TEST  = false;
// Internal payload size
PAY_SIZE  = [100,60,40];

/* [Hidden] */

module __test__() {
  verbs=[
    FL_ADD,
    if (ASSEMBLY) FL_ASSEMBLY,
    if (AXES)     FL_AXES,
    if (BBOX)     FL_BBOX,
  ];

  PARTS = (LOWER_PART && UPPER_PART) ? "all" 
        : LOWER_PART ? "lower" 
        : UPPER_PART ? "upper"
        : "none";

  TREAL = T + TOLERANCE;

  Tpl=fl_T([TREAL,TREAL,T+TOLERANCE]);
  if (PAY_TEST) intersection() {
      __wrap_box__(verbs);
      __wrap_box__(FL_PAYLOAD);
    }
  else {
    __wrap_box__(verbs);
    if (PLOAD)
      #__wrap_box__(FL_PAYLOAD);
  }
  module __wrap_box__(verbs) {
    size  = PAY_SIZE+[2*TREAL,2*TREAL,2*TREAL];
    fl_placeIf(!PLACE_NATIVE,octant=OCTANT,size=size)
      fl_box(verbs,psize=PAY_SIZE,thick=T,radius=(RADIUS!=0?RADIUS:undef),parts=PARTS,material_upper=FILAMENT_UPPER,material_lower=FILAMENT_LOWER,tolerance=TOLERANCE,fillet=FILLET);
  }
}

// engine for generating boxes
module fl_box(
  verbs           = FL_ADD,
  preset,             // preset profiles
  size,               // dimensioni del profilato [w,h,d]. Uno scalare s indica [s,s,s]
  psize,              // internal payload size
  thick,              // sheet thickness
  radius,             // fold internal radius (square if undef)
  parts,              // "all","upper","lower"
  tolerance       = 0.3,
  material_upper,     // upper side color
  material_lower,     // lower side color
  fillet          = true,
  axes            = false
) {

  assert((size==undef && psize!=undef) || (size!=undef && psize==undef));
  assert(thick!=undef);
  Treal   = thick + tolerance;
  deltas  = [2*Treal,2*Treal,2*Treal];  // deltas = size - payload
  sz      = size!=undef ? size : psize + deltas;
  psz     = psize!=undef ? psize : sz - deltas;
  sz_low  = sz;
  sz_up   = [sz.x,sz.y-2*Treal,sz.z-Treal];
  knut    = KnurlNut_M3x8x5;
  screw   = M3_cs_cap_screw;
  holder_sz = bb_size(knut)+[3,3,-2*FL_NIL];
  Mholder = fl_T([0,sz_up.y/2,sz_up.z/2-(holder_sz.y+thick-tolerance)/2]) * fl_Rx(90);

  fl_trace("size",size);
  fl_trace("psize",psize);
  fl_trace("sz",sz);

  module do_fillet(r) {
    delta = thick - r;
    for(i=[-1,1])
      translate([0,i*(delta + thick - sz.y/2),-sz.z/2 + delta + thick]) rotate([90,0,i*90]) 
        fillet(r=r,h=sz_low.x,center=true);
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
          profile(FL_ADD,type="U",size=[sz_low.y,sz_low.z,sz_low.x],thick=thick,radius=undef,material=material_lower);
        if (radius!=undef)
          rotate(-90,FL_X)
            bent_sheet(FL_FOOTPRINT,type="U",size=[sz_low.x,sz_low.z,sz_low.y],thick=thick,radius=radius,material=material_lower);
      }
      translate(+fl_Y(Treal+FL_NIL))
        multmatrix(Mholder) 
          knut(FL_LAYOUT,knut) 
            rotate(180,FL_X) meta_screw(screw,10);
    }
    if (fillet) 
      fl_color(material_lower) do_fillet(thick);
  }

  module upper() {
    difference() {
      translate(+fl_Z(Treal/2))
        rotate(-90,FL_X)
          bent_sheet(FL_ADD,type="U",size=[sz_up.x,sz_up.z,sz_up.y],thick=thick,radius=radius,material=material_upper);
      if (fillet)
        do_fillet(thick-tolerance);
    }
    multmatrix(Mholder) {
      fl_color(material_upper) holder();
    }
  }

  module do_assembly() {
    if (parts=="all" || parts=="upper")
      multmatrix(Mholder) 
        knut(FL_ADD,knut) ;
    if (parts=="all" || parts=="lower")
      translate(+fl_Y(Treal+FL_NIL))
        multmatrix(Mholder) 
          knut(FL_LAYOUT,knut) 
            rotate(180,FL_X) screw(screw,10);
  }

  module do_add() {
    if (parts=="all" || parts==("upper")) upper();
    if (parts=="all" || parts==("lower")) lower();
  }

  module do_pload() {
    fl_cube(size=psz,center=true);
  }

  fl_parse(verbs)  {
    if ($verb==FL_ADD) {
      do_add();
      if (axes)
        fl_axes(size=sz);
    } else if ($verb==FL_BBOX) {
      %cube(size=sz, center=true);
    } else if ($verb==FL_AXES) {
      fl_axes(size=sz);
    } else if ($verb==FL_ASSEMBLY) {
      do_assembly();
    } else if ($verb==FL_PAYLOAD) {
      do_pload();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

__test__();
