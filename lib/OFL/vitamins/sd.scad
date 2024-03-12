/*!
 * Secure Digital flash memory card for OpenSCAD Foundation Library.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <../../NopSCADlib/vitamins/pcb.scad>

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
  //! thickness for FL_CUTOUT
  cut_thick,
  //! tolerance used during FL_CUTOUT
  cut_tolerance=0,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant,
  // see constructor fl_parm_Debug()
  debug
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  D     = direction ? fl_direction(direction)  : FL_I;
  M     = fl_octant(octant,bbox=bbox);

  module do_add() {
    rotate(-90,Z)
      uSD(size);
  }

  module do_cutout() {
    assert(cut_thick!=undef);
    translate(-Y(size.y/2))
      fl_cutout(len=cut_thick,z=-Y,x=X,delta=cut_tolerance)
        rotate(-90,Z)
          uSD(size);
  }

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction,debug);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_CUTOUT) {
      fl_modifier($modifier) do_cutout();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
