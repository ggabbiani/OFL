/*
 * Single pole, double throw switch test file.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../lib/OFL/vitamins/spdts.scad>

$fn         = 50;           // [3:100]
// When true, disables epsilon corrections
$FL_RENDER    = false;
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES    = -2;     // [-2:10]
$fl_debug     = false;
SHOW_LABELS   = false;
SHOW_SYMBOLS  = false;

/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [-360:1:360]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Hidden] */

fl_status();
direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
debug     = fl_parm_Debug(labels=SHOW_LABELS,symbols=SHOW_SYMBOLS);

verbs=[
  if ($FL_ADD!="OFF")   FL_ADD,
  if ($FL_AXES!="OFF")  FL_AXES,
  if ($FL_BBOX!="OFF")  FL_BBOX,
  if ($FL_DRILL!="OFF") FL_DRILL,
];

fl_spdt(verbs,FL_SODAL_SPDT,octant=octant,direction=direction,debug=debug);
