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

$fn           = 50;           // [3:100]
// When true debug statements are turned on
$fl_debug     = true;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER    = false;
// Default color for printable items (i.e. artifacts)
$fl_filament  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]

/* [DEBUG] */

LABELS  = false;
SYMBOLS = false;

/* [Holes] */

// hole depth
DEPTH = 0.7;      // [0.7:0.1:3]
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
debug = fl_parm_Debug(labels=LABELS,symbols=SYMBOLS);

holes = [
  // ONE
  fl_Hole(size/2*[0,0,1], D, +Z, DEPTH),
  // TWO
  fl_Hole(size/2*[+0.5,+0.5,-1],D,-Z, DEPTH, ldir=[-Z,180]),
  fl_Hole(size/2*[-0.5,-0.5,-1],D,-Z, DEPTH, ldir=[-Z,180]),
  // THREE
  fl_Hole(size/2*[ 0,    1,   0  ],D,  +Y, DEPTH, ldir=[+Y,180]),
  fl_Hole(size/2*[+0.5,  1,  +0.5],D,  +Y, DEPTH, ldir=[+Y,180]),
  fl_Hole(size/2*[-0.5,  1,  -0.5],D,  +Y, DEPTH, ldir=[+Y,180]),
  // FOUR
  fl_Hole(size/2*[-1,   0.5,  0.5 ],D,-X, DEPTH, ldir=[-X,90]),
  fl_Hole(size/2*[-1,  -0.5,  0.5 ],D,-X, DEPTH, ldir=[-X,90]),
  fl_Hole(size/2*[-1,  -0.5, -0.5 ],D,-X, DEPTH, ldir=[-X,90]),
  fl_Hole(size/2*[-1,   0.5, -0.5 ],D,-X, DEPTH, ldir=[-X,90]),
  // FIVE
  fl_Hole(size/2*[1,   0,  0   ],D,+X, DEPTH, ldir=[+X,90]),
  fl_Hole(size/2*[1, 0.5,  0.5 ],D,+X, DEPTH, ldir=[+X,90]),
  fl_Hole(size/2*[1,-0.5,  0.5 ],D,+X, DEPTH, ldir=[+X,90]),
  fl_Hole(size/2*[1,-0.5, -0.5 ],D,+X, DEPTH, ldir=[+X,90]),
  fl_Hole(size/2*[1, 0.5, -0.5 ],D,+X, DEPTH, ldir=[+X,90]),
  // SIX
  fl_Hole(size/2*[+0.5,  -1,  0  ],D,-Y, DEPTH, ldir=[-Y,0]),
  fl_Hole(size/2*[-0.5,  -1,  0  ],D,-Y, DEPTH, ldir=[-Y,0]),
  fl_Hole(size/2*[+0.5,  -1,  0.5],D,-Y, DEPTH, ldir=[-Y,0]),
  fl_Hole(size/2*[-0.5,  -1,  0.5],D,-Y, DEPTH, ldir=[-Y,0]),
  fl_Hole(size/2*[-0.5,  -1, -0.5],D,-Y, DEPTH, ldir=[-Y,0]),
  fl_Hole(size/2*[+0.5,  -1, -0.5],D,-Y, DEPTH, ldir=[-Y,0]),
];

enable  = fl_3d_AxisList([
  if (ONE)    "+z",
  if (TWO)    "-z",
  if (THREE)  "+y",
  if (FOUR)   "-x",
  if (FIVE)   "+x",
  if (SIX)    "-y",
]);

fl_color()
  difference() {
    fl_cube(size=size,octant=O);
    fl_holes(holes=holes,enable=enable);
  }
fl_hole_debug(holes=holes,enable=enable,debug=debug);
