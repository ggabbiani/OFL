/*!
 * Vitamin template for OpenSCAD Foundation Library.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../foundation/unsafe_defs.scad>

//! prefix used for namespacing
__FL_TMP_NS  = "tmp";

//! package inventory as a list of pre-defined and ready-to-use 'objects'
__FL_TMP_INVENTORY = [
];

//! helper for new 'object' definition
function __fl_Template(
  //! optional description
  description
)  = let(
  // constructor specific variables
  // ...
) [
  fl_native(value=true),
  if (description) fl_description(value=description),
];

module __fl_template(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  this,
  // ==========================================================================
  // module specific parameters
  parameter,
  // ...
  // ==========================================================================
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction
) {
  // run with an execution context set by fl_vmanage{}
  module engine() let(
    // start of engine specific internal variables
    dummy_var = "whatever you need"
  ) if ($this_verb==FL_ADD) {
      // your code ...

    } else if ($this_verb==FL_BBOX)
      // ... this should be enough
      fl_bb_add(corners=$this_bbox,$FL_ADD=$FL_BBOX);

    else if ($this_verb==FL_CUTOUT) {
      // your code ...

    } else if ($this_verb==FL_DRILL) {
      // your code ...

    } else if ($this_verb==FL_LAYOUT) {
      // your code ...

    } else if ($this_verb==FL_MOUNT) {
      // your code ...

    } else
      assert(false,str("***OFL ERROR***: unimplemented verb ",$this_verb));

  // fl_vmanage() manages standard parameters and prepares the execution
  // context for the engine.
  fl_vmanage(verbs,this,octant=octant,direction=direction)
    engine()
      children();
}
