/*
 * Base string test
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

include <../../lib/OFL/foundation/core.scad>

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

s = "I was A Mixed string!";

assert(fl_str_upper(s)=="I WAS A MIXED STRING!");
assert(fl_str_lower(s)=="i was a mixed string!");

let(
  in  = ["one","two",["three","four"],"five","six",["seven","eight"]],
  out = ["one", "two", "three", "four", "five", "six", "seven", "eight"]
) assert(fl_list_flatten(in)==out);
let(
  in  = [1,2,[3,4],5,6,[7,8]],
  out = [1, 2, 3, 4, 5, 6, 7, 8]
) assert(fl_list_flatten(in)==out);
let(
  in  = [1,2,[3,4],[5,6,[7,8,["nine",10]]]],
  out = [1, 2, 3, 4, 5, 6, 7, 8, "nine", 10]
) assert(fl_list_flatten(in)==out);
