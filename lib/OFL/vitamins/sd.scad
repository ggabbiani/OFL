/*!
 * Secure Digital flash memory card for OpenSCAD Foundation Library.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <../../ext/NopSCADlib/vitamins/pcb.scad>

use <../foundation/bbox-engine.scad>
use <../foundation/3d-engine.scad>
use <../foundation/mngm-engine.scad>
use <../foundation/util.scad>

//! sd namespace
FL_SD_NS  = "sd";

FL_SD_MOLEX_uSD_SOCKET = let(
  // size  = [12, 11.5, 1.28]
  size  = [13, 11.5, 1.28]
) [
  fl_bb_corners(value=[[-size.x/2,-size.y/2,0],[+size.x/2,+size.y/2,+size.z]]),
  // fl_director(value=-Y),fl_rotor(value=+X),
  fl_cutout(value=[-FL_Y]),
];

//! sd dictionary
FL_SD_DICT = [
  FL_SD_MOLEX_uSD_SOCKET
];

/*!
 * micro SD socket
 */
module fl_sd_usocket(
  //! supported verbs: FL_ADD, FL_BBOX, FL_CUTOUT
  verbs       = FL_ADD,
  //! Secure Digital flash memory card socket type
  type,
  //! translation applied to cutout
  cut_drift=0,
  //! thickness for FL_CUTOUT
  cut_thick,
  //! tolerance used during FL_CUTOUT
  cut_tolerance=0,
  //! FL_CUTOUT direction list. Defaults to 'preferred' cutout direction
  cut_dirs,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  cut_dirs  = is_undef(cut_dirs) ? fl_cutout(type) : cut_dirs;

  module do_print()
    rotate(-90,Z)
      uSD($this_size);

  fl_vmanage(verbs,type,octant=octant,direction=direction) {
    if ($verb==FL_ADD)
      do_print();

    else if ($verb==FL_BBOX)
      fl_bb_add($this_bbox);

    else if ($verb==FL_CUTOUT)
      fl_cutoutLoop(cut_dirs,fl_cutout(type))
        if ($co_preferred)
          fl_new_cutout($this_bbox,$co_current,drift=cut_drift,$fl_tolerance=cut_tolerance,$fl_thickness=cut_thick)
            do_print();

    else
      fl_error(["unimplemented verb",$this_verb]);
  }
}
