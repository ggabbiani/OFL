/*
 * Comparison test between OpenSCAD primitives and OFL ones
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/foundation/core.scad>

use <../../lib/OFL/foundation/2d-engine.scad>
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





/* [Primitive comparison] */

PRIMITIVE = "fl_circle vs circle"; // [fl_circle vs circle,fl_square vs square,fl_cube vs cube,fl_sphere vs sphere]


/* [Hidden] */

// end of automatically generated code

T_legacy  = [+1.5,0,0];
T_ofl     = [-1.5,0,0];

translate(T_legacy) {
  if (PRIMITIVE=="fl_circle vs circle") {
    fl_2d_doAxes([1,1]);
    circle(d=1);
  } else if (PRIMITIVE=="fl_square vs square") {
    fl_2d_doAxes([1,1]);
    square([1,1]);
  } else if (PRIMITIVE=="fl_cube vs cube") {
    fl_doAxes([1,1,1]);
    cube([1,1,1]);
  } else if (PRIMITIVE=="fl_sphere vs sphere") {
    fl_doAxes([1,1,1]);
    sphere(d=1);
  }
}

translate(T_ofl) {
  if (PRIMITIVE=="fl_circle vs circle") {
    fl_circle([FL_ADD,FL_AXES],d=1);
  } else if (PRIMITIVE=="fl_square vs square") {
    fl_square([FL_ADD,FL_AXES],[1,1]);
  } else if (PRIMITIVE=="fl_cube vs cube") {
    fl_cube([FL_ADD,FL_AXES],[1,1,1]);
  } else if (PRIMITIVE=="fl_sphere vs sphere") {
    fl_sphere([FL_ADD,FL_AXES],d=[1,1,1]);
  }
}
