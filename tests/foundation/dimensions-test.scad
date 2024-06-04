/*
 *
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


include <../../lib/OFL/foundation/dimensions.scad>


$fn            = 50;           // [3:100]
// When true, debug statements are turned on
$fl_debug      = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER     = false;
// Default color for printable items (i.e. artifacts)
$fl_filament   = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES     = -2;     // [-2:10]
SHOW_LABELS     = false;
SHOW_SYMBOLS    = false;
SHOW_DIMENSIONS = false;


/* [Supported verbs] */
// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


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


/* [Dimension Lines] */
$DIM_MODE      = "full"; // [full,label,value,silent]
$DIM_GAP       = 1;  // [1:.1:10]
VIEW_TYPE      = "other";  // [other,right,top,bottom,left]



/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// end of automatically generated code

verbs   = fl_verbList([FL_ADD,FL_BBOX]);

d       = 4;
h       = 10;
cyl     = fl_cylinder_defaults(h=h,d=d);
line_w  = 0.1;

dim_radius    = fl_Dimension(value=d/2,  label="radius",   object=cyl, spread=-Y, line_width=line_w);
dim_diameter  = fl_Dimension(value=d,    label="diameter", object=cyl, spread=-Y, line_width=line_w);
dim_height    = fl_Dimension(value=h,    label="height",   object=cyl, spread=+X, line_width=line_w, view="right");

$vpr = fl_view(VIEW_TYPE);

fl_dimension(verbs,geometry=dim_radius,align=+X)
  fl_dimension(verbs,geometry=dim_diameter);
fl_dimension(verbs,geometry=dim_height,align=+Y,direction=[+X,90]);

fl_cylinder(h=h,d=d,$fn=100);
