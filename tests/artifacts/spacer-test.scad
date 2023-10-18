/*
 * Spacers test file
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/artifacts/spacer.scad>


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
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
$FL_FOOTPRINT = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// mount shape through predefined screws
$FL_MOUNT     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


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


/* [FACTORY] */

// height
H     = 4;  // [0.1:0.1:10]
// external radius
R     = 2;  // [0.1:0.1:10]

SCREW_SIZE  = 2;         // [2,2.5,3,4,5,6,8]
// when true the spacer must host a screw
SCREW       = true;
// when true tries to find a screw fitting knurl nut
KNUT  = false;
// no fillet if zero
FILLET  = 0;  // [0:0.1:5]

ANCHOR_X_POS  = false;
ANCHOR_X_NEG  = false;
ANCHOR_Y_POS  = false;
ANCHOR_Y_NEG  = false;
ANCHOR_Z_NEG  = false;

/* [TEST] */

// thickness on +Z axis
THICK_POSITIVE = 1;      // [0:0.1:10]
// thickness on -Z axis
THICK_NEGATIVE = 2;      // [0:0.1:10]

// FL_LAYOUT directions
LAYOUT_DIRS  = "±z";  // [±z, -z, +z]


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// end of automatically generated code

anchor  = [
  if (ANCHOR_X_POS) +X,
  if (ANCHOR_X_NEG) -X,
  if (ANCHOR_Y_POS) +Y,
  if (ANCHOR_Y_NEG) -Y,
  if (ANCHOR_Z_NEG) -Z,
];

verbs = fl_verbList([
  FL_ADD,
  FL_ASSEMBLY,
  FL_AXES,
  FL_BBOX,
  FL_DRILL,
  FL_FOOTPRINT,
  FL_LAYOUT,
  FL_MOUNT,
]);
thickness = let(t= [
  if (THICK_NEGATIVE) -THICK_NEGATIVE,
  if (THICK_POSITIVE) +THICK_POSITIVE
]) t ? t : undef;

screw = SCREW ? find_screw(hs_cap,SCREW_SIZE) : undef;
knut  = screw ? KNUT : undef;
dirs  = fl_3d_AxisList([LAYOUT_DIRS]);

if (SCREW && !screw)
  echo(str("***WARN***: no ",SCREW_TYPE," screw M",SCREW_SIZE," found."));
if (KNUT && !knut)
  echo(str("***WARN***: knurl nut set to false because no nut found."));

fl_spacer(verbs,H,R,screw=screw,knut=knut,thick=thickness,lay_direction=dirs,anchor=anchor,fillet=FILLET,octant=octant,direction=direction)
  fl_cylinder([FL_ADD,FL_AXES],h=5,d2=0,d1=fl_screw_nominal($spc_screw),direction=[$spc_director,0],$FL_ADD=$FL_LAYOUT,$FL_AXES="ON");
