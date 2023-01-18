/*
 * Empty file description
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../foundation/3d.scad>

/******************************************************************************
 * Full semi-axis value list contructor from key/value list
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
 * Full boolean semi-axis value list contructor from literal semi-axis list
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
