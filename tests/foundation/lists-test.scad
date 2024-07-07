/*
 * Lists tests
 *
 * NOTE: this file is generated automatically from 'template-nogui.scad', any
 * change will be lost.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
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

let(
  list      = [0, 1, 2, 3, 4, 4, 1, 2, 3, 3, 2, 3],
  expected  = [0, 1, 2, 3, 4],
  result    = fl_list_sort(fl_list_unique(list))
) assert(result==expected,result);

let(
  list      = [[1,0,0],[0, 0, 1], [0, 0, -1], [0, 0, 1], [0, 0, -1]],
  expected  = [[0, 0, -1], [0, 0, 1],[1,0,0]],
  unique    = fl_list_unique(list),
  result    = fl_list_sort(
    unique,
    function(ax1,ax2) let(
      first=[4,2,1]*ax1,
      second=[4,2,1]*ax2
    ) first-second
  )
) assert(result==expected,result);

//**** median index ***********************************************************

// median x-index of an odd unordered 2d/3d point list
let(
  list      = [[-2,4],[-6,2],[1,10],[20,4],[15,7]],
  result    = fl_list_medianIndex(list),
  expected  = 2
) echo(expected=expected) assert(result==expected,result);

// median x-index of an even 2d/3d point list
let(
  list      = [[-2,4],[-6,2],[20,4],[15,7]],
  result    = fl_list_medianIndex(list),
  expected  = 1
) echo(expected=expected) assert(result==expected,result);
