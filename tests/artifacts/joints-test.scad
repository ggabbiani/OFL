/*
 * Snap-fit joints test.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../lib/OFL/artifacts/joints.scad>

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
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
$FL_CUTOUT    = "OFF";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
$FL_FOOTPRINT = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [FACTORY] */

JOINT_TYPE    = "cantilever"; // [cantilever]
// fillet radius
JOINT_FILLET  = "auto";  // [auto,0,1,2,3,4,5,6,7,8,9,10]
CANTILEVER_ORIENT = "+z"; // [+z,-z]
// total cantilever length (arm+tooth)
CANTILEVER_L  = 1;
// thickness of arm
CANTILEVER_H  = 1;
// width of arm
CANTILEVER_B  = 1;
// undercut
CANTILEVER_Y  = 1;
// tooth angle
CANTILEVER_ANGLE  = 30; // [1:89]

/* [TEST] */

/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

verbs = fl_verbList([
  FL_ADD,
  FL_AXES,
  FL_BBOX,
  FL_CUTOUT,
  FL_FOOTPRINT,
]);

orient  = CANTILEVER_ORIENT=="+z" ? +Z : -Z;
fillet  = JOINT_FILLET!="auto" ? fl_atof(JOINT_FILLET) : JOINT_FILLET;
joint   = JOINT_TYPE=="cantilever" ?
  fl_jnt_RectCantilever(alpha=CANTILEVER_ANGLE,orientation=orient, length=CANTILEVER_L,h=CANTILEVER_H,b=CANTILEVER_B,undercut=CANTILEVER_Y,fillet=fillet) :
  undef;

fl_jnt_joint(verbs, joint, octant=octant, direction=direction, debug=debug);
