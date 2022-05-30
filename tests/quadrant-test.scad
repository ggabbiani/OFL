/*
 * Template file for OpenSCAD Founfation Library.
 * Created on Fri Jul 16 2021.
 *
 * Copyright © 2021 Giampiero Gabbiani.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL).
 *
 * OFL is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * OFL is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with OFL.  If not, see <http: //www.gnu.org/licenses/>.
 */

include <../foundation/2d.scad>

$fn         = 50;           // [3:50]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, trace messages are turned on
$fl_traces   = false;

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
