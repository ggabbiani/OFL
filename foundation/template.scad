/*
 * Template file for OpenSCAD Foundation Library.
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
include <defs.scad>
use     <3d.scad>
use     <layout.scad>
use     <placement.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = true;
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
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Hidden] */

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

  type      = [
    fl_bb_cornersKV([[0,0,0],[0.5,0.5,1]]),
    fl_directorKV([0,0,1]),
    fl_rotorKV([1,0,0]),
  ];

  // $FL_ADD=ADD;$FL_AXES=AXES;$FL_BBOX=BBOX;
  stub(verbs,type,octant=octant,direction=direction,$FL_ADD=ADD,$FL_AXES=AXES,$FL_BBOX=BBOX);
}

module stub(
  verbs       = FL_ADD, // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  type,
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant,               // when undef native positioning is used
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  D     = direction ? fl_direction(proto=type,direction=direction)  : FL_I;
  M     = octant    ? fl_octant(octant=octant,bbox=bbox)            : FL_I;

  fl_trace("D",D);
  fl_trace("M",M);
  fl_trace("bbox",bbox);

  module do_add() {}
  module do_bbox() {}
  module do_assembly() {}
  module do_layout() {}
  module do_drill() {}

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) fl_cube(size=size);
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_cube(size=size);
      } else if ($verb==FL_LAYOUT) {
        fl_modifier($FL_LAYOUT) do_layout()
          children();
      } else if ($verb==FL_FOOTPRINT) {
        fl_modifier($FL_FOOTPRINT);
      } else if ($verb==FL_ASSEMBLY) {
        fl_modifier($FL_ASSEMBLY);
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
