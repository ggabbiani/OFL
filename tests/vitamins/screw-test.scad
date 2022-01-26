/*
 * Screw wrappers test file for OpenSCAD Foundation Library vitamins.
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
ASSEMBLY  = "ON";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
FPRINT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Screw] */

SCREW     = "M2_cap_screw"; // [No632_pan_screw,M2_cap_screw,M2_cs_cap_screw,M2_dome_screw,M2p5_cap_screw,M2p5_pan_screw,M3_cap_screw,M3_cs_cap_screw,M3_dome_screw,M3_grub_screw,M3_hex_screw,M3_low_cap_screw,M3_pan_screw,M4_cap_screw,M4_cs_cap_screw,M4_dome_screw,M4_grub_screw,M4_hex_screw,M4_pan_screw,M5_cap_screw,M5_cs_cap_screw,M5_dome_screw,M5_hex_screw,M5_pan_screw,M6_cap_screw,M6_cs_cap_screw,M6_hex_screw,M6_pan_screw,M8_cap_screw,M8_hex_screw,No2_screw,No4_screw,No6_cs_screw,No6_screw,No8_screw]
FIXED_LEN = 0;
// thickness
T       = 10;   // [1:0.1:20]
WASHER  = "no"; // [no,default,penny]
XWASHER = "no"; // [no,spring,star]
NWASHER = false;
NUT     = "no"; // [no,default,nyloc]

/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
verbs=[
  if (ADD!="OFF")       FL_ADD,
  if (ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if (AXES!="OFF")      FL_AXES,
  if (BBOX!="OFF")      FL_BBOX,
  if (DRILL!="OFF")     FL_DRILL,
  if (FPRINT!="OFF")    FL_FOOTPRINT,
];

screw = SCREW=="No632_pan_screw" ? No632_pan_screw
      : SCREW=="M2_cap_screw"    ? M2_cap_screw
      : SCREW=="M2_cs_cap_screw" ? M2_cs_cap_screw
      : SCREW=="M2_dome_screw"   ? M2_dome_screw
      : SCREW=="M2p5_cap_screw"  ? M2p5_cap_screw
      : SCREW=="M2p5_pan_screw"  ? M2p5_pan_screw
      : SCREW=="M3_cap_screw"    ? M3_cap_screw
      : SCREW=="M3_cs_cap_screw" ? M3_cs_cap_screw
      : SCREW=="M3_dome_screw"   ? M3_dome_screw
      : SCREW=="M3_grub_screw"   ? M3_grub_screw
      : SCREW=="M3_hex_screw"    ? M3_hex_screw
      : SCREW=="M3_low_cap_screw"? M3_low_cap_screw
      : SCREW=="M3_pan_screw"    ? M3_pan_screw
      : SCREW=="M4_cap_screw"    ? M4_cap_screw
      : SCREW=="M4_cs_cap_screw" ? M4_cs_cap_screw
      : SCREW=="M4_dome_screw"   ? M4_dome_screw
      : SCREW=="M4_grub_screw"   ? M4_grub_screw
      : SCREW=="M4_hex_screw"    ? M4_hex_screw
      : SCREW=="M4_pan_screw"    ? M4_pan_screw
      : SCREW=="M5_cap_screw"    ? M5_cap_screw
      : SCREW=="M5_cs_cap_screw" ? M5_cs_cap_screw
      : SCREW=="M5_dome_screw"   ? M5_dome_screw
      : SCREW=="M5_hex_screw"    ? M5_hex_screw
      : SCREW=="M5_pan_screw"    ? M5_pan_screw
      : SCREW=="M6_cap_screw"    ? M6_cap_screw
      : SCREW=="M6_cs_cap_screw" ? M6_cs_cap_screw
      : SCREW=="M6_hex_screw"    ? M6_hex_screw
      : SCREW=="M6_pan_screw"    ? M6_pan_screw
      : SCREW=="M8_cap_screw"    ? M8_cap_screw
      : SCREW=="M8_hex_screw"    ? M8_hex_screw
      : SCREW=="No2_screw"       ? No2_screw
      : SCREW=="No4_screw"       ? No4_screw
      : SCREW=="No6_cs_screw"    ? No6_cs_screw
      : SCREW=="No6_screw"       ? No6_screw
      : SCREW=="No8_screw"       ? No8_screw
      : undef;
assert(screw!=undef);

fl_screw(verbs,screw,thick=T,washer=WASHER,nut=NUT,xwasher=XWASHER,nwasher=NWASHER,len=FIXED_LEN?FIXED_LEN:undef,
  octant=octant,direction=direction,
  $FL_ADD=ADD,$FL_AXES=AXES,$FL_BBOX=BBOX,$FL_DRILL=DRILL,$FL_FOOTPRINT=FPRINT);
