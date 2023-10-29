/*
 * Base string test
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/foundation/core.scad>

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

//**** fl_list_max() *********************************************************

let(
  list      = [],
  expected  = undef,
  result    = fl_list_max(list)
) assert(result==expected,result) echo(result=result);

let(
  list      = [7],
  expected  = 7,
  result    = fl_list_max(list)
) assert(result==expected,result) echo(result=result);

let(
  list      = [-2, 5, 0, 7],
  expected  = 7,
  result    = fl_list_max(list)
) assert(result==expected,result) echo(result=result);

//**** fl_list_min() *********************************************************

let(
  list      = [],
  expected  = undef,
  result    = fl_list_min(list)
) assert(result==expected,result) echo(result=result);

let(
  list      = [7],
  expected  = 7,
  result    = fl_list_min(list)
) assert(result==expected,result) echo(result=result);

let(
  list      = [-2, 5, 0, 7],
  expected  = -2,
  result    = fl_list_min(list)
) assert(result==expected,result) echo(result=result);

