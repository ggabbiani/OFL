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

module fl_torus(
  verbs       = FL_ADD, // supported verbs: FL_ADD, FL_AXES, FL_BBOX
  r           = 1,
  a,
  b,
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant                // when undef native positioning is used
) {
  assert(r>=a,str("r=",r,",a=",a));

  // echo(n=($fn>0?($fn>=3?$fn:3):ceil(max(min(360/$fa,r*2*PI/$fs),5))),a_based=360/$fa,s_based=r*2*PI/$fs);

  ellipse = [a,b];
  bbox    = let(edge=a+r) [[-edge,-edge,-b],[+edge,+edge,+b]];
  size    = bbox[1]-bbox[0];
  D       = direction ? fl_direction(direction=direction,default=[+Z,+X]) : I;
  M       = octant    ? fl_octant(octant=octant,bbox=bbox)                : I;

  fn      = $fn;

  fl_trace("D",D);
  fl_trace("M",M);

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($FL_ADD) rotate_extrude($fn=$fn) translate(X(r-a)) fl_ellipse(e=ellipse,quadrant=+X,$fn=fn);
    } else if ($verb==FL_BBOX) {
      fl_modifier($FL_BBOX) fl_bb_add(bbox);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
    fl_modifier($FL_AXES) fl_axes(size=size);
  }
}
