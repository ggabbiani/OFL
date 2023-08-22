/*
 * Spacers test file.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <../../lib/OFL/artifacts/spacer.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$fl_debug   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// Default color for printable items (i.e. artifacts)
$fl_filament  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]

/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
$FL_ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
$FL_FOOTPRINT = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// mount shape through predefined screws
$FL_MOUNT     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Spacer] */

// height
H     = 4;  // [0.1:0.1:10]
// external radius
R     = 2;  // [0.1:0.1:10]

// when true the spacer must host a screw
SCREW       = true;
SCREW_TYPE  = "hs_cap";  // [hs_cap,hs_pan,hs_cs,hs_hex,hs_grub,hs_cs_cap,hs_dome]
SCREW_SIZE  = 2;         // [2,2.5,3,3.5,4,4.2,5,6,7,8]

// when true tries to find a screw fitting knurl nut
KNUT  = false;

// thickness along ±Z semi axes
Tz = [0,0];  // [0:0.1:10]

// FL_LAYOUT directions in floating semi-axis list
LAYOUT_DIRS  = ["±z"];

/* [Hidden] */

HS_TYPES=["hs_cap","hs_pan","hs_cs","hs_hex","hs_grub","hs_cs_cap","hs_dome"];

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
verbs=[
  if ($FL_ADD!="OFF")       FL_ADD,
  if ($FL_ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if ($FL_AXES!="OFF")      FL_AXES,
  if ($FL_BBOX!="OFF")      FL_BBOX,
  if ($FL_DRILL!="OFF")     FL_DRILL,
  if ($FL_FOOTPRINT!="OFF") FL_FOOTPRINT,
  if ($FL_LAYOUT!="OFF")    FL_LAYOUT,
  if ($FL_MOUNT!="OFF")     FL_MOUNT,
];

screw = SCREW ? find_screw(search([SCREW_TYPE],HS_TYPES)[0],SCREW_SIZE) : undef;
knut  = SCREW ? KNUT : undef;
dirs  = fl_3d_AxisList(LAYOUT_DIRS);
thick = [[0,0],[0,0],Tz];

fl_spacer(verbs,H,R,screw=screw,knut=knut,thick=thick,lay_direction=dirs,octant=octant,direction=direction)
  translate($spc_director*$spc_thick)
    fl_screw(FL_DRAW,$spc_screw,thick=$spc_h+$spc_thick,washer="nylon",direction=[$spc_director,0]);
