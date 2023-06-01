/*!
 * Fillet primitives.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <3d.scad>
include <mngm.scad>

module fl_vFillet(
  //! FL_ADD, FL_AXES, FL_BBOX
  verbs   = FL_ADD,
  //! shortcut for «rx»/«ry»
  r,
  h,
  //! ellipse's horizontal radius
  rx,
  //! ellipse's vertical radius
  ry,
  //! desired direction [director,rotation], [+Z,0°] native direction when undef [+Z,+X]
  direction,
  //! when undef native positioning is used (+Z)
  octant
  ) {
  rx      = r ? r : rx;
  ry      = r ? r : ry;

  fl_fillet(verbs,r,h,rx,ry,octant=+X);
}

module fl_hFillet(
  //! FL_ADD, FL_AXES, FL_BBOX
  verbs   = FL_ADD,
  //! shortcut for «rx»/«ry»
  r,
  h,
  //! ellipse's horizontal radius
  rx,
  //! ellipse's vertical radius
  ry,
  //! desired direction [director,rotation], [+Z,0°] native direction when undef [+Z,+X]
  direction,
  //! when undef native positioning is used (+Z)
  octant
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
  //! FL_ADD, FL_AXES, FL_BBOX
  verbs   = FL_ADD,
  //! shortcut for «rx»/«ry»
  r,
  h,
  //! ellipse's horizontal radius
  rx,
  //! ellipse's vertical radius
  ry,
  //! desired direction [director,rotation], [+Z,0°] native direction when undef [+Z,+X]
  direction,
  //! when undef native positioning is used (+Z)
  octant
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

function __3d__(p)  = [p.x,p.y,0];

function fl_bb_90DegFillet(
  //! fillet radius
  r,
  //! number of steps along Z axis
  n,
  //! bounding box of the object to apply the fillet to
  child_bbox,
) = [__3d__(child_bbox[0])-[r,r,0],__3d__(child_bbox[1])+[r,r,r]];

//! 90 Degree fillet taken from [OpenSCAD - Fillet With Internal Angles](https://forum.openscad.org/Fillet-With-Internal-Angles-td17201.html)
module fl_90DegFillet(
  verbs = FL_ADD,
  //! fillet radius
  r,
  //! number of steps along Z axis
  n,
  //! 2D bounding box of the object to apply the fillet to
  child_bbox,
  //! desired direction [director,rotation], [+Z,0°] native direction when undef
  direction,
  //! 3d placement, children positioning when undef
  octant,
) {
  assert(child_bbox!=undef);

  function rad(x) = r - sqrt(pow(r,2) - pow(x - r, 2));

  default = [+Z,+X];  // default director and rotor
  // bbox    = [__3d__(child_bbox[0])-[r,r,0],__3d__(child_bbox[1])+[r,r,r]];
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
