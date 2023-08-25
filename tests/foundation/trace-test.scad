/*
 * Trace test.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <../../lib/OFL/foundation/core.scad>

// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;  // [-2:10]

/* [Hidden] */

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

  dummy=test();echo(dummy=dummy);
  fl_trace("dummy",dummy);
  fl_trace("Mandatory message from module three!",always=true);
}

fl_trace("Program root message!");
one();
