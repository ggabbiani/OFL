/*
 * Fillet primitives.
 *
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org)
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

module fl_vFillet(
  verbs   = FL_ADD, // FL_ADD, FL_AXES, FL_BBOX
  r,          // shortcut for «rx»/«ry»
  h,
  rx,ry,      // ellipse's radius
  direction,  // desired direction [director,rotation], [+Z,0°] native direction when undef [+Z,+X]
  octant      // when undef native positioning is used (+Z)
  ) {
  rx      = r ? r : rx;
  ry      = r ? r : ry;

  fl_fillet(verbs,r,h,rx,ry,octant=+X);
}

module fl_hFillet(
  verbs   = FL_ADD, // FL_ADD, FL_AXES, FL_BBOX
  r,          // shortcut for «rx»/«ry»
  h,
  rx,ry,      // ellipse's radius
  direction,  // desired direction [director,rotation], [+Z,0°] native direction when undef [+Z,+X]
  octant      // when undef native positioning is used (+Z)
  ) {
  default = [+Z,+X];  // default director and rotor
  rx      = r ? r : rx;
  ry      = r ? r : ry;
  bbox    = [[0,-h/2,0],[rx,h/2,ry]];
  size    = bbox[1]-bbox[0];
  M       = octant!=undef ? fl_octant(octant=octant,bbox=bbox) : I;
  D       = direction!=undef ? fl_direction(direction=direction,default=default) : I;

  module do_add() {
    translate(Y(h/2))
      rotate(90,X)
        fl_fillet(FL_ADD,r,h,rx,ry);
  }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD)
      fl_modifier($modifier) do_add();
    else if ($verb==FL_BBOX)
      fl_modifier($modifier) fl_bb_add(bbox);
    else
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
  }
}

module fl_fillet(
  verbs   = FL_ADD, // FL_ADD, FL_AXES, FL_BBOX
  r,          // shortcut for «rx»/«ry»
  h,
  rx,ry,      // ellipse's radius
  direction,  // desired direction [director,rotation], [+Z,0°] native direction when undef [+Z,+X]
  octant      // when undef native positioning is used (+Z)
  ) {
  default = [+Z,+X];  // default director and rotor
  rx      = r ? r : rx;
  ry      = r ? r : ry;
  size    = [rx,ry,h];
  bbox    = [O,size];
  M       = octant!=undef ? fl_octant(octant=octant,bbox=bbox) : I;
  D       = direction!=undef ? fl_direction(direction=direction,default=default) : I;
  fl_trace("D",D);
  fl_trace("default",default);

  module do_add() {
    linear_extrude(h)
      difference() {
        fl_square(size=[rx,ry],quadrant=+X+Y);
        fl_ellipse(e=[rx,ry],quadrant=+X+Y);
    }
  }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD)
      fl_modifier($modifier) do_add();
    else if ($verb==FL_BBOX)
      fl_modifier($modifier) fl_cube(size=size);
    else
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
  }
}

function _3d_(p)  = [p.x,p.y,0];

function fl_bb_90DegFillet(
  r,                  // fillet radius
  n,                  // number of steps along Z axis
  child_bbox,         // bounding box od the object to apply the fillet to
) = [_3d_(child_bbox[0])-[r,r,0],_3d_(child_bbox[1])+[r,r,r]];

// 90 Degree fillet taken from:
// https://forum.openscad.org/Fillet-With-Internal-Angles-td17201.html
module fl_90DegFillet(
  verbs = FL_ADD,
  r,                  // fillet radius
  n,                  // number of steps along Z axis
  child_bbox,         // 2D bounding box of the object to apply the fillet to
  direction,          // desired direction [director,rotation], [+Z,0°] native direction when undef
  octant,             // 3d placement, children positioning when undef
) {
  assert(child_bbox!=undef);

  function rad(x) = r - sqrt(pow(r,2) - pow(x - r, 2));

  default = [+Z,+X];  // default director and rotor
  // bbox    = [_3d_(child_bbox[0])-[r,r,0],_3d_(child_bbox[1])+[r,r,r]];
  bbox    = fl_bb_90DegFillet(r,n,child_bbox);
  size    = bbox[1]-bbox[0];
  D       = direction ? fl_direction(direction=direction,default=default) : I;
  M       = fl_octant(octant,bbox=bbox);

  module do_add() {
    s   = r/n;    //step size
    eps = 0.001;  // a little overlap between slices
    for(i = [0 : s : r - s])
      translate([0, 0, i]) minkowski() {
        linear_extrude(height = eps)
          children();
        cylinder(r1 = rad(i), r2 = rad(i + s), h = s, $fn = 32);
      }
    }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD)
      fl_modifier($modifier) do_add() children();
    else if ($verb==FL_BBOX)
      fl_modifier($modifier) translate(bbox[0]) fl_cube(size=size);
    else
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
  }
}
