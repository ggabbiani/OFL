/*
 * NopACADlib Jack definitions wrapper.
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

include <../foundation/3d.scad>
include <../foundation/util.scad>

FL_JACK_NS = "jack";

//*****************************************************************************
// Jack constructors
function fl_jack_new(utype) = let(
  // following data definitions taken from NopSCADlib jack() module
  l = 12,
  w = 7,
  h = 6,
  ch = 2.5,
  // calculated bounding box corners
  bbox      = [[-l/2,-w/2,0],[+l/2+ch,+w/2,h]]
) [
  fl_bb_corners(value=bbox),
  fl_director(value=+FL_X),fl_rotor(value=+FL_Y),
];

FL_JACK = fl_jack_new();

FL_JACK_DICT = [
  FL_JACK,
];

module fl_jack(
  verbs       = FL_ADD, // supported verbs: FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT
  type,
  cut_thick,            // thickness for FL_CUTOUT
  cut_tolerance=0,      // tolerance used during FL_CUTOUT
  cut_drift=0,          // translation applied to cutout
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant,               // when undef native positioning is used
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(type!=undef);

  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  D     = direction ? fl_direction(proto=type,direction=direction)  : I;
  M     = octant    ? fl_octant(octant=octant,bbox=bbox)            : I;

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier)
        jack();
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);
    } else if ($verb==FL_CUTOUT) {
      assert(cut_thick!=undef);
      fl_modifier($modifier)
        translate(+X(bbox[1].x-2.5+cut_drift))
          fl_cutout(len=cut_thick,z=X,x=-Z,delta=cut_tolerance,trim=X(-size.x/2),cut=true)
            jack();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
