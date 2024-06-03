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
  message   = "error message",
  attended  = "***OFL ERROR***: error message",
  result    = fl_error(message)
) assert(attended==result,result);

let(
  message   = ["this","is","an","error","message"],
  attended  = "***OFL ERROR***: this is an error message",
  result    = fl_error(message)
) assert(attended==result,result);

let(
  message   = ["this","is","an","error","number",str(3)],
  attended  = "***OFL ERROR***: this is an error number 3",
  result    = fl_error(message)
) assert(attended==result,result);
