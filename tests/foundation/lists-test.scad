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

// **** TAB_Debug *************************************************************

/* [Debug] */

// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]
DEBUG_ASSERTIONS  = false;
DEBUG_COMPONENTS  = ["none"];
DEBUG_COLOR       = false;
DEBUG_DIMENSIONS  = false;
DEBUG_LABELS      = false;
DEBUG_SYMBOLS     = false;

// **** TEST_PROLOGUE *********************************************************


$dbg_Assert     = DEBUG_ASSERTIONS;
$dbg_Dimensions = DEBUG_DIMENSIONS;
$dbg_Color      = DEBUG_COLOR;
$dbg_Components = DEBUG_COMPONENTS[0]=="none" ? undef : DEBUG_COMPONENTS;
$dbg_Labels     = DEBUG_LABELS;
$dbg_Symbols    = DEBUG_SYMBOLS;


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

//**** list sort **************************************************************

// x-ascending sort of a 2d/3d point list
let(
  list      = [[-2,4],[-6,2],[1,10],[20,4],[15,7]],
  result    = fl_list_sort(list,function(e1,e2) (e1.x-e2.x)),
  expected  = [[-6,2],[-2,4],[1,10],[15,7],[20,4]]
) echo(expected=expected) assert(result==expected,result);

// x-descending sort of a 2d/3d point list
let(
  list      = [[-2,4],[-6,2],[1,10],[20,4],[15,7]],
  result    = fl_list_sort(list,function(e1,e2) (e2.x-e1.x)),
  expected  = [[20,4],[15,7],[1,10],[-2,4],[-6,2]]
) echo(expected=expected) assert(result==expected,result);

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
