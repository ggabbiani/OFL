/*
 * 2d square test
 *
 * NOTE: this file is generated automatically from 'template-2d.scad', any
 * change will be lost.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

// **** TEST_INCLUDES *********************************************************

include <../../lib/OFL/foundation/core.scad>

use <../../lib/OFL/foundation/2d-engine.scad>

// **** TAB_PARAMETERS ********************************************************

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

// **** TAB_Verbs *************************************************************

/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD   = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

// **** TAB_Placement *********************************************************

/* [2D Placement] */

X_PLACE = "undef";  // [undef,-1,0,+1]
Y_PLACE = "undef";  // [undef,-1,0,+1]

// **** TAB_TEST **************************************************************

/* [Square] */

// primitive used
MODE      = "square";  // [frame, square]

// overall size of the rectangle
SIZE      = [15,10];
// Quadrant I [x radius,y radius]
CORNER_0  = [6,3];
// Quadrant II [x radius,y radius]
CORNER_1  = [2,2];
// Quadrant III [x radius,y radius]
CORNER_2  = [3,6];
// Quadrant IV [x radius,y radius]
CORNER_3  = [0,0];

// frame thickness
T = 2.5;  // [0.1:0.1:5]

/* [Hidden] */
// **** TEST_PROLOGUE *********************************************************

quadrant    = fl_parm_Quadrant(X_PLACE,Y_PLACE);
debug       = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// **** end of automatically generated code ***********************************

verbs=[
  if ($FL_ADD!="OFF")   FL_ADD,
  if ($FL_AXES!="OFF")  FL_AXES,
  if ($FL_BBOX!="OFF")  FL_BBOX,
];
corners  = [CORNER_0,CORNER_1,CORNER_2,CORNER_3];

if (MODE=="square") fl_square(verbs,size=SIZE,corners=corners,quadrant=quadrant);
else fl_2d_frame(verbs,size=SIZE,corners=corners,thick=T,quadrant=quadrant);

