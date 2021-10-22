/*
 * Countersink implementation.
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

include <countersinks.scad>
include <../foundation/unsafe_defs.scad>
use     <../foundation/3d.scad>
use     <../foundation/layout.scad>
use     <../foundation/placement.scad>


use <NopSCADlib/utils/layout.scad>
include <NopSCADlib/lib.scad>
include <NopSCADlib/vitamins/screws.scad>

module fl_countersink(
  verbs,
  type,
  direction,        // desired direction [director,rotation], native direction when undef
  octant            // when undef native positioning is used (+Z)
) {
  assert(verbs!=undef);
  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  d     = fl_cs_d(type);
  h     = fl_cs_h(type);
  D     = direction!=undef ? fl_direction(proto=type,direction=direction) : I;
  M     = octant!=undef ? fl_octant(octant=octant,bbox=bbox) : I;

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD)
        fl_modifier($FL_ADD) 
          fl_cylinder(d1=0,d2=d,h=h,octant=-Z);
      else if ($verb==FL_BBOX)
        fl_modifier($FL_BBOX) translate(Z(NIL)) fl_bb_add(bbox);
      else
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=1.2*size);
  }
}
