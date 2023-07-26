/*
 * Draw.io helpers.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../foundation/defs.scad>

use <../../foundation/drawio.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$fl_debug   = false;
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

/* [Placement] */

PLACE_NATIVE  = true;
QUADRANT      = [+1,+1];  // [-1:+1]

/* [Draw.io] */

POLYCOORDS  = [[0.25,0],[0.75,0],[0.4,0.7],[0.6,0.7],[0.75,1],[0.25,1],[0.3,0.7],[0.2,0.5]];
SIZE        = [100,100];

/* [Hidden] */

verbs = [
  if ($FL_ADD!="OFF")   FL_ADD,
  if ($FL_AXES!="OFF")  FL_AXES,
  if ($FL_BBOX!="OFF")  FL_BBOX,
];
quadrant  = PLACE_NATIVE ? undef : QUADRANT;
dio_polyCoords(verbs, POLYCOORDS, SIZE, quadrant);
