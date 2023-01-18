/*
 * Box artifact test.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../artifacts/box.scad>

$fn         = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
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
// mount shape through predefined screws
$FL_MOUNT     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a box representing the payload of the shape
$FL_PAYLOAD   = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Box] */

// external dimensions
XSIZE           = [100,60,40];
// internal payload size
ISIZE           = [100,60,40];
// internal bounding box low corner
PLOAD_0         = [0,0,0];
// internal bounding box high corner
PLOAD_1         = [100,60,40];
// select the input to use
SIZE_BY         = "XSIZE";  // [XSIZE,ISIZE,PLOAD]
// sheet thickness
THICK           = 2.5;
// fold internal radius (square if undef)
RADIUS          = 1.1;

PARTS           = "all";    // [all,upper,lower]
TOLERANCE       = 0.3;
// upper side color
MATERIAL_UPPER  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// lower side color
MATERIAL_LOWER  = "SteelBlue";  // [DodgerBlue,Blue,OrangeRed,SteelBlue]
FILLET          = true;

/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
verbs=[
  if ($FL_ADD!="OFF")       FL_ADD,
  if ($FL_ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if ($FL_AXES!="OFF")      FL_AXES,
  if ($FL_BBOX!="OFF")      FL_BBOX,
  if ($FL_MOUNT!="OFF")     FL_MOUNT,
  if ($FL_PAYLOAD!="OFF")   FL_PAYLOAD,
];

fl_box(verbs,
  xsize=SIZE_BY=="XSIZE"?XSIZE:undef,
  isize=SIZE_BY=="ISIZE"?ISIZE:undef,
  pload=SIZE_BY=="PLOAD"?[PLOAD_0,PLOAD_1]:undef,
  thick=THICK,
  radius=RADIUS?RADIUS:undef,
  parts=PARTS,
  material_upper=MATERIAL_UPPER,
  material_lower=MATERIAL_LOWER,
  tolerance=TOLERANCE,
  fillet=FILLET,
  octant=octant,direction=direction
);
