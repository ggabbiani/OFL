/*
 * Fillet primitives.
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

RADIUS  = 1;
LENGTH  = 10;

/* [Round fillet] */

ROUND_RADIUS  = 1;
ROUND_STEPS   = 10;
CHILD_SIZE    = [1,2];

/* [Hidden] */

CHILD_BBOX=[O,CHILD_SIZE];

module __test__() {
  direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
  octant    = PLACE_NATIVE  ? undef : OCTANT;
  verbs=[
    if (ADD!="OFF")   FL_ADD,
    if (AXES!="OFF")  FL_AXES,
    if (BBOX!="OFF")  FL_BBOX,
  ];
  fl_trace("PLACE_NATIVE",PLACE_NATIVE);
  fl_trace("octant",octant);

  if (TEST=="linear")
    fl_fillet(verbs,r=RADIUS,h=LENGTH,octant=octant,direction=direction,
              $FL_ADD=ADD,$FL_AXES=AXES,$FL_BBOX=BBOX);
  else 
    fl_90DegFillet(verbs,r=ROUND_RADIUS,n=ROUND_STEPS,child_bbox=CHILD_BBOX,octant=octant,direction=direction,
                    $FL_ADD=ADD,$FL_AXES=AXES,$FL_BBOX=BBOX)
      square(size=CHILD_SIZE);
}

__test__();