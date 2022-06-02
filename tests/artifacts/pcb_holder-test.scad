/*
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org)
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

include <../../artifacts/pcb_holder.scad>
include <../../vitamins/pcbs.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$fl_debug   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// Default color for printable items (i.e. artifacts)
$fl_filament  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// When true, trace messages are turned on
$fl_traces   = false;

/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
$FL_ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// mount shape through predefined screws
$FL_MOUNT     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a box representing the payload of the shape
$FL_PAYLOAD   = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [PCB Holder]*/
ENGINE  = "by holes"; // [by holes, by size]
H   = 4;  // [0.1:0.1:10]
// frame thickness on Z axis
FRAME_T  = 0; // [0:0.1:5]
TOLERANCE = 0.5;  // [0:0.1:1]
// thickness along ±Z semi axes
Tz = [0,0];  // [0:0.1:10]
// knurl nut
KNUT  = false;
// FL_LAYOUT directions in floating semi-axis list
LAYOUT_DIRS  = ["±z"];

PCB         = "FL_PCB_PERF80x20";  // [FL_PCB_HILETGO_SX1308, FL_PCB_RPI_uHAT, FL_PCB_RPI4, FL_PCB_PERF70x50, FL_PCB_PERF60x40, FL_PCB_PERF70x30, FL_PCB_PERF80x20, FL_PCB_MH4PU_P]

/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
verbs=[
  if ($FL_ADD!="OFF")       FL_ADD,
  if ($FL_ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if ($FL_AXES!="OFF")      FL_AXES,
  if ($FL_BBOX!="OFF")      FL_BBOX,
  if ($FL_DRILL!="OFF")     FL_DRILL,
  if ($FL_LAYOUT!="OFF")    FL_LAYOUT,
  if ($FL_MOUNT!="OFF")     FL_MOUNT,
  if ($FL_PAYLOAD!="OFF")   FL_PAYLOAD,
];
pcb = PCB=="FL_PCB_RPI4"      ? FL_PCB_RPI4
    : PCB=="FL_PCB_PERF70x50" ? FL_PCB_PERF70x50
    : PCB=="FL_PCB_PERF60x40" ? FL_PCB_PERF60x40
    : PCB=="FL_PCB_PERF70x30" ? FL_PCB_PERF70x30
    : PCB=="FL_PCB_PERF80x20" ? FL_PCB_PERF80x20
    : PCB=="FL_PCB_MH4PU_P"   ? FL_PCB_MH4PU_P
    : PCB=="FL_PCB_RPI_uHAT"  ? FL_PCB_RPI_uHAT
    : PCB=="FL_PCB_HILETGO_SX1308"  ? FL_PCB_HILETGO_SX1308
    : undef;

dirs  = fl_3d_AxisList(LAYOUT_DIRS);
thick = [[0,0],[0,0],Tz];

// screw   = SCREW=="M2" ? M2_cap_screw : M3_cap_screw;

// frame = FRAME_H && FRAME_T ? [FRAME_H,FRAME_T] : undef;
// holder  = ENGINE=="by holes" ? fl_pcb_HolderByHoles(pcb,H) : fl_pcb_HolderBySize(pcb,H,TOLERANCE);

// fl_pcb_holder(verbs,holder,direction=direction,octant=octant,frame=frame,thick=T,knut=KNUT)
//   fl_screw(type=$hole_screw,thick=H+fl_pcb_thick(pcb)+T);

if (ENGINE=="by holes")
  fl_pcb_holderByHoles(verbs,pcb,H,knut=KNUT,frame=FRAME_T,thick=thick,lay_direction=dirs,direction=direction,octant=octant)
      fl_screw(FL_DRAW,type=$hld_screw,thick=$hld_h+fl_pcb_thick($hld_pcb)+$hld_thick.z[0]+$hld_thick.z[1],washer="nylon",nut="default",nwasher="nylon",direction=[$spc_director,0]);
else
  fl_pcb_holderBySize(verbs,pcb,H,knut=KNUT,frame=FRAME_T,thick=thick,lay_direction=dirs,tolerance=TOLERANCE,direction=direction,octant=octant)
    fl_screw(FL_DRAW,type=$hld_screw,thick=$hld_h+$hld_thick.z[0]+$hld_thick.z[1],washer="nylon",nut="default",nwasher="nylon",direction=[$spc_director,0]);
