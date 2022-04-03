/*
 * Hole engine test.
 *
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org)
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

include <../../foundation/hole.scad>
include <../../foundation/util.scad>

include <../../vitamins/screw.scad>

include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/screws.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = true;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

$FL_FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Holes] */

// hole depth
DEPTH     = 0.7;      // [0.7:0.1:3]
// hole diameter
D     = 2;        // [2:4]

ONE   = false;
TWO   = false;
THREE = false;
FOUR  = false;
FIVE  = false;
SIX   = true;

/* [Hidden] */

size  = 20;

holes = [
  // ONE
  [size/2*[0,0,1],+Z, D, DEPTH],
  // TWO
  [size/2*[+0.5,+0.5,-1],-Z, D, DEPTH],
  [size/2*[-0.5,-0.5,-1],-Z, D, DEPTH],
  // THREE
  [size/2*[ 0,    1,   0  ],  +Y, D, DEPTH],
  [size/2*[+0.5,  1,  +0.5],  +Y, D, DEPTH],
  [size/2*[-0.5,  1,  -0.5],  +Y, D, DEPTH],
  // FOUR
  [size/2*[-1,   0.5,  0.5 ],-X, D, DEPTH],
  [size/2*[-1,  -0.5,  0.5 ],-X, D, DEPTH],
  [size/2*[-1,  -0.5, -0.5 ],-X, D, DEPTH],
  [size/2*[-1,   0.5, -0.5 ],-X, D, DEPTH],
  // FIVE
  [size/2*[1,   0,  0   ],+X, D, DEPTH],
  [size/2*[1, 0.5,  0.5 ],+X, D, DEPTH],
  [size/2*[1,-0.5,  0.5 ],+X, D, DEPTH],
  [size/2*[1,-0.5, -0.5 ],+X, D, DEPTH],
  [size/2*[1, 0.5, -0.5 ],+X, D, DEPTH],
  // SIX
  [size/2*[+0.5,  -1,  0  ],-Y, D, DEPTH],
  [size/2*[-0.5,  -1,  0  ],-Y, D, DEPTH],
  [size/2*[+0.5,  -1,  0.5],-Y, D, DEPTH],
  [size/2*[-0.5,  -1,  0.5],-Y, D, DEPTH],
  [size/2*[-0.5,  -1, -0.5],-Y, D, DEPTH],
  [size/2*[+0.5,  -1, -0.5],-Y, D, DEPTH],
];

enable  = fl_3d_AxisList([
  if (ONE)    "+z",
  if (TWO)    "-z",
  if (THREE)  "+y",
  if (FOUR)   "-x",
  if (FIVE)   "+x",
  if (SIX)    "-y",
]);

module do() {
  if ($FL_DEBUG)
    #children();
  else
    children();
}

do() fl_color($FL_FILAMENT)
  difference() {
    fl_cube(size=size,octant=O);
    fl_holes(holes=holes,enable=enable);
  }
if ($FL_DEBUG)
  fl_hole_debug(holes=holes,enable=enable);
