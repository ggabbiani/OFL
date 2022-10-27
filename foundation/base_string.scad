/*!
 * string utility implementation file.
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
 * along with OFL.  If not, see <http://www.gnu.org/licenses/>.
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

//! recursively flatten infinitely nested list
function fl_list_flatten(list) =
  assert(is_list(list))
  [
    for (i=list) let(sub = is_list(i) ? fl_list_flatten(i) : [i])
      for (i=sub) i
  ];

//! see fl_list_filter() «operator» parameter
FL_EXCLUDE_ANY  = ["AND",function(one,other) one!=other];
//! see fl_list_filter() «operator» parameter
FL_INCLUDE_ALL  = ["OR", function(one,other) one==other];

function fl_list_filter(list,operator,compare,__result__=[],__first__=true) =
// echo(list=list,compare=compare,operator=operator,__result__=__result__,__first__=__first__)
assert(is_list(list)||is_string(list),list)
assert(is_list(compare)||is_string(compare),compare)
let(
  s_list  = is_list(list) ? list : [list],
  c_list  = is_string(compare) ? [compare] : compare,
  len     = len(c_list),
  logic   = operator[0],
  f       = operator[1],
  string  = c_list[0],
  match   = [for(item=(logic=="OR" || __first__) ? s_list:__result__) if (f(item,string)) item],
  result  = (logic=="OR") ? concat(__result__,match) : match
)
// echo(match=match, result=result)
len==1 ? result : fl_list_filter(s_list,operator,[for(i=[1:len-1]) c_list[i]],result,false);

function fl_list_has(list,item) = len(fl_list_filter(list,FL_INCLUDE_ALL,item))>0;
