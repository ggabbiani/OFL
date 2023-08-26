/*
 * Definition file template for OpenSCAD Foundation Library.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
// include <../foundation/actions.scad>
use <../foundation/mngm-engine.scad>

//! template namespace
__FL_TEMP_NS  = "mag";

__FL_TEMP_DICT = [
];

module __stub__(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  type,
  //! see constructor fl_parm_Debug()
  debug,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant,
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  D     = direction ? fl_direction(direction)  : FL_I;
  M     = fl_octant(octant,bbox=bbox);

  module do_add() {
  }

  module do_assembly() {

  }

  module do_cutout() {

  }

  module do_drill() {

  }

  module do_footprint() {

  }

  module do_layout() {

  }

  module do_mount() {

  }

  module do_pload() {

  }

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_assembly();

    } else if ($verb==FL_AXES) {
      fl_modifier($modifier)
        fl_doAxes(size,direction,debug);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_CUTOUT) {
      fl_modifier($modifier) do_cutout();

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier) do_drill();

    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) do_footprint();

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout()
        children();

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier) do_mount()
        children();

    } else if ($verb==FL_PAYLOAD) {
      fl_modifier($modifier) do_pload()
        children();

    } else if ($verb==FL_SYMBOLS) {
      fl_modifier($modifier) fl_doSymbols()
        children();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
