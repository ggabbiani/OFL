/*
 * Bit-holder example.
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

include <../foundation/unsafe_defs.scad>
include <../foundation/incs.scad>
include <../vitamins/incs.scad>

$fn         = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Supported verbs] */

// adds shapes to scene.
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
ASSEMBLY  = "ON";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Bits] */

MM1   = false;
MM1P6 = false;
MM2   = false;
MM3   = true;
MM3P3 = false;
MM4   = true;
MM4P2 = false;
MM5   = true;
MM6   = true;
MM7   = true;
MM8   = true;

/* [Holder] */

// thickness around bit hole
T = 1;  // [0:0.1:10]
T_bottom = 1; // [0:0.1:10]
// gap between bit drill and magnet
GAP_magnet  = 1; // [0:0.1:10]
// min bit holder height
HEIGHT  = 32;
// bit tolerance (fl_JNgauge=0.15mm)
TOLERANCE = 0.15; // [0:0.05:1]
// inter holder gap
GAP_holder  = 10;

/* [Hidden] */

verbs=[
  if (ADD!="OFF")       FL_ADD,
  if (ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if (BBOX!="OFF")      FL_BBOX,
];

magnet_size = [10,5,1];
bits = [
  if (MM1)    ["1mm",   [1,      40]],
  if (MM1P6)  ["1.6mm", [1.6,    50]],
  if (MM2)    ["2mm",   [2,      60]],
  if (MM3)    ["3mm",   [2.73,   70]],  // *
  if (MM3P3)  ["3.3mm", [3.3,    80]],
  if (MM4)    ["4mm",   [3.34,   74]],  // *
  if (MM4P2)  ["4.2mm", [4.2,    85]],
  if (MM5)    ["5mm",   [4.23,   85]],  // *
  if (MM6)    ["6mm",   [4.55,  100]],  // *
  if (MM7)    ["7mm",   [5.15,  100]],  // *
  if (MM8)    ["8mm",   [6.3,   120]],  // *
];

function bitHolder(name,bit) = let(
  h     = max(bit[1]/3,HEIGHT),
  d     = bit[0]+2*TOLERANCE,
  bbox  = fl_bb_cylinder(h=h,d=d)+[[-T-GAP_holder/2,-T,0],[+T+GAP_holder/2,+T,0]]
) [
    fl_nameKV(str(name," bit-holder")),
    fl_bb_cornersKV(bbox),
    fl_sizeKV(bbox[1]-bbox[0]),
    ["h",   h],
    ["d",   d],
    ["bit", bit],
  ];

strip = let(
  bhs   = [for(bit=bits) bitHolder(bit[0],bit[1])],
  bb    = lay_bb_corners(axis=+X,types=bhs),
  size  = bb[1]-bb[0],
  bbox  = bb + [-Y(size.y/2),-Y(size.y/2)]
) [ 
    ["Bit holders",  bhs],
    ["Bit number",  len(bhs)],
    fl_bb_cornersKV(bbox),
    fl_sizeKV(size)
  ];
strip_bb  = fl_bb_corners(strip);
fl_trace("strip object",strip);

fl_modifier(ADD) fl_color($FL_FILAMENT) difference() {
  // strip FL_LAYOUT and FL_ADD of the first and last $item shape
  hull() fl_layout(FL_LAYOUT,axis=+X,types=fl_get(strip,"Bit holders")) union() {
    h = fl_get($item,"h");
    d = fl_get($item,"d");
    translate(-Y($size.y/2))
      linear_extrude(h) 
        if ($first||$last) fl_square(size=$size,vertices=[0,0,d/2,d/2]);
  }
  // FL_LAYOUT of bits and magnets
  fl_layout(FL_LAYOUT,axis=+X,types=fl_get(strip,"Bit holders")) union() {
    bhs     = fl_get(strip,"Bit holders");
    next    = bhs[$i+1];
    prev    = bhs[$i-1];
    bbox    = fl_bb_corners($item);
    sz_next = !$last  ? fl_size(next) : undef;
    sz_prev = !$first ? fl_size(prev) : undef;
    h       = fl_get($item,"h");
    d       = fl_get($item,"d");
    translate(-Y($size.y/2))
      translate(Z(T_bottom-NIL)) {
        // bit 
        fl_cylinder(h=100,d=d);
        // magnet
        translate(Y(d/2+GAP_magnet))
          fl_cutout(100,z=+Y)
            fl_cutout(magnet_size.x+2*TOLERANCE,delta=TOLERANCE) 
              translate(Y(d/2+magnet_size.z/2+GAP_magnet)) rotate(90,Z)
                fl_cube(size=magnet_size,direction=[-X,0],octant=+X);
      }
  }
}

fl_modifier(ASSEMBLY) fl_color("silver")
  fl_layout(FL_LAYOUT,axis=+X,types=fl_get(strip,"Bit holders")) union() {
    d = fl_get($item,"d");
    translate(-Y($size.y/2))
      translate(Z(T_bottom-NIL)) {
        let(bit=fl_get($item,"bit")) 
          fl_cylinder(h=bit[1],d=bit[0]);
        translate([0,d/2+magnet_size.z/2+GAP_magnet,TOLERANCE]) rotate(90,Z)
          fl_cube(size=magnet_size,direction=[-X,0],octant=+X);
      }
  }

fl_modifier(BBOX) 
  fl_bb_add(fl_bb_corners(strip));

