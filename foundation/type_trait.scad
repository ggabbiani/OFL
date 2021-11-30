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

function fl_str_upper(s) = let(len=len(s))
  len==0 ? ""
  : len==1 ? let(
      c   = s[0],
      cp  = ord(c),
      uc = cp>=97 && cp<=122 ? str(chr(ord(c)-32)) : c
    ) uc
  : str(fl_str_upper(s[0]),fl_str_upper([for(i=[1:len-1]) s[i]]));

function fl_str_lower(s) = let(
    len=len(s)
  )
  len==0 ? ""
  : len==1 ? let(
      c   = s[0],
      cp  = ord(c),
      lc = cp>=65 && cp<=90 ? str(chr(ord(c)+32)) : c
    ) lc
  : str(fl_str_lower(s[0]),fl_str_lower([for(i=[1:len-1]) s[i]]));

function fl_tt_isList(list,f=function(value) true,size) = let(
    len   = len(list),
    rest  = len>1 ? [for(i=[1:len-1]) list[i]] : []
  ) 
  (
    (size!=undef ? size==len : true) 
    && (len>0 ? f(list[0]) : true)
    && (rest!=[] ? fl_tt_isList(rest,f) : true)
  );

function fl_tt_isInDictionary(string,dictionary,nocase=true) =
  assert(is_string(string))
  let(
    len   = len(dictionary),
    rest  = len>1 ? [for(i=[1:len-1]) dictionary[i]] : []
  ) dictionary==[] ? false 
  : (nocase ? fl_str_lower(string)==fl_str_lower(dictionary[0]) : string==dictionary[0]) || fl_tt_isInDictionary(string,rest);

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

function fl_tt_isKVList(list,dictionary=[],f=function (value) value!=undef,size) =
  fl_tt_isList(list,function (value) fl_tt_isKV(value,dictionary=dictionary,f=f),size);

/*
 * Key/value list of thickness
 *
 * Each item of the list is actually a key/value pair representing thickness 
 * along a given semi-axis. The dimension of this representation is floating
 * from 0 (empty list) to 6 (complete list), both of them being valid list
 * values.
 *
 * example:
 *
 * thick=[["+x",3],["-Z",1.5]];
 * 
 * indicates a thickness of 3mm along +X and of 1.5mm along +Z.
 */
function fl_tt_isThickKVList(list) = 
  assert(len(list)<=6,list)
  fl_tt_isKVList(list,dictionary=["-x","+x","-y","+y","-z","+z"],f=function(value) is_num(value));

/*
 * Full thickness list.
 *
 * Each row is the thickness along one 3d dimension (X,Y and Z) represented as
 * a pair of thickness values for negative/positive direction.
 * Concretely is a 3x2 matrix in which each item is the thickness 
 * along one of the six 3d semi-axes.
 * 
 * example:
 *
 * [[0,3],[0,0],[1.5,0]]
 *
 * indicates a thickness of 3mm along +X, 1.5mm along -Z and 0mm otherwise.
 */
function fl_tt_isThickList(list) = 
  fl_tt_isList(
    list,size=3,
    f=function(x) fl_tt_isList(
      x,size=2,
      f=function(x) is_num(x)
      )
    );
