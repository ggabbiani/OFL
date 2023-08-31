/*
 * NopSCADlib RJ45 wrapper test.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <../../lib/OFL/foundation/core.scad>
include <../../lib/OFL/vitamins/ethers.scad>

use <../../lib/OFL/dxf.scad>

$fn           = 50;   // [3:100]
// When true, disables epsilon corrections
$FL_RENDER    = false;
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES    = -2;   // [-2:10]
$fl_debug     = false;
SHOW_LABELS   = false;
SHOW_SYMBOLS  = false;

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

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [RJ45] */

ETHER = "FL_ETHER_RJ45";  // [FL_ETHER_RJ45, FL_ETHER_RJ45_SM]
// tolerance used during FL_CUTOUT
CO_TOLERANCE   = 0;  // [0:0.1:5]
// thickness for FL_CUTOUT
CO_T  = 2.5;
// translation applied to cutout
CO_DRIFT = 0; // [-5:0.05:5]

/* [Hidden] */

direction = DIR_NATIVE        ? undef         : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE      ? undef         : OCTANT;
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);
thick     = $FL_CUTOUT!="OFF" ? CO_T          : undef;
tolerance = $FL_CUTOUT!="OFF" ? CO_TOLERANCE  : undef;
drift     = $FL_CUTOUT!="OFF" ? CO_DRIFT      : undef;

p_thick = thick!=undef && drift!=undef ? thick-drift : undef;

verbs=[
  if ($FL_ADD!="OFF")       FL_ADD,
  if ($FL_AXES!="OFF")      FL_AXES,
  if ($FL_BBOX!="OFF")      FL_BBOX,
  if ($FL_CUTOUT!="OFF")    FL_CUTOUT,
  if ($FL_FOOTPRINT!="OFF") FL_FOOTPRINT,
];
ether = ETHER=="FL_ETHER_RJ45"  ? FL_ETHER_RJ45
      : FL_ETHER_RJ45_SM;

fl_trace("verbs",verbs);

fl_ether(verbs,ether,
  debug=debug,direction=direction,octant=octant,
  cut_thick=p_thick,cut_tolerance=tolerance,cut_drift=drift
);
