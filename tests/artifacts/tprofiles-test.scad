/*
 * T-slot structural framing tests.
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/artifacts/t-profiles.scad>


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
// adds a footprint to scene, usually a simplified FL_ADD
$FL_FOOTPRINT = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];    // [-1:+1]


/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [-360:360]


/* [T Profile] */

PROFILE     = "FL_E1515"; // [FL_E1515,FL_E2020,FL_E2020t,FL_E2040,FL_E2060,FL_E2080,FL_E3030,FL_E3060,FL_E4040,FL_E4040t,FL_E4080]
LENGTH      = 50;
CORNER_HOLE = false;


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// end of automatically generated code

verbs=[
  if ($FL_ADD!="OFF")       FL_ADD,
  if ($FL_AXES!="OFF")      FL_AXES,
  if ($FL_BBOX!="OFF")      FL_BBOX,
  if ($FL_FOOTPRINT!="OFF") FL_FOOTPRINT,
];

profile = PROFILE=="FL_E1515"   ? FL_E1515
        : PROFILE=="FL_E2020"   ? FL_E2020
        : PROFILE=="FL_E2020t"  ? FL_E2020t
        : PROFILE=="FL_E2040"   ? FL_E2040
        : PROFILE=="FL_E2060"   ? FL_E2060
        : PROFILE=="FL_E2080"   ? FL_E2080
        : PROFILE=="FL_E3030"   ? FL_E3030
        : PROFILE=="FL_E3060"   ? FL_E3060
        : PROFILE=="FL_E4040"   ? FL_E4040
        : PROFILE=="FL_E4040t"  ? FL_E4040t
        : FL_E4080;

fl_tprofile(verbs,profile,LENGTH,CORNER_HOLE,debug,direction,octant);
