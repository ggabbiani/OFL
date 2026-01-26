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
include <../../ext/NopSCADlib/vitamins/pcb.scad>

use <../foundation/type-engine.scad>
use <../foundation/mngm-engine.scad>

//! prefix used for namespacing
FL_CHIP_NS  = "chip";

//! package inventory as a list of pre-defined and ready-to-use 'objects'
FL_CHIP_INVENTORY = [
];

/*!
 * Chip constructor.
 */
function fl_Chip(
  bbox,
  name,
  //! optional description
  description,
  colour="darkslategrey",
  others
)  = let(
) fl_Object(bbox, name=name, description=description, FL_CHIP_NS, others = [fl_material(value=colour)]);

module fl_chip(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  type,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction
) {
  // run with an execution context set by fl_vmanage{}
  module engine() let(
    // start of engine specific internal variables
    colour = fl_material(type)
  ) if ($this_verb==FL_ADD) {
      chip($this_size.x, $this_size.y, $this_size.z, colour, cutout = false);

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
  fl_vmanage(verbs,type,octant=octant,direction=direction)
    engine()
      children();
}
