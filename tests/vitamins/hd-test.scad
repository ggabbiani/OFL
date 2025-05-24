/*
 * Test file for hard disk
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/vitamins/hds.scad>


$fn            = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER     = false;
// Default color for printable items (i.e. artifacts)
$fl_filament   = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]


/* [Debug] */

// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES        = -2;     // [-2:10]
DEBUG_ASSERTIONS  = false;
DEBUG_COMPONENTS  = ["none"];
DEBUG_COLOR       = false;
DEBUG_DIMENSIONS  = false;
DEBUG_LABELS      = false;
DEBUG_SYMBOLS     = false;


/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// add predefined component shape(s)
$FL_ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// draw of local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
$FL_CUTOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
$FL_FOOTPRINT = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// mount shape through predefined screws
$FL_MOUNT     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


/* [3D Placement] */

X_PLACE = "undef";  // [undef,-1,0,+1]
Y_PLACE = "undef";  // [undef,-1,0,+1]
Z_PLACE = "undef";  // [undef,-1,0,+1]


/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [-360:360]



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

// FL_DRILL and FL_CUTOUT tolerance (fl_JNgauge=0.15mm)
TOLERANCE   = 0.15; // [-2:.05:2]
// faces to be used during children layout
LAY_DIRECTION     = ["-X","+X","-Z"];
// FL_CUTOUT drift
DRIFT=0;  // [0:0.5:2]

/* [Hidden] */


$dbg_Assert     = DEBUG_ASSERTIONS;
$dbg_Dimensions = DEBUG_DIMENSIONS;
$dbg_Color      = DEBUG_COLOR;
$dbg_Components = DEBUG_COMPONENTS[0]=="none" ? undef : DEBUG_COMPONENTS;
$dbg_Labels     = DEBUG_LABELS;
$dbg_Symbols    = DEBUG_SYMBOLS;


direction       = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant          = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);

fl_status();

// end of automatically generated code

verbs   = fl_verbList([FL_ADD,FL_ASSEMBLY,FL_AXES,FL_BBOX,FL_CUTOUT,FL_DRILL,FL_FOOTPRINT,FL_LAYOUT,FL_MOUNT]);
hd      = FL_HD_EVO860;
// thickness matrix built from customizer values
T       = [T_x,T_y,T_z];
// 'NIL' list to be added to children thickness in order to avoid 'z' fighting problem during preview
T_NIL   = [[NIL,NIL],[NIL,NIL],[NIL,NIL]];
// thickness list built from customizer values
rail    = [Rail_x,Rail_y,Rail_z];

hd_ctor = fl_connectors(hd)[0];

lay_dir = fl_3d_AxisList(LAY_DIRECTION);
fl_trace("lay_dir",lay_dir);

fl_hd(verbs,hd,cut_drift=DRIFT,$fl_tolerance=TOLERANCE,$fl_thickness=T,lay_direction=lay_dir,dri_rails=rail,direction=direction,octant=octant)
  fl_cylinder(h=$hd_screw_len,d=$hole_d,direction=$hole_direction,octant=-Z);
