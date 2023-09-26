/*
 * PCB vitamins test
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/foundation/unsafe_defs.scad>
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


/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";     // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
$FL_ASSEMBLY  = "OFF";    // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";    // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";    // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
$FL_CUTOUT    = "OFF";    // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";    // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws or supports)
$FL_LAYOUT    = "OFF";    // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a box representing the payload of the shape
$FL_PAYLOAD   = "OFF";    // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


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


/* [ Adapter ] */

NOP  = "PERF80x20"; // [PERF74x51, PERF70x51, PERF70x50, PERF60x40, PERF70x30, PERF80x20, RAMPSEndstop, MT3608, PI_IO, ExtruderPCB, ZC_A0591, RPI0, EnviroPlus, ArduinoUno3, ArduinoLeonardo, WD2002SJ, RPI3, RPI4, BTT_SKR_MINI_E3_V2_0, BTT_SKR_E3_TURBO, BTT_SKR_V1_4_TURBO, DuetE, Duex5]
// FL_DRILL and FL_CUTOUT thickness
T         = 2.5;
PAY_LOAD  = [-5,-5,10];        // [-100:0.1:100]


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// end of automatically generated code

verbs=[
  if ($FL_ADD!="OFF")       FL_ADD,
  if ($FL_ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if ($FL_AXES!="OFF")      FL_AXES,
  if ($FL_BBOX!="OFF")      FL_BBOX,
  if ($FL_CUTOUT!="OFF")    FL_CUTOUT,
  if ($FL_DRILL!="OFF")     FL_DRILL,
  if ($FL_LAYOUT!="OFF")    FL_LAYOUT,
  if ($FL_PAYLOAD!="OFF")   FL_PAYLOAD,
];

nop = NOP=="RAMPSEndstop" ? RAMPSEndstop
    : NOP=="MT3608" ? MT3608
    : NOP=="PI_IO"  ? PI_IO
    : NOP=="ExtruderPCB"  ? ExtruderPCB
    : NOP=="ZC_A0591" ? ZC_A0591
    : NOP=="RPI0" ? RPI0
    : NOP=="EnviroPlus" ? EnviroPlus
    : NOP=="ArduinoUno3"  ? ArduinoUno3
    : NOP=="ArduinoLeonardo"  ? ArduinoLeonardo
    : NOP=="WD2002SJ" ? WD2002SJ
    : NOP=="RPI3" ? RPI3
    : NOP=="RPI4" ? RPI4
    : NOP=="BTT_SKR_MINI_E3_V2_0" ? BTT_SKR_MINI_E3_V2_0
    : NOP=="BTT_SKR_E3_TURBO" ? BTT_SKR_E3_TURBO
    : NOP=="BTT_SKR_V1_4_TURBO" ? BTT_SKR_V1_4_TURBO
    : NOP=="DuetE"  ? DuetE
    : NOP=="Duex5"  ? Duex5
    : NOP=="PERF74x51"  ? PERF74x51
    : NOP=="PERF70x51"  ? PERF70x51
    : NOP=="PERF70x50"  ? PERF70x50
    : NOP=="PERF60x40"  ? PERF60x40
    : NOP=="PERF70x30"  ? PERF70x30
    : PERF80x20;

fl_trace("verbs",verbs);

payload = let(
    sz    = pcb_size(nop),
    bare  = [[-sz.x/2,-sz.y/2,0],[+sz.x/2,+sz.y/2,+sz.z]]
  ) [[bare[0].x-PAY_LOAD.x,bare[0].y-PAY_LOAD.y,bare[1].z],[bare[1].x+PAY_LOAD.x,bare[1].y+PAY_LOAD.y,bare[1].z+PAY_LOAD.z]];

fl_pcb_adapter(verbs,nop,payload=payload, direction=direction,octant=octant,thick=T) fl_color()
  fl_cylinder(d=$hole_d+2,h=T,octant=-$hole_n);
