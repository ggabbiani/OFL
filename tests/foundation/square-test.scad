/*
 * 2d square test.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../lib/OFL/foundation/core.scad>

use <../../lib/OFL/foundation/2d-engine.scad>

$fn         = 5000;           // [3:10000]
// Debug statements are turned on
$fl_debug   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// Default color for printable items (i.e. artifacts)
$fl_filament  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]

/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD   = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
QUADRANT      = [0,0];  // [-1:+1]

/* [Square] */

// primitive used
MODE      = "square";  // ["frame", "square"]

// overall size of the rectangle
SIZE      = [15,10];
// Quadrant I
CORNER_0  = [6,3];
// Quadrant II
CORNER_1  = [2,2];
// Quadrant III
CORNER_2  = [3,6];
// Quadrant IV
CORNER_3  = [0,0];

// frame thickness
T = 2.5;  // [0.1:0.1:5]

/* [Hidden] */

$vpr = [0, 0, 0];
$vpt = [0.371305, 0.380909, 0.268921];
$vpd = 43.9335;
$vpf = 22.5;

// echo($vpr=$vpr);
// echo($vpt=$vpt);
// echo($vpd=$vpd);
// echo($vpf=$vpf);

quadrant  = PLACE_NATIVE  ? undef : QUADRANT;
verbs=[
  if ($FL_ADD!="OFF")   FL_ADD,
  if ($FL_AXES!="OFF")  FL_AXES,
  if ($FL_BBOX!="OFF")  FL_BBOX,
];
corners  = [CORNER_0,CORNER_1,CORNER_2,CORNER_3];

if (MODE=="square") fl_square(verbs,size=SIZE,corners=corners,quadrant=quadrant);
else fl_2d_frame(verbs,size=SIZE,corners=corners,thick=T,quadrant=quadrant);
