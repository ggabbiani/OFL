/*
 * Bit-holder example.
 *
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

include <../foundation/util.scad>
include <../vitamins/magnets.scad>

/* [Globals] */

$fn         = 50;           // [3:100]
// May trigger debug statement in client modules / functions
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, trace messages are turned on
$fl_traces   = false;
// Filament color used for printed parts
$FL_FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
$FL_ASSEMBLY  = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Bits (nominal/shank/length,cardinality)] */

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
BIT_11  = [0,0,0,0];      // [0:0.01:200]
BIT_12  = [0,0,0,0];      // [0:0.01:200]
BIT_13  = [0,0,0,0];      // [0:0.01:200]
BIT_14  = [0,0,0,0];      // [0:0.01:200]
BIT_15  = [0,0,0,0];      // [0:0.01:200]

/* [Holder] */

// thickness around bit hole
T_hole      = 1.5;  // [0:0.1:10]
T_bottom    = 1;    // [0:0.1:10]
// Y wall thickness with magnet
T_magnet    = 0.5; // [0:0.1:10]
// min bit holder height
HEIGHT      = 20;
// bit tolerance (fl_JNgauge=0.15mm)
TOLERANCE   = 0.18; // [0:0.05:1]
// inter holder distance along X axis
I_holder  = 1;
// magnet size
MAGNET    = "FL_MAG_RECT_10x5x2"; // [FL_MAG_RECT_10x5x1,FL_MAG_RECT_10x5x2]

/* [Hidden] */

function check(r) = r[3]!=0;

function bitHolder(name,bit,cardinality,magnet) = let(
  d       = bit[0]+2*TOLERANCE,
  h       = max(bit[1]/3,HEIGHT),
  width   = max(SZ_magnet.y+2*(TOLERANCE+T_magnet)+I_holder,d+2*(TOLERANCE+T_hole)+I_holder),
  length  = T_magnet+2*TOLERANCE+T_hole+SZ_magnet.z+cardinality*(d+T_hole),
  bbox    = [[-width/2,-length,0],[+width/2,0,h]]
) [
    fl_name(value=str(name," bit-holder")),
    fl_bb_corners(value=bbox),
    ["h",           h],
    ["d",           d],
    ["bit",         bit],
    ["cardinality", cardinality],
    ["magnet",      magnet],
  ];

magnet    = MAGNET=="FL_MAG_RECT_10x5x1"
          ? FL_MAG_RECT_10x5x1
          : MAGNET=="FL_MAG_RECT_10x5x2"
          ? FL_MAG_RECT_10x5x2
          : undef;

SZ_magnet = fl_size(magnet);

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
  if (check(BIT_11)) let(r=BIT_11)  [str(r[0],"mm"),[r[1],r[2]],r[3]],
  if (check(BIT_12)) let(r=BIT_12)  [str(r[0],"mm"),[r[1],r[2]],r[3]],
  if (check(BIT_13)) let(r=BIT_13)  [str(r[0],"mm"),[r[1],r[2]],r[3]],
  if (check(BIT_14)) let(r=BIT_14)  [str(r[0],"mm"),[r[1],r[2]],r[3]],
  if (check(BIT_15)) let(r=BIT_15)  [str(r[0],"mm"),[r[1],r[2]],r[3]],
];
strip();

module strip() {
  if (bits) {
    strip = let(
      bhs   = [for(bit=bits) bitHolder(bit[0],bit[1],bit[2],magnet)],
      bbox  = lay_bb_corners(axis=+X,types=bhs),
      size  = bbox[1]-bbox[0]
    ) [
        ["Bit holders",  bhs],
        ["Bit number",  len(bhs)],
        fl_bb_corners(value=bbox),
      ];

    //**** FL_ADD ***************************************************************
    if ($FL_ADD!="OFF") fl_modifier($FL_ADD) difference() {
      fl_color($FL_FILAMENT) hull() fl_layout(FL_LAYOUT,axis=+X,types=fl_get(strip,"Bit holders"))
        holder(FL_ADD,$item);
      fl_layout(FL_LAYOUT,axis=+X,types=fl_get(strip,"Bit holders"))
        holder(FL_DRILL,$item);
    }
    //**** FL_ASSEMBLY **********************************************************
    if ($FL_ASSEMBLY!="OFF") fl_modifier($FL_ASSEMBLY)
      fl_layout(FL_LAYOUT,axis=+X,types=fl_get(strip,"Bit holders"))
        holder(FL_ASSEMBLY,$item);

    if ($FL_BBOX!="OFF") fl_modifier($FL_BBOX)
      fl_bb_add(fl_bb_corners(strip));
  }
}

module holder(verbs,item) {
  assert(verbs!=undef);
  assert(item!=undef);

  module bit(gross=false) {
    assert(is_bool(gross));
    d = bit[0];
    h = bit[1];
    if (gross)
      fl_cutout(h+2*TOLERANCE,delta=TOLERANCE) bit(gross=false);
    else
      fl_cylinder(h=h,d=d);
  }

  module box() {
    linear_extrude(h)
      fl_square(size=size,corners=[0,0,d/2,d/2],quadrant=+X+Y);
  }

  module do_drill() {
    // bit
    multmatrix(Mbit)
      for(i=[0:card-1]) translate(-Y(i*(T_hole+d)))
        bit(gross=true);
    // magnet
    multmatrix(Mmagnet) {
      fl_magnet(FL_FOOTPRINT,magnet,fp_gross=TOLERANCE,octant=+X,direction=[-Y,90]);
    }
  }

  bbox    = fl_bb_corners(item);
  size    = fl_size(item);
  h       = fl_get(item,"h");
  d       = fl_get(item,"d");
  card    = fl_get(item,"cardinality");
  bit     = fl_get(item,"bit");
  Mbox    = T(bbox[0]);
  magnet  = fl_get(item,"magnet");
  Mmagnet = T([0,-SZ_magnet.z/2-T_magnet-TOLERANCE,T_bottom]);
  Mbit    = T([0,-(T_magnet+2*TOLERANCE+T_hole+SZ_magnet.z+d/2),T_bottom]);

  fl_trace("item",item);
  fl_trace("size",size);
  fl_trace("bit",bit);
  fl_trace("magnet",magnet);

  fl_manage(verbs) {
    if ($verb==FL_ADD) {
      fl_modifier($FL_ADD) fl_color($FL_FILAMENT)
        multmatrix(Mbox) box();
    } else if ($verb==FL_BBOX) {
      fl_modifier($FL_BBOX) fl_bb_add(bbox);
    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($FL_ASSEMBLY) fl_color("silver") {
        // bit
        multmatrix(Mbit)
          for(i=[0:card-1]) translate(-Y(i*(T_hole+d)))
            bit();
        // magnet
        multmatrix(Mmagnet)
          fl_magnet(FL_ADD,magnet,octant=+X,direction=[-Y,90]);
      }
    } else if ($verb==FL_DRILL) {
      fl_modifier($FL_DRILL) do_drill();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
