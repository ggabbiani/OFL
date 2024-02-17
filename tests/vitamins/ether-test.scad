/*
 * NopSCADlib RJ45 wrapper test
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/foundation/core.scad>
include <../../lib/OFL/vitamins/ethers.scad>

use <../../lib/OFL/dxf.scad>


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


/* [RJ45] */

ETHER = "FL_ETHER_RJ45";  // [FL_ETHER_RJ45, FL_ETHER_RJ45_SM]
// tolerance used during FL_CUTOUT
CO_TOLERANCE   = 0;  // [0:0.1:5]
// thickness for FL_CUTOUT
CO_T  = 2.5;          // [0:0.5:5]
// translation applied to cutout
CO_DRIFT = 0; // [-5:0.5:5]
CO_DIRECTION  = ["+X"]; // [+X,-X,+Y,-Y,+Z,-Z]

/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// end of automatically generated code

thick     = $FL_CUTOUT!="OFF" ? CO_T          : undef;
tolerance = $FL_CUTOUT!="OFF" ? CO_TOLERANCE  : undef;
drift     = $FL_CUTOUT!="OFF" ? CO_DRIFT      : undef;

p_thick = thick!=undef && drift!=undef ? thick-drift : undef;

verbs = fl_verbList([FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT,FL_FOOTPRINT]);
ether = ETHER=="FL_ETHER_RJ45" ?
          FL_ETHER_RJ45 :
          FL_ETHER_RJ45_SM;
co_direction  = fl_3d_AxisList(CO_DIRECTION);
echo(co_direction=co_direction);

fl_ether(verbs,ether,
  debug=debug,direction=direction,octant=octant,
  // cut_direction=co_direction,cut_thick=p_thick,cut_tolerance=tolerance,cut_drift=drift
  cut_direction=co_direction,cut_thick=thick,cut_tolerance=tolerance,cut_drift=drift
);
