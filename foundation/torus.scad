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
include <unsafe_defs.scad>
use     <2d.scad>
use     <placement.scad>

$fn         = 50;           // [3:100]
$fs         = 50;           // [3:100]
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
// layout of predefined auxiliary shapes (like predefined screws)
ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
CUTOUT    = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
FPRINT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a box representing the payload of the shape
PLOAD     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
QUADRANT      = [+1,+1];  // [-1:+1]

/* [Torus] */

// Torus radius
R = 5;                // [0:+100]
// Ellipse horiz. semi axis
A = 2;
// Ellipse vert. semi axis
B = 1;
// arc/sector specific
START_ANGLE   = 0;    // [0:360]
END_ANGLE     = 60;   // [0:360]
T             = 1;

/* [Hidden] */

module __test__() {
  quadrant  = PLACE_NATIVE ? undef : QUADRANT;
  verbs=[
    if (ADD!="OFF")       FL_ADD,
    if (ASSEMBLY!="OFF")  FL_ASSEMBLY,
    if (AXES!="OFF")      FL_AXES,
    if (BBOX!="OFF")      FL_BBOX,
    if (LAYOUT!="OFF")    FL_LAYOUT,
  ];
  fl_torus(verbs,r=R,a=A,b=B)
    fl_ellipticArc(e=[A,B],angles=[START_ANGLE,END_ANGLE],width=T,quadrant=+X);
  // fl_torus(r=R) fl_circle(radius=A,quadrant=+X);
  // fl_torus(r=R) fl_ellipse(e=[A,B],quadrant=+X);
  // fl_torus(r=R) fl_ellipticArc(e=[A,B],angles=[START_ANGLE,END_ANGLE],width=T,quadrant=+X);
  // fl_torus(r=R) fl_ellipticSector(e=[A,B],angles=[START_ANGLE,END_ANGLE],quadrant=+X);

}

module fl_torus(
  verbs       = FL_ADD, // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  r           = 1,
  a,
  b,
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant                // when undef native positioning is used
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  
  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  // bbox  = fl_bb_corners(type);
  // size  = fl_bb_size(type);
  // D     = direction ? fl_direction(proto=type,direction=direction)  : FL_I;
  // M     = octant    ? fl_octant(octant=octant,bbox=bbox)            : FL_I;
  D     = I;
  M     = I;

  fl_trace("D",D);
  fl_trace("M",M);
  // fl_trace("bbox",bbox);

  module do_bbox() {}
  
  module do_assembly() {
    do_layout()
      fl_ellipse(e=[a,b],quadrant=+X);
  }
  
  module do_layout() {
    rotate_extrude() translate(X(r)) children();
  }

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_assembly();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_cube(size=size);
      } else if ($verb==FL_LAYOUT) {
        fl_modifier($FL_LAYOUT) do_layout()
          children();
      } else if ($verb==FL_FOOTPRINT) {
        fl_modifier($FL_FOOTPRINT);
      } else if ($verb==FL_ASSEMBLY) {
        fl_modifier($FL_ASSEMBLY) do_assembly();
      } else if ($verb==FL_DRILL) {
        fl_modifier($FL_DRILL);
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=size);
  }
}

__test__();
