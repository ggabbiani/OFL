/*!
 * Verb management for OpenSCAD Foundation Library.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <defs.scad>

/*!
 * manage verbs parsing, placement, orientation and fl_axes{}
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
  D,
  //! size used for fl_axes{}
  size,
  //! see constructor fl_parm_Debug()
  debug,
  //! list of connectors to debug
  connectors,
  //! list of holes to debug
  holes,
  /*!
   * direction [director,rotation], when undef the debug flag will be ignored
   * for the direction symbol
   */
  direction,
  /*!
   * Native Coordinate System when different from the default [+Z,+X]
   *
   * TODO: remove the [director,rotor] definition and use always the default
   */
  ncs = [+FL_Z,+FL_X]
) {
  assert(!fl_debug() || D);

  M = M ? M : FL_I;
  D = D ? D : FL_I;

  module context(vlist) {
    assert(is_list(vlist)||is_string(vlist),vlist);
    flat  = fl_list_flatten(is_list(vlist)?vlist:[vlist]);
    let(
      $_axes_   = fl_list_has(flat,FL_AXES),
      $_verbs_  = fl_list_filter(flat,FL_EXCLUDE_ANY,FL_AXES)
    ) children();
  }

  // parse verbs and trigger children with predefined context (see module fl_manage())
  module parse(verbs) {

    // given a verb returns the corresponding modifier value
    function verb2modifier(verb)  =
        verb==FL_ADD        ? $FL_ADD
      : verb==FL_ASSEMBLY   ? $FL_ASSEMBLY
      : verb==FL_AXES       ? $FL_AXES
      : verb==FL_BBOX       ? $FL_BBOX
      : verb==FL_CUTOUT     ? $FL_CUTOUT
      : verb==FL_DRILL      ? $FL_DRILL
      : verb==FL_FOOTPRINT  ? $FL_FOOTPRINT
      : verb==FL_HOLDERS    ? $FL_HOLDERS
      : verb==FL_LAYOUT     ? $FL_LAYOUT
      : verb==FL_MOUNT      ? $FL_MOUNT
      : verb==FL_PAYLOAD    ? $FL_PAYLOAD
      : assert(false,str("Unsupported verb ",verb)) undef;

    assert(is_list(verbs)||is_string(verbs),verbs);
    for($verb=verbs) {
      tokens  = split($verb);
      fl_trace(tokens[0]);
      if (fl_isSet("**DEPRECATED**",tokens)) {
        fl_trace(str("***WARN*** ", tokens[0], " is marked as DEPRECATED and will be removed in future version!"),always=true);
      } else if (fl_isSet("**OBSOLETE**",tokens)) {
        assert(false,str(tokens[0], " is marked as OBSOLETE!"));
      } let(
        $modifier = verb2modifier($verb)
      ) if ($modifier!="OFF") children();
    }
  }

  multmatrix(D) context(verbs) union() {
    multmatrix(M) union() {
      if (debug) {
        if (connectors)
          fl_conn_debug(connectors,debug=debug);
        if (holes)
          fl_hole_debug(holes,debug=debug);
      }
      parse($_verbs_) children();
    }
    if ($_axes_ && size)
      fl_modifier($FL_AXES) {
        sz = 1.2*size;
        fl_axes(size=sz);
        echo(direction=direction);
        echo(debug=debug);
        if (direction && fl_parm_symbols(debug))
          fl_sym_direction(ncs=ncs,direction=direction,size=sz);
      }
  }
}
