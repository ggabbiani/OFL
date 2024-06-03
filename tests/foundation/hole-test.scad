/*
 * Hole engine test
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


include <../../lib/OFL/foundation/hole.scad>
include <../../lib/OFL/foundation/util.scad>
include <../../lib/OFL/vitamins/screw.scad>


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

// end of automatically generated code

size  = 20;
debug = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

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
