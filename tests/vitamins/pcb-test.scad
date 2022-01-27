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
// include <../../foundation/incs.scad>
include <../../vitamins/pcbs.scad>

$fn         = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

$FL_FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Supported verbs] */

// adds shapes to scene.
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
CUTOUT    = "OFF";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws or supports)
LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
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

/* [PCB] */

TYPE  = "FL_PCB_RPI4";  // [FL_PCB_RPI4, FL_PCB_PERF70x50, FL_PCB_PERF60x40, FL_PCB_PERF70x30, FL_PCB_PERF80x20, ALL]
// FL_DRILL and FL_CUTOUT thickness
T             = 2.5;
// FL_CUTOUT tolerance
TOLERANCE     = 0.5;
// when !="undef", FL_CUTOUT verb is triggered only on the labelled component
CO_LABEL      = "undef";        // [undef,POWER IN,HDMI0,HDMI1,A/V,USB2,USB3,ETHERNET,GPIO]
// when !=[0,0,0], FL_CUTOUT is triggered only on components oriented accordingly to any of the not-null axis values
CO_DIRECTION  = [0,0,0];  // [-1:+1]

/* [Hidden] */

co_direction  = CO_DIRECTION==[0,0,0]  ? undef : let(axes=[X,Y,Z]) [for(i=[0:2]) if (CO_DIRECTION[i]) CO_DIRECTION[i]*axes[i]];
co_label      = CO_LABEL=="undef" ? undef : CO_LABEL;
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

single  = TYPE=="FL_PCB_RPI4"       ? FL_PCB_RPI4
        : TYPE=="FL_PCB_PERF70x50"  ? FL_PCB_PERF70x50
        : TYPE=="FL_PCB_PERF60x40"  ? FL_PCB_PERF60x40
        : TYPE=="FL_PCB_PERF70x30"  ? FL_PCB_PERF70x30
        : TYPE=="FL_PCB_PERF80x20"  ? FL_PCB_PERF80x20
        : undef;

module test() {

  module pcb(type) {
    fl_pcb(verbs,type,
      direction=direction,octant=octant,thick=T,cut_tolerance=TOLERANCE,cut_label=co_label,cut_direction=co_direction,
      $FL_ADD=ADD,$FL_ASSEMBLY=ASSEMBLY,$FL_AXES=AXES,$FL_BBOX=BBOX,$FL_CUTOUT=CUTOUT,$FL_DRILL=DRILL,$FL_LAYOUT=LAYOUT,$FL_PAYLOAD=PAYLOAD)
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
  fl_color($FL_FILAMENT)
    translate(-Z($hole_depth))
      fl_cylinder(d=$hole_d+2,h=T,octant=-$hole_n);
