/*
 * T-slot structural framing tests.
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
SHOW_DIMENSIONS = false;


/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
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



/* [T Profile] */

PROFILE     = "E1515"; // [E1515,E2020,E2020t,E2040,E2060,E2080,E3030,E3060,E4040,E4040t,E4080]
LENGTH      = 50;
CORNER_HOLE = false;


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS,dimensions=SHOW_DIMENSIONS);

fl_status();

// end of automatically generated code

verbs=[
  if ($FL_ADD!="OFF")       FL_ADD,
  if ($FL_AXES!="OFF")      FL_AXES,
  if ($FL_BBOX!="OFF")      FL_BBOX,
  if ($FL_FOOTPRINT!="OFF") FL_FOOTPRINT,
];

xsec  = PROFILE=="E1515"   ? FL_TSP_E1515
      : PROFILE=="E2020"   ? FL_TSP_E2020
      : PROFILE=="E2020t"  ? FL_TSP_E2020t
      : PROFILE=="E2040"   ? FL_TSP_E2040
      : PROFILE=="E2060"   ? FL_TSP_E2060
      : PROFILE=="E2080"   ? FL_TSP_E2080
      : PROFILE=="E3030"   ? FL_TSP_E3030
      : PROFILE=="E3060"   ? FL_TSP_E3060
      : PROFILE=="E4040"   ? FL_TSP_E4040
      : PROFILE=="E4040t"  ? FL_TSP_E4040t
      : FL_TSP_E4080;

profile = fl_tsp_TProfile(xsec,LENGTH);

fl_tProfile(verbs,profile,debug=debug,direction=direction,octant=octant);
