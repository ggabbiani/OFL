/*
 * Magnet test file for OpenSCAD Foundation Library.
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
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

/* [Supported verbs] */

// adds shapes to scene.
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
FPRINT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
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

/* [Magnet] */

SHOW      = "ALL"; // [ALL:All, M3_cs_magnet10x2:M3_cs_magnet10x2, M3_cs_magnet10x5:M3_cs_magnet10x5, M3_magnet10x5:M3_magnet10x5, M4_cs_magnet32x6:M4_cs_magnet32x6]
GROSS     = 0;
T         = 2.5;

/* [Hidden] */

module __test__() {
  direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
  octant    = PLACE_NATIVE  ? undef : OCTANT;
  verbs=[
    if (ADD!="OFF")       FL_ADD,
    if (ASSEMBLY!="OFF")  FL_ASSEMBLY,
    if (AXES!="OFF")      FL_AXES,
    if (BBOX!="OFF")      FL_BBOX,
    if (DRILL!="OFF")     FL_DRILL,
    if (FPRINT!="OFF")    FL_FOOTPRINT,
    if (LAYOUT!="OFF")    FL_LAYOUT,
  ];

  // target object(s)
  object  = SHOW=="M3_cs_magnet10x2"  ? FL_MAG_M3_CS_10x2 
          : SHOW=="M3_magnet10x5"     ? FL_MAG_M3_10x5 
          : SHOW=="M3_cs_magnet10x5"  ? FL_MAG_M3_CS_10x5 
          : SHOW=="M4_cs_magnet32x6"  ? FL_MAG_M4_CS_32x6
          : undef;

  module do_test(magnet) {
    fl_trace("obj name:",fl_name(magnet));
    fl_trace("DIR_NATIVE",DIR_NATIVE);
    fl_trace("DIR_Z",DIR_Z);
    fl_trace("DIR_R",DIR_R);
    screw = fl_mag_screw(magnet);
    fl_magnet(verbs,magnet,gross=GROSS,thick=T,octant=octant,direction=direction,
      $FL_ADD=ADD,$FL_ASSEMBLY=ASSEMBLY,$FL_AXES=AXES,$FL_BBOX=BBOX,$FL_DRILL=DRILL,$FL_FOOTPRINT=FPRINT,$FL_LAYOUT=LAYOUT)
        if (screw!=undef) fl_color("green") fl_cylinder(h=fl_mag_height(magnet),r=screw_radius(screw),octant=-Z);
  }

  if (object)
    do_test(object);
  else
    layout([for(magnet=FL_MAG_DICT) fl_mag_diameter(magnet)], 10)
      do_test(FL_MAG_DICT[$i]);
}

__test__();