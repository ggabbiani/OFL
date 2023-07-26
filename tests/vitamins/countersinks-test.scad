/*
 * Countersink test.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../foundation/unsafe_defs.scad>
include <../../vitamins/countersinks.scad>

use <../../foundation/3d-engine.scad>

$fn         = 50;           // [3:100]
// When true, disables epsilon corrections
$FL_RENDER  = false;
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]
$fl_debug   = false;
SHOW_LABELS      = false;
SHOW_SYMBOLS     = false;

/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Countersink] */

TOLERANCE = 0;  // [-1:0.1:1]
// -1 for all, the ordinal dictionary member otherwise
SHOW    = -1;   // [-1:1:8]
GAP     = 5;

/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
debug     = fl_parm_Debug(labels=SHOW_LABELS,symbols=SHOW_SYMBOLS);

verbs=[
  if ($FL_ADD!="OFF")   FL_ADD,
  if ($FL_AXES!="OFF")  FL_AXES,
  if ($FL_BBOX!="OFF")  FL_BBOX,
];

if (SHOW>-1)
  echo("countersink ",fl_name(FL_CS_DICT[SHOW]))
    fl_countersink(verbs,FL_CS_DICT[SHOW],tolerance=TOLERANCE,octant=octant,direction=direction);
else
  fl_layout(axis=X,gap=GAP,types=FL_CS_DICT)
    fl_countersink(verbs,FL_CS_DICT[$i],tolerance=TOLERANCE,octant=octant,direction=direction);
