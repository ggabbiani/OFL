/*
 * Vitamins test template.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <NopSCADlib/global_defs.scad>
use     <NopSCADlib/utils/layout.scad>

include <../../lib/OFL/foundation/defs.scad>
include <../../lib/OFL/vitamins/hdmi.scad>

$fn         = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]

/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
$FL_CUTOUT    = "OFF";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [HDMI] */

SHOW        = "ALL"; // [ALL,FL_HDMI_TYPE_A,FL_HDMI_TYPE_C,FL_HDMI_TYPE_D]
// tolerance used during FL_CUTOUT
CO_TOLERANCE   = 0;  // [0:0.1:5]
// thickness for FL_CUTOUT
CO_LEN  = 2.5;
// translation applied to cutout
CO_DRIFT = 0; // [-5:0.05:5]

/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
cutout    = $FL_CUTOUT!="OFF" ? CO_LEN : undef;
tolerance = $FL_CUTOUT!="OFF" ? CO_TOLERANCE : undef;
drift     = $FL_CUTOUT!="OFF" ? CO_DRIFT : undef;

verbs=[
  if ($FL_ADD!="OFF")       FL_ADD,
  if ($FL_AXES!="OFF")      FL_AXES,
  if ($FL_BBOX!="OFF")      FL_BBOX,
  if ($FL_CUTOUT!="OFF")    FL_CUTOUT,
];
// target object(s)
single  = SHOW=="FL_HDMI_TYPE_A"  ? FL_HDMI_TYPE_A
        : SHOW=="FL_HDMI_TYPE_C"  ? FL_HDMI_TYPE_C
        : SHOW=="FL_HDMI_TYPE_D"  ? FL_HDMI_TYPE_D
        : undef;

fl_trace("verbs",verbs);
if (single)
  fl_hdmi(verbs,single,direction=direction,octant=octant,cut_thick=cutout,cut_tolerance=tolerance,cut_drift=drift);
else
  layout([for(socket=FL_HDMI_DICT) fl_width(socket)], 10)
    fl_hdmi(verbs,FL_HDMI_DICT[$i],direction=direction,octant=octant,cut_thick=cutout,cut_tolerance=tolerance,cut_drift=drift);
