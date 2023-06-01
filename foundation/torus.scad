/*!
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <3d.scad>
include <mngm.scad>

function fl_bb_torus(
  //! radius of the circular tube.
  r,
  //! diameter of the circular tube.
  d,
  //! elliptic tube [a,b] form
  e,
  //! distance from the center of the tube to the center of the torus
  R
) = let(
  // e     = r ? assert(!e) [r,r] : assert(len(e)==2) e,
  e       = r ? assert(!e && !d) [r,r] : d ? assert(!e && !r) [d/2,d/2] : assert(!r && !d && len(e)==2) e,
  a     = e[0],
  b     = e[1],
  edge  = assert(R>=a,str("R=",R,",a=",a)) a+R
) [[-edge,-edge,-b],[+edge,+edge,+b]];

/*!
 * «e» and «R» are mutually exclusive parameters
 */
module fl_torus(
  //! supported verbs: FL_ADD, FL_AXES, FL_BBOX
  verbs       = FL_ADD,
  //! radius of the circular tube.
  r,
  //! diameter of the circular tube.
  d,
  //! elliptic tube [a,b] form
  e,
  //! distance from the center of the tube to the center of the torus
  R,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant
) {
  bbox    = fl_bb_torus(r,d,e,R);
  e       = r ? [r,r] : d ? [d/2,d/2] : e;
  a       = e[0];
  b       = e[1];
  size    = bbox[1]-bbox[0];
  D       = direction ? fl_direction(direction=direction,default=[+Z,+X]) : I;
  M       = fl_octant(octant,bbox=bbox);

  fn      = $fn;

  fl_trace("D",D);
  fl_trace("M",M);

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) rotate_extrude($fn=$fn) translate(X(R-a)) fl_ellipse(e=e,quadrant=+X,$fn=fn);
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
