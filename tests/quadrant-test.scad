/*
 * 2d quadrant test
 *
 * NOTE: this file is generated automatically from 'template-2d.scad', any
 * change will be lost.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

// **** TEST_INCLUDES *********************************************************

include <../lib/OFL/foundation/core.scad>
use <../lib/OFL/foundation/2d-engine.scad>
// **** TAB_PARAMETERS ********************************************************

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

// **** TAB_Verbs *************************************************************

// **** TAB_Placement *********************************************************

/* [2D Placement] */

X_PLACE = "undef";  // [undef,-1,0,+1]
Y_PLACE = "undef";  // [undef,-1,0,+1]

// **** TAB_TEST **************************************************************

/* [TEST] */

SIZE          = [200,100];

/* [Hidden] */
// **** TEST_PROLOGUE *********************************************************

quadrant    = fl_parm_Quadrant(X_PLACE,Y_PLACE);
debug       = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// **** end of automatically generated code ***********************************

module do_square(primus=false) {
  fl_color("cyan") square(size=SIZE);
  fl_color("black") {
    translate([-20,-10]) if (primus) text("C'0"); else text("C0");
    translate(SIZE) if (primus) text("C'1"); else text("C1");
  }
}

do_square();
#fl_2d_place(quadrant=quadrant,bbox=[FL_O,SIZE])
  do_square(true);

