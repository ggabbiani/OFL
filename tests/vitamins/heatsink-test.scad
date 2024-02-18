/*
 * Heatsink test file
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


// TODO: the following include MUST be removed
include <../../lib/OFL/vitamins/pcbs.scad>
include <../../lib/OFL/vitamins/heatsinks.scad>


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
// adds a footprint to scene, usually a simplified FL_ADD
$FL_FOOTPRINT = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


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


/* [Heatsink] */

TYPE  = "FL_HS_PIMORONI_TOP"; // [FL_HS_PIMORONI_TOP,FL_HS_PIMORONI_BOTTOM,FL_HS_KHADAS]
// Thickness during FL_CUTOUT
CUT_THICK = 10; // [0:1:10]
// Tolerance during FL_CUTOUT
CUT_TOLERANCE = 1; // [0:0.1:2]
CUT_DIRECTION  = ["±x","±y","±z"]; // [+X,-X,+Y,-Y,+Z,-Z,±x,±y,±z]


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// end of automatically generated code

verbs = fl_verbList([FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT,FL_FOOTPRINT]);
type  = (TYPE=="FL_HS_PIMORONI_TOP") ? FL_HS_PIMORONI_TOP
      : (TYPE=="FL_HS_PIMORONI_BOTTOM") ? FL_HS_PIMORONI_BOTTOM
      : FL_HS_KHADAS;

fl_heatsink(verbs, type=type, cut_thick=CUT_THICK, cut_tolerance=CUT_TOLERANCE, cut_direction=fl_3d_AxisList(CUT_DIRECTION), direction=direction, octant=octant)
  fl_color()
    fl_cylinder(h=10,d=5,octant=$hs_normal);
