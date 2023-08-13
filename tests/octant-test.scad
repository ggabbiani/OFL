/*
 * 3d octant test
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../foundation/defs.scad>
use <../foundation/3d-engine.scad>



$fn         = 50;           // [3:100]
// Debug statements are turned on
$fl_debug   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// Default color for printable items (i.e. artifacts)
$fl_filament  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]


/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];    // [-1:+1]


/* [TEST] */

SIZE          = [1,2,3];


/* [Hidden] */

fl_placeIf(!PLACE_NATIVE,octant=OCTANT,bbox=[FL_O,SIZE])
  cube(size=SIZE);
