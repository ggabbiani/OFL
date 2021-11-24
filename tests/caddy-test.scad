/*
 * Caddy test file.
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
use     <../caddy.scad>

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
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
CUTOUT    = "OFF";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
FPRINT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
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

/* [Caddy] */
// wall thickness on X semi-axes (-X,+X)
T_x   = [2.5,2.5];  // [0:0.1:10]
// wall thickness on Y semi-axes (-Y,+Y)
T_y   = [2.5,2.5];  // [0:0.1:10]
// wall thickness on Z semi-axes (-Z,+Z)
T_z   = [2.5,2.5];  // [0:0.1:10]
FACES = ["+X","-X","-Z"];

// CUT OUT tolerance
CO_TOLERANCE  = 0.5;
// Internal tolerance (fl_JNgauge=0.15mm)
TOLERANCE     = 0.15;
// fillet radius
FILLET_R      = 0;  // [0:0.1:5]

/* [Hidden] */
// converts a list of strings into a list of their represented axes
// TODO: insert the function in OFL defs?
function s2axes(slist) = 
  [for(s=slist)
    assert(s=="+X"||s=="-X"||s=="+Y"||s=="-Y"||s=="+Z"||s=="-Z",str("Invalid value '",s,"'"))
    (s=="+X") ? +FL_X : (s=="-X") ? -FL_X : (s=="+Y") ? +FL_Y : (s=="-Y") ? -FL_Y : (s=="+Z") ? +FL_Z : -FL_Z];

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
verbs=[
  if (ADD!="OFF")       FL_ADD,
  if (ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if (AXES!="OFF")      FL_AXES,
  if (BBOX!="OFF")      FL_BBOX,
  if (CUTOUT!="OFF")    FL_CUTOUT,
  if (DRILL!="OFF")     FL_DRILL,
  if (FPRINT!="OFF")    FL_FOOTPRINT,
  if (LAYOUT!="OFF")    FL_LAYOUT,
  if (PLOAD!="OFF")     FL_PAYLOAD,
];

faces     = s2axes(FACES);
medium    = FL_PCB_RPI4;
T         = [T_x,T_y,T_z];
tolerance = [[TOLERANCE+FILLET_R+FL_NIL,TOLERANCE+FILLET_R+FL_NIL],[TOLERANCE+FILLET_R+FL_NIL,TOLERANCE+FILLET_R+FL_NIL],[TOLERANCE+FL_NIL,TOLERANCE+FL_NIL]];

fl_trace("faces",faces);

// $FL_ADD=ADD;$FL_ASSEMBLY=ASSEMBLY;$FL_AXES=AXES;$FL_BBOX=BBOX;$FL_CUTOUT=CUTOUT;$FL_DRILL=DRILL;$FL_FOOTPRINT=FPRINT;$FL_LAYOUT=LAYOUT;$FL_PAYLOAD=PLOAD;
fl_caddy(verbs,medium,thick=T,faces=faces,tolerance=TOLERANCE,fillet=FILLET_R,direction=direction,octant=octant,
  $FL_ADD=ADD,$FL_ASSEMBLY=ASSEMBLY,$FL_AXES=AXES,$FL_BBOX=BBOX,$FL_CUTOUT=CUTOUT,$FL_DRILL=DRILL,$FL_FOOTPRINT=FPRINT,$FL_LAYOUT=LAYOUT,$FL_PAYLOAD=PLOAD)
  fl_pcb($verb,medium,thick=T+tolerance,co_by_direction=faces,co_tolerance=CO_TOLERANCE,$FL_TRACE=TRACE);
