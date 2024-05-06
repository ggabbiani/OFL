/*
 * din_rails test
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/artifacts/din_rails.scad>


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
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
$FL_CUTOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
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


/* [DIN rails] */

SHOW    = "ALL";  // [ALL, TS15, TS35, TS35D]
LENGTH  = 50;     // [0:100]
PUNCHED = false;
// used during FL_CUTOUT and FL_FOOTPRINT
TOLERANCE   = 0;  // [0:0.1:5]
// thickness for FL_CUTOUT
CO_T  = 2.5;          // [0:0.5:5]
// translation applied to cutout
CO_DRIFT = 0; // [-100:0.5:100]
CO_DIRECTION  = ["±Z"];


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// end of automatically generated code

thick         = $FL_CUTOUT!="OFF" ? CO_T       : undef;
tolerance     = $FL_CUTOUT!="OFF" || $FL_FOOTPRINT!="OFF" ? TOLERANCE  : undef;
drift         = $FL_CUTOUT!="OFF" ? CO_DRIFT   : undef;
p_thick       = thick!=undef && drift!=undef ? thick-drift : undef;
co_direction  = fl_3d_AxisList(CO_DIRECTION);

verbs = fl_verbList([FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT,FL_FOOTPRINT,FL_LAYOUT,FL_MOUNT]);

single = fl_switch(SHOW,fl_list_pack(fl_dict_names(FL_DIN_TS_INVENTORY),FL_DIN_RAIL_INVENTORY));
if (single) {
  fl_DIN_rail(
    verbs,single(LENGTH,PUNCHED),
    cut_direction=co_direction,cut_thick=p_thick,tolerance=tolerance,cut_drift=drift,
    octant=octant,direction=direction,debug=debug
  );
} else {
  all = [for(constructor=FL_DIN_RAIL_INVENTORY) constructor(LENGTH,PUNCHED)];
  fl_layout(axis=+X,gap=3,types=all,$FL_LAYOUT="ON")
    fl_DIN_rail(
      verbs,all[$i],
      cut_direction=co_direction,cut_thick=p_thick,tolerance=tolerance,cut_drift=drift,
      octant=octant,direction=direction,debug=debug
    );
}