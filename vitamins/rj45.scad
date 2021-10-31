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
use     <../foundation/util.scad>

use     <NopSCADlib/vitamins/pcb.scad>

module fl_rj45(
  verbs       = FL_ADD, // supported verbs: FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT
  co_thick,                // thickness for FL_CUTOUT
  co_tolerance=0,          // tolerance used during FL_CUTOUT
  co_drift=0,              // translation applied to cutout
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant,               // when undef native positioning is used
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  axes    = fl_list_has(verbs,FL_AXES);
  verbs   = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  bbox  = let(l=21,w=16,h=13.5) [[-l/2,-w/2,0],[+l/2,+w/2,h]];
  size  = bbox[1]-bbox[0];
  D     = direction ? fl_direction(direction=direction,default=[+X,-Z])  : I;
  M     = octant    ? fl_octant(octant=octant,bbox=bbox)            : I;

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) 
          rj45();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_bb_add(bbox);
      } else if ($verb==FL_CUTOUT) {
        assert(co_thick!=undef);
        fl_modifier($FL_CUTOUT) 
          translate(+X(bbox[1].x+co_drift))
            fl_cutout(len=co_thick,z=X,x=-Z,delta=co_tolerance,trim=-X(size.x/2),cut=true)
              rj45();
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes([size.x,size.y,1.5*size.z]);
  }
}
