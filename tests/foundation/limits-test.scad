/*
 * Foundation test for 3d printing limits.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../foundation/limits.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$fl_debug   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// Default color for printable items (i.e. artifacts)
$fl_filament  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]

/* [Hidden] */

for(limits=FL_LIMITS) {
  $fl_print_tech=limits[0];
  settings=limits[1];
  for(prop=settings) {
    // echo(prop=prop);
    name=prop[0];
    value=prop[1];
    // echo(str(name,"=",value));
    assert(value==fl_techLimit(name));
  }
}
