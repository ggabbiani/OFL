/*
 * T-nut test.
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


include <../../lib/OFL/artifacts/t-nut.scad>
include <../../lib/OFL/foundation/core.scad>
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
SHOW_DIMENSIONS = false;


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
// adds a footprint to scene, usually a simplified ADD operation (see variable FL_ADD)
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



/* [T-slot nut] */

opening               = 6.4;
in_width              = 10.0; // [0:0.1:20]
length                = 20; // [0:30]
screw_name            = "M3_cap_screw"; // [M3_cap_screw,M4_cap_screw,M5_cap_screw,M6_cap_screw]
wall_thick            = 2.0;  // [0:0.1:1]
base_thick            = 1.0;  // [0:0.1:3]
cone_thick            = 2.0;  // [0:0.1:6]
nut_tolerance         = 0;    // [-1:0.1:1]
hole_tolerance        = 0;    // [-1:0.1:2]
countersink_tolerance = 0;    // [-1:0.1:1]

countersink           = false;
knut                  = false;

DRILL_THICKNESS       = 10; // [0:1:20]


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS,dimensions=SHOW_DIMENSIONS);

fl_status();

// end of automatically generated code

screw = fl_switch(screw_name,[
  ["M3_cap_screw", M3_cap_screw],
  ["M4_cap_screw", M4_cap_screw],
  ["M5_cap_screw", M5_cap_screw],
  ["M6_cap_screw", M6_cap_screw]
]);
verbs = fl_verbList([FL_ADD,FL_ASSEMBLY,FL_AXES,FL_BBOX,FL_DRILL,FL_FOOTPRINT,FL_LAYOUT,FL_MOUNT]);

thick = wall_thick+base_thick+cone_thick;
nut   = fl_TNut(opening,[in_width,length],[wall_thick,base_thick,cone_thick],screw,knut);

fl_tnut(verbs,nut,
  tolerance=[nut_tolerance,hole_tolerance,countersink_tolerance],
  countersink=countersink,
  dri_thick=DRILL_THICKNESS,
  debug=debug,direction=direction,octant=octant
) fl_cylinder([FL_ADD,FL_AXES],h=10,d=$hole_d,direction=[$hole_n,0],$FL_AXES=$FL_LAYOUT);
