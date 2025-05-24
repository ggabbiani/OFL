/*
 * verb dependent parameters (vdp) test file
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

// **** flat value without and with constructor *******************************
let(
  $verb         = FL_ADD,
  $fl_tolerance = 0.2,
  attended      = 0.2,
  result        = fl_parm_tolerance()
) assert(result==attended,result);

let(
  $this_verb    = FL_ADD,
  $fl_tolerance = 0.2,
  attended      = 0.2,
  result        = fl_parm_tolerance()
) assert(result==attended,result);

let(
  $this_verb    = FL_ADD,
  $fl_tolerance = fl_parm_MultiVerb(0.2),
  attended      = 0.2,
  result        = fl_parm_tolerance()
) assert(result==attended,result);

// **** flat value without/with constructor and with (ignored) default ********
let(
  $verb         = FL_ADD,
  $fl_tolerance = 0.2,
  attended      = 0.2,
  result        = fl_parm_tolerance(-1)
) assert(result==attended,result);

let(
  $this_verb    = FL_ADD,
  $fl_tolerance = fl_parm_MultiVerb(0.2),
  attended      = 0.2,
  result        = fl_parm_tolerance(-1)
) assert(result==attended,result);

// **** verb-dependent value with constructor *********************************
let(
  $this_verb    = FL_ADD,
  $fl_tolerance = fl_parm_MultiVerb([
    [FL_ADD,        0.1],
    [FL_FOOTPRINT,  0.2]
  ]),
  attended      = 0.1,
  result        = fl_parm_tolerance()
) assert(result==attended,result);

let(
  $this_verb    = FL_DRILL,
  $fl_tolerance = fl_parm_MultiVerb([
    [FL_ADD,        0.1],
    [FL_FOOTPRINT,  0.2]
  ]),
  attended      = 0,
  result        = fl_parm_tolerance()
) assert(result==attended,result);

let(
  $this_verb    = FL_DRILL,
  $fl_tolerance = undef,
  attended      = 0,
  result        = fl_parm_tolerance(0)
) assert(result==attended,result);

// **** default values order **************************************************

let(
  $this_verb    = FL_DRILL,
  $fl_tolerance = fl_parm_MultiVerb([
    [FL_ADD,        .1],
    [FL_FOOTPRINT,  .2],
    ["*",           .3]
  ]),
  attended      = 0.3,
  result        = fl_parm_tolerance()
) assert(result==attended,result);

let(
  $this_verb    = FL_DRILL,
  // $fl_tolerance = undef,
  attended      = 0.4,
  result        = fl_parm_tolerance(.4)
) assert(result==attended,result);

let(
  $this_verb    = FL_DRILL,
  // $fl_tolerance = undef,
  attended      = 0,
  result        = fl_parm_tolerance()
) assert(result==attended,result);
