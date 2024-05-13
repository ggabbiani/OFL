/*
 * Test for generic component(s)
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
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
$FL_DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


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


/* [Constructor parameters] */

// when true FL_ADD is a no-op
GHOST=false;

// Bounding box low corner
BB_NEGATIVE = [-1,-1,-0.5]; // [-10:0.05:10]
// Bounding box high corner
BB_POSITIVE = [1,1,0];      // [-10:0.05:10]

// cut directions
CUT_DIRECTIONS = ["±x","±y","±z"];

/* [Engine parameters] */

CUT_TOLERANCE = 0;  // [0:0.1:0.5]

// thickness for FL_CUTOUT along X semi axes
THICK_X = [0,0];  // [0:0.1:3]
// thickness for FL_CUTOUT along Y semi axes
THICK_Y = [0,0];  // [0:0.1:3]
// thickness for FL_CUTOUT along Z semi axes
THICK_Z = [0,0];  // [0:0.1:3]

// translation for FL_CUTOUT along X semi axes
CUT_DRIFT_X = [0,0];  // [-1:0.1:1]
// translation for FL_CUTOUT along Y semi axes
CUT_DRIFT_Y = [0,0];  // [-1:0.1:1]
// translation for FL_CUTOUT along Z semi axes
CUT_DRIFT_Z = [0,0];  // [-1:0.1:1]


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// end of automatically generated code

verbs = fl_verbList([FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT,FL_DRILL,FL_LAYOUT]);
bbox  = [BB_NEGATIVE,BB_POSITIVE];
cut_directions = fl_3d_AxisList(CUT_DIRECTIONS);
holes = let(size=bbox[1]-bbox[0]) [
  fl_Hole(bbox[0]+[size.x/2,size.y/2,size.z],min(size.x,size.y)/3,depth=size.z),
  fl_Hole(bbox[0]+[size.x/4,size.y/4,size.z],min(size.x,size.y)/6,depth=size.z)
];

type  = fl_generic_Vitamin(bbox,"Test type",ghost=GHOST,cut_directions=cut_directions,holes=holes);
drift = CUT_DRIFT_X[0] || CUT_DRIFT_X[1] || CUT_DRIFT_Y[0] || CUT_DRIFT_Y[1] || CUT_DRIFT_Z[0] || CUT_DRIFT_Z[1] ? [CUT_DRIFT_X,CUT_DRIFT_Y,CUT_DRIFT_Z] : 0;
thick = THICK_X[0] || THICK_X[1] || THICK_Y[0] || THICK_Y[1] || THICK_Z[0] || THICK_Z[1] ? [THICK_X,THICK_Y,THICK_Z] : 0;

fl_generic_vitamin(verbs,type,
  cut_tolerance=CUT_TOLERANCE,
  thick=thick,
  cut_drift=drift,
  direction=direction,octant=octant,
  debug=debug
) fl_cylinder(h=$hole_depth,d=$hole_d,direction=$hole_direction,$FL_ADD=$FL_LAYOUT);
