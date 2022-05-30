/*
 * Assertion tests
 *
 * Copyright © 2022 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
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

include <../../foundation/defs.scad>

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

// let(
//   condition   = [true,false,true],
//   message     = ["condition one unmet","condition two unmet","condition three unmet"],
//   result      = "test 5",
//   $fl_asserts = true
// ) assert(fl_assert(condition,message,result)==result);

