/*
 * PSU test.
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'Raspberry PI4' (RPI4) project.
 *
 * RPI4 is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * RPI4 is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with RPI4.  If not, see <http: //www.gnu.org/licenses/>.
 */

include <../../foundation/unsafe_defs.scad>
include <../../vitamins/psus.scad>

// include <../../vitamins/incs.scad>

$fn         = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
TRACE       = false;

$FL_FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Supported verbs] */

// adds shapes to scene.
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [PSU] */

SHOW        = "ALL"; // [ALL, PSU_MeanWell_RS_25_5, PSU_MeanWell_RS_15_5]

// Holder thickness
T           = 2.5;
// Assembly flags
SCREW_MODE  = ["-Z","+X","+Y"];

/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
verbs = [
  if (ADD!="OFF")       FL_ADD,
  if (ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if (AXES!="OFF")      FL_AXES,
  if (BBOX!="OFF")      FL_BBOX,
  if (DRILL!="OFF")     FL_DRILL,
];

// target object(s)
single  = SHOW=="PSU_MeanWell_RS_25_5"  ? PSU_MeanWell_RS_25_5 
        : SHOW=="PSU_MeanWell_RS_15_5"  ? PSU_MeanWell_RS_15_5 
        : undef;

// $FL_CUTOUT=CUTOUT;$FL_FOOTPRINT=FPRINT;$FL_PAYLOAD=PLOAD;

if (single)
  ofl_psu(verbs,single,thick=T,assembly=SCREW_MODE,octant=octant,direction=direction,
  $FL_TRACE=TRACE,
    $FL_ADD=ADD,$FL_ASSEMBLY=ASSEMBLY,$FL_AXES=AXES,$FL_BBOX=BBOX,$FL_DRILL=DRILL);
else
  fl_layout(FL_LAYOUT,+X,20,FL_PSU_DICT) 
    let(type=FL_PSU_DICT[$i])
      ofl_psu(verbs,type,thick=T,assembly=SCREW_MODE,octant=octant,direction=direction,
        $FL_TRACE=TRACE,
        $FL_ADD=ADD,$FL_ASSEMBLY=ASSEMBLY,$FL_AXES=AXES,$FL_BBOX=BBOX,$FL_DRILL=DRILL);
