/*
 * Artifacts test template.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
// include <NopSCADlib/core.scad>
// include <NopSCADlib/vitamins/screws.scad>

include <../../artifacts/t-nut.scad>
include <../../foundation/defs.scad>
include <../../vitamins/knurl_nuts.scad>

$fn         = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// Default color for printable items (i.e. artifacts)
$fl_filament  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]
// Debug statements are turned on
$fl_debug   = false;
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
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [tnut] */

opening   = 6.4;
in_width  = 10.0; // [0:0.1:20]
length    = 20;
screw_name     = "M3_cs_cap_screw"; // [M3_cs_cap_screw,M4_cs_cap_screw,M5_cs_cap_screw,M6_cs_cap_screw]
wall_thick  = 2.0;  // [0:0.1:1]
base_thick  = 1.0;  // [0:0.1:3]
cone_thick  = 2.0;  // [0:0.1:6]
nut_tolerance   = 0;    // [-1:0.1:1]
hole_tolerance   = 0;    // [-1:0.1:2]
countersink_tolerance   = 0;    // [-1:0.1:1]

countersink = false;
knut = false;

/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
debug     = fl_parm_Debug(labels=SHOW_LABELS,symbols=SHOW_SYMBOLS);
echo(debug=debug);
verbs=[
  if ($FL_ADD!="OFF")       FL_ADD,
  if ($FL_ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if ($FL_AXES!="OFF")      FL_AXES,
  if ($FL_BBOX!="OFF")      FL_BBOX,
  if ($FL_LAYOUT!="OFF")    FL_LAYOUT,
];

screw = screw_name=="M3_cs_cap_screw" ? M3_cs_cap_screw
      : screw_name=="M4_cs_cap_screw" ? M4_cs_cap_screw
      : screw_name=="M5_cs_cap_screw" ? M5_cs_cap_screw
      : screw_name=="M6_cs_cap_screw" ? M6_cs_cap_screw
      : undef;
nop   = screw_name=="M3_cs_cap_screw" ? M3_sliding_t_nut
      : screw_name=="M4_cs_cap_screw" ? M4_sliding_t_nut
      : screw_name=="M5_cs_cap_screw" ? M5_sliding_t_nut
      : screw_name=="M6_cs_cap_screw" ? M6_sliding_t_nut
      : undef;

thick = wall_thick+base_thick+cone_thick;
nut = fl_TNut(opening,[in_width,length],[wall_thick,base_thick,cone_thick],screw,knut);
// knut = fl_knut_search(screw,thick);

// echo(knut=knut);

fl_tnut(verbs,nut,[nut_tolerance,hole_tolerance,countersink_tolerance],countersink,debug,direction,octant);
  // fl_knut([FL_ADD,FL_AXES],type=knut,direction=$hole_direction,octant=-Z);

// sliding_t_nut(nop);