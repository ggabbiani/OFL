/*!
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <3d-engine.scad>

/*!
 * mimics standard resize() module behavior
 *
 * TODO: either remove or move elsewhere
 */
function fl_resize(oldsize,newsize,auto=false) =
  assert(oldsize)
  assert(newsize!=undef)
  let(
    len     = len(oldsize),
    auto    = let(a=is_list(auto) ? auto : [auto,auto,auto]) assert(is_bool(a.x) && is_bool(a.y) && is_bool(a.z)) a,
    leader  = let(v=[for(i=[0:len-1]) if (auto[i] && newsize[i]) newsize[i]/oldsize[i]]) len(v)==1 ? v[0] : undef
  ) leader  ? [for(i=[0:len-1]) auto[i] ? leader*oldsize[i] : newsize[i] ? newsize[i] : oldsize[i]]
            : [newsize.x ? newsize.x : oldsize.x,newsize.y ? newsize.y : oldsize.y,newsize.z ? newsize.z : oldsize.z];

/*!
 * modify position according to size modifications
 *
 * TODO: likely to be removed
 */
function fl_repos(oldpos,oldsize,newsize) =
  assert(oldpos)
  assert(oldsize)
  assert(newsize)
  let(
    len   = len(oldpos),
    facts = [for(i=[0:len-1]) echo(newsize[i]) newsize[i]/oldsize[i]]
  ) [for(i=[0:len-1]) facts[i]*oldpos[i]];

module fl_label(
  //! supported verbs: FL_ADD, FL_AXES
  verbs   = FL_ADD,
  //! TODO: rename as «text»
  string,
  fg      = "white",
  //! font y-size
  size,
  //! depth along z-axis
  thick=0.1,
  //! extra delta to add to octant placement
  extra=0,
  //! String. The name of the font that should be used.
  font="Symbola:style=Regular",
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation] or native direction if undef
  direction
) {
  assert(is_list(verbs)||is_string(verbs));
  assert(is_num(thick));

  string  = is_string(string) ? string : is_list(string) ? fl_str_concat(string) : str(string);
  bbox  = [O,Z(thick)];
  M     = let(
    t = T(0.6*extra*[
      octant.x ? sign(octant.x) : 0,
      octant.y ? sign(octant.y) : 0,
      octant.z ? sign(octant.z) : 0
    ])
  ) octant ? t * fl_octant(octant=[0,0,octant.z],bbox=bbox) : I;
  D     = direction ? fl_direction(direction)  : I;

  halign  = is_undef(octant) || octant.x==1 ? "left"    : !octant.x ? "center" : "right";
  valign  = is_undef(octant) || octant.y==1 ? "bottom"  : !octant.y ? "center" : "top";

  module do_add() {
    // translate(+Z(NIL))
      fl_color(fg)
        resize([0,size,thick],auto=true)
          linear_extrude(thick)
            text(string, valign=valign, halign=halign, font=font);
  }

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD)
      fl_modifier($modifier) do_add();
    else if ($verb==FL_AXES)
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction);
    else
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
  }
}
