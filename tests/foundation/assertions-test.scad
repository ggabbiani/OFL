/*
 * Assertion tests
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
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

