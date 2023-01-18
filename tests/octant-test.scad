/*
 * Template file for OpenSCAD Founfation Library.
 * Created on Fri Jul 16 2021.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <../foundation/3d.scad>

$fn         = 50;           // [3:50]
// Debug statements are turned on
$fl_debug   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]
SIZE          = [1,2,3];

/* [Hidden] */

module __test__() {
  fl_placeIf(!PLACE_NATIVE,octant=OCTANT,bbox=[FL_O,SIZE])
    cube(size=SIZE);
}

__test__();
