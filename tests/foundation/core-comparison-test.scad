/*
 * Foundation test template.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <../../lib/OFL/foundation/defs.scad>

use <../../lib/OFL/foundation/2d-engine.scad>
use <../../lib/OFL/foundation/3d-engine.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$fl_debug   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]

/* [Primitive comparison] */

PRIMITIVE = "circle"; // [circle,square,cube,sphere]

/* [Hidden] */

echo($vpr=$vpr);
echo($vpt=$vpt);
echo($vpd=$vpd);
echo($vpf=$vpf);

$vpr  = [0, 0, 0];
$vpt  = [0, 0, 0];
$vpd  = 7;
$vpf  = 22.5;

T_legacy  = [-1.5,0,0];
T_ofl     = [+1.5,0,0];

translate(T_legacy) {
  if (PRIMITIVE=="circle") {
    fl_2d_doAxes([1,1]);
    circle(d=1);
  } else if (PRIMITIVE=="square") {
    fl_2d_doAxes([1,1]);
    square([1,1]);
  } else if (PRIMITIVE=="cube") {
    fl_doAxes([1,1,1]);
    cube([1,1,1]);
  } else if (PRIMITIVE=="sphere") {
    fl_doAxes([1,1,1]);
    sphere(d=1);
  }
}

translate(T_ofl) {
  if (PRIMITIVE=="circle") {
    fl_circle([FL_ADD,FL_AXES],d=1);
  } else if (PRIMITIVE=="square") {
    fl_square([FL_ADD,FL_AXES],[1,1]);
  } else if (PRIMITIVE=="cube") {
    fl_cube([FL_ADD,FL_AXES],[1,1,1]);
  } else if (PRIMITIVE=="sphere") {
    fl_sphere([FL_ADD,FL_AXES],d=[1,1,1]);
  }
}
