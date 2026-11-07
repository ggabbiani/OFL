/*
 * This test generates an error: duplicate names in an inventory
 *
 * NOTE: this file is generated automatically from 'template-nogui.scad', any
 * change will be lost.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

// **** TEST_INCLUDES *********************************************************

include <../lib/OFL/foundation/unsafe_defs.scad>
use <../lib/OFL/foundation/type-engine.scad>

// **** TAB_Debug *************************************************************

/* [Debug] */

// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES        = -2;     // [-2:10]
DEBUG_ASSERTIONS  = false;
DEBUG_COMPONENTS  = ["none"];
DEBUG_COLOR       = false;
DEBUG_DIMENSIONS  = false;
DEBUG_LABELS      = false;
DEBUG_SYMBOLS     = false;

// **** TEST_PROLOGUE *********************************************************


$dbg_Assert     = DEBUG_ASSERTIONS;
$dbg_Dimensions = DEBUG_DIMENSIONS;
$dbg_Color      = DEBUG_COLOR;
$dbg_Components = DEBUG_COMPONENTS[0]=="none" ? undef : DEBUG_COMPONENTS;
$dbg_Labels     = DEBUG_LABELS;
$dbg_Symbols    = DEBUG_SYMBOLS;


fl_status();

// end of automatically generated code

first   = fl_Object(bbox=[[0,0,0],[1,1,1]],name="first");
twin    = fl_Object(bbox=[[0,0,0],[2,2,2]],name="first");
inv     = fl_Inventory([first,twin]);
