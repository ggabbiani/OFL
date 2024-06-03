/*
 * NopSCADlib fan wrapper test.
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/vitamins/fans.scad>
include <../../lib/OFL/vitamins/screw.scad>


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
SHOW  = "ALL";  // [ALL,17x17x8mm fan,25.4x25.4x10mm fan,30x30x10mm fan,40x40x11mm fan,50x50x15mm fan,60x60x15mm fan,60x60x25mm fan,70x70x15mm fan,80x80x25mm fan,80x80x38mm fan,120x120x25mm fan]

/* [TEST] */
// thickness on +Z axis
THICK_POSITIVE = 1.6;      // [0:0.1:10]
// thickness on -Z axis
THICK_NEGATIVE = 2.5;      // [0:0.1:10]


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// end of automatically generated code

verbs = fl_verbList([
  FL_ADD,
  FL_AXES,
  FL_BBOX,
  FL_DRILL,
  FL_FOOTPRINT,
  FL_LAYOUT,
  FL_MOUNT,
]);
thickness = let(
  t = [
    if (THICK_NEGATIVE) -THICK_NEGATIVE,
    if (THICK_POSITIVE) +THICK_POSITIVE
  ]
) t ? t : undef;

fan = fl_switch(SHOW,fl_list_pack(FL_FAN_NAMES,FL_FAN_INVENTORY));

if (fan) {
  screw = fl_fan_screw(fan);
  fl_fan(verbs,fan,thick=thickness,octant=octant,direction=direction,debug=debug)
    fl_screw(type=screw,thick=$fan_thick,direction=$fan_direction);
} else {
  fl_layout(axis=+X, gap=3, types=FL_FAN_INVENTORY,$FL_LAYOUT="ON") let(
    screw = fl_fan_screw($item)
  ) fl_fan(verbs,$item,thick=thickness,octant=octant,direction=direction,debug=debug)
    fl_screw(type=screw,thick=$fan_thick,direction=$fan_direction);
}