/*
 * Box artifact test.
 *
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

include <../foundation/unsafe_defs.scad>
include <../foundation/incs.scad>
include <../vitamins/incs.scad>
use     <../box.scad>

$fn         = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

FILAMENT_UPPER  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
FILAMENT_LOWER  = "SteelBlue";  // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Supported verbs] */

// adds shapes to scene.
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a box representing the payload of the shape
PLOAD     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Parts] */

UPPER_PART  = true;
LOWER_PART  = true;

/* [Box] */

// thickness 
T         = 2.5;
// inner radius for rounded angles (square if undef)
RADIUS    = 1.1;
EXPLODE   = 7.5;
TOLERANCE = 0.3;
FILLET    = false;

// Internal payload size
PAY_SIZE  = [100,60,40];

/* [Hidden] */

module __test__() {
  direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
  octant    = PLACE_NATIVE  ? undef : OCTANT;
  verbs=[
    if (ADD!="OFF")       FL_ADD,
    if (ASSEMBLY!="OFF")  FL_ASSEMBLY,
    if (AXES!="OFF")      FL_AXES,
    if (BBOX!="OFF")      FL_BBOX,
    if (PLOAD!="OFF")     FL_PAYLOAD,
  ];
  $FL_ADD       = ADD;
  $FL_ASSEMBLY  = ASSEMBLY;
  $FL_AXES      = AXES;
  $FL_BBOX      = BBOX;
  $FL_PAYLOAD   = PLOAD;

  radius  = RADIUS!=0 ? RADIUS : undef;

  PARTS = (LOWER_PART && UPPER_PART) ? "all" 
        : LOWER_PART ? "lower" 
        : UPPER_PART ? "upper"
        : "none";

  TREAL = T + TOLERANCE;

  Tpl=fl_T([TREAL,TREAL,T+TOLERANCE]);

  size  = PAY_SIZE+[2*TREAL,2*TREAL,2*TREAL];

  fl_trace("$FL_ADD",$FL_ADD);
  fl_trace("external size",size);
  // fl_placeIf(!PLACE_NATIVE,octant=OCTANT,bbox=[-size/2,+size/2])
  fl_box(verbs,psize=PAY_SIZE,thick=T,radius=radius,parts=PARTS,material_upper=FILAMENT_UPPER,material_lower=FILAMENT_LOWER,tolerance=TOLERANCE,fillet=FILLET,octant=octant,direction=direction,
  $FL_PAYLOAD=PLOAD);
}

__test__();
