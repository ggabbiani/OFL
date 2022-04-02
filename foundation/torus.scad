/*
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

include <3d.scad>

function fl_bb_torus(
  // radius of the circular tube.
  r,
  // elliptic tube [a,b] form
  e,
  // distance from the center of the tube to the center of the torus
  R
) = let(
  e     = r ? assert(!e) [r,r] : assert(len(e)==2) e,
  a     = e[0],
  b     = e[1],
  edge  = assert(R>=a,str("R=",R,",a=",a)) a+R
) [[-edge,-edge,-b],[+edge,+edge,+b]];

/**
 * «e» and «R» are mutually exclusive parameters
 */
module fl_torus(
  // supported verbs: FL_ADD, FL_AXES, FL_BBOX
  verbs       = FL_ADD, 
  // radius of the circular tube.
  r,
  // elliptic tube [a,b] form
  e,
  // distance from the center of the tube to the center of the torus
  R,
  // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,            
  // when undef native positioning is used
  octant                
) {
  bbox    = fl_bb_torus(r,e,R);
  e       = r ? [r,r] : e;
  a       = e[0];
  b       = e[1];
  size    = bbox[1]-bbox[0];
  D       = direction ? fl_direction(direction=direction,default=[+Z,+X]) : I;
  M       = octant    ? fl_octant(octant=octant,bbox=bbox)                : I;

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
