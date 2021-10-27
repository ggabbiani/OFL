/*
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org).
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

FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Supported verbs] */

// adds shapes to scene.
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
FPRINT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [+1,+1,+1];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Commons] */

// thickness 
T         = 2.5;
// Type
TYPE    = "Profile";     // ["Profile", "Bent plate"]
SIZE    = [150,40,200]; // [1:0.1:100] 
// radius in case of rounded angles (square if 0)
RADIUS  = 1.1;
SECTION = "L"; // ["E", "L", "T", "U"]

/* [Hidden] */

module __test__() {
  direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
  octant    = PLACE_NATIVE  ? undef : OCTANT;
  verbs=[
    if (ADD!="OFF")     FL_ADD,
    if (AXES!="OFF")    FL_AXES,
    if (BBOX!="OFF")    FL_BBOX,
    if (FPRINT!="OFF")  FL_FOOTPRINT,
  ];
  radius  = RADIUS!=0 ? RADIUS : undef;
  fl_trace("TYPE",TYPE);

  $FL_ADD=ADD;$FL_AXES=AXES;$FL_BBOX=BBOX;$FL_FOOTPRINT=FPRINT;
  if (TYPE=="Profile")
    fl_profile(verbs,type=SECTION,size=SIZE,thick=T,radius=radius,material=FILAMENT,octant=octant,direction=direction);
  else
    fl_bentPlate(verbs,type=SECTION,size=SIZE,thick=T,radius=radius,material=FILAMENT,octant=octant,direction=direction);
}

__test__();