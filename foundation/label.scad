/*
 * Template file for OpenSCAD Foundation Library.
 *
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL).
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

include <3d.scad>

/**
 * mimics standard resize() module behaviour
 */
// TODO: either remove or move elsewhere
function fl_resize(oldsize,newsize,auto=false) =
  assert(oldsize)
  assert(newsize!=undef)
  let(
    len     = len(oldsize),
    auto    = let(a=is_list(auto) ? auto : [auto,auto,auto]) assert(is_bool(a.x) && is_bool(a.y) && is_bool(a.z)) a,
    leader  = let(v=[for(i=[0:len-1]) if (auto[i] && newsize[i]) newsize[i]/oldsize[i]]) len(v)==1 ? v[0] : undef
  ) leader  ? [for(i=[0:len-1]) auto[i] ? leader*oldsize[i] : newsize[i] ? newsize[i] : oldsize[i]]
            : [newsize.x ? newsize.x : oldsize.x,newsize.y ? newsize.y : oldsize.y,newsize.z ? newsize.z : oldsize.z];

/**
 * modify position according to size modifications
 */
// TODO: likely to be removed
function fl_repos(oldpos,oldsize,newsize) =
  assert(oldpos)
  assert(oldsize)
  assert(newsize)
  let(
    len   = len(oldpos),
    facts = [for(i=[0:len-1]) echo(newsize[i]) newsize[i]/oldsize[i]]
  ) [for(i=[0:len-1]) facts[i]*oldpos[i]];

module fl_label(
  // supported verbs: FL_ADD, FL_AXES
  verbs   = FL_ADD,
  string,
  fg      = "white",
  // font y-size
  size,
  // depth along z-axis
  thick,
  // extra delta to add to octant placement
  extra=0,
  // when undef native positioning is used
  octant,
  // desired direction [director,rotation] or native direction if undef
  direction
) {
  assert(is_list(verbs)||is_string(verbs));
  assert(is_num(thick));

  bbox  = [O,Z(thick)];
  M     = octant ? T(extra*[sign(octant.x),sign(octant.y),sign(octant.z)]) * fl_octant(octant=[0,0,octant.z],bbox=bbox) : I;
  D     = direction ? fl_direction(direction=direction,default=[+Z,+X])  : I;

  halign  = is_undef(octant) || octant.x==1 ? "left"    : !octant.x ? "center" : "right";
  valign  = is_undef(octant) || octant.y==1 ? "bottom"  : !octant.y ? "center" : "top";

  module do_add() {
    // translate(+Z(NIL))
      fl_color(fg)
        resize([0,size,thick],auto=true)
          linear_extrude(thick)
            text(string, valign=valign, halign=halign);
  }

  fl_manage(verbs,M,D,size=size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
