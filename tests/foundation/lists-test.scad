/*
 * Lists tests
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
  list    = ["one","two","three"],
  result  = fl_pop(list)
) assert(len(result)==len(list)-1) echo(list=list,i=0,result=result);

let(
  list    = ["one","two","three"],
  i       = 1,
  result  = fl_pop(list,i)
) assert(len(result)==len(list)-(i+1)) echo(list=list,i=i,result=result);

let(
  list    = ["one","two","three"],
  i       = 2,
  result  = fl_pop(list,i)
) assert(len(result)==len(list)-(i+1)) echo(list=list,i=i,result=result);

let(
  list    = ["one","two","three"],
  result  = fl_push(list,"four")
) assert(len(result)==len(list)+1) echo(list=list,result=result);
