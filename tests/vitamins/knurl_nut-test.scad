/*
 * Knurl nut (aka brass inserts) test file
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/vitamins/knurl_nuts.scad>


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


/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
$FL_ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


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


/* [Knurl nut] */

SHOW    = "All"; // [All, FL_KNUT_M2x4x3p5, FL_KNUT_M2x6x3p5,  FL_KNUT_M2x8x3p5,  FL_KNUT_M2x10x3p5, FL_KNUT_M3x4x5,   FL_KNUT_M3x6x5,    FL_KNUT_M3x8x5,    FL_KNUT_M3x10x5, FL_KNUT_M4x4x6,   FL_KNUT_M4x6x6,    FL_KNUT_M4x8x6,    FL_KNUT_M4x10x6,FL_KNUT_M5x6x7,   FL_KNUT_M5x8x7,    FL_KNUT_M5x10x7]


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// end of automatically generated code

obj   = fl_switch(SHOW,cases=[
  ["FL_KNUT_M2x4x3p5",  FL_KNUT_M2x4x3p5],
  ["FL_KNUT_M2x6x3p5",  FL_KNUT_M2x6x3p5],
  ["FL_KNUT_M2x8x3p5",  FL_KNUT_M2x8x3p5],
  ["FL_KNUT_M2x10x3p5", FL_KNUT_M2x10x3p5],
  ["FL_KNUT_M3x4x5",    FL_KNUT_M3x4x5],
  ["FL_KNUT_M3x6x5",    FL_KNUT_M3x6x5],
  ["FL_KNUT_M3x8x5",    FL_KNUT_M3x8x5],
  ["FL_KNUT_M3x10x5",   FL_KNUT_M3x10x5],
  ["FL_KNUT_M4x4x6",    FL_KNUT_M4x4x6],
  ["FL_KNUT_M4x6x6",    FL_KNUT_M4x6x6],
  ["FL_KNUT_M4x8x6",    FL_KNUT_M4x8x6],
  ["FL_KNUT_M4x10x6",   FL_KNUT_M4x10x6],
  ["FL_KNUT_M5x6x7",    FL_KNUT_M5x6x7],
  ["FL_KNUT_M5x8x7",    FL_KNUT_M5x8x7],
  ["FL_KNUT_M5x10x7",   FL_KNUT_M5x10x7]
]);
verbs = fl_verbList([FL_ADD,FL_ASSEMBLY,FL_AXES,FL_BBOX,FL_DRILL]);

if (obj)
  fl_knut(verbs,obj,octant=octant,direction=direction);
else {
  // build a dictionary with rows constituted by items with equal internal thread
  dict  = fl_dict_organize(FL_KNUT_DICT,[2:5],function(nut) 2*screw_radius(fl_screw(nut)));
  for(i=[0:len(dict)-1]) let(row=dict[i],l=len(row))
    translate(fl_Y(12*i))
      fl_layout(axis=+FL_X,gap=3,types=row)
        fl_knut(verbs,$item,octant=octant,direction=direction);
}
