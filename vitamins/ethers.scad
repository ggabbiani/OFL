/*
 * Ethernet.
 *
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL).
 *
 * OFL is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * OFL is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with OFL.  If not, see <http: //www.gnu.org/licenses/>.
 */

include <../foundation/3d.scad>

use     <NopSCADlib/vitamins/pcb.scad>

FL_ETHER_NS = "ether";

FL_ETHER_RJ45 = let(
  bbox  = let(l=21,w=16,h=13.5) [[-l/2,-w/2,0],[+l/2,+w/2,h]]
) [
  fl_name(value="RJ45"),
  fl_bb_corners(value=bbox),
  fl_director(value=+FL_X),fl_rotor(value=-FL_Z),
];

FL_ETHER_DICT = [
  FL_ETHER_RJ45,
];

module fl_ether(
  // supported verbs: FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT
  verbs       = FL_ADD,
  type,
  // thickness for FL_CUTOUT
  cut_thick,
  // tolerance used during FL_CUTOUT
  cut_tolerance=0,
  // translation applied to cutout (default 0)
  cut_drift=0,
  // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  // when undef native positioning is used
  octant,
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(type!=undef);

  bbox      = fl_bb_corners(type);
  size      = bbox[1]-bbox[0];
  D         = direction ? fl_direction(proto=type,direction=direction)  : I;
  M         = fl_octant(octant,bbox=bbox);

  fl_trace("cutout drift",cut_drift);

  module do_cutout() {
    translate([cut_thick,0,size.z/2])
    rotate(-90,Y)
    linear_extrude(cut_thick)
    offset(r=cut_tolerance)
    fl_square(FL_ADD,size=[size.z,size.y]);
  }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier)
        rj45();

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_CUTOUT) {
      assert(cut_thick!=undef);
      fl_modifier($modifier)
        translate(+X(bbox[1].x+cut_drift))
          do_cutout();

    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
