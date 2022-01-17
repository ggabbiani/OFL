/*
 * PCB vitamins test.
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL).
 *
 * OFL is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * OFL is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with OFL.  If not, see <http: //www.gnu.org/licenses/>.
 */

include <../../foundation/unsafe_defs.scad>
include <../../foundation/incs.scad>
include <../../vitamins/incs.scad>

$fn         = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
TRACE   = false;

$FL_FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Supported verbs] */

// adds shapes to scene.
ADD       = "ON";     // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
ASSEMBLY  = "OFF";    // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";    // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "DEBUG";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
CUTOUT    = "OFF";    // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
DRILL     = "OFF";    // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws or supports)
LAYOUT    = "OFF";    // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a box representing the payload of the shape
PAYLOAD   = "ON";     // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [ Adapter ] */

NOP  = "PERF80x20"; // [PERF74x51, PERF70x51, PERF70x50, PERF60x40, PERF70x30, PERF80x20, RAMPSEndstop, MT3608, PI_IO, ExtruderPCB, ZC_A0591, RPI0, EnviroPlus, ArduinoUno3, ArduinoLeonardo, WD2002SJ, RPI3, RPI4, BTT_SKR_MINI_E3_V2_0, BTT_SKR_E3_TURBO, BTT_SKR_V1_4_TURBO, DuetE, Duex5]
// FL_DRILL and FL_CUTOUT thickness
T         = 2.5;
PAY_LOAD  = [-5,-5,10];        // [-100:0.1:100]

/* [Hidden] */

direction     = DIR_NATIVE        ? undef : [DIR_Z,DIR_R];
octant        = PLACE_NATIVE      ? undef : OCTANT;
verbs=[
  if (ADD!="OFF")       FL_ADD,
  if (ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if (AXES!="OFF")      FL_AXES,
  if (BBOX!="OFF")      FL_BBOX,
  if (CUTOUT!="OFF")    FL_CUTOUT,
  if (DRILL!="OFF")     FL_DRILL,
  if (LAYOUT!="OFF")    FL_LAYOUT,
  if (PAYLOAD!="OFF")   FL_PAYLOAD,
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

fl_pcb_adapter(verbs,nop,
  payload=payload, direction=direction,octant=octant,thick=T,
  $FL_ADD=ADD,$FL_ASSEMBLY=ASSEMBLY,$FL_AXES=AXES,$FL_BBOX=BBOX,$FL_CUTOUT=CUTOUT,$FL_DRILL=DRILL,$FL_LAYOUT=LAYOUT,$FL_PAYLOAD=PAYLOAD,
  $FL_TRACE=TRACE
) fl_color($FL_FILAMENT) 
  translate(-Z($hole_depth))
    fl_cylinder(d=$hole_d+2,h=T,octant=-$hole_n);
