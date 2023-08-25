/*
 * Type traits test file.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../lib/OFL/foundation/core.scad>

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
