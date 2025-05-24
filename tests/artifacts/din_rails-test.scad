/*
 * din_rails test
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


include <../../lib/OFL/artifacts/din_rails.scad>


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
$FL_CUTOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
$FL_FOOTPRINT = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// mount shape through predefined screws
$FL_MOUNT     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


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


/* [Dimension Lines] */
VIEW_TYPE     = "other";    // [other,right,top,bottom,left,front,back]
DIM_MODE      = "full";     // [full,label,value,silent]


/* [DIN rails] */

SHOW    = "ALL";  // [ALL, TS15, TS35, TS35D]
LENGTH  = 50;    // [0:100]
PUNCH   = false;
// used during FL_CUTOUT and FL_FOOTPRINT
TOLERANCE   = 0;  // [0:0.1:5]
// thickness for FL_CUTOUT
CO_T  = 2.5;          // [0:0.5:5]
// translation applied to cutout
CO_DRIFT = 0; // [-100:0.5:100]
// list of cutout directions or "undef" for preferred directions only
CO_DIRECTION  = ["±Z"];

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


$vpr          = fl_view(VIEW_TYPE);
$dim_mode     = DIM_MODE;
$fl_thickness = $FL_CUTOUT!="OFF" ? CO_T       : undef;
$fl_tolerance = $FL_CUTOUT!="OFF" || $FL_FOOTPRINT!="OFF" ? TOLERANCE  : undef;
drift         = $FL_CUTOUT!="OFF" ? CO_DRIFT   : undef;
co_direction  = CO_DIRECTION=="undef" ? undef : fl_3d_AxisList(CO_DIRECTION);

verbs = fl_verbList([FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT,FL_FOOTPRINT,FL_LAYOUT,FL_MOUNT]);

single = fl_switch(SHOW,fl_list_pack(fl_dict_names(FL_DIN_TS_INVENTORY),FL_DIN_RAIL_INVENTORY));
if (single) {
  fl_DIN_rail(verbs,single(LENGTH,PUNCH),cut_dirs=co_direction,cut_drift=drift,octant=octant,direction=direction);
} else {
  all = [for(constructor=FL_DIN_RAIL_INVENTORY) constructor(LENGTH,PUNCH)];
  fl_layout(axis=+X,gap=3,types=all,$FL_LAYOUT="ON")
    fl_DIN_rail(verbs,all[$i],cut_dirs=co_direction,cut_drift=drift,octant=octant,direction=direction);
}
