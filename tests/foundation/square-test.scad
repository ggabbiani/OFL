/*
 * 2d square test.
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
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
include <../../foundation/unsafe_defs.scad>
include <../../foundation/incs.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

$FL_FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Supported verbs] */

// adds shapes to scene.
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
QUADRANT      = [0,0];  // [-1:+1]

/* [Square] */

// overall size of the rectangle
SIZE      = [2,1];
// one radius for each vertex
VERTICES  = [0,0,0,0];  // [0:0.1:10]

/* [Hidden] */

$vpr  = [0, 0, 0];
$vpt  = [0, 0, 0];
$vpd  = 5.73;
$vpf  = 22.5;

quadrant  = PLACE_NATIVE  ? undef : QUADRANT;
verbs=[
  if (ADD!="OFF")       FL_ADD,
  if (AXES!="OFF")      FL_AXES,
  if (BBOX!="OFF")      FL_BBOX,
];

// $FL_ADD=ADD;$FL_ASSEMBLY=ASSEMBLY;$FL_AXES=AXES;$FL_BBOX=BBOX;$FL_CUTOUT=CUTOUT;$FL_DRILL=DRILL;$FL_FOOTPRINT=FPRINT;$FL_LAYOUT=LAYOUT;$FL_PAYLOAD=PLOAD;
fl_square(
  verbs,
  size=SIZE,vertices=VERTICES,
  quadrant=quadrant,
  $FL_ADD=ADD,$FL_AXES=AXES,$FL_BBOX=BBOX
);
