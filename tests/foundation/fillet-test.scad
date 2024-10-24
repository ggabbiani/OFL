/*
 * Fillet primitives
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


include <../../lib/OFL/foundation/fillet.scad>


$fn            = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER     = false;
// Default color for printable items (i.e. artifacts)
$fl_filament   = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]


/* [Debug] */

// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]
DEBUG_ASSERTIONS  = false;
DEBUG_COMPONENTS  = ["none"];
DEBUG_COLOR       = false;
DEBUG_DIMENSIONS  = false;
DEBUG_LABELS      = false;
DEBUG_SYMBOLS     = false;


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



/* [Fillets] */

// choose one test
TEST="linear"; // [linear,round]

/* [Linear fillet] */

LINEAR_TYPE = "fillet"; // [fillet,hFillet,vFillet]

R_x     = 1;  // [0:10]
R_y     = 1;  // [0:10]
LENGTH  = 10;

/* [Round fillet] */

ROUND_RADIUS  = 1;
ROUND_STEPS   = 10;
CHILD_SIZE    = [1,2];


/* [Hidden] */


$dbg_Assert     = DEBUG_ASSERTIONS;
$dbg_Dimensions = DEBUG_DIMENSIONS;
$dbg_Color      = DEBUG_COLOR;
$dbg_Components = DEBUG_COMPONENTS[0]=="none" ? undef : DEBUG_COMPONENTS;
$dbg_Labels     = DEBUG_LABELS;
$dbg_Symbols    = DEBUG_SYMBOLS;


direction       = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant          = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);

fl_status();

// end of automatically generated code

verbs=[
  if ($FL_ADD!="OFF")   FL_ADD,
  if ($FL_AXES!="OFF")  FL_AXES,
  if ($FL_BBOX!="OFF")  FL_BBOX,
];

module linear_wrpper() {
  if (LINEAR_TYPE=="fillet")
    fl_fillet(verbs,rx=R_x,ry=R_y,h=LENGTH,octant=octant,direction=direction);
  else if (LINEAR_TYPE=="hFillet")
    fl_hFillet(verbs,rx=R_x,ry=R_y,h=LENGTH,octant=octant,direction=direction);
  else if (LINEAR_TYPE=="vFillet")
    fl_vFillet(verbs,rx=R_x,ry=R_y,h=LENGTH,octant=octant,direction=direction);
}

if (TEST=="linear")
  linear_wrpper();
else
  fl_90DegFillet(verbs,r=ROUND_RADIUS,n=ROUND_STEPS,child_bbox=[O,CHILD_SIZE],octant=octant,direction=direction)
    square(size=CHILD_SIZE);

