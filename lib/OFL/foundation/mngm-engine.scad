/*!
 * Verb management for OpenSCAD Foundation Library.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <core.scad>

use <3d-engine.scad>

/*!
 * Low-level verb manager: parsing, placement and orientation for low level
 * APIs. Even if generally surpassed by the new polymorph{} module, this module
 * is still necessary when dealing with primitives without a «type» parameter.
 *
 * This module is responsible for spatial basic transformations via «octant» and
 * «direction» parameters. It also intercepts and manages the FL_AXES verb that
 * will never arrive to children.
 *
 * Context variables:
 *
 * | Name       | Context   | Description
 * | ---------- | --------- | ---------------------
 * | $verb      | Children  | current parsed verb
 * | $modifier  | Children  | current verb modifier
 */
module fl_manage(
  //! verb list
  verbs,
  //! placement matrix
  M,
  //! orientation matrix
  D,
  //! mandatory size used for fl_axes()
  size
) {
  module context(verb_list) {
    assert(is_list(verb_list)||is_string(verb_list),verb_list);
    fl_trace(str("prima: ",verb_list));
    flat  = fl_list_flatten(is_list(verb_list)?verb_list:[verb_list]);
    let(
      $_axes_   = fl_list_has(flat,FL_AXES),
      $_verbs_  = fl_list_filter(flat,function(item) item!=FL_AXES)
    ) children();
  }

  // parse verbs and trigger children with predefined context
  module parse(verbs) {
    assert(is_list(verbs)||is_string(verbs),verbs);
    for($verb=verbs) {
      tokens  = fl_split($verb);
      if (fl_isSet("**DEPRECATED**",tokens)) {
        fl_trace(str("***WARN*** ", tokens[0], " is marked as DEPRECATED and will be removed in future version!"),always=true);
      } else if (fl_isSet("**OBSOLETE**",tokens)) {
        assert(false,str(tokens[0], " is marked as OBSOLETE!"));
      }
      let($modifier = fl_verb2modifier($verb))
        children();
    }
  }

  M = M ? M : I;
  D = D ? D : I;

  multmatrix(D) context(verbs) union() {
    multmatrix(M) union()
      parse($_verbs_) children();
    // trigger FL_AXES WITHOUT octant related transformation (i.e. matrix M)
    if ($_axes_)
      assert(size!=undef) let(
        $verb     = FL_AXES,
        $modifier = fl_verb2modifier($verb)
      ) fl_axes(size);
  }
}
