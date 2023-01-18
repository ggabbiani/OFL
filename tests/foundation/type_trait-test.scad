/*
 * Type traits test file.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../foundation/type_trait.scad>
include <../../foundation/unsafe_defs.scad>
// include <../../foundation/hole.scad>

assert(fl_tt_isInDictionary("inexistent",["key1","key2","key3"])==false);
assert(fl_tt_isInDictionary("key2",["key1","key2","key3"]));

assert(fl_tt_isKV(["key",1],dictionary=["badula"])==false);
assert(fl_tt_isKV(["key2",1],dictionary=["key1","key2","key3"]));


assert(fl_tt_isKVList([]));
assert(fl_tt_isKVList([["first",1],["second",2]]));
assert(fl_tt_isKVList([["first",1],["second"]])==false);

assert(fl_tt_isKVList([],f=function (value) is_num(value)));
assert(fl_tt_isKVList([["first",1],["second","2"]],f=function (x) is_num(x))==false);
assert(fl_tt_isKVList([["first","1"],["second","2"]],f=function (x) is_string(x)));
assert(fl_tt_isKVList([["first","1"],["second",2]],f=function (x) is_string(x))==false);
assert(fl_tt_isKVList([["first",1],["second",2]],f=function (x) is_num(x)));
assert(fl_tt_isKVList([["first",1],["second"]],f=function (x) is_num(x))==false);

assert(fl_tt_isKV(["key",1])==true);
assert(fl_tt_isKV(["key","1"])==true);
assert(fl_tt_isKV(["key","1",2])==false);

assert(fl_tt_isKV(["key",1],f=function (value) is_num(value))==true);
assert(fl_tt_isKV(["key",1],f=function (value) is_string(value))==false);
assert(fl_tt_isKV(["key",[1,2,3,4]],f=function (value) is_string(value))==false);
assert(fl_tt_isKV(["key",[1,2,3,4]],f=function (value) is_list(value))==true);

free_ko = [
];

assert(fl_tt_isAxisKVList([]));
assert(fl_tt_isAxisKVList([["shit",2]])==false);
assert(fl_tt_isAxisKVList([["-x",2]]));
assert(fl_tt_isAxisKVList([["-x",2],["+Z",3]]));
assert(fl_tt_isAxisKVList([["-x",2],["+Z",3],["-y","wrong"]])==false);

assert(fl_tt_isList([],function (value) is_num(value))==true);
assert(fl_tt_isList([1,2,3,4],function (value) is_num(value))==true);

assert(fl_tt_isAxisVList([])==false);
assert(fl_tt_isAxisVList([[1,2],[],[5,6]])==false);
assert(fl_tt_isAxisVList([[1,2],[3,4],[5]])==false);
assert(fl_tt_isAxisVList([[1,2],[3,4],[5,6]]));
assert(fl_tt_isAxisVList([[1,2],[5,6]])==false);
assert(fl_tt_isAxisVList([[1,"2"],[3,4],[5,6]])==true);

assert(fl_tt_isPointNormal([[1,2,3],[1,0,0]]));
assert(fl_tt_isPointNormal([[1,2,3],4])==false);
assert(fl_tt_isPointNormal([3,[1,0,0]])==false);

assert(
  fl_tt_isPointNormalList([
    [[ 24.5, 3.5,  0 ],[0,0,1]],
    [[ 24.5, 61.5, 0 ],[1,0,0]],
    [[-24.5, 3.5,  0 ],[0,1,0]],
  ])
);

// holes
// assert(fl_tt_isHole(fl_Hole([1,2,3]))==false);
// assert(fl_tt_isHole(fl_Hole(2.7))==false);
// assert(fl_tt_isHole(fl_Hole([1,2,3],2.7,[1,0,0]))==true);
// assert(fl_tt_isHole(fl_Hole([1,2,3],2.7,[1,0,0],5))==true);
// assert(fl_tt_isHole(fl_Hole([1,2,3],2.7,[1,0,0],"5"))==false);
// assert(fl_tt_isHole(fl_Hole([1,2,3],2.7,[1,0,0],5,[]))==false);
// assert(fl_tt_isHole(fl_Hole([1,2,3],2.7,[1,0,0],5,"string"))==false);
// assert(fl_tt_isHole(fl_Hole([1,2,3],2.7,[1,0,0],5,-2))==false);
// assert(fl_tt_isHole(fl_Hole([1,2,3],2.7,[1,0,0],5,[["key1","value"],["key2",2]]))==true);

// axis lists

let(
  axes  = [-X,+X,-Y,+Y,-Z,+Z],
  r     = fl_tt_isAxisList(axes)
) assert(r,axes);

let(
  axes  = [],
  r     = fl_tt_isAxisList(axes)
) assert(r,axes);

let(
  axes  = [[1,2,3],-Z],
  r     = fl_tt_isAxisList(axes)
) assert(!r,axes);
