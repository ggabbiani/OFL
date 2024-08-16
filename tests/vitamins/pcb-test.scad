/*
 * PCB vitamins test
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
SHOW_DIMENSIONS = false;


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



/* [PCB] */

TYPE  = "HiLetgo SX1308 DC-DC Step up power module";  // [ALL,"HiLetgo SX1308 DC-DC Step up power module", "ORICO 4 Ports USB 3.0 Hub 5 Gbps with external power supply port", "Perfboard 70 x 50mm", "Perfboard 60 x 40mm", "Perfboard 70 x 30mm", "Perfboard 80 x 20mm", "RPI4-MODBP-8GB", "Raspberry PI uHAT", "KHADAS-SBC-VIM1"]

// FL_DRILL and FL_CUTOUT thickness
T             = 2.5;  // [0:0.1:3]
// FL_CUTOUT tolerance
TOLERANCE     = 0.5;
// when !="undef", FL_CUTOUT verb is triggered only on the component whose label match the rule
COMPS      = "undef";
// when !=[0,0,0], FL_CUTOUT is triggered only on components oriented accordingly to any of the not-null axis values
CO_DIRECTION  = [0,0,0];  // [-1:+1]


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS,dimensions=SHOW_DIMENSIONS);

fl_status();

// end of automatically generated code

co_direction  = CO_DIRECTION==[0,0,0]  ? undef : let(axes=[X,Y,Z]) [for(i=[0:2]) if (CO_DIRECTION[i]) CO_DIRECTION[i]*axes[i]];
comps      = COMPS=="undef" ? undef : COMPS;
filament      = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
verbs         = fl_verbList([FL_ADD,FL_ASSEMBLY,FL_AXES,FL_BBOX,FL_CUTOUT,FL_DRILL,FL_FOOTPRINT,FL_LAYOUT,FL_MOUNT,FL_PAYLOAD]);

single  = fl_pcb_select(TYPE);

module test() {
  module pcb(type) {
    fl_pcb(verbs,type,
      direction=direction,octant=octant,thick=T,$fl_tolerance=TOLERANCE,components=comps,cut_direction=co_direction,debug=debug)
      children();
  }

  if (single)
    pcb(single)
      children();
  else // TODO: replace with fl_layout
    layout([for(pcb=FL_PCB_DICT) fl_width(pcb)], 10)
      pcb(FL_PCB_DICT[$i])
        children();
}

test()
  fl_color(filament)
    translate(-Z($hole_depth))
      fl_cylinder(d=$hole_d+2,h=T,octant=-$hole_n);
