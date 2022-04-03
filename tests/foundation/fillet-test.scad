/*
 * Fillet primitives.
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

include <../../foundation/fillet.scad>

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
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [+1,+1,+1];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Fillets] */

// choose one test
TEST="linear"; // [linear,round]

/* [Linear fillet] */

LINEAR_TYPE = "fillet"; // [fillet,hFillet,vFillet]

R_x     = 1;  // [0:10]
R_y     = 1;  // [0:10]
LENGTH  = 10;

/* [Round fillet] */

ROUND_RADIUS  = 1;
ROUND_STEPS   = 10;
CHILD_SIZE    = [1,2];

/* [Hidden] */

CHILD_BBOX=[O,CHILD_SIZE];

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
verbs=[
  if ($FL_ADD!="OFF")   FL_ADD,
  if ($FL_AXES!="OFF")  FL_AXES,
  if ($FL_BBOX!="OFF")  FL_BBOX,
];
fl_trace("PLACE_NATIVE",PLACE_NATIVE);
fl_trace("octant",octant);

module linear_wrpper() {
  if (LINEAR_TYPE=="fillet")
    fl_fillet(verbs,rx=R_x,ry=R_y,h=LENGTH,octant=octant,direction=direction);
  else if (LINEAR_TYPE=="hFillet")
    fl_hFillet(verbs,rx=R_x,ry=R_y,h=LENGTH,octant=octant,direction=direction);
  else if (LINEAR_TYPE=="vFillet")
    fl_vFillet(verbs,rx=R_x,ry=R_y,h=LENGTH,octant=octant,direction=direction);
}

if (TEST=="linear")
  linear_wrpper();
else
  fl_90DegFillet(verbs,r=ROUND_RADIUS,n=ROUND_STEPS,child_bbox=CHILD_BBOX,octant=octant,direction=direction)
    square(size=CHILD_SIZE);
