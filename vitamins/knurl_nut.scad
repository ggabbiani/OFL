/*
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
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

include <knurl_nuts.scad>
include <../foundation/unsafe_defs.scad>

use     <../foundation/3d.scad>
use     <../foundation/layout.scad>
use     <../foundation/placement.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

/* [Supported verbs] */

// adds shapes to scene.
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Knurl nut] */

SHOW    = "All"; // [All, FL_KNUT_M2x4x3p5, FL_KNUT_M2x6x3p5,  FL_KNUT_M2x8x3p5,  FL_KNUT_M2x10x3p5, FL_KNUT_M3x4x5,   FL_KNUT_M3x6x5,    FL_KNUT_M3x8x5,    FL_KNUT_M3x10x5, FL_KNUT_M4x4x6,   FL_KNUT_M4x6x6,    FL_KNUT_M4x8x6,    FL_KNUT_M4x10x6,FL_KNUT_M5x6x7,   FL_KNUT_M5x8x7,    FL_KNUT_M5x10x7]

/* [Hidden] */

module __test__() {
  direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
  octant    = PLACE_NATIVE  ? undef : OCTANT;
  obj       = SHOW=="FL_KNUT_M2x4x3p5"  ? FL_KNUT_M2x4x3p5
            : SHOW=="FL_KNUT_M2x6x3p5"  ? FL_KNUT_M2x6x3p5
            : SHOW=="FL_KNUT_M2x8x3p5"  ? FL_KNUT_M2x8x3p5
            : SHOW=="FL_KNUT_M2x10x3p5" ? FL_KNUT_M2x10x3p5
            : SHOW=="FL_KNUT_M3x4x5"    ? FL_KNUT_M3x4x5
            : SHOW=="FL_KNUT_M3x6x5"    ? FL_KNUT_M3x6x5
            : SHOW=="FL_KNUT_M3x8x5"    ? FL_KNUT_M3x8x5
            : SHOW=="FL_KNUT_M3x10x5"   ? FL_KNUT_M3x10x5
            : SHOW=="FL_KNUT_M4x4x6"    ? FL_KNUT_M4x4x6
            : SHOW=="FL_KNUT_M4x6x6"    ? FL_KNUT_M4x6x6
            : SHOW=="FL_KNUT_M4x8x6"    ? FL_KNUT_M4x8x6
            : SHOW=="FL_KNUT_M4x10x6"   ? FL_KNUT_M4x10x6
            : SHOW=="FL_KNUT_M5x6x7"    ? FL_KNUT_M5x6x7
            : SHOW=="FL_KNUT_M5x8x7"    ? FL_KNUT_M5x8x7
            : SHOW=="FL_KNUT_M5x10x7"   ? FL_KNUT_M5x10x7
            : undef;
  verbs=[
    if (ADD!="OFF")       FL_ADD,
    if (ASSEMBLY!="OFF")  FL_ASSEMBLY,
    if (AXES!="OFF")      FL_AXES,
    if (BBOX!="OFF")      FL_BBOX,
    if (DRILL!="OFF")     FL_DRILL,
  ];
  fl_trace("verbs",verbs);

  module _knut_(verbs,obj) {
    knut(verbs,obj,octant=octant,direction=direction
        ,$FL_ADD=ADD,$FL_ASSEMBLY=ASSEMBLY,$FL_AXES=AXES,$FL_BBOX=BBOX,$FL_DRILL=DRILL);
  }

  if (obj)
    _knut_(verbs,obj);
  else
    for(i=[0:len(FL_KNUT_DICT)-1]) let(row=FL_KNUT_DICT[i],l=len(row)) translate(fl_Y(12*i)) {
      fl_trace("len(row)",len(row));
      fl_layout(axis=+FL_X,gap=3,types=row) { 
        if (l>0) let(type=row[0]) _knut_(verbs,type);
        if (l>1) let(type=row[1]) _knut_(verbs,type);
        if (l>2) let(type=row[2]) _knut_(verbs,type);
        if (l>3) let(type=row[3]) _knut_(verbs,type);
      }
    }
}

