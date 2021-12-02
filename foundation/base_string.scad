/*
 * string utility implementation file.
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

// converts a list of strings into a list of their represented axes
// in case of error, a message is printed and the returned value is -1.
function fl_str_2axes(slist) = 
  let(
    len   = len(slist),
    s     = len>0 ? fl_str_lower(slist[0]) : undef,
    rest  = len>1 ? [for(i=[1:len-1]) slist[i]] : [],
    this  = s==undef ? []
        : (len(s)!=2 || search(s[0],"+-")==[] || search(s[1],"xyz")==[]) ? -1
        : (s=="+x") ? [+[1,0,0]] : (s=="-x") ?  [-[1,0,0]]
        : (s=="+y") ? [+[0,1,0]] : (s=="-y") ?  [-[0,1,0]] 
        : (s=="+z") ? [+[0,0,1]] :              [-[0,0,1]],
    others = (this!=-1 && this!=[]) ? fl_str_2axes(rest) : undef
  ) (this==-1 || this==[]) ? this  : is_list(others) ?  concat(this,fl_str_2axes(rest)) : others;

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
