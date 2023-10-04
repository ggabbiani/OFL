/*
 * Screw wrappers test file for OpenSCAD Foundation Library vitamins
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/foundation/core.scad>
include <../../lib/OFL/vitamins/screw.scad>


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


/* [Screw] */

SCREW     = "M2_cap_screw"; // [No632_pan_screw,M2_cap_screw,M2_cs_cap_screw,M2_dome_screw,M2p5_cap_screw,M2p5_pan_screw,M3_cap_screw,M3_cs_cap_screw,M3_dome_screw,M3_grub_screw,M3_hex_screw,M3_low_cap_screw,M3_pan_screw,M4_cap_screw,M4_cs_cap_screw,M4_dome_screw,M4_grub_screw,M4_hex_screw,M4_pan_screw,M5_cap_screw,M5_cs_cap_screw,M5_dome_screw,M5_hex_screw,M5_pan_screw,M6_cap_screw,M6_cs_cap_screw,M6_hex_screw,M6_pan_screw,M8_cap_screw,M8_hex_screw,No2_screw,No4_screw,No6_cs_screw,No6_screw,No8_screw]
FIXED_LEN = 0;
// thickness
T       = 10;   // [1:0.1:20]
WASHER  = "no"; // [no,default,penny,nylon]
XWASHER = "no"; // [no,spring,star]
NWASHER = false;
NUT     = "no"; // [no,default,nyloc]


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// end of automatically generated code

verbs = fl_verbList([FL_ADD,FL_ASSEMBLY,FL_AXES,FL_BBOX,FL_DRILL,FL_FOOTPRINT]);
screw = SCREW=="No632_pan_screw" ? No632_pan_screw
      : SCREW=="M2_cap_screw"    ? M2_cap_screw
      : SCREW=="M2_cs_cap_screw" ? M2_cs_cap_screw
      : SCREW=="M2_dome_screw"   ? M2_dome_screw
      : SCREW=="M2p5_cap_screw"  ? M2p5_cap_screw
      : SCREW=="M2p5_pan_screw"  ? M2p5_pan_screw
      : SCREW=="M3_cap_screw"    ? M3_cap_screw
      : SCREW=="M3_cs_cap_screw" ? M3_cs_cap_screw
      : SCREW=="M3_dome_screw"   ? M3_dome_screw
      : SCREW=="M3_grub_screw"   ? M3_grub_screw
      : SCREW=="M3_hex_screw"    ? M3_hex_screw
      : SCREW=="M3_low_cap_screw"? M3_low_cap_screw
      : SCREW=="M3_pan_screw"    ? M3_pan_screw
      : SCREW=="M4_cap_screw"    ? M4_cap_screw
      : SCREW=="M4_cs_cap_screw" ? M4_cs_cap_screw
      : SCREW=="M4_dome_screw"   ? M4_dome_screw
      : SCREW=="M4_grub_screw"   ? M4_grub_screw
      : SCREW=="M4_hex_screw"    ? M4_hex_screw
      : SCREW=="M4_pan_screw"    ? M4_pan_screw
      : SCREW=="M5_cap_screw"    ? M5_cap_screw
      : SCREW=="M5_cs_cap_screw" ? M5_cs_cap_screw
      : SCREW=="M5_dome_screw"   ? M5_dome_screw
      : SCREW=="M5_hex_screw"    ? M5_hex_screw
      : SCREW=="M5_pan_screw"    ? M5_pan_screw
      : SCREW=="M6_cap_screw"    ? M6_cap_screw
      : SCREW=="M6_cs_cap_screw" ? M6_cs_cap_screw
      : SCREW=="M6_hex_screw"    ? M6_hex_screw
      : SCREW=="M6_pan_screw"    ? M6_pan_screw
      : SCREW=="M8_cap_screw"    ? M8_cap_screw
      : SCREW=="M8_hex_screw"    ? M8_hex_screw
      : SCREW=="No2_screw"       ? No2_screw
      : SCREW=="No4_screw"       ? No4_screw
      : SCREW=="No6_cs_screw"    ? No6_cs_screw
      : SCREW=="No6_screw"       ? No6_screw
      : SCREW=="No8_screw"       ? No8_screw
      : undef;
assert(screw!=undef);

let(
  d      = fl_screw_nominal(screw),
  hd_typ = screw_head_type(screw),
  found  = fl_screw_search(d=d, head_type=hd_typ)
) assert(found && len(found)>=1)
//   echo(found=found)
  fl_screw(verbs,screw,thick=T,washer=WASHER,nut=NUT,xwasher=XWASHER,nwasher=NWASHER,len=FIXED_LEN?FIXED_LEN:undef,octant=octant,direction=direction);
