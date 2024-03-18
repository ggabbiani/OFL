/*
 * 3d frame test.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../lib/OFL/foundation/core.scad>

use <../../lib/OFL/foundation/3d-engine.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$fl_debug   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// Default color for printable items (i.e. artifacts)
$fl_filament  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]
SHOW_LABELS     = false;
SHOW_SYMBOLS    = false;

/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [3D Placement] */

X_PLACE = "undef";  // [undef,-1,0,+1]
Y_PLACE = "undef";  // [undef,-1,0,+1]
Z_PLACE = "undef";  // [undef,-1,0,+1]


/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [-360:360]

/* [3d frame] */

// overall size
SIZE      = [15,15,15];
// base thickness (walls)
T         =2.5; // [0:.1:5]
// Quadrant I [x radius,y radius]
CORNER_0  = [6,3];
// Quadrant II [x radius,y radius]
CORNER_1  = [2,2];
// Quadrant III [x radius,y radius]
CORNER_2  = [3,6];
// Quadrant IV [x radius,y radius]
CORNER_3  = [0,0];

/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

verbs=fl_verbList([
  FL_ADD,
  FL_AXES,
  FL_BBOX,
]);
corners  = [CORNER_0,CORNER_1,CORNER_2,CORNER_3];

fl_frame(verbs,SIZE, corners,T, debug, octant, direction);
