/*!
 * Verb management for OpenSCAD Foundation Library.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <core.scad>

/*!
 * manage verbs parsing, placement and orientation
 *
 * children context:
 *
 * - $verb    : current parsed verb
 * - $modifier: current verb modifier
 */
module fl_manage(
  //! verb list
  verbs,
  //! placement matrix
  M,
  //! orientation matrix
  D
) {
  assert(!fl_debug() || D);

  module context(verb_list) {
    assert(is_list(verb_list)||is_string(verb_list),verb_list);
    flat  = fl_list_flatten(is_list(verb_list)?verb_list:[verb_list]);
    let(
      $_axes_   = fl_list_has(flat,FL_AXES),
      $_verbs_  = fl_list_filter(flat,function(item) item!=FL_AXES)
    ) children();
  }

  // parse verbs and trigger children with predefined context
  module parse(verbs) {
    assert(is_list(verbs)||is_string(verbs),verbs);
    fl_trace("verbs",verbs);
    for($verb=verbs) {
      tokens  = split($verb);
      fl_trace("tokens[0]",tokens[0]);
      if (fl_isSet("**DEPRECATED**",tokens)) {
        fl_trace(str("***WARN*** ", tokens[0], " is marked as DEPRECATED and will be removed in future version!"),always=true);
      } else if (fl_isSet("**OBSOLETE**",tokens)) {
        assert(false,str(tokens[0], " is marked as OBSOLETE!"));
      }
      let($modifier = fl_verb2modifier($verb))
        children();
    }
  }

  M = M ? M : FL_I;
  D = D ? D : FL_I;

  fl_trace("verbs",verbs);
  multmatrix(D) context(verbs) union() {
    multmatrix(M) union()
      parse($_verbs_) children();

    // trigger FL_AXES WITHOUT octant related transformation (i.e. matrix M)
    if ($_axes_)
      parse([FL_AXES]) children();
  }
}
