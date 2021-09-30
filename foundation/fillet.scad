/*
 * Fillet primitives.
 *
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

include <unsafe_defs.scad>
use     <3d.scad>
use     <placement.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

$FL_FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Supported verbs] */

// adds shapes to scene.
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [+1,+1,+1];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Fillets] */

// choose one test
TEST="linear"; // [linear,round]

/* [Linear fillet] */

RADIUS  = 1;
LENGTH  = 10;

/* [Round fillet] */

ROUND_RADIUS  = 1;
ROUND_STEPS   = 10;
CHILD_SIZE    = [1,2];

/* [Hidden] */

CHILD_BBOX=[O,CHILD_SIZE];

module __test__() {
  direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
  octant    = PLACE_NATIVE  ? undef : OCTANT;
  verbs=[
    if (ADD!="OFF")   FL_ADD,
    if (AXES!="OFF")  FL_AXES,
    if (BBOX!="OFF")  FL_BBOX,
  ];
  fl_trace("PLACE_NATIVE",PLACE_NATIVE);
  fl_trace("octant",octant);

  if (TEST=="linear")
    fl_fillet(verbs,r=RADIUS,h=LENGTH,octant=octant,direction=direction,
              $FL_ADD=ADD,$FL_AXES=AXES,$FL_BBOX=BBOX);
  else 
    fl_90DegFillet(verbs,r=ROUND_RADIUS,n=ROUND_STEPS,child_bbox=CHILD_BBOX,octant=octant,direction=direction,
                    $FL_ADD=ADD,$FL_AXES=AXES,$FL_BBOX=BBOX)
      square(size=CHILD_SIZE);
}

module fl_fillet(
  verbs   = FL_ADD, // FL_ADD, FL_AXES, FL_BBOX
  r,
  h,
  direction,  // desired direction [director,rotation], [+Z,0°] native direction when undef [+Z,+X]
  octant      // when undef native positioning is used (+Z)
  ) {
  assert(verbs!=undef,str("verbs=",verbs));

  axes    = fl_list_has(verbs,FL_AXES);
  verbs   = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  default = [+Z,+X];  // default director and rotor
  size    = [r,r,h];
  bbox    = [O,size];
  M       = octant!=undef ? fl_octant(octant=octant,bbox=bbox) : I;
  D       = direction!=undef ? fl_direction(direction=direction,default=default) : I;
  fl_trace("D",D);
  fl_trace("default",default);

  module do_add() {
    linear_extrude(h)
      difference() {
        square(r);
        translate([r, r]) circle(r);
    }
  }

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
    fl_trace("***");
        fl_modifier($FL_ADD) do_add();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_cube(size=size);
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=size);
  }
}

// 90 Degree fillet taken from:
// https://forum.openscad.org/Fillet-With-Internal-Angles-td17201.html
module fl_90DegFillet(
  verbs = FL_ADD,
  r,                  // fillet radius
  n,                  // number of steps along Z axis
  child_bbox,         // bounding box od the object to apply the fillet to
  direction,          // desired direction [director,rotation], [+Z,0°] native direction when undef
  octant,             // 3d placement, children positioning when undef
) {
  assert(child_bbox!=undef);
  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  function rad(x) = r - sqrt(pow(r,2) - pow(x - r, 2));
  function d3(p)  = [p.x,p.y,0];

  default = [+Z,+X];  // default director and rotor
  bbox    = [d3(child_bbox[0])-[r,r,0],d3(child_bbox[1])+[r,r,r]];
  size    = bbox[1]-bbox[0];
  D       = direction ? fl_direction(direction=direction,default=default) : I;
  M       = octant    ? fl_octant(octant=octant,bbox=bbox) : I;

  module do_add() {
    s   = r/n;    //step size
    eps = 0.001;  // a little overlap between slices
    for(i = [0 : s : r - s]) 
      translate([0, 0, i]) minkowski() {
        linear_extrude(height = eps)
          children();
        cylinder(r1 = rad(i), r2 = rad(i + s), h = s, $fn = 32);
      }
    }

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_add() children();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) translate(bbox[0]) fl_cube(size=size);
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_axes(size=size);
  }
}

__test__();
