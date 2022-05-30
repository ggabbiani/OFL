/*
 * Test for 'naive' SATA plug & socket.
 *
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * OFL is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * OFL is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with OFL.  If not, see <http: //www.gnu.org/licenses/>.
 */

include <../../vitamins/sata.scad>
include <../../foundation/unsafe_defs.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, trace messages are turned on
TRACE       = false;

$FL_FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

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
