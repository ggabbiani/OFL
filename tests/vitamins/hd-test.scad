/*
 * Test file for hard disk.
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
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

include <../../vitamins/hds.scad>

include <../../foundation/type_trait.scad>
include <../../vitamins/sata-adapters.scad>
include <../../foundation/unsafe_defs.scad>
use     <../../caddy.scad>
use     <../../vitamins/screw.scad>

// include <OFL/foundation/incs.scad>
// use     <OFL/foundation/util.scad>

$fn         = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
TRACE   = false;

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
// adds a footprint to scene, usually a simplified FL_ADD
FPRINT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [ Thickness ] */

// thickness on X semi-axes (-X,+X)
T_x   = [2.5,2.5];  // [0:0.1:10]
// thickness on Y semi-axes (-Y,+Y)
T_y   = [2.5,2.5];  // [0:0.1:10]
// thickness on Z semi-axes (-Z,+Z)
T_z   = [2.5,2.5];  // [0:0.1:10]

/* [ Rails (FL_DRILL) ] */

// [-X,+X]
Rail_x   = [0,0];  // [0:0.1:10]
// [-Y,+Y]
Rail_y   = [0,0];  // [0:0.1:10]
// [-Z,+Z]
Rail_z   = [0,0];  // [0:0.1:10]

/* [ Hard Disk ] */

SHOW_CONNECTORS = false;

// FL_DRILL tolerance (fl_JNgauge=0.15mm)
DRI_TOLERANCE   = 0.15;
// faces to be used during children layout
LAY_DIRECTION     = ["-X","+X","-Z"];

/* [Hidden] */

hd        = HD_EVO860;
direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
verbs=[
  if (ADD!="OFF")       FL_ADD,
  if (ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if (AXES!="OFF")      FL_AXES,
  if (BBOX!="OFF")      FL_BBOX,
  if (DRILL!="OFF")     FL_DRILL,
  if (FPRINT!="OFF")    FL_FOOTPRINT,
  if (LAYOUT!="OFF")    FL_LAYOUT,
];

// $FL_ADD=ADD;$FL_ASSEMBLY=ASSEMBLY;$FL_AXES=AXES;$FL_BBOX=BBOX;$FL_CUTOUT=CUTOUT;$FL_LAYOUT=LAYOUT;$FL_PAYLOAD=PLOAD;

// thickness matrix built from customizer values
T         = [T_x,T_y,T_z];
// 'NIL' list to be added to children thickness in order to avoid 'z' fighting problem during preview
T_NIL     = [[NIL,NIL],[NIL,NIL],[NIL,NIL]];
// thickness list built from customizer values
rail      = [Rail_x,Rail_y,Rail_z];

hd_ctor   = fl_connectors(hd)[0];
adp       = FL_SADP_ELUTENG;
adp_ctor  = fl_connectors(adp)[0];

lay_dir     = fl_str_2axes(LAY_DIRECTION);
fl_trace("lay_dir",lay_dir);

fl_hd( verbs,hd,
    dri_tolerance=DRI_TOLERANCE,thick=T,lay_direction=lay_dir,add_connectors=SHOW_CONNECTORS,dri_rails=rail,direction=direction,octant=octant,
    $FL_TRACE=TRACE,
    $FL_ADD=ADD,$FL_ASSEMBLY=ASSEMBLY,$FL_AXES=AXES,$FL_BBOX=BBOX,$FL_DRILL=DRILL,$FL_FOOTPRINT=FPRINT,$FL_LAYOUT=LAYOUT)
  // fl_screw(type=M3_cap_screw,len=$length,direction=$direction);
  fl_cylinder(h=$length,r=screw_radius(fl_screw(hd)),direction=$direction,octant=-Z);
