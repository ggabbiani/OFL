/*
 * Type traits implementation file.
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
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

include <base_string.scad>

/**
 * return true when «list» is a list and each item satisfy f(value)
 */
function fl_tt_isList(
    // list to be verified
    list,
    // check function
    f=function(value) true,
    // optional list size
    size
  ) = let(
    len   = assert(is_list(list),list) len(list),
    rest  = len>1 ? [for(i=[1:len-1]) list[i]] : []
  )
  (
    (size!=undef ? size==len : true)
    && (len>0 ? f(list[0]) : true)
    && (rest!=[] ? fl_tt_isList(rest,f) : true)
  );

/**
 * true if «string» appears in «dictionary»
 */
function fl_tt_isInDictionary(string,dictionary,nocase=true) =
  assert(is_string(string))
  let(
    len   = len(dictionary),
    rest  = len>1 ? [for(i=[1:len-1]) dictionary[i]] : []
  ) dictionary==[] ? false
  : (nocase
    ? fl_str_lower(string)==fl_str_lower(dictionary[0])
    : string==dictionary[0]
    ) || fl_tt_isInDictionary(string,rest,nocase);

/**
 * true if «kv» is a key/value pair satisfying f(value)
 */
function fl_tt_isKV(kv,dictionary=[],f=function (value) value!=undef) =
  assert(fl_tt_isList(dictionary,function(value) is_string(value)))
  let(
    key   = kv[0],
    value = kv[1]
  ) (
    (dictionary ? fl_tt_isInDictionary(key,dictionary) : true)
    && len(kv)==2
    && is_string(key) && f(value)
  );

/**
 * true if «kv» is a key/value pair list with each item satisfying f(value)
 */
function fl_tt_isKVList(list,dictionary=[],f=function (value) value!=undef,size) =
  fl_tt_isList(list,function(value) fl_tt_isKV(value,dictionary=dictionary,f=f),size);

/*
 * Semi-axis Key/value list
 *
 * Each item of the list is actually a key/value pair representing a value
 * associated to one semi-axis. The dimension of this representation is floating
 * from 0 (empty list) to 6 (complete list).
 *
 * example:
 *
 * thick=[["+x",3],["-Z",1.5]];
 *
 * indicates a thickness of 3mm along +X and of 1.5mm along +Z.
 */
function fl_tt_isAxisKVList(list) =
  assert(len(list)<=6,list)
  fl_tt_isKVList(
    list,
    dictionary=["-x","+x","±x","-y","+y","±y","-z","+z","±z"],
    f=function(value) is_num(value)
  );

/*
 * Full semi axis value list.
 *
 * Each row represents values associated to X,Y and Z semi-axes.
 *
 * [
 *  [«-x value»,«+x value»],
 *  [«-y value»,«+y value»],
 *  [«-z value»,«+z value»]
 * ]
 *
 * example:
 *
 * [
 *  [0,3],
 *  [0,0],
 *  [1.5,0]
 * ]
 *
 * indicates a value of 3 along +X, 1.5 along -Z and 0 otherwise.
 */
function fl_tt_isAxisVList(list) =
  fl_tt_isList(
    list,size=3,
    f=function(x) fl_tt_isList(
      x,size=2,
      f=function(x) is_num(x)||is_string(x)||is_bool(x)
      )
    );

/**
 * plane in point-normal format: [<3d point>,<plane normal>]
 */
function fl_tt_isPointNormal(plane) = let(
    point = plane[0],
    n     = plane[1]
  )  (len(plane)==2)
  && (is_list(point) && len(point)==3)
  && (is_list(n) && len(n)==3);

function fl_tt_isPointNormalList(list) =
  fl_tt_isList(list,f=function(plane) fl_tt_isPointNormal(plane));

function fl_tt_isAxisString(s) =
  fl_tt_isInDictionary(
    string=s,
    dictionary=["-x","+x","±x","-y","+y","±y","-z","+z","±z"],
    nocase=true
  );

/**
 * Hole representation as:
 * «3d point»,«plane normal»,«diameter»[,«depth»]
 * NOTE: «depth» is an optional scalar, when absent means thru-hole
 */
function fl_tt_isHole(hole) = let(
    len   = len(hole),
    depth = len==4 ? hole[3] : 0
  )  ((len==4 && is_num(depth)) || (len==3 && depth==0))
  && fl_tt_isPointNormal([hole[0],hole[1]])
  && is_num(hole[2]);

function fl_tt_isHoleList(list) =
  fl_tt_isList(list,f=function(hole) fl_tt_isHole(hole));

function fl_tt_isAxis(axis) = (axis==-X||axis==+X||axis==-Y||axis==+Y||axis==-Z||axis==+Z);

/*
 * Floating semi-axis list.
 *
 * One row with matricial representation of cartesian semi-axes in whatever order.
 *
 * example:
 *
 * [-X,+Z,-Y]
 */
function fl_tt_isAxisList(list) =
  fl_tt_isList(list,f=function(axis) fl_tt_isAxis(axis));