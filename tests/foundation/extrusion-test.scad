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
include <../../lib/OFL/foundation/unsafe_defs.scad>

use <../../lib/OFL/foundation/3d-engine.scad>
use <../../lib/ext/NopSCADlib/utils/maths.scad>

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

// extrusion direction vector
XTR_AXIS        = [0,0,1];  // [-1:0.1:+1]
// extrusion length
XTR_LENGTH      = 20;        // [0:50]

/* [DIRECTIONAL] */
OFFSET_TYPE     = "radial"; // [radial,delta]
// offset() is bypassed when '0'
OFFSET_VALUE    = 0;
// valid only for "delta" offset()
OFFSET_CHAMFER  = false;
CUT_PLANE         = false;
// translation BEFORE projection()
XTR_TRIM        = [0,0,0];


/* [Hidden] */

fl_status();

// end of automatically generated code

// extrude direction
xtr_direction = [XTR_AXIS,0];
xtr_trim      = CUT_PLANE ? XTR_TRIM : undef;

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

module test(direction,length,trim,cut_plane) {
  plane_t = 0.1;

  module xy_plane()
    fl_cube(size=[100,100,plane_t],$FL_ADD="ON");

  module translate_if(t)
    if (t)
      translate(t)
        children();
    else
      children();

  module extrude(length)
    fl_direction_extrude(
      [XTR_AXIS,0],
      length,
      r       = OFFSET_TYPE=="radial" ? OFFSET_VALUE : undef,
      delta   = OFFSET_TYPE=="delta"  ? OFFSET_VALUE : undef,
      chamfer = OFFSET_CHAMFER,
      trim    = CUT_PLANE ? trim : undef
    ) translate_if(CUT_PLANE?undef:XTR_TRIM) // when trimming is on, children translation is already performed by fl_direction_extrude()
      children();

  // extrusion
  #translate(fl_versor(XTR_AXIS)*plane_t/2)
    extrude(XTR_LENGTH)
      children();

  // cut plane section
  extrude(length=plane_t)
    children();

  // children
  %translate(trim)
      children();

  // extrusion direction vector
  fl_color()
    translate(plane_t*fl_versor(XTR_AXIS))
      fl_vector(40*XTR_AXIS);
}

test(xtr_direction,XTR_LENGTH,XTR_TRIM,CUT_PLANE)
  example002();

