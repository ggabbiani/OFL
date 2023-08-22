/*
 * Lists tests
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../lib/OFL/foundation/defs.scad>

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
