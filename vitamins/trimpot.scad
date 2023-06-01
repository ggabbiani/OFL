/*!
 * trimpot engine file
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../foundation/3d.scad>
include <../foundation/bbox.scad>
include <../foundation/mngm.scad>
include <../foundation/unsafe_defs.scad>
include <../foundation/util.scad>

include <NopSCADlib/lib.scad>

//! namespace
FL_TRIM_NS    = "trim";

FL_TRIM_POT10  = let(
  sz  = [9.5,10+1.5,4.8]
) [
  fl_name(value="ten turn trimpot"),
  fl_bb_corners(value=[[-sz.x/2,-sz.y/2-1.5/2,0],[sz.x/2,sz.y/2-1.5/2,sz.z]]),
  fl_director(value=+Z),fl_rotor(value=+X),
];

module fl_trimpot(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  type,
  //! thickness for FL_CUTOUT
  cut_thick,
  //! tolerance used during FL_CUTOUT
  cut_tolerance=0,
  //! translation applied to cutout (default 0)
  cut_drift=0,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant
) {
  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  D     = direction ? fl_direction(proto=type,direction=direction)  : FL_I;
  M     = fl_octant(octant,bbox=bbox);

  module do_add() {
    trimpot10();
  }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) trimpot10();

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_CUTOUT) {
      assert(cut_thick);
      fl_modifier($modifier)
        translate(-Y(6.5+cut_drift))
          fl_cutout(len=cut_thick,delta=cut_tolerance,trim=[0,5.1,0],z=-Y,cut=true)
            do_add();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
