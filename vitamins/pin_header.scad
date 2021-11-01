/*
 * NopSCADlib pin header wrapper implementation for OpenSCAD Foundation Library.
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
use     <../foundation/layout.scad>

// include <template-defs.scad>
include <NopSCADlib/vitamins/pin_headers.scad>

module fl_pinHeader(
  verbs       = FL_ADD, // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  type,                 // NopSCADlib header
  cols      = 1,
  rows      = 1,
  smt = false,          // surface mount
  right_angle = false,
  color,
  co_thick,                // thickness for FL_CUTOUT
  co_tolerance=0,          // tolerance used during FL_CUTOUT
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant,               // when undef native positioning is used
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  fl_trace("hdr_pin_length",hdr_pin_length(type));
  fl_trace("hdr_pin_below",hdr_pin_below(type));
  fl_trace("hdr_pin_width",hdr_pin_width(type));
  fl_trace("hdr_box_size",hdr_box_size(type));
  fl_trace("hdr_box_wall",hdr_box_wall(type));
  fl_trace("hdr_pitch",hdr_pitch(type));

  bbox  = let(
    w = hdr_pitch(type)*cols,
    d = hdr_pitch(type)*rows,
    h = hdr_pin_length(type),
    b = hdr_pin_below(type)
  ) [
    [-w/2,-d/2,-b],[+w/2,+d/2,h-b]
  ];
  size  = bbox[1]-bbox[0];
  D     = direction ? fl_direction(proto=type,direction=direction,default=[Z,X])  : I;
  M     = octant    ? fl_octant(octant=octant,bbox=bbox)            : I;

  module do_add() {
    // pin_header(type, cols = 1, rows = 1, smt = false, right_angle = false, cutout = false, "red");
    pin_header(type, cols, rows,smt=smt,right_angle=right_angle,colour=color);
  }
  module do_layout() {}
  module do_drill() {}

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_add();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_bb_add(bbox);
      } else if ($verb==FL_CUTOUT) {
        assert(co_thick!=undef);
        fl_modifier($FL_CUTOUT) 
          fl_cutout(len=co_thick,delta=co_tolerance)
            do_add();
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=size);
  }
}
