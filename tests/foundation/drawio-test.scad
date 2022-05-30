/*
 * Draw.io helpers.
 *
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL).
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

include <../../foundation/drawio.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, trace messages are turned on
$fl_traces   = false;

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
