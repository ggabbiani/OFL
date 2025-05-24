/*
 * fl_pcb_Frame() used as a fl_PCB() proxy
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


include <../../lib/OFL/vitamins/pcbs.scad>


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

// Draw base shape (no components nor screws)
$FL_ADD       = "ON";           // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// Draw predefined component shape(s)
$FL_ASSEMBLY  = "ON";           // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";          // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// assembled shape bounding box
$FL_BBOX      = "OFF";          // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
$FL_CUTOUT    = "OFF";          // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";          // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified ADD operation (see variable FL_ADD)
$FL_FOOTPRINT = "OFF";          // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws or supports)
$FL_LAYOUT    = "OFF";          // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// add mounting accessories shapes
$FL_MOUNT     = "ON";           // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// components payload bounding box
$FL_PAYLOAD   = "OFF";          // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


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



/* [PCB Frame] */

LAYOUT  = "auto"; // [auto,horizontal,vertical]
// nominal screw ⌀
D   = 3;  // [2,2.5,3,4,5,6,8]
COUNTERSINK = false;
LEFT  = true;
RIGHT = true;
// distance between holes and external frame dimensions
WALL = 1.5; // [0.5:0.1:3]
// top and bottom surface thickness
FACE_T = 1.2;   // [.5:.1:3]
// overlap along major pcb dimension
WIDE_OVER = 4; // [0.1:0.1:10]
// overlap along minor pcb dimension
THIN_OVER = 1;  // [0:0.1:10]
// size along major pcb dimension, laterally surrounding the pcb
INCLUSION = 10; // [0.1:20]

/* [PCB] */

// FL_DRILL and FL_CUTOUT thickness
T             = 2.5;  // [0:0.1:3]
// when !="undef", FL_CUTOUT verb is triggered only on components whose label match the rule
COMPS      = "undef";
// when !=[0,0,0], FL_CUTOUT is triggered only on components oriented accordingly to any of the not-null axis values
CO_DIRECTION  = [0,0,0];  // [-1:+1]

/* [TEST] */

TOLERANCE=0.5;  // [0:0.1:1]
PROXY=false;


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

verbs = fl_verbList([FL_ADD,FL_ASSEMBLY,FL_AXES,FL_BBOX,FL_CUTOUT,FL_DRILL,FL_FOOTPRINT,FL_LAYOUT,FL_MOUNT,FL_PAYLOAD]);
co_direction  = CO_DIRECTION==[0,0,0]  ? undef : let(axes=[X,Y,Z]) [for(i=[0:2]) if (CO_DIRECTION[i]) CO_DIRECTION[i]*axes[i]];
comps      = COMPS=="undef" ? undef : COMPS;

pcb = FL_PCB_HILETGO_SX1308;
frame = fl_pcb_Frame(pcb,d=D,faces=FACE_T,wall=WALL,overlap=[WIDE_OVER,THIN_OVER],inclusion=INCLUSION,countersink=COUNTERSINK,layout=LAYOUT);


fl_pcb(verbs,PROXY?frame:pcb,
    direction=direction,octant=octant,thick=T,$fl_tolerance=TOLERANCE,components=comps,cut_direction=co_direction);

