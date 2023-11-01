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

include <../../lib/OFL/vitamins/countersinks.scad>
include <../../lib/OFL/vitamins/knurl_nuts.scad>

use <../../lib/OFL/foundation/label.scad>


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
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


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

SHOW        = "ALL";  // [ALL, Linear M2x4mm,Linear M2x6mm,Linear M2x8mm,Linear M2x10mm,Linear M3x4mm,Linear M3x6mm,Linear M3x8mm,Linear M3x10mm,Linear M4x4mm,Linear M4x6mm,Linear M4x8mm,Linear M4x10mm,Linear M5x6mm,Linear M5x8mm,Linear M5x10mm,Spiral M2x4mm,Spiral M2p5x5.7mm,Spiral M3x5.7mm,Spiral M4x8.1mm,Spiral M5x9.5mm,Spiral M6x12.7mm,Spiral M8x12.7mm]
THREAD_TYPE = "ANY";  // [ANY,linear,spiral]
// FL_DRILL on Z axis
DRILL_THICK = 0;        // [-10:0.1:10]


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// end of automatically generated code

verbs         = fl_verbList([FL_ADD,FL_ASSEMBLY,FL_AXES,FL_BBOX,FL_DRILL,FL_LAYOUT]);
one           = let(all=fl_knut_dict())
                  fl_switch(SHOW,fl_list_pack(fl_dict_names(all),all));
scr_inventory = screw_lists[0]; // cap screws only from NopSCADlib
drill_t       = [DRILL_THICK];
thread_type   = THREAD_TYPE!="ANY" ? THREAD_TYPE : undef;

if (one) {
  fl_knut(verbs,one,dri_thick=drill_t,octant=octant,direction=direction) {
    if ($knut_verb==FL_ASSEMBLY) {
      test_screw($knut_obj,$knut_thickness,$FL_ADD=$FL_ASSEMBLY);
    } else if ($knut_verb==FL_LAYOUT) {
      translate(+Z($knut_thick[1]))
        fl_countersink(type=fl_cs_search(d=$knut_nominal)[0],octant=+Z,direction=[+Z,0],$FL_ADD=$FL_LAYOUT);
      translate(-Z($knut_length-$knut_thick[0]))
        fl_countersink(type=fl_cs_search(d=$knut_nominal)[0],octant=+Z,direction=[-Z,0],$FL_ADD=$FL_LAYOUT);
    }
  }
} else {
  // filter items by the thread type
  items = fl_knut_find(thread=thread_type);
  // organize items by rows with same nominal size
  dict  = fl_dict_organize(items,[2:0.5:8],function(nut) fl_nominal(nut));
  // for each not empty row calculates the offsets along Y axis
  y_coords  = let(
    y_offsets = [for(i=[0:len(dict)-1]) (i>0 && dict[i]) ? 12 : 0]
  ) fl_cumulativeSum(y_offsets);
  for(i=[0:len(dict)-1]) let(row=dict[i],l=len(row))
    if (row) { // no empty row
      // row movement along Y axis
      translate(Y(y_coords[i])) {
        fl_lookAtMe()
          translate(-X(7))
            fl_label(string=["M",fl_nominal(row[0])],fg="black",size=2,octant=O);
        // row horizontal layout
        fl_layout(axis=+X,gap=3,types=row,$FL_LAYOUT=$FL_ADD)
          fl_knut(verbs,$item,dri_thick=drill_t,octant=octant,direction=direction) {
            if ($knut_verb==FL_ASSEMBLY) {
              test_screw($knut_obj,$knut_thickness);
            } else if ($knut_verb==FL_LAYOUT) let(cs=fl_cs_search(d=$knut_nominal)[0]) {
              translate(+Z($knut_thick[1]))
                fl_countersink(type=cs,octant=+Z,direction=[+Z,0],$FL_ADD=$FL_LAYOUT);
              translate(-Z($knut_length-$knut_thick[0]))
                fl_countersink(type=cs,octant=+Z,direction=[-Z,0],$FL_ADD=$FL_LAYOUT);
            }
          }
      }
    }
}

module test_screw(knut,length) let(
  screw = fl_knut_screws(knut,scr_inventory)[0]
) fl_screw(type=screw,len=length);