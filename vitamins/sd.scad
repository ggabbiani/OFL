/*!
 * Secure Digital flash memory card for OpenSCAD Foundation Library.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <../foundation/3d.scad>
include <../foundation/util.scad>

include <NopSCADlib/vitamins/pcb.scad>

//! sd namespace
FL_SD_NS  = "sd";

FL_SD_MOLEX_uSD_SOCKET = let(
  size  = [12, 11.5, 1.28]
) [
  fl_bb_corners(value=[[-size.x/2,-size.y/2,0],[+size.x/2,+size.y/2,+size.z]]),
  fl_director(value=-Y),fl_rotor(value=+X),
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
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  D     = direction ? fl_direction(proto=type,direction=direction)  : FL_I;
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

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_CUTOUT) {
      fl_modifier($modifier) do_cutout();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
