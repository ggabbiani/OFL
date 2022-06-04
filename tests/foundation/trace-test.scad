/*
 * Trace test.
 *
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL).
 *
 * OFL is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * OFL is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with OFL.  If not, see <http: //www.gnu.org/licenses/>.
 */
include <../../foundation/base_trace.scad>

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
