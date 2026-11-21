/*
 * Comparison test between OpenSCAD primitives and OFL ones
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

use     <../../lib/OFL/foundation/3d-engine.scad>

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


//**** TAB_Direction ***********************************************************


//**** TAB_Dimensions **********************************************************


//**** TAB_TEST ****************************************************************
/* [Primitive comparison] */

PRIMITIVE = "fl_circle vs circle"; // [fl_circle vs circle,fl_square vs square,fl_cube vs cube,fl_sphere vs sphere]

/* [Hidden] */

//**** TEST_PROLOGUE ***********************************************************


// end of automatically generated code
T_legacy  = [+1.5,0,0];
T_ofl     = [-1.5,0,0];

translate(T_legacy) {
  if (PRIMITIVE=="fl_circle vs circle") {
    fl_doAxes([1,1]);
    circle(d=1);
  } else if (PRIMITIVE=="fl_square vs square") {
    fl_doAxes([1,1]);
    square([1,1]);
  } else if (PRIMITIVE=="fl_cube vs cube") {
    fl_doAxes([1,1,1]);
    cube([1,1,1]);
  } else if (PRIMITIVE=="fl_sphere vs sphere") {
    fl_doAxes([1,1,1]);
    sphere(d=1);
  }
}

translate(T_ofl) {
  if (PRIMITIVE=="fl_circle vs circle") {
    fl_circle([FL_ADD,FL_AXES],d=1);
  } else if (PRIMITIVE=="fl_square vs square") {
    fl_square([FL_ADD,FL_AXES],[1,1]);
  } else if (PRIMITIVE=="fl_cube vs cube") {
    fl_cube([FL_ADD,FL_AXES],size=[1,1,1]);
  } else if (PRIMITIVE=="fl_sphere vs sphere") {
    fl_sphere([FL_ADD,FL_AXES],d=[1,1,1]);
  }
}
