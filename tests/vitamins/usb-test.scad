/*
 * USB test file
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


include <../../lib/OFL/vitamins/usbs.scad>

include <../../lib/ext/NopSCADlib/global_defs.scad>
use     <../../lib/ext/NopSCADlib/utils/layout.scad>


$fn            = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER     = false;
// Default color for printable items (i.e. artifacts)
$fl_filament   = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]


/* [Debug] */

// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES        = -2;     // [-2:10]
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
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
$FL_CUTOUT    = "OFF";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
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



/* [USB] */

SHOW      = "ALL";  // [ALL,FL_USB_TYPE_Ax1_NF_SM,FL_USB_TYPE_Ax1,FL_USB_TYPE_Ax2,FL_USB_TYPE_B,FL_USB_TYPE_C,FL_USB_TYPE_uA]
// tolerance used during FL_CUTOUT and FL_FOOTPRINT
TOLERANCE = 0;      // [0:0.1:5]
// thickness for FL_CUTOUT
CO_T      = 2.5;
// translation applied to cutout
CO_DRIFT  = 0;      // [-5:0.05:5]
// tongue color
COLOR     = "white";  // [white, OrangeRed, DodgerBlue]
CUT_DIRECTION  = ["±x","±y","±z"]; // [+X,-X,+Y,-Y,+Z,-Z,±x,±y,±z]


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

thick     = $FL_CUTOUT!="OFF" ? CO_T          : undef;
tolerance = $FL_CUTOUT!="OFF" || $FL_FOOTPRINT!="OFF" ? TOLERANCE : undef;
drift     = $FL_CUTOUT!="OFF" ? CO_DRIFT : undef;
verbs     = fl_verbList([FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT,FL_FOOTPRINT]);

// target object(s)
single  = SHOW=="FL_USB_TYPE_Ax1_NF_SM"  ? FL_USB_TYPE_Ax1_NF_SM
        : SHOW=="FL_USB_TYPE_Ax1"   ? FL_USB_TYPE_Ax1
        : SHOW=="FL_USB_TYPE_Ax2"   ? FL_USB_TYPE_Ax2
        : SHOW=="FL_USB_TYPE_B"     ? FL_USB_TYPE_B
        : SHOW=="FL_USB_TYPE_C"     ? FL_USB_TYPE_C
        : SHOW=="FL_USB_TYPE_uA"    ? FL_USB_TYPE_uA
        : undef;

dirs  = fl_3d_AxisList(CUT_DIRECTION);

if (single)
  fl_USB(verbs,single,direction=direction,octant=octant,cut_thick=thick,cut_direction=dirs,cut_tolerance=tolerance,cut_drift=drift,tongue=COLOR);
else
  layout([for(socket=FL_USB_DICT) fl_width(socket)], 10)
    fl_USB(verbs,FL_USB_DICT[$i],direction=direction,octant=octant,cut_thick=thick,cut_dirs=dirs,cut_tolerance=tolerance,cut_drift=drift,tongue=COLOR);

