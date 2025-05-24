/*
 * Various 3d functions tests
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

include <../../lib/OFL/foundation/unsafe_defs.scad>
use <../../lib/OFL/foundation/3d-engine.scad>

// **** TAB_Debug *************************************************************

/* [Debug] */

// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES        = -2;     // [-2:10]
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

/******************************************************************************
 * Full semi-axis value list constructor from key/value list
 */

let(
  kvs       = [
    ["±x",1],
    ["±y",2],
    ["±z",3],
  ],
  expected  = [
    [1,1],
    [2,2],
    [3,3]
  ],
  result    = fl_3d_AxisVList(kvs=kvs)
) echo(result=result) assert(result==expected,result);

let(
  kvs       = [
    ["±X",1],
    ["±Y",2],
    ["±Z",3],
  ],
  expected  = [
    [1,1],
    [2,2],
    [3,3]
  ],
  result    = fl_3d_AxisVList(kvs=kvs)
) echo(result=result) assert(result==expected,result);

let(
  kvs       = [
    ["-x",1],
    ["+x",2],
    ["-y",3],
    ["+y",4],
    ["-z",5],
    ["+z",6],
  ],
  expected  = [
    [1,2],
    [3,4],
    [5,6]
  ],
  result    = fl_3d_AxisVList(kvs=kvs)
) echo(result=result) assert(result==expected,result);

let(
  kvs       = [
    ["-X",1],
    ["+X",2],
    ["-Y",3],
    ["+Y",4],
    ["-Z",5],
    ["+Z",6],
  ],
  expected  = [
    [1,2],
    [3,4],
    [5,6]
  ],
  result    = fl_3d_AxisVList(kvs=kvs)
) echo(result=result) assert(result==expected,result);

let(
  kvs       = [
  ],
  expected  = [
    [0,0],
    [0,0],
    [0,0]
  ],
  result    = fl_3d_AxisVList(kvs=kvs)
) echo(result=result) assert(result==expected,result);

let(
  kvs       = [
    ["+x",1],
    ["±z",5],
  ],
  expected  = [
    [0,1],
    [0,0],
    [5,5]
  ],
  result    = fl_3d_AxisVList(kvs=kvs)
) echo(result=result) assert(result==expected,result);

/******************************************************************************
 * Full boolean semi-axis value list constructor from literal semi-axis list
 */

let(
  axes      = ["±x","±y","±z"],
  expected  = [
    [true,true],
    [true,true],
    [true,true],
  ],
  result    = fl_3d_AxisVList(axes=axes)
) echo(result=result) assert(result==expected,result);

let(
  axes      = ["+x","±y"],
  expected  = [
    [false, true  ],
    [true,  true  ],
    [false, false ],
  ],
  result    = fl_3d_AxisVList(axes=axes)
) echo(result=result) assert(result==expected,result);

/******************************************************************************
 * Full boolean semi-axis value list: get value from axis
 */

let(
  values    = [
    [0,1],
    [2,3],
    [4,5],
  ],
  axis      = -Z,
  expected  = 4,
  result    = fl_3d_axisValue(axis,values)
) echo(result=result) assert(result==expected,result);

let(
  values    = [
    [true,  false ],
    [false, true  ],
    [false, false ],
  ],
  axis      = +Y,
  expected  = values[1][1],
  result    = fl_3d_axisValue(axis,values)
) echo(result=result) assert(result==expected,result);

let(
  values    = [
    ["zero",  "one"   ],
    ["two",   "three" ],
    ["four",  "five"  ],
  ],
  axis      = -Z,
  expected  = values[2][0],
  result    = fl_3d_axisValue(axis,values)
) echo(result=result) assert(result==expected,result);

/******************************************************************************
 * Semi-axis list from axis literals list
 */

let(
  values    = [],
  expected  = [],
  result    = fl_3d_AxisList(values)
) echo(result=result) assert(result==expected,result);

