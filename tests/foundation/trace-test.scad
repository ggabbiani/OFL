/*
 * Trace test
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

module one() {
  fl_trace("Module one message!");
  two();
}

module two() {
  fl_trace("Module two message!");
  three();
}

module three() {
  function test() = let(
    result  = -1
  ) fl_trace("Function test() result",result);

  dummy=test();
  fl_trace("dummy",dummy);
  fl_trace("Mandatory message from module three!",always=true);
}

fl_trace("Program root message!");
one();
