/*
 * Test file for hard disk.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../lib/OFL/vitamins/hds.scad>
// include <../../lib/OFL/vitamins/sata-adapters.scad>
// include <../../lib/OFL/vitamins/screw.scad>

$fn         = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// Default color for printable items (i.e. artifacts)
$fl_filament  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]

/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// add predefined component shape(s)
$FL_ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// draw of local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
$FL_FOOTPRINT = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// mount shape through predefined screws
$FL_MOUNT     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

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

// rail along [-X,+X] faces
Rail_x   = [0,0];  // [0:0.1:10]
// rail along [-Y,+Y] faces
Rail_y   = [0,0];  // [0:0.1:10]
// rail along [-Z,+Z] faces
Rail_z   = [0,0];  // [0:0.1:10]

/* [ Hard Disk ] */

SHOW_CONNECTORS = false;

// FL_DRILL tolerance (fl_JNgauge=0.15mm)
DRI_TOLERANCE   = 0.15;
// faces to be used during children layout
LAY_DIRECTION     = ["-X","+X","-Z"];

/* [Hidden] */

hd        = FL_HD_EVO860;
direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
verbs=[
  if ($FL_ADD!="OFF")       FL_ADD,
  if ($FL_ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if ($FL_AXES!="OFF")      FL_AXES,
  if ($FL_BBOX!="OFF")      FL_BBOX,
  if ($FL_DRILL!="OFF")     FL_DRILL,
  if ($FL_FOOTPRINT!="OFF") FL_FOOTPRINT,
  if ($FL_LAYOUT!="OFF")    FL_LAYOUT,
  if ($FL_MOUNT!="OFF")     FL_MOUNT,
];

// thickness matrix built from customizer values
T         = [T_x,T_y,T_z];
// 'NIL' list to be added to children thickness in order to avoid 'z' fighting problem during preview
T_NIL     = [[NIL,NIL],[NIL,NIL],[NIL,NIL]];
// thickness list built from customizer values
rail      = [Rail_x,Rail_y,Rail_z];

hd_ctor   = fl_connectors(hd)[0];

lay_dir     = fl_3d_AxisList(LAY_DIRECTION);
fl_trace("lay_dir",lay_dir);

fl_hd(verbs,hd,dri_tolerance=DRI_TOLERANCE,thick=T,lay_direction=lay_dir,add_connectors=SHOW_CONNECTORS,dri_rails=rail,direction=direction,octant=octant)
  fl_cylinder(h=$hd_screw_len,d=$hole_d,direction=$hole_direction,octant=-Z);

