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

//**** TEST_INCLUDES ***********************************************************
include <../../lib/OFL/foundation/core.scad>
use <../../lib/OFL/foundation/algo-engine.scad>

//**** TAB_PARAMETERS **********************************************************
// number of segments
$fn            = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_EPS
$FL_RENDER     = false;
// Default color for printable items (i.e. artifacts)
$fl_filament   = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// When false polyRound() is disabled
$fl_polyround  = true;

//**** TAB_Debug ***************************************************************
/* [Debug] */

// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES        = -2;     // [-2:10]
DEBUG_ASSERTIONS  = false;
DEBUG_COMPONENTS  = ["none"];
DEBUG_COLOR       = false;
DEBUG_DIMENSIONS  = false;
DEBUG_LABELS      = false;
DEBUG_SYMBOLS     = false;

//**** TAB_Verbs ***************************************************************


//**** TAB_Placement ***********************************************************
/* [3D Placement] */

X_PLACE = "undef";  // [undef,-1,0,+1]
Y_PLACE = "undef";  // [undef,-1,0,+1]
Z_PLACE = "undef";  // [undef,-1,0,+1]

//**** TAB_Direction ***********************************************************


//**** TAB_Dimensions **********************************************************


//**** TAB_TEST ****************************************************************
/* [Algo] */

// Draw planes
FL_PLANES  = true;
DEPLOYMENT  = [10,0,0];
ALIGN       = [0,0,0];  // [-1:+1]

/* [Hidden] */

//**** TEST_PROLOGUE ***********************************************************
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);

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
