/*
 * Dimension lines test
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
VIEW_TYPE     = "other";  // [other,right,top,bottom,left]
DISTRIBUTION  = "+x"; // [-x,+x,-y,+y,-z,+z]
ALIGN         = "positive"; // [centered,positive,negative]
$DIM_MODE     = "full"; // [full,label,value,silent]
$DIM_GAP      = 1;  // [1:.1:10]

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

dim_r = fl_Dimension(value=d/2,  label="r");
dim_d = fl_Dimension(value=d,    label="d");
dim_h = fl_Dimension(value=h,    label="h");

$vpr = fl_view(VIEW_TYPE);

distribution  = fl_3d_AxisList([DISTRIBUTION])[0];

fl_dimension(verbs,dim_r,
  view="top",
  gap=1,
  align=ALIGN,
  object=cyl,
  spread=distribution,
  line_width=line_w
) fl_dimension(verbs,geometry=dim_d,align="centered")
    fl_dimension(verbs,geometry=dim_d,align=-1.5);

fl_dimension(verbs,dim_h,
  align=ALIGN,
  spread=distribution,
  gap=1,
  line_width=line_w,
  object=cyl,
  view="right"
);

// fl_dimension(verbs,view="top",geometry=dim_r,gap=1,align="+",object=cyl,spread=-Y,line_width=line_w,debug=debug)
//   fl_dimension(verbs,geometry=dim_d,align="centered")
//     fl_dimension(verbs,geometry=dim_d,align=-1.5);

// fl_dimension(verbs,view="top",geometry=dim_r,gap=1,align=-X,object=cyl,spread=+Y,line_width=line_w,debug=debug);
// fl_dimension(verbs,view="top",geometry=dim_r,gap=1,align=+Y,object=cyl,spread=+X,line_width=line_w,debug=debug);
// fl_dimension(verbs,view="top",geometry=dim_r,gap=1,align=-Y,object=cyl,spread=-X,line_width=line_w,debug=debug);

// fl_dimension(verbs,view="top",geometry=dim_r,gap=1,align=+X,object=cyl,spread=-Y,line_width=line_w)
//   fl_dimension(verbs,geometry=dim_d,align=O);
// fl_dimension(verbs,geometry=dim_h,gap=1,align=+Y,object=cyl,spread=+X,line_width=line_w,view="right");
// fl_dimension(verbs,geometry=dim_h,gap=1,align=+Y,object=cyl,spread=+X,line_width=line_w,view="left");

fl_cylinder(h=h,d=d,$fn=100,$FL_ADD="DEBUG");
