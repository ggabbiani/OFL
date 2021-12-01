/*
 * NopACADlib RJ45 engine wrapper.
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
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
include <../foundation/unsafe_defs.scad>
include <../foundation/defs.scad>
include <../foundation/layout.scad>
include <../foundation/2d.scad>
include <ethers.scad>

use     <../foundation/util.scad>

use     <NopSCADlib/vitamins/pcb.scad>

module fl_ether(
  verbs       = FL_ADD, // supported verbs: FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT
  type,
  cut_thick,            // thickness for FL_CUTOUT
  cut_tolerance=0,      // tolerance used during FL_CUTOUT
  co_drift=0,           // translation applied to cutout
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant,               // when undef native positioning is used
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(type!=undef);

  axes    = fl_list_has(verbs,FL_AXES);
  verbs   = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  bbox  = fl_bb_corners(type);
  size  = bbox[1]-bbox[0];
  D     = direction ? fl_direction(proto=type,direction=direction)  : I;
  M     = octant    ? fl_octant(octant=octant,bbox=bbox)            : I;

  module do_cutout() {
    translate([cut_thick,0,size.z/2])
    rotate(-90,Y)
    linear_extrude(cut_thick)
    offset(r=cut_tolerance)
    fl_square(FL_ADD,size=[size.z,size.y]);
  }

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) 
          rj45();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_bb_add(bbox);
      } else if ($verb==FL_CUTOUT) {
        assert(cut_thick!=undef);
        fl_modifier($FL_CUTOUT) 
          translate(+X(bbox[1].x+co_drift))
            do_cutout();
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes([size.x,size.y,1.5*size.z]);
  }
}
