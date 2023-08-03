/*
 * Template file for OpenSCAD Founfation Library.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../foundation/defs.scad>

use <../foundation/2d-engine.scad>

$fn         = 50;           // [3:50]
// Debug statements are turned on
$fl_debug   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]

/* [Placement] */

PLACE_NATIVE  = true;
QUADRANT      = [0,0];  // [-1:+1]
SIZE          = [200,100];

/* [Hidden] */

module do_square(primus=false) {
  fl_color("cyan") square(size=SIZE);
  fl_color("black") {
    translate([-20,-10]) if (primus) text("C'0"); else text("C0");
    translate(SIZE) if (primus) text("C'1"); else text("C1");
  }
}

if (PLACE_NATIVE)
  do_square();
#fl_2d_place(quadrant=QUADRANT,bbox=[FL_O,SIZE])
  do_square(true);
