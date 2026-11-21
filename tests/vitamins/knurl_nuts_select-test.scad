/*
 * Knurl nut (aka brass inserts) select() test
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

// **** TAB_PARAMETERS ********************************************************
$fn            = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_EPS
$FL_RENDER     = false;
// Default color for printable items (i.e. artifacts)
$fl_filament   = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// When false polyRound() is disabled
$fl_polyround  = true;
// **** TAB_Debug *************************************************************
/* [Debug] */

// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES        = -2;     // [-2:10]
DEBUG_ASSERTIONS  = false;
DEBUG_COMPONENTS  = ["none"];
DEBUG_COLOR       = false;
DEBUG_DIMENSIONS  = false;
DEBUG_LABELS      = false;
DEBUG_SYMBOLS     = false;
// **** TAB_Verbs *************************************************************
/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
$FL_ASSEMBLY  = "ON";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
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
// mount shape through predefined screws
$FL_MOUNT     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// **** TAB_Placement *********************************************************
/* [2D Placement] */

X_PLACE = "undef";  // [undef,-1,0,+1]
Y_PLACE = "undef";  // [undef,-1,0,+1]
// **** TAB_TEST **************************************************************

/* [Hidden] */
// **** TEST_PROLOGUE *********************************************************
$dbg_Assert     = DEBUG_ASSERTIONS;
$dbg_Dimensions = DEBUG_DIMENSIONS;
$dbg_Color      = DEBUG_COLOR;
$dbg_Components = DEBUG_COMPONENTS[0]=="none" ? undef : DEBUG_COMPONENTS;
$dbg_Labels     = DEBUG_LABELS;
$dbg_Symbols    = DEBUG_SYMBOLS;

quadrant    = fl_parm_Quadrant(X_PLACE,Y_PLACE);

fl_status();
// **** end of automatically generated code ***********************************

