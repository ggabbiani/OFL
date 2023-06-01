/*!
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <3d.scad>
include <mngm.scad>

module fl_tube(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  //! base ellipse in [a,b] form
  base,
  //! «base» alternative radius for circular tubes
  r,
  //! «base» alternative diameter for circular tubes
  d,
  //! pipe height
  h,
  //! tube thickness
  thick,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant,
) {
  assert(h!=undef);
  assert(thick!=undef);

  obase = r ? [r,r] : d ? [d/2,d/2] : base;
  assert(obase);
  bbox  = let(bbox=fl_bb_ellipse(obase)) [[bbox[0].x,bbox[0].y,0],[bbox[1].x,bbox[1].y,h]];
  size  = bbox[1]-bbox[0];
  D     = direction ? fl_direction(direction=direction,default=[+Z,+X]) : I;
  M     = fl_octant(octant,bbox=bbox);

  fl_trace("bbox",bbox);
  fl_trace("size",size);

  module do_add() {
    linear_extrude(height=h)
      fl_ellipticArc(e=obase,angles=[0,360],thick=thick);
  }
  module do_fprint() {
    linear_extrude(height=h)
      fl_ellipse(e=obase);
  }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);
    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) do_fprint();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
