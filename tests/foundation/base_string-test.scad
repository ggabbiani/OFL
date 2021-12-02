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

use <../../foundation/base_string.scad>

s = "I was A Mixed string!";

assert(fl_str_upper(s)=="I WAS A MIXED STRING!");
assert(fl_str_lower(s)=="i was a mixed string!");

let(r=fl_str_2axes([]))                   assert(r==[],r);
let(r=fl_str_2axes(["+x","-Z"]))          assert(r==[[1,0,0],[0,0,-1]],r);
let(r=fl_str_2axes(["+x","pippo","-Z"]))  assert(r==-1,r);

