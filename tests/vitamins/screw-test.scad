/*
 * Screw wrappers test file for OpenSCAD Foundation Library vitamins
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


include <../../lib/OFL/foundation/core.scad>
include <../../lib/OFL/vitamins/screw.scad>


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
// layout of predefined auxiliary shapes (like predefined screws)
$FL_ASSEMBLY  = "ON";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
$FL_FOOTPRINT = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


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

VIEW_TYPE     = "other";    // [other,right,top,bottom,left,front,back]
DIM_MODE      = "full";     // [full,label,value,silent]
DIM_GAP       = 1;          // [1:.1:10]
DIM_W         = 0.05;       // [0.01:0.01:1]

/* [Screw select] */

SCREW_NAME  = "*";  // [*, M2_cap, M2p5_cap, M3_cap, M4_cap, M5_cap, M6_cap, M8_cap, M3_low_cap, M3_shoulder, M4_shoulder, M2_cs_cap, M3_cs_cap, M4_cs_cap, M5_cs_cap, M6_cs_cap, M8_cs_cap, M2_dome, M2p5_dome, M3_dome, M4_dome, M5_dome, M3_hex, M4_hex, M5_hex, M6_hex, M8_hex, M2p5_pan, M3_pan, M4_pan, M5_pan, M6_pan, No632_pan, No2, No4, No6, No8, No6_cs, M3_grub, M4_grub, M5_grub, M6_grub]
HEAD_TYPE   = "*";  // [*, cap, pan, cs, hex, grub, cs cap, dome]

/* [Screw parameters] */

// shaft length
LENGTH_MODE   = "exact";      // [exact, longer, shorter]
SHAFT_LENGTH  = 0;            // [0:0.1:25]

HEAD_SPRING   = "undef";      // [undef, spring, star]
HEAD_WASHER   = "undef";      // [undef, default, penny]

NUT_WASHER    = "undef";      // [undef, default, penny]
NUT_SPRING    = "undef";      // [undef, spring, star]
NUT           = "undef";      // [undef, default, nyloc]

DRILL_TYPE    = "clearance";  // [clearance,tap]

/* [Context] */

$fl_thickness = 10;     // [1:0.1:20]

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

function fl_cstz_undef(value,_if_="undef",_when_=false) =
  value==_if_ || _when_ ?
    undef :
    value;

$vpr        = fl_view(VIEW_TYPE);
$dim_mode   = DIM_MODE;
$dim_width  = DIM_W;

verbs       = fl_verbList([FL_ADD,FL_ASSEMBLY,FL_AXES,FL_BBOX,FL_DRILL,FL_FOOTPRINT]);
// echo(labels=[for(s=FL_SCREW_SPECS_INVENTORY) s[0]]);
echo(LENGTH_MODE=LENGTH_MODE);
inventory = fl_ScrewInventory(
  name          = fl_cstz_undef(SCREW_NAME,   _when_=SCREW_NAME=="*"        ),
  length        = fl_cstz_undef(SHAFT_LENGTH, _when_=LENGTH_MODE!="exact"   ),
  longer_than   = fl_cstz_undef(SHAFT_LENGTH, _when_=LENGTH_MODE!="longer"  ),
  shorter_than  = fl_cstz_undef(SHAFT_LENGTH, _when_=LENGTH_MODE!="shorter" ),
  head_name     = HEAD_TYPE,
  head_spring   = fl_cstz_undef(HEAD_SPRING),
  head_washer   = fl_cstz_undef(HEAD_WASHER),
  nut_washer    = fl_cstz_undef(NUT_WASHER),
  nut_spring    = fl_cstz_undef(NUT_SPRING),
  nut           = fl_cstz_undef(NUT),
  thickness     = $fl_thickness
);
echo(inventory=[for(screw=inventory) fl_name(screw)]);

// list of unique ordered sizes from user selected screws
sizes     = fl_list_sort(fl_list_unique([for(s=inventory) fl_nominal(s)]));
// list organized by rows of screws with same nominal size
dict      = fl_dict_organize(inventory,sizes,function(screw) fl_nominal(screw));
for(row=dict) echo([for(screw=row) str(fl_name(screw),"/",fl_nominal(screw))]);
// for each not empty row calculates the offsets along Y axis
y_coords  = let(
  y_offsets = [for(i=[0:len(dict)-1]) (i>0) ? 20 : 0]
) fl_cumulativeSum(y_offsets);

for(i=[0:len(dict)-1]) let(row=dict[i])
  // row movement along Y axis
  translate(Y(y_coords[i])) {
    if (SCREW_NAME=="*")
      translate(-X(12))
        label(str("⌀",fl_nominal(row[0])),halign="center");
    // horizontal layout of row screws
    fl_layout(axis=+X,gap=3,types=row)
      fl_screw(verbs,$item,
        head_spring = fl_cstz_undef(HEAD_SPRING),
        head_washer = fl_cstz_undef(HEAD_WASHER),
        nut_washer  = fl_cstz_undef(NUT_WASHER),
        nut_spring  = fl_cstz_undef(NUT_SPRING),
        nut         = fl_cstz_undef(NUT),
        octant=octant,direction=direction
      );
    }

//! Draw text that always faces the camera
module label(str, scale = 0.25, valign = "baseline", halign = "left")
  color("black")
    fl_lookAtMe()
      linear_extrude(NIL)
        scale(scale)
          text(str, valign = valign, halign = halign, font="Symbola:style=Regular");

