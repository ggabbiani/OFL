/*
 * OFL linear vs directional extrusion tests
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

use <../../lib/OFL/foundation/3d-engine.scad>


$fn            = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER     = false;
// Default color for printable items (i.e. artifacts)
$fl_filament   = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]


/* [Debug] */

// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]
DEBUG_ASSERTIONS  = false;
DEBUG_COMPONENTS  = ["none"];
DEBUG_COLOR       = false;
DEBUG_DIMENSIONS  = false;
DEBUG_LABELS      = false;
DEBUG_SYMBOLS     = false;






/* [EXTRUSION] */

EXTRUSION_TYPE  = "linear"; // [none,linear,directional]
XTR_AXIS        = [0,0,1];  // [-1:0.1:+1]
XTR_ROT         = 0;        // [-360:+360]
DISTANCE        = 30;       // [0:60]

/* [DIRECTIONAL] */
OFFSET_TYPE     = "radial"; // [radial,delta]
// offset() is bypassed when '0'
OFFSET_VALUE    = 0;
// valid only for "delta" offset()
OFFSET_CHAMFER  = false;


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
    translate(DISTANCE*direction[0])
      if (EXTRUSION_TYPE=="linear")
        fl_linear_extrude(direction, length, convexity)
          projection(cut = false)
            children();
      else
        fl_direction_extrude(
          xtr_direction,
          length,
          convexity,
          r       = OFFSET_TYPE=="radial" ? OFFSET_VALUE : undef,
          delta   = OFFSET_TYPE=="delta"  ? OFFSET_VALUE : undef,
          chamfer = OFFSET_CHAMFER
        ) children();
  children();
}

extrude(xtr_direction,1)
  example002();

