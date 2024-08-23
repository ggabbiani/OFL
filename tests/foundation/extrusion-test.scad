/*
 *
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


include <../../lib/OFL/foundation/unsafe_defs.scad>

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
SHOW_DIMENSIONS = false;



/* [EXTRUSION] */

EXTRUSION_TYPE  = "linear"; // [none,linear,directional]
XTR_AXIS        = [0,0,1];  // [-1:0.1:+1]
XTR_ROT         = 0;        // [-360:+360]

/* [Hidden] */

fl_status();

// end of automatically generated code

// extrude direction
xtr_direction = EXTRUSION_TYPE=="none" ? undef : [XTR_AXIS,XTR_ROT];

module example002() {
  intersection() {
    difference() {
      union() {
        cube([30, 30, 30], center = true);
        translate([0, 0, -25])
          cube([15, 15, 50], center = true);
      }
      union() {
        cube([50, 10, 10], center = true);
        cube([10, 50, 10], center = true);
        cube([10, 10, 50], center = true);
      }
    }
    translate([0, 0, 5])
      cylinder(h = 50, r1 = 20, r2 = 5, center = true);
  }
}

module extrude(direction,length,convexity = 10) {
  #if (direction)
    translate(30*direction[0])
      if (EXTRUSION_TYPE=="linear")
        fl_linear_extrude(direction, length, convexity)
          projection(cut = false)
            children();
      else
        fl_direction_extrude(xtr_direction, length, convexity)
          children();
  children();
}

extrude(xtr_direction,1)
  example002();
