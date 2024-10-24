/*
 * NopSCADlib IEC wrapper
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


include <../../lib/OFL/vitamins/iec.scad>


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
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
$FL_CUTOUT    = "OFF";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
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



/* [Iec] */

IEC = "INLET";  // [FUSED_INLET,FUSED_INLET2,320_C14_SWITCHED_FUSED_INLET,INLET,INLET_ATX,INLET_ATX2,YUNPEN,OUTLET]
// thickness for FL_CUTOUT and FL_DRILL
THICK   = 2.5;      // [0:0.5:5]
TOLERANCE = 0.2;  // [0:0.1:1]


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

verbs = fl_verbList([FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT,FL_DRILL,FL_LAYOUT,FL_MOUNT]);
thick = $FL_CUTOUT!="OFF"||$FL_DRILL!="OFF" ? THICK : undef;
iec   = fl_switch(IEC, [
    ["FUSED_INLET",                   FL_IEC_FUSED_INLET],
    ["FUSED_INLET2",                  FL_IEC_FUSED_INLET2],
    ["320_C14_SWITCHED_FUSED_INLET",  FL_IEC_320_C14_SWITCHED_FUSED_INLET],
    ["INLET",                         FL_IEC_INLET],
    ["INLET_ATX",                     FL_IEC_INLET_ATX],
    ["INLET_ATX2",                    FL_IEC_INLET_ATX2],
    ["YUNPEN",                        FL_IEC_YUNPEN],
    ["OUTLET",                        FL_IEC_OUTLET],
  ]);

fl_iec(verbs,iec,direction=direction,octant=octant,$fl_thickness=thick,$fl_tolerance=TOLERANCE)
  fl_cylinder(verbs=[FL_ADD,FL_AXES],h=10,r=screw_radius($iec_screw),octant=-Z,$FL_ADD=$FL_LAYOUT,$FL_AXES="ON");

