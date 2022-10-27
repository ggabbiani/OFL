/*!
 * trimpot engine file
 *
 * Copyright © 2022 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'Raspberry Pi4' (RPI4) project.
 *
 * RPI4 is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * RPI4 is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with RPI4.  If not, see <http://www.gnu.org/licenses/>.
 */

include <../foundation/3d.scad>
include <../foundation/bbox.scad>
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
