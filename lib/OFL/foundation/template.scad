/*!
 * Template file for OpenSCAD Foundation Library.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <3d-engine.scad>

function __constructor__(description,bbox,holes)  = let(
) [
  fl_native(value=true),
  assert(bbox) fl_bb_corners(value=bbox),
  if (description) fl_description(value=description),
  if (holes) fl_holes(value=holes),
];

module __stub__(
  // supported verbs: FL_ADD, FL_ASSEMBLY, FL_AXES, FL_BBOX, FL_CUTOUT, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT, FL_MOUNT, FL_PAYLOAD
  verbs       = FL_ADD,
  type,
  // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  // when undef native positioning is used
  octant
) {
  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  D     = direction ? fl_direction(direction)  : FL_I;
  M     = fl_octant(octant,bbox=bbox);

  module do_add() {
  }

  module do_assembly() {
  }

  module do_bbox() {
  }

  module do_cutout() {
  }

  module do_drill() {
  }

  module do_fprint() {
  }

  module do_layout() {
    children();
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
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction,debug);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox,$FL_ADD=$FL_BBOX);

    } else if ($verb==FL_CUTOUT) {
      fl_modifier($modifier) do_cutout();

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier) do_drill();

    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) do_fprint();

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout()
        children();

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier) do_mount();

    } else if ($verb==FL_PAYLOAD) {
      fl_modifier($modifier) do_pload();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
