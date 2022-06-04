/*
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org).
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

include <../../foundation/3d.scad>
include <../../vitamins/hds.scad>
include <../../vitamins/pcbs.scad>
include <../../vitamins/psus.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$fl_debug   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]

/* [Supported verbs] */

// adds local reference axes
$FL_AXES      = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Layout] */

GAP     = 5;
AXIS    = "+X";   // [+X, -X, +Y, -Y, +Z, -Z]
RENDER  = "ADD"; // [DRAW, ADD, BBOX]
ALIGN   = [0,0,0];  // [-1:+1]

/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
verbs=[
  if ($FL_AXES!="OFF")    FL_AXES,
  if ($FL_BBOX!="OFF")    FL_BBOX,
  if ($FL_LAYOUT!="OFF")  FL_LAYOUT,
];

types   = [FL_PCB_RPI4,FL_HD_EVO860,FL_HD_EVO860,FL_PSU_MeanWell_RS_25_5];
axis    = fl_3d_AxisList([AXIS])[0];
overbs  = [
  if (RENDER=="DRAW"||RENDER=="ADD") FL_ADD,
  if (RENDER=="DRAW"||RENDER=="ASSEMBLY") FL_ASSEMBLY,
  if (RENDER=="BBOX") FL_BBOX,
];

module object(object) {
  engine        = fl_engine(object);
  octant        = undef;
  $FL_ADD       = "ON";
  $FL_ASSEMBLY  = "ON";
  $FL_BBOX      = "DEBUG";
  if (engine==FL_PCB_NS)
    fl_pcb(overbs,object,octant=octant);
  else if (engine==FL_HD_NS)
    fl_hd(overbs,object,octant=octant);
  else if (engine==FL_PSU_NS)
    fl_psu(overbs,object,octant=octant);
  else
    assert(false,str("Engine ",engine," UNKNOWN."));
}

fl_layout(verbs,axis,GAP,types,align=ALIGN,octant=octant,direction=direction)
  object($item);
