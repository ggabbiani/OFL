/*
 * insert a brief description here
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../lib/OFL/foundation/3d-engine.scad>
include <../lib/OFL/vitamins/screw.scad>
include <../lib/OFL/foundation/hole.scad>

use <../lib/OFL/foundation/fillet.scad>
use <../lib/OFL/foundation/profile.scad>
use <../lib/OFL/foundation/util.scad>

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

/* [DIMS] */

LENGTH  = 252;  // [227:252]
WIDTH   = 36;
HEIGHT  = 21;   // [10:0.1:25]
HORIZ_T = 7;    // [6:0.1:8]
VERT_T  = 4;
RADIUS  = 1.1;

/* [Holes] */

DRILL_TYPE  = "clearance";  // [clearance,tap]
COUNTERSUNK = false;
TOLERANCE   = 0;  // [0:0.1:2]

/* [Hidden] */

debug = fl_parm_Debug(symbols=SHOW_SYMBOLS);

screw = No6_cs_screw;
scr_nominal = fl_screw_nominal(screw);

holes = [
  fl_Hole([30,  8,HORIZ_T],scr_nominal),
  fl_Hole([131, 8,HORIZ_T],scr_nominal),
  fl_Hole([223, 8,HORIZ_T],scr_nominal),

  fl_Hole([30,    28,HORIZ_T],scr_nominal),
  fl_Hole([131, 28,HORIZ_T],scr_nominal),
  fl_Hole([223, 28,HORIZ_T],scr_nominal),
];
// holes = [
//   fl_Hole([30.5,  7+1,HORIZ_T],scr_nominal),
//   fl_Hole([131.5, 7+1,HORIZ_T],scr_nominal),
//   fl_Hole([223.5, 8+1,HORIZ_T],scr_nominal),

//   fl_Hole([29,    28+1,HORIZ_T],scr_nominal),
//   fl_Hole([130.5, 28+1,HORIZ_T],scr_nominal),
//   fl_Hole([222.5, 28.5+1,HORIZ_T],scr_nominal),
// ];

difference() {
  rotate(90,Y) rotate(-90,Z) translate(-X(WIDTH/2)-Y((HORIZ_T-VERT_T))) {

    // "T" profile with VERT_T thickness
    fl_profile(type="T", radius=RADIUS, size=[WIDTH,HEIGHT-(HORIZ_T-VERT_T),LENGTH], thick=VERT_T, octant=-Y+Z);
    // additional thickness added to bottom to get HORIZ_T
    fl_color()
      linear_extrude(height=LENGTH)
        translate([0,-RADIUS])
          fl_square(size = [WIDTH,HORIZ_T-VERT_T+RADIUS], quadrant=+Y);
    // two fillets
    fl_color()
      for(i=[-1,+1])
        translate([i*VERT_T/2,-VERT_T])
          fl_fillet(r=RADIUS, h=LENGTH,direction=[+Z,45-i*135]);
  }
  // screw holes
  // translate(X(LENGTH-252))
    // fl_screw_holes(holes, thick=HORIZ_T, screw=screw, type = DRILL_TYPE,
    // tolerance=TOLERANCE, countersunk=COUNTERSUNK);
  translate(+Z(0.1))
    fl_lay_holes(holes)
      fl_rail(5)
        fl_screw(FL_FOOTPRINT,screw,10);
}
