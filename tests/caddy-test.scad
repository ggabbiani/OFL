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
// include <../foundation/incs.scad>
include <../vitamins/hds.scad>
include <../vitamins/pcbs.scad>
include <../caddy.scad>

$fn         = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE       = false;

$FL_FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
$FL_ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
$FL_CUTOUT    = "OFF";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
$FL_FPRINT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a box representing the payload of the shape
$FL_PLOAD     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

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
// the media to be contained
MEDIUM  = "Raspberry PI4";  // [Raspberry PI4,Hard Disk]
// wall thickness on X semi-axes (-X,+X)
T_x   = [2.5,2.5];  // [0:0.1:10]
// wall thickness on Y semi-axes (-Y,+Y)
T_y   = [2.5,2.5];  // [0:0.1:10]
// wall thickness on Z semi-axes (-Z,+Z)
T_z   = [2.5,2.5];  // [0:0.1:10]

FACES = ["+X","-X","-Z"];

// CUT OUT tolerance
CUT_TOLERANCE = 0.5;
// Internal tolerance (fl_JNgauge=0.15mm)
TOLERANCE     = 0.15;
// fillet radius
FILLET_R      = 0;  // [0:0.1:5]

/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
verbs=[
  if ($FL_ADD!="OFF")       FL_ADD,
  if ($FL_ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if ($FL_AXES!="OFF")      FL_AXES,
  if ($FL_BBOX!="OFF")      FL_BBOX,
  if ($FL_CUTOUT!="OFF")    FL_CUTOUT,
  if ($FL_DRILL!="OFF")     FL_DRILL,
  if ($FL_FPRINT!="OFF")    FL_FOOTPRINT,
  if ($FL_LAYOUT!="OFF")    FL_LAYOUT,
  if ($FL_PLOAD!="OFF")     FL_PAYLOAD,
];
// list of normals to faces
faces     = fl_str_2axes(FACES);
// the carried item
medium    = MEDIUM=="Raspberry PI4" ? FL_PCB_RPI4 : HD_EVO860;
// thickness list built from customizer values
T         = [T_x,T_y,T_z];
// 'NIL' list to be added to children thickness in order to avoid 'z' fighting problem during preview
T_NIL     = [[NIL,NIL],[NIL,NIL],[NIL,NIL]];

fl_trace("faces",faces);

fl_caddy(verbs,medium,thick=T,faces=faces,tolerance=TOLERANCE,fillet=FILLET_R,direction=direction,octant=octant)
  // the children is called with the following special variables set:
  // $verbs ⇒ list of verbs to be executed
  // $thick ⇒ thickness list for DRILL and CUTOUT
  if (medium==FL_PCB_RPI4) fl_pcb($verbs,medium,thick=$thick+T_NIL,cut_direction=faces,cut_tolerance=CUT_TOLERANCE,$FL_DRILL="ON",$FL_CUTOUT="ON");
  else                     fl_hd($verbs,medium,thick=$thick+T_NIL,lay_direction=faces,dri_tolerance=TOLERANCE,$FL_DRILL="ON",$FL_CUTOUT="ON");
      // fl_screw(type=M3_cap_screw,len=$length,direction=$direction);
      // fl_cylinder(h=$length,r=screw_radius(fl_screw(hd)),direction=$direction,octant=-Z);
