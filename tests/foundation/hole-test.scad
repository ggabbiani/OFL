/*
 * Hole engine test.
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
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
include <../../foundation/unsafe_defs.scad>
include <../../foundation/incs.scad>

use     <../../foundation/hole.scad>
use     <../../vitamins/screw.scad>
include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/screws.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

$FL_FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Holes] */

SIZE  = 20;       // [20:20]
// hole depth
T     = 0.7;      // [0.7:0.1:3]
// hole radius
R     = 2;        // [0:0.1:3]
MODE  = "holes";  // [layout,holes]

ONE   = true;
TWO   = true;
THREE = true;
FOUR  = true;
FIVE  = true;
SIX   = true;

/* [Hidden] */

vectors = [
  // ONE
  [SIZE/2*[0,0,1],+Z],
  // TWO
  [SIZE/2*[+0.5,+0.5,-1],-Z],
  [SIZE/2*[-0.5,-0.5,-1],-Z],
  // THREE
  [SIZE/2*[ 0,    1,   0  ],  +Y],
  [SIZE/2*[+0.5,  1,  +0.5],  +Y],
  [SIZE/2*[-0.5,  1,  -0.5],  +Y],
  // FOUR
  [SIZE/2*[-1,   0.5,  0.5 ],-X],
  [SIZE/2*[-1,  -0.5,  0.5 ],-X],
  [SIZE/2*[-1,  -0.5, -0.5 ],-X],
  [SIZE/2*[-1,   0.5, -0.5 ],-X],
  // FIVE
  [SIZE/2*[1,   0,  0   ],+X],
  [SIZE/2*[1, 0.5,  0.5 ],+X],
  [SIZE/2*[1,-0.5,  0.5 ],+X],
  [SIZE/2*[1,-0.5, -0.5 ],+X],
  [SIZE/2*[1, 0.5, -0.5 ],+X],
  // SIX
  [SIZE/2*[+0.5,  -1,  0  ],-Y],
  [SIZE/2*[-0.5,  -1,  0  ],-Y],
  [SIZE/2*[+0.5,  -1,  0.5],-Y],
  [SIZE/2*[-0.5,  -1,  0.5],-Y],
  [SIZE/2*[-0.5,  -1, -0.5],-Y],
  [SIZE/2*[+0.5,  -1, -0.5],-Y],
];

enable  = [
  if (ONE)    "+z",
  if (TWO)    "-z",
  if (THREE)  "+y",
  if (FOUR)   "-x",
  if (FIVE)   "+x",
  if (SIX)    "-y",
];

if (MODE=="layout") difference() {
  fl_color("red") 
    fl_cube(size=SIZE,octant=O);
  fl_lay_points(points=vectors,enable=enable)
    translate(NIL*$normal) 
      fl_screw(FL_FOOTPRINT,type=M2_cs_cap_screw,len=T,direction=[$normal,0]);
} else difference() {
  fl_color("red") 
    fl_cube(size=SIZE,octant=O);
  fl_holes(points=vectors,enable=enable,thick=T,r=R);
}