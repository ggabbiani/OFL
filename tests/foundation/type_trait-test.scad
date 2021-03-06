/*
 * Type traits test file.
 *
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org)
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
