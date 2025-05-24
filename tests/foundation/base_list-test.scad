/*
 * Base list test
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
include <../../lib/OFL/foundation/unsafe_defs.scad>

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

//**** fl_list_filter() *******************************************************

// extracts numbers from an heterogeneous item list
let(
  list      = ["a", 4, -1, false, 5, "a string"],
  expected  = [4, -1, 5],
  result    = fl_list_filter(list,function(item) is_num(item))
) assert(result==expected,result) echo(result=result);

// no filter ⇒ verbatim copy
let(
  list    = ["a", 4, -1, false, 5, "a string"],
  result  = fl_list_filter(list)
) assert(result==list,result) echo(result=result);

// extracts values inside an open interval
let(
  // «interval()» creates a filter checking values between «low» and «high»
  interval  = function(low,high) function(item) item>low && item<high,
  list      = [for(i=[-10:10]) i],
  expected  = [-1, 0, 1, 2],
  result    = fl_list_filter(list,interval(-2,3))
) assert(result==expected,result) echo(result=result);

// exclude any matching strings from a string list
let(
  verbs   = [FL_ADD,FL_AXES,FL_BBOX,FL_AXES],
  // «exclude()» builds a filter discarding any «verb» occurrence
  exclude = function(verb) function(item) item!=verb,
  result  = fl_list_filter(verbs,exclude(FL_AXES))
) assert(result==[FL_ADD,FL_BBOX]) echo(result=result);

// include all matching strings from a string list
let(
  verbs   = [FL_ADD,FL_AXES,FL_BBOX,FL_AXES],
  // «include()» builds a filter accepting all «verb» occurrences
  include = function(verb) function(item) item==verb,
  result  = fl_list_filter(verbs,include(FL_AXES))
) assert(result==[FL_AXES,FL_AXES]) echo(result=result);

// include items matching two conditions
let(
  list      = ["a", 4, -1, false, 5, "a string"],
  expected  = [4,5],
  result  = fl_list_filter(list,[
    function(item) is_num(item),// check if number (first)
    function(item) item>0       // check if positive (last)
  ])
) assert(result==expected,result) echo(result=result);

let(
  list = ["POWER IN", "HDMI0", "HDMI1", "A/V", "USB2", "USB3", "ETHERNET", "GPIO", "uSD", "PIM TOP", "PIM BOT"],
  expected    = ["HDMI0", "HDMI1"],
  or_filters  = ["HDMI0", "HDMI1"],
  result = fl_list_filter(list,function(item) item==or_filters[0] || item==or_filters[1])
) assert(result==expected,result);

//**** fl_list_head() *********************************************************

let(
  list      = [1,2,3,4,5,6,7,8,9,10],
  expected  = [1,2,3],
  result    = fl_list_head(list,3)
) assert(result==expected,result);

let(
  list      = [1,2,3,4,5,6,7,8,9,10],
  expected  = [1,2,3],
  result    = fl_list_head(list,-7)
) assert(result==expected,result);

let(
  list      = [1],
  expected  = [],
  result    = fl_list_head(list,-1)
) assert(result==expected,result);

let(
  list      = [1],
  expected  = [1],
  result    = fl_list_head(list,1)
) assert(result==expected,result);

//**** fl_list_tail() *********************************************************

let(
  list      = [1,2,3,4,5,6,7,8,9,10],
  expected  = [8,9,10],
  result    = fl_list_tail(list,3)
) assert(result==expected,result);

let(
  list      = [1,2,3,4,5,6,7,8,9,10],
  expected  = [8,9,10],
  result    = fl_list_tail(list,-7)
) assert(result==expected,result);

let(
  list      = [1],
  expected  = [],
  result    = fl_list_tail(list,-1)
) assert(result==expected,result);

let(
  list      = [1],
  expected  = [1],
  result    = fl_list_tail(list,1)
) assert(result==expected,result);

//**** fl_list_pack() *********************************************************

let(
  labels = ["label 1", "label 2", "label 3"],
  values = [1, 2, 3],
  result = fl_list_pack(labels,values),
  expected = [
    ["label 1",  1  ],
    ["label 2",  2  ],
    ["label 3",  3  ]
  ]
) assert(result==expected) echo(result=result);

let(
  labels = ["label 1", "label 2", "label 3", "label 4"],
  values = [1, 2, 3],
  result = fl_list_pack(labels,values),
  expected = [
    ["label 1",  1      ],
    ["label 2",  2      ],
    ["label 3",  3      ],
    ["label 4",  undef  ]
  ]
) assert(result==expected) echo(result=result);

let(
  labels = ["label 1", "label 2", "label 3"],
  values = [1, 2, 3, 4],
  result = fl_list_pack(labels,values),
  expected = [
    ["label 1",  1    ],
    ["label 2",  2    ],
    ["label 3",  3    ],
    [undef    ,  4    ]
  ]
) assert(result==expected) echo(result=result);

//**** fl_dict_organize() *****************************************************

let(
  dict = [
    ["first", 7],
    ["second",9],
    ["third", 9],
    ["fourth",2],
    ["fifth", 2],
  ],
  result    = fl_dict_organize(dictionary=dict, range=[0:10], func=function(item) item[1]),
  expected  = [
    [], // 0
    [], //  1
    [   //  2
      ["fourth", 2],
      ["fifth",  2]
    ],
    [], // 3
    [], // 4
    [], // 5
    [], // 6
    [   // 7
      ["first", 7]
    ],
    [], // 8
    [   // 9
      ["second", 9], ["third", 9]
    ],
    []  // 10
  ]
) assert(result==expected,result) echo(result=result);

let(
  dict = [
    [fl_name(value="first"),  ["length",  7 ]],
    [fl_name(value="second"), ["length", 9  ]],
    [fl_name(value="third"),  ["length",  9 ]],
    [fl_name(value="fourth"), ["length", 2  ]],
    [fl_name(value="fifth"),  ["length",  2 ]],
  ],
  result    = fl_dict_organize(dictionary=dict, range=[0:10], func=function(item) fl_property(item,"length")),
  expected  = [
    [], // length 0
    [], // length 1
    [   // length 2
      [["name", "fourth"], ["length", 2]],
      [["name", "fifth"], ["length", 2]]
    ],
    [], // length 3
    [], // length 4
    [], // length 5
    [], // length 6
    [   // length 7
      [["name", "first"], ["length", 7]]
    ],
    [], // length 8
    [   // length 9
      [["name", "second"], ["length", 9]], [["name", "third"], ["length", 9]]
    ],
    []  // length 10
  ]
) assert(result==expected,result) echo(result=result);

//**** fl_list_transform() ****************************************************

let(
  list    = [[1,2],[3,4],[5,6]],
  t       = [1,2],
  M       = fl_T(t),
  result  = fl_list_transform(list,M,function(2d) [2d.x,2d.y,0],function(3d) [3d.x,3d.y]),
  expected = [for(item=list) item+t]
) assert(result==expected,result);

//**** fl_list_AND() **********************************************************

let(
  a         = [   +X,+Y,-Y,-Z],
  b         = [-X      ,-Y,-Z],
  result    = fl_list_AND(a,b),
  expected  = [-Y,-Z]
) assert(result==expected,result);

