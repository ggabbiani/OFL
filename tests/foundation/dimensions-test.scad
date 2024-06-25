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




/* [Dimension Lines] */
VIEW_TYPE     = "other";    // [other,right,top,bottom,left,front,back]
DIM_MODE      = "full";     // [full,label,value,silent]
DIM_GAP       = 1;          // [1:.1:10]
DIM_W         = 0.1;        // [0.1:0.1:1]



/* [Hidden] */

debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS,dimensions=SHOW_DIMENSIONS);

fl_status();

// end of automatically generated code

verbs   = fl_verbList([FL_ADD,FL_BBOX]);

d       = 4;
h       = 10;
cyl     = fl_cylinder_defaults(h=h,d=d);

dim_r = fl_Dimension(value=d/2,  label="r");
dim_d = fl_Dimension(value=d,    label="d");
dim_h = fl_Dimension(value=h,    label="h");

$vpr = fl_view(VIEW_TYPE);

fl_cylinder(h=h,d=d,$fn=100,$FL_ADD="ON");

if (fl_parm_dimensions(debug)) {
  fl_dimension(verbs,dim_r,
    view="top",
    gap=DIM_GAP,
    align="positive",
    object=cyl,
    distr="h+",
    line_width=DIM_W,
    mode=DIM_MODE
  ) fl_dimension(verbs,geometry=dim_d,align="centered")
      fl_dimension(verbs,geometry=dim_d,align=-1.5);

  let($dim_view="right") {
    fl_dimension(verbs,dim_h,
      gap=DIM_GAP,
      align="positive",
      object=cyl,
      distr="h+",
      line_width=DIM_W,
      mode=DIM_MODE
    );

    fl_dimension(verbs,dim_r,
      gap=DIM_GAP,
      align="positive",
      object=cyl,
      distr="v+",
      line_width=DIM_W,
      mode=DIM_MODE
    );
  }
  let($dim_view="front") {
    fl_dimension(verbs,dim_h,
      gap=DIM_GAP,
      align="positive",
      object=cyl,
      distr="h+",
      line_width=DIM_W,
      mode=DIM_MODE
    );

    fl_dimension(verbs,dim_r,
      gap=DIM_GAP,
      align="positive",
      object=cyl,
      distr="v+",
      line_width=DIM_W,
      mode=DIM_MODE
    );
  }
}
