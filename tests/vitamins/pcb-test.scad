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

SHOW  = "FL_PCB_RPI4";  // [ALL,FL_PCB_RPI4]
// FL_DRILL and FL_CUTOUT thickness
T     = 2.5;
// FL_CUTOUT tolerance
TOLERANCE = 0.5;
// when passed, the FL_CUTOUT verb will be triggered only on the labelled component
CO_LABEL = "undef"; // [undef,POWER IN,HDMI0,HDMI1,A/V,USB2,USB3,ETHERNET,GPIO]

/* [Hidden] */

module wrap(type) {
  fl_pcb(verbs,type,
    direction=direction,octant=octant,thick=T,co_tolerance=TOLERANCE,co_label=co_label,
    $FL_ADD=ADD,$FL_ASSEMBLY=ASSEMBLY,$FL_AXES=AXES,$FL_BBOX=BBOX,$FL_CUTOUT=CUTOUT,$FL_DRILL=DRILL,$FL_LAYOUT=LAYOUT,
    $FL_TRACE=TRACE
  )
    children();
}

co_label  = CO_LABEL=="undef" ? undef : CO_LABEL;
direction = DIR_NATIVE    ? undef         : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef         : OCTANT;
verbs=[
  if (ADD!="OFF")       FL_ADD,
  if (ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if (AXES!="OFF")      FL_AXES,
  if (BBOX!="OFF")      FL_BBOX,
  if (CUTOUT!="OFF")    FL_CUTOUT,
  if (DRILL!="OFF")     FL_DRILL,
  if (LAYOUT!="OFF")    FL_LAYOUT,
];
// target object(s)
single  = SHOW=="FL_PCB_RPI4"   ? FL_PCB_RPI4
        : undef;
fl_trace("verbs",verbs);
fl_trace("single",single);
fl_trace("FL_PCB_DICT",FL_PCB_DICT);

module support(pcb) {
  screw = fl_screw(pcb);
  translate(-Z(fl_PCB_thick(pcb)))
    fl_color($FL_FILAMENT)
      fl_cylinder(r=screw_head_radius(screw),h=T,octant=-Z);
}

// $FL_ADD=ADD;$FL_ASSEMBLY=ASSEMBLY;$FL_AXES=AXES;$FL_BBOX=BBOX;$FL_CUTOUT=CUTOUT;$FL_DRILL=DRILL;$FL_FOOTPRINT=FPRINT;$FL_LAYOUT=LAYOUT;$FL_PAYLOAD=PLOAD;
if (single)
  wrap(single)
    support(single);
else // TODO: replace with fl_layout
  layout([for(pcb=FL_PCB_DICT) fl_width(pcb)], 10)
    wrap(FL_PCB_DICT[$i])
      support(FL_PCB_DICT[$i]);