//*****************************************************************************
// getters
function knut_screw(type)   = fl_get(type,fl_knut_screwKV());
function knut_l(type)       = fl_get(type,fl_knut_lengthKV());
function knut_tooth_h(type) = fl_get(type,fl_knut_toothHeightKV());
function knut_teeth(type)   = fl_get(type,fl_knut_teethNumberKV());
function knut_r(type)       = fl_get(type,fl_knut_externalRadiusKV());
function knut_rings(type)   = fl_get(type,fl_knut_ringsKV());

function knut_size(type)    = fl_bb_size(type);

module knut(
  verbs,
  type,
  direction,            // desired direction [director,rotation], native direction when undef ([+Z])
  octant,               // when undef native positioning is used
) {
  assert(verbs!=undef);
  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  r       = knut_r(type);
  l       = knut_l(type);
  screw   = knut_screw(type);
  screw_r = screw_radius(screw);
  screw_l = screw_shorter_than(l);
  rings   = knut_rings(type);
  tooth_h = knut_tooth_h(type);
  teeth   = knut_teeth(type);
  bbox    = fl_bb_corners(type);
  size    = knut_size(type);
  D       = direction ? fl_direction(proto=type,direction=direction)  : FL_I;
  M       = octant    ? fl_octant(octant=octant,bbox=bbox)            : FL_I;

  fl_trace("bbox",bbox);
  fl_trace("size",size);
  
  module tooth(r,h) {
    assert(r!=undef||h!=undef);
    // echo(str("r=", r));
    hh = (h==undef) ? r * 3 / 2 : h;
    rr = (r==undef) ? h * 2 / 3 : r;
    translate([hh-rr,0,0]) rotate(240,FL_Z) circle(rr,$fn=3);
  }

  module toothed_circle(
    n,      // number of teeth
    r,      // inner circle
    h       // tooth height
    ) {
    for(i=[0:n])
      rotate([0,0,i*360/n])
        translate([r,0,0])
          tooth(h=h);
    circle(r=r);
    // %circle(r+h);
    // #circle(r);
  }

  module toothed_nut(
    n=100,  // number of teeth
    r,      // inner circle
    R,      // outer circle
    thick,
    center=false
    ) {
    translate([0,0,center?-thick/2:0])
      linear_extrude(thick) {
        difference() {
          toothed_circle(n=n,r=r,h=R-r);
          circle(r=r);
        }
      }
  }

  module do_add() {
    fl_color("gold") difference() {
      union() {
        for(ring=rings)
          translate([0, 0, ring[1]]) 
            toothed_nut(r=screw_r,R=r,thick=ring[0],n=teeth);
        cylinder(r=r-tooth_h, h=l);
      }
      translate(-fl_Z(FL_NIL)) cylinder(r=screw_r, h=l+2*FL_NIL);
    }
    // #cylinder(r=r, h=l);
  }

  module do_bbox() {
    translate(+Z(l/2)) fl_cube(size=size+[0,0,2*NIL], octant=O);
  }

  module do_layout()    {
    translate(fl_Z(l)) children();
  }
  module do_drill() {
    fl_cylinder(r=r-0.2 /* tooth_h */, h=l,octant=+Z);
  }

  // translate(-fl_Z(center?l/2:0))
  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_add();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) do_bbox();
      } else if ($verb==FL_ASSEMBLY) {
        fl_modifier($FL_ASSEMBLY) do_layout()  screw(screw,screw_l);
      } else if ($verb==FL_LAYOUT) { 
        fl_modifier($FL_LAYOUT) do_layout() children();
      } else if ($verb==FL_DRILL) {
        fl_modifier($FL_DRILL) do_drill();
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=size);
  }
}

__test__();