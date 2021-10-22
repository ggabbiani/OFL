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

BBOX        = false;

/* [Layout] */

GAP           = 5;
AXIS          = "+X"; // [+X, -X, +Y, -Y, +Z, -Z]

/* [Hidden] */

module __test__() {
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

  module arrow() {
    first   = types[0];
    size    = lay_bb_size(axis,GAP,types);
    sum     = axis*[1,1,1]>0;
    corner  = fl_bb_corners(first);
    pivot   = sum ? corner[0] : corner[1];

    translate(fl_3d_vectorialProjection(pivot,axis))
      fl_vector(abs(size*axis)*axis);
  }

  fl_color("red") arrow();

  fl_layout(axis,GAP,types) { 
    let(type=rpi, bc=fl_bb_corners(type)) fl_bb_add(bc);
    let(type=hd,  bc=fl_bb_corners(type)) fl_bb_add(bc);
    let(type=hd,  bc=fl_bb_corners(type)) fl_bb_add(bc);
    let(type=psu, bc=fl_bb_corners(type)) fl_bb_add(bc);
  }
  bc = lay_bb_corners(axis,GAP,types);
  fl_trace("bc",bc);
  if (BBOX) 
    %fl_bb_add(bc);
}

__test__();
