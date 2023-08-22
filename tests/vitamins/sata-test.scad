/*
 * Test for 'naive' SATA plug & socket.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../lib/OFL/vitamins/sata.scad>
include <../../lib/OFL/foundation/unsafe_defs.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$fl_debug   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]
// Default color for printable items (i.e. artifacts)
$fl_filament  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
$FL_CUTOUT    = "OFF";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
$FL_FOOTPRINT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Sata] */
PART            = "data plug";  // ["data plug", "power plug", "power data plug", "power data socket"]
// TODO: see comment on sata.scad
SW_SHELL        = true;
CONTACTS        = true;
CONNECTORS      = false;

/* [Hidden] */

fl_trace("OFL version", fl_version());

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
verbs=[
  if ($FL_ADD!="OFF")       FL_ADD,
  if ($FL_AXES!="OFF")      FL_AXES,
  if ($FL_BBOX!="OFF")      FL_BBOX,
  if ($FL_FOOTPRINT!="OFF")    FL_FOOTPRINT,
];

if (PART=="data plug") {
  fl_sata(verbs,FL_SATA_DATAPLUG,connectors=CONNECTORS,octant=octant,direction=direction);
} else if (PART=="power plug") {
  fl_sata_powerPlug(verbs,FL_SATA_POWERPLUG,connectors=CONNECTORS,octant=octant,direction=direction);
} else if (PART=="power data plug") {
    fl_sata_powerDataPlug(verbs,FL_SATA_POWERDATAPLUG,shell=SW_SHELL,connectors=CONNECTORS,octant=octant,direction=direction);
} else {
  sata_PowerDataSocket(verbs,FL_SATA_POWERDATASOCKET,connectors=CONNECTORS,octant=octant,direction=direction);
}
