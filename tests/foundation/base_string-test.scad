/*
 * Base string test
 *
 * NOTE: this file is generated automatically from 'template-nogui.scad', any
 * change will be lost.
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
