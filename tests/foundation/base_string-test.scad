/*
 * Type traits test file.
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
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

include <../../foundation/base_string.scad>

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
