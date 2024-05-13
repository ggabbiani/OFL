/*
 * Assertion tests
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

// **** TEST_PROLOGUE *********************************************************

fl_status();

// end of automatically generated code

let(
  condition   = false,
  message     = "message",
  result      = "test 1"
) assert(fl_assert(condition,message,result)==result);

let(
  condition   = [],
  message     = ["message one","message two","message three"],
  result      = "test 2"
) assert(fl_assert(condition,message,result)==result);

let(
  condition   = [],
  message     = ["message one","message two","message three"],
  result      = "test 3",
  $fl_asserts = true
) assert(fl_assert(condition,message,result)==result);

let(
  condition   = [true,true,true],
  message     = ["message one","message two","message three"],
  result      = "test 4",
  $fl_asserts = true
) assert(fl_assert(condition,message,result)==result);
