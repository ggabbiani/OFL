/*
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org).
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

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

/* [Supported verbs] */

// adds local reference axes
AXES      = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
LAYOUT    = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

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

GAP           = 5;
AXIS          = "+X"; // [+X, -X, +Y, -Y, +Z, -Z]

/* [Hidden] */

module __test__() {
  direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
  octant    = PLACE_NATIVE  ? undef : OCTANT;
  verbs=[
    if (AXES!="OFF")    FL_AXES,
    if (BBOX!="OFF")    FL_BBOX,
    if (LAYOUT!="OFF")  FL_LAYOUT,
  ];

  psu= [
    ["name", "PSU MeanWell RS-25-5 25W 5V 5A"],
    fl_bb_cornersKV([
        [-51/2, -11,   0],  // negative corner
        [+51/2,  78,  28],  // positive corner
      ]),
  ];

  hd = [
    ["name",  "Samsung V-NAND SSD 860 EVO"],
    fl_bb_cornersKV([
      [-69/2,-(13+3),0],  // negative corner
      [69/2,100,6.7],     // positive corner
    ]),
  ];

  rpi = [
    ["name",                "RPI4-MODBP-8GB"],
    fl_bb_cornersKV([
      [-56/2-2.5,  -3, -1.5],     // negative corner
      [+56/2,     85,  -1.5+16],  // positive corner
    ]),
  ];

  types   = [rpi,hd,hd,psu];
  bcs     = [for(t=types) fl_bb_corners(t)];
  axis    = AXIS=="+X" ? +X : AXIS=="-X" ? -X : AXIS=="+Y" ? +Y : AXIS=="-Y" ? -Y : AXIS=="+Z" ? +Z : -Z;

  fl_layout(verbs,axis,GAP,types,octant=octant,direction=direction,$FL_AXES=AXES,$FL_BBOX=BBOX,$FL_LAYOUT=LAYOUT) { 
    let(type=rpi, bc=fl_bb_corners(type)) fl_bb_add(bc);
    let(type=hd,  bc=fl_bb_corners(type)) fl_bb_add(bc);
    let(type=hd,  bc=fl_bb_corners(type)) fl_bb_add(bc);
    let(type=psu, bc=fl_bb_corners(type)) fl_bb_add(bc);
  }
}

__test__();