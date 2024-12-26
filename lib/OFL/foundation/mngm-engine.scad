/*!
 * Verb management for OpenSCAD Foundation Library.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <unsafe_defs.scad>

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
 *
 * | Performed actions        | octant  | quadrant  | direction | verbs | bbox    |
 * | ---                      | ---     | ---       | ---       | ---   | ---     |
 * | octant translation       | X       | -         | -         | -     | X       |
 * | quadrant translation     | undef   | X         | -         | -     | X       |
 * | direction transformation | -       | -         | X         | -     | -       |
 * | FL_AXES                  | -       | -         | O         | X     | X       |
 *
 * X: mandatory, O: optional, -: unused
 *
 * Context variables:
 *
 * | Name       | Context   | Description
 * | ---------- | --------- | ---------------------
 * | $verb      | Children  | current parsed verb
 * | $modifier  | Children  | current verb modifier
 */
module fl_vloop(
  //! verb list
  verbs,
  //! mandatory bounding box
  bbox,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef
  direction,
  quadrant,
  do_axes = true
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

  M     = octant ? fl_octant(octant,bbox=bbox) : quadrant ? fl_quadrant(quadrant,bbox=bbox) : I;
  D     = fl_direction(direction);
  size  = bbox ? bbox[1]-bbox[0] : undef;

  multmatrix(D) context(verbs) union() {
    multmatrix(M)
      union()
        parse($_verbs_)
          children();

    // FL_AXES WITHOUT octant transformations (i.e. matrix M)
    if ($_axes_ && do_axes && size) {
      let(
        $verb     = FL_AXES,
        $modifier = fl_verb2modifier($verb)
      ) echo(size=size) fl_doAxes(size,direction);
    }
  }
}
