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


/* [Magnetic Key Holder] */

// extra gap between adiacent bits
GAP           = [3,1,2];  // [0:0.1:10]
// min bit height
HEIGHT  = 32;
// bit tolerance (fl_JNgauge=0.15mm)
BIT_TOLERANCE = 0.15;

/* [Hidden] */

verbs=[
  if (ADD!="OFF")       FL_ADD,
  if (ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if (BBOX!="OFF")      FL_BBOX,
];

magnet_size = [10,5,1];

function bitHolder(d) = let(
  h   = 10
) [
    fl_nameKV(str(d,"mm bit-holder")),
    fl_bb_cornersKV(fl_bb_cylinder(h,d))
  ];
diameters = [1,1.6,2,3,3.3,4,4.2,5];
// diameters = [1];

strip = let(
  bits  =[for(d=diameters) bitHolder(d)]
) [
  ["bits",  bits],
  fl_bb_cornersKV(lay_bb_corners(+X,GAP.x,bits)),
];
fl_trace("strip object",strip);

bar_bb = let(
  y = max(diameters)/2 + GAP.x,
  strip_bb = fl_get(strip,fl_bb_cornersKV())
) 
assert(len(strip_bb)==2,strip_bb)
[[strip_bb[0].x-GAP.x,0,0],[strip_bb[1].x+GAP.x,y,HEIGHT]];
fl_trace("bar bounding box",bar_bb);

bar_bb2 = let(
  y = max(diameters)/2 + GAP.y,
  strip_bb = fl_get(strip,fl_bb_cornersKV())
) 
assert(len(strip_bb)==2,strip_bb)
[[strip_bb[0].x-GAP.x,0,0],[strip_bb[1].x+GAP.x,y,HEIGHT]];

fl_modifier(ADD) fl_color($FL_FILAMENT) difference() {
  union() {
    // +Y part
    fl_place(octant=+Y+Z,bbox=bar_bb)
      fl_bb_add(bar_bb);
    // -Y part
    fl_place(octant=-Y+Z,bbox=bar_bb2)
      fl_bb_add(bar_bb2);
  }
  translate([0,0,NIL])
    fl_layout(axis=+X,gap=GAP.x,types=fl_get(strip,"bits"),octant=+Z) union() {
      // bit hole
      translate(+Z(GAP.z))
        fl_cylinder(h=HEIGHT+2*NIL,d=diameters[$i]+2*BIT_TOLERANCE);
      // magnet hole
      translate([0,diameters[$i]/2+GAP.y,GAP.z]) 
        fl_cube(verbs=[FL_ADD], size=[max(magnet_size.x,HEIGHT),magnet_size.y,10]+X(2*NIL),octant=-X-Z,direction=[-Y,-90]);
    }
}
fl_modifier(ASSEMBLY) {
  fl_color("silver") translate(-Z(NIL))
    fl_layout(axis=+X,gap=GAP.x,types=fl_get(strip,"bits"),octant=+Z)
      translate([0,diameters[$i]/2+GAP.y,GAP.z]) fl_cube(verbs=[FL_ADD], size=magnet_size+X(2*NIL),octant=-X-Z,direction=[-Y,-90],$FL_ADD=ASSEMBLY);
}
