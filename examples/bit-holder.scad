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

/* [Bits (nominal/shank/length)] */

BIT_1   = [3,2.73,70,1];  // [0:0.01:200]
BIT_2   = [4,3.34,74,1];  // [0:0.01:200]
BIT_3   = [5,4.23,85,1];  // [0:0.01:200]
BIT_4   = [6,4.55,100,1]; // [0:0.01:200]
BIT_5   = [7,5.15,100,1]; // [0:0.01:200]
BIT_6   = [8,6.3,120,1];  // [0:0.01:200]
BIT_7   = [0,0,0,0];      // [0:0.01:200]
BIT_8   = [0,0,0,0];      // [0:0.01:200]
BIT_9   = [0,0,0,0];      // [0:0.01:200]
BIT_10  = [0,0,0,0];      // [0:0.01:200]

/* [Holder] */

// thickness around bit hole
T           = 1.5;  // [0:0.1:10]
T_bottom    = 1;    // [0:0.1:10]
// Y distance between bit and magnet
GAP_magnet  = 0.5; // [0:0.1:10]
// min bit holder height
HEIGHT      = 20;
// bit tolerance (fl_JNgauge=0.15mm)
TOLERANCE   = 0.15; // [0:0.05:1]
// inter holder gap along X axis
GAP_holder  = 1;

/* [Hidden] */

function check(r) = r[3]!=0;

function bitHolder(name,bit,cardinality) = let(
  h     = max(bit[1]/3,HEIGHT),
  d     = bit[0]+2*TOLERANCE,
  bbox_1 = fl_bb_cylinder(h=h,d=d+T),
  bbox  = [
    [bbox_1[0].x-GAP_holder/2,(bbox_1[0].y)*cardinality-T/2,bbox_1[0].z],
    [bbox_1[1].x+GAP_holder/2,(bbox_1[1].y)*cardinality+T/2,bbox_1[1].z]
  ]
) [
    fl_nameKV(str(name," bit-holder")),
    fl_bb_cornersKV(bbox),
    fl_sizeKV(bbox[1]-bbox[0]),
    ["h",           h],
    ["d",           d],
    ["bit",         bit],
    ["cardinality", cardinality],
  ];

verbs=[
  if (ADD!="OFF")       FL_ADD,
  if (ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if (BBOX!="OFF")      FL_BBOX,
];

magnet_size = [10,5,1];

bits = [
  if (check(BIT_1))  let(r=BIT_1)   [str(r[0],"mm"),[r[1],r[2]],r[3]],
  if (check(BIT_2))  let(r=BIT_2)   [str(r[0],"mm"),[r[1],r[2]],r[3]],
  if (check(BIT_3))  let(r=BIT_3)   [str(r[0],"mm"),[r[1],r[2]],r[3]],
  if (check(BIT_4))  let(r=BIT_4)   [str(r[0],"mm"),[r[1],r[2]],r[3]],
  if (check(BIT_5))  let(r=BIT_5)   [str(r[0],"mm"),[r[1],r[2]],r[3]],
  if (check(BIT_6))  let(r=BIT_6)   [str(r[0],"mm"),[r[1],r[2]],r[3]],
  if (check(BIT_7))  let(r=BIT_7)   [str(r[0],"mm"),[r[1],r[2]],r[3]],
  if (check(BIT_8))  let(r=BIT_8)   [str(r[0],"mm"),[r[1],r[2]],r[3]],
  if (check(BIT_9))  let(r=BIT_9)   [str(r[0],"mm"),[r[1],r[2]],r[3]],
  if (check(BIT_10)) let(r=BIT_10)  [str(r[0],"mm"),[r[1],r[2]],r[3]],
];

if (bits) {
  strip = let(
    bhs   = [for(bit=bits) bitHolder(bit[0],bit[1],bit[2])],
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
  strip_sz  = strip_bb[1]-strip_bb[0];
  fl_trace("strip object",strip);

  fl_modifier(ADD) fl_color($FL_FILAMENT) difference() {
    // strip FL_LAYOUT and FL_ADD of the first and last $item shape
    hull() fl_layout(FL_LAYOUT,axis=+X,types=fl_get(strip,"Bit holders")) union() {
      h = fl_get($item,"h");
      d = fl_get($item,"d");
      translate(-Y($size.y/2))
        linear_extrude(h) 
          fl_square(size=$size,vertices=[0,0,d/2,d/2]);
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
      card    = fl_get($item,"cardinality");
      translate([0,-(d/2+T),T_bottom-NIL]) {
        // bit 
        for(i=[0:card-1]) translate(-Y(i*(T+d))) 
          fl_cylinder(h=100,d=d);
        // magnet
        translate(Y(d/2+GAP_magnet))
          fl_cutout(100,z=+Y)
            fl_cutout(magnet_size.x+2*TOLERANCE,delta=TOLERANCE) 
              translate([0,d/2+magnet_size.z/2+GAP_magnet,TOLERANCE]) rotate(90,Z)
                fl_cube(size=magnet_size,direction=[-X,0],octant=+X);
        }
    }
  }

  fl_modifier(ASSEMBLY) fl_color("silver")
    fl_layout(FL_LAYOUT,axis=+X,types=fl_get(strip,"Bit holders")) union() {
      d     = fl_get($item,"d");
      card  = fl_get($item,"cardinality");
      translate([0,-(d/2+T),T_bottom-NIL]) {
        // bit(s)
        let(bit=fl_get($item,"bit")) for(i=[0:card-1]) translate(-Y(i*(T+d)))  
            fl_cylinder(h=bit[1],d=bit[0]);     
        // magnet
        translate([0,d/2+magnet_size.z/2+GAP_magnet,TOLERANCE]) rotate(90,Z)
          fl_cube(size=magnet_size,direction=[-X,0],octant=+X);
      }
    }

  fl_modifier(BBOX) 
    fl_bb_add(fl_bb_corners(strip));
}