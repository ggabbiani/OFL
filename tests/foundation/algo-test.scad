/*
 * 3D algorithms tests.
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


include <../../lib/OFL/foundation/core.scad>
use <../../lib/OFL/foundation/algo-engine.scad>


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



/* [3D Placement] */

X_PLACE = "undef";  // [undef,-1,0,+1]
Y_PLACE = "undef";  // [undef,-1,0,+1]
Z_PLACE = "undef";  // [undef,-1,0,+1]




/* [Algo] */

// Draw planes
FL_PLANES  = true;
DEPLOYMENT  = [10,0,0];
ALIGN       = [0,0,0];  // [-1:+1]


/* [Hidden] */

octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// end of automatically generated code

data    = [
  ["zero",    [1,11,111]],
  ["first",   [2,22,1]],
  ["second",  [3,33,1]],
];
pattern = [0,1,1,2];

fl_trace("result",fl_algo_pattern(10,pattern,data));
fl_algo_pattern(10,pattern,data,deployment=DEPLOYMENT,octant=octant,align=ALIGN);

if (FL_PLANES)
  fl_planes(size=200);