let(
  values    = ["-X","+z","±y"],
  expected  = [[-1,0,0],[0,-1,0],[0,+1,0],[0,0,+1]],
  result    = fl_3d_AxisList(values)
) echo(result=result) assert(result==expected,result);

let(
  values    = ["-X","+x","±y"],
  expected  = [[-1,0,0],[+1,0,0],[0,-1,0],[0,+1,0]],
  result    = fl_3d_AxisList(values)
) echo(expected=expected) assert(result==expected,result);

let(
  values    = ["-x","+X","±y"],
  expected  = [[-1,0,0],[+1,0,0],[0,-1,0],[0,+1,0]],
  result    = fl_3d_AxisList(values)
) echo(expected=expected) assert(result==expected,result);

/******************************************************************************
 * semi-axis lists
 */

let(
  list      = fl_3d_AxisList(["-x","+X","±y"]),
  result    = fl_3d_axisIsSet(-X,list),
  expected  = true
) echo(expected=expected) assert(result==expected,result);

let(
  list      = fl_3d_AxisList(["-x","+X","±y"]),
  result    = fl_3d_axisIsSet(-Z,list),
  expected  = false
) echo(expected=expected) assert(result==expected,result);

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

//**** median value along reference axes **************************************

// median x-value of an odd unordered 2d/3d point list
let(
  list      = [[-2,4],[-6,2],[1,10],[20,4],[15,7]],
  result    = fl_3d_medianValue(list,X),
  expected  = 1
) echo(expected=expected) assert(result==expected,result);

// median x-value of an even unordered 2d/3d point list
let(
  list      = [[-2,4],[-6,2],[20,4],[15,7]],
  result    = fl_3d_medianValue(list,X),
  expected  = 6.5
) echo(expected=expected) assert(result==expected,result);

//**** closest points *********************************************************

let(
  rnd = function(value) round(value*100000)/100000,
  res = function(expected,result) str("expected=",expected,"; ","result=",result,"; difference=",is_undef(expected)||is_undef(result)?"undef":expected-result)
) {

  // empty 2d/3d point list
  let(
    points    = [],
    result    = fl_2d_closest(points),
    expected  = undef
  ) assert(result==expected,res(expected,result));

  // single 2d/3d point list
  let(
    points    = [[-2,4]],
    result    = fl_2d_closest(points),
    expected  = undef
  ) assert(result==expected,res(expected,result));

  // two unordered 2d/3d point list
  let(
    points    = [[1, 1],[0, 0]],
    result    = fl_2d_closest(points),
    expected  = sqrt(2)
    ) assert(rnd(result)==rnd(expected),res(expected,result));

  // three unordered 2d/3d point list
  let(
    points    = [[20,0],[-2,0],[-6,0]],
    result    = fl_2d_closest(points),
    expected  = 4
  ) assert(rnd(result)==rnd(expected),res(expected,result));

  // four unordered 2d/3d point list
  let(
    points    = [[-1,0],[20,0],[-2,0],[6,0]],
    result    = fl_2d_closest(points),
    expected  = 1
  ) assert(rnd(result)==rnd(expected),res(expected,result));

  // six unordered 2d/3d point list
  let(
    points    = [[2, 3], [12, 30], [40, 50], [5, 1], [12, 10], [3, 4]],
    result    = fl_2d_closest(points),
    expected  = sqrt(2)
  ) assert(rnd(result)==rnd(expected),res(expected,result));

  // unordered 2d/3d (near) point list
  let(
    points    = [[0, 0], [0.1, 0.1], [1, 1], [2, 2]],
    result    = fl_2d_closest(points),
    expected  = sqrt(0.02)
  ) assert(rnd(result)==rnd(expected),res(expected,result));

  // unordered 2d/3d point list with duplicates
  let(
    points    = [[0, 0], [0, 0], [1, 1], [2, 2]],
    result    = round(fl_2d_closest(points)*100000)/100000,
    expected  = 0
  ) assert(rnd(result)==rnd(expected),res(expected,result));
}