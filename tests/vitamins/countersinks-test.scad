/*
 * Countersink test
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/foundation/unsafe_defs.scad>
include <../../lib/OFL/vitamins/countersinks.scad>
include <../../lib/OFL/vitamins/screw.scad>

use <../../lib/OFL/foundation/3d-engine.scad>


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
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
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


/* [Countersink] */

TOLERANCE = 0;  // [0:0.1:1]
TYPE      = "ISO";  // [ISO,UNI]
// 'ALL' for complete dictionary, nominal size for single display
SIZE      = "ALL";
GAP       = 5;


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// end of automatically generated code

//! Draw text that always faces the camera
module label(str, scale = 0.25, valign = "baseline", halign = "left")
  color("black")
    rotate($vpr != [0, 0, 0] ? $vpr : [70, 0, 315])
      linear_extrude(NIL)
        scale(scale)
          text(str, valign = valign, halign = halign, font="Symbola:style=Regular");

dictionary = TYPE=="ISO"?FL_CS_ISO_DICT:FL_CS_UNI_DICT;
verbs = fl_verbList([FL_ADD,FL_AXES,FL_BBOX]);
if (SIZE!="ALL") {
  cs = fl_cs_search(dictionary=dictionary,d=fl_atof(SIZE))[0];
  assert(cs,str("No M",SIZE," ",TYPE," countersink found."))
    fl_countersink(verbs,cs,tolerance=TOLERANCE,octant=octant,direction=direction);
} else
  fl_layout(axis=X,gap=GAP,types=dictionary) {
    let(delta=fl_bb_size($item).y/2+2)
      translate(+Y(delta))
        label(str("M",fl_cs_nominal($item)),halign="center");
    fl_countersink(verbs,$item,tolerance=TOLERANCE,octant=octant,direction=direction);
  }
