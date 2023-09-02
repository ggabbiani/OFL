/*!
 * Wrapper for NopSCADlib extrusions defining T-slot structural framing as
 * described [T-slot structural framing](https://en.wikipedia.org/wiki/T-slot_structural_framing)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <NopSCADlib/vitamins/extrusions.scad>
include <../foundation/3d-engine.scad>

use <../foundation/mngm-engine.scad>

//! namespace
__FL_TSP_NS  = "t-slotted profile";

//! constructor
function fl_TProfile(
  name,
  //! verbatim NopSCADlib definition
  nop,
  description
) =
assert(name)
assert(nop)
let(

) [
  fl_name(value=name),
  fl_description(value=description),
  fl_nopSCADlib(value=nop),
];

FL_E1515  = fl_TProfile("E1515", E1515);
FL_E2020  = fl_TProfile("E2020", E2020);
FL_E2020t = fl_TProfile("E2020t",E2020t);
FL_E2040  = fl_TProfile("E2040",E2040);
FL_E2060  = fl_TProfile("E2060",E2060);
FL_E2080  = fl_TProfile("E2080",E2080);
FL_E3030  = fl_TProfile("E3030",E3030);
FL_E3060  = fl_TProfile("E3060",E3060);
FL_E4040  = fl_TProfile("E4040",E4040);
FL_E4040t = fl_TProfile("E4040t",E4040t);
FL_E4080  = fl_TProfile("E4080",E4080);

FL_XTR_DICT = [
  FL_E1515,
  FL_E2020,
  FL_E2020t,
  FL_E2040,
  FL_E2060,
  FL_E2080,
  FL_E3030,
  FL_E3060,
  FL_E4040,
  FL_E4040t,
  FL_E4080
];

module fl_tprofile(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  type,
  length,
  //! see constructor fl_parm_Debug()
  debug,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant,
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(length,length);

  nop   = fl_nopSCADlib(type);
  bbox  = let(
    w = extrusion_width(nop),
    h = extrusion_height(nop)
  ) echo(w=w,h=h) [
    [-w/2,-h/2,-length/2],
    [+w/2,+h/2,+length/2]
  ];
  echo(bbox=bbox);
  size  = bbox[1]-bbox[0];
  D     = direction ? fl_direction(direction) : I;
  M     = fl_octant(octant,bbox=bbox);

  module do_add() {
    extrusion(nop, length, center = true, cornerHole = false);
  }

  module do_assembly() {}
  module do_layout() {}
  module do_drill() {}

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_assembly();

    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction,debug);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout()
        children();

    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier);

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier);

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
