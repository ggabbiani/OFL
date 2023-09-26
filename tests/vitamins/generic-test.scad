/*
 * Test for generic component(s)
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/foundation/unsafe_defs.scad>
include <../../lib/OFL/vitamins/generic.scad>


$fn            = 50;           // [3:100]
// When true, debug statements are turned on
$fl_debug      = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER     = false;
// Default color for printable items (i.e. artifacts)
$fl_filament   = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES     = -2;     // [-2:10]
SHOW_LABELS     = false;
SHOW_SYMBOLS    = false;


/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
$FL_CUTOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)


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


/* [Bounding box] */

BB_NEGATIVE = [-1,-1,-0.5]; // [-10:0.05:10]
BB_POSITIVE = [1,1,0];      // [-10:0.05:10]

/* [Cut out] */

TOLERANCE = 0;  // [0:0.1:5]

T_X = [0,0];  // [0:0.1:1]
T_Y = [0,0];  // [0:0.1:1]
T_Z = [0,0];  // [0:0.1:1]

/* [Drift] */

D_X = [0,0];  // [-1:0.1:1]
D_Y = [0,0];  // [-1:0.1:1]
D_Z = [0,0];  // [-1:0.1:1]


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// end of automatically generated code

verbs = fl_verbList([FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT]);
bbox  = [BB_NEGATIVE,BB_POSITIVE];

type  = fl_generic_Vitamin("Test type",bbox=bbox,cut_directions=[-X,+X,-Y,+Y,-Z,+Z]);
drift = D_X && D_Y && D_Z ? [D_X,D_Y,D_Z] : undef;

fl_generic_vitamin(verbs,type,cut_tolerance=TOLERANCE,cut_thick=[T_X,T_Y,T_Z],cut_drift=drift,direction=direction,octant=octant);
