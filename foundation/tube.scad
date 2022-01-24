/*
 * Empty file description
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

include <layout.scad>

module fl_tube(
  verbs       = FL_ADD, // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  base,                 // base ellipse in [a,b] form
  r,                    // «base» alternative radius for circular tubes
  d,                    // «base» alternative diameter for circular tubes
  h,                    // pipe height
  thick,                // tube thickness
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant,               // when undef native positioning is used
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(h!=undef);
  assert(thick!=undef);

  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  obase = r ? [r,r] : d ? [d/2,d/2] : base;
  assert(obase);
  ibase = [obase[0]-thick,obase[1]-thick];
  bbox  = let(bbox=fl_bb_ellipse(obase)) [[bbox[0].x,bbox[0].y,0],[bbox[1].x,bbox[1].y,h]];
  size  = bbox[1]-bbox[0];
  D     = direction ? fl_direction(direction=direction,default=[+Z,+X]) : I;
  M     = octant    ? fl_octant(octant=octant,bbox=bbox)                : I;

  fl_trace("bbox",bbox);
  fl_trace("size",size);

  module do_add() {
    linear_extrude(height=h)
      fl_ellipticArc(e=ibase,angles=[0,360],thick=thick);
  }
  module do_fprint() {
    linear_extrude(height=h)
      fl_ellipse(e=obase);
  }
  module do_assembly() {}
  module do_layout() {}
  module do_drill() {}

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_add();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_bb_add(bbox);
      } else if ($verb==FL_LAYOUT) {
        fl_modifier($FL_LAYOUT) do_layout()
          children();
      } else if ($verb==FL_FOOTPRINT) {
        fl_modifier($FL_FOOTPRINT) do_fprint();
      } else if ($verb==FL_ASSEMBLY) {
        fl_modifier($FL_ASSEMBLY);
      } else if ($verb==FL_DRILL) {
        fl_modifier($FL_DRILL);
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=size);
  }
}
