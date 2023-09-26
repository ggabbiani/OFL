/*
 * Box artifact test
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/artifacts/box.scad>

use <../../lib/OFL/foundation/2d-engine.scad>


$fn            = 50;           // [3:100]
// When true, debug statements are turned on
$fl_debug      = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER     = false;
// Default color for printable items (i.e. artifacts)
$fl_filament   = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES     = -2;     // [-2:10]
SHOW_LABELS     = false;
SHOW_SYMBOLS    = false;


/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
$FL_ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// mount shape through predefined screws
$FL_MOUNT     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a box representing the payload of the shape
$FL_PAYLOAD   = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


/* [3D Placement] */

X_PLACE = "undef";  // [undef,-1,0,+1]
Y_PLACE = "undef";  // [undef,-1,0,+1]
Z_PLACE = "undef";  // [undef,-1,0,+1]


/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [-360:360]


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

/* [Layout] */

LAY_NATIVE  = true;
LAY_OCTANT  = [0,0,0];  // [-1:+1]


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// end of automatically generated code

verbs=[
  if ($FL_ADD!="OFF")       FL_ADD,
  if ($FL_ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if ($FL_AXES!="OFF")      FL_AXES,
  if ($FL_BBOX!="OFF")      FL_BBOX,
  if ($FL_LAYOUT!="OFF")    FL_LAYOUT,
  if ($FL_MOUNT!="OFF")     FL_MOUNT,
  if ($FL_PAYLOAD!="OFF")   FL_PAYLOAD,
];

lay_octant  = LAY_NATIVE  ? undef : LAY_OCTANT;

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
  lay_octant=lay_octant,
  octant=octant,direction=direction
)
  fl_sphere([FL_AXES],r=10);
