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
function fl_resize(oldsize,newsize,auto=false) =
  assert(oldsize)
  assert(newsize!=undef)
  let(
    len     = len(oldsize),
    auto    = let(a=is_list(auto) ? auto : [auto,auto,auto]) assert(is_bool(a.x) && is_bool(a.y) && is_bool(a.z)) a,
    leader  = let(v=[for(i=[0:len-1]) if (auto[i] && newsize[i]) newsize[i]/oldsize[i]]) len(v)==1 ? v[0] : undef
  ) leader  ? [for(i=[0:len-1]) auto[i] ? leader*oldsize[i] : newsize[i] ? newsize[i] : oldsize[i]]
            : [newsize.x ? newsize.x : oldsize.x,newsize.y ? newsize.y : oldsize.y];

/**
 * modify position according to size modifications
 */
function fl_repos(oldpos,oldsize,newsize) =
  assert(oldpos)
  assert(oldsize)
  assert(newsize)
  let(
    len   = len(oldpos),
    facts = [for(i=[0:len-1]) newsize[i]/oldsize[i]]
  ) [for(i=[0:len-1]) facts[i]*oldpos[i]];

/**
 * calculates the 2d bounding box of a label
 */
function fl_bb_2d_label(
  string,
  halign  = "left",
  valign  = "baseline",
  // when undef the default font rendered label size is used.
  // Otherwise see «newsize» parameter for resize() module.
  size,
  // see «auto» parameter for resize() module
  auto    = false
) = let(
  tm  = textmetrics(string,halign=halign,valign=valign),
  sz  = size ? fl_resize(tm.size,size,auto)     : tm.size,
  pos = size ? fl_repos(tm.position,tm.size,sz) : tm.position,
) [pos,pos+sz];

module fl_2d_label(
  verbs   = FL_ADD,
  string,
  halign  = "left",
  valign  = "baseline",
  // when undef the default font rendered label size is used.
  // Otherwise see «newsize» parameter for resize() module.
  size,
  // see «auto» parameter for resize() module
  auto    = false,
  quadrant
) {
  assert(is_list(verbs)||is_string(verbs));

  bbox  = fl_bb_2d_label(string,halign,valign,size,auto);
  sz    = bbox[1]-bbox[0];
  M     = quadrant ? fl_quadrant(quadrant=quadrant,bbox=bbox) : I;

  module do_add() {
    resize(newsize=sz,auto=auto)
      text(string, valign=valign, halign=halign);
  }

  module do_bbox() {
    translate(bbox[0])
      fl_square(size=sz,quadrant=+X+Y);
  }

  fl_manage(verbs,M,size=sz) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) do_bbox();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

module fl_label(
  // supported verbs: FL_ADD, FL_AXES, FL_BBOX,
  verbs   = FL_ADD,
  string,
  halign  = "left",
  valign  = "baseline",
  fg      = "white",
  bg,
  // when undef the default font rendered label size is used.
  // Otherwise see «newsize» parameter for resize() module.
  size,
  // see «auto» parameter for resize() module
  auto    = false,
  // when undef native positioning is used
  octant  = +X+Y,
  // desired direction [director,rotation] or native direction if undef
  direction
) {
  assert(is_list(verbs)||is_string(verbs));

  bbox    = let(2d=fl_bb_2d_label(string,halign,valign,size,auto)) [
              [2d[0].x,2d[0].y,0],
              [2d[1].x,2d[1].y,NIL2]
            ];
  sz    = bbox[1]-bbox[0];
  M     = octant ? fl_octant(octant=octant,bbox=bbox) : I;
  D     = direction ? fl_direction(direction=direction,default=[+Z,+X])  : I;
  fl_trace("bbox",bbox);
  fl_trace("sz",sz);

  module do_add() {
    fl_color(fg)
      resize(size,true)
      translate(+Z(sz.z/2))
        linear_extrude(sz.z/2)
          fl_2d_label(FL_ADD,string,halign,valign,size,auto);
    if (bg)
      fl_color(bg)
        resize(size,true)
          linear_extrude(sz.z/2)
            fl_2d_label(FL_BBOX,string,halign,valign,size,auto,$FL_BBOX=$FL_ADD);
  }

  module do_bbox()
    resize(size,true)
      fl_bb_add(bbox);

  fl_manage(verbs,M,D,size=sz) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) do_bbox();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
