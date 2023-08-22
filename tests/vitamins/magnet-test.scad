/*
 * Magnet test file.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../lib/OFL/foundation/unsafe_defs.scad>

include <../../lib/OFL/vitamins/magnets.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$fl_debug   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]

/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
$FL_ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
$FL_FOOTPRINT = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Magnet] */

// -1 for all, the ordinal dictionary member otherwise
SHOW      = -1;   // [-1:1:5]
// extra dimension to be added when FOOTPRINT verb is called
FP_EXTRA  = 0;    // [0:0.1:3]
T         = 2.5;  // [0:20]

/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
verbs=[
  if ($FL_ADD!="OFF")       FL_ADD,
  if ($FL_ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if ($FL_AXES!="OFF")      FL_AXES,
  if ($FL_BBOX!="OFF")      FL_BBOX,
  if ($FL_DRILL!="OFF")     FL_DRILL,
  if ($FL_FOOTPRINT!="OFF") FL_FOOTPRINT,
  if ($FL_LAYOUT!="OFF")    FL_LAYOUT,
];

module do_test(magnet) {
  echo(str("obj name:",fl_name(magnet)));
  fl_trace("DIR_NATIVE",DIR_NATIVE);
  fl_trace("DIR_Z",DIR_Z);
  fl_trace("DIR_R",DIR_R);
  screw = fl_screw(magnet);
  fl_magnet(verbs,magnet,fp_gross=FP_EXTRA,thick=T,octant=octant,direction=direction)
      if (screw!=undef) fl_color("green") fl_cylinder(h=fl_thick(magnet),r=screw_radius(screw),octant=-Z);
}

if (SHOW>-1)
  do_test(FL_MAG_DICT[SHOW]);
else
  layout([for(magnet=FL_MAG_DICT) fl_bb_size(magnet).x], 10)
    do_test(FL_MAG_DICT[$i]);
