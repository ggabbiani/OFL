/*
 * PCB switches definition file for OpenSCAD Foundation Library.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <../foundation/bbox.scad>
include <../foundation/3d.scad>
include <../foundation/unsafe_defs.scad>

//! template namespace
FL_SWT_NS  = "swt";

FL_SWT_USWITCH_7p2x3p4x3x2p5  = let(
  Tbutton=1, Tshild=0.1,
  w=7, h = 3.4, l=2.5+Tbutton
) [
  fl_bb_corners(value=[[-l+Tbutton,-w/2,0],[Tbutton,+w/2,h]]),
  fl_director(value=+X),fl_rotor(value=+Y),
];

FL_SWT_DICT = [
  FL_SWT_USWITCH_7p2x3p4x3x2p5
];

module fl_switch(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  type,
  cut_thick,
  cut_tolerance,
  cut_drift,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant,
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  Tshild  = 0.1;
  Tbutton = 1;
  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  D     = direction ? fl_direction(proto=type,direction=direction)  : FL_I;
  M     = fl_octant(octant,bbox=bbox);

  module do_add() {
    fl_color(color="beige")
      translate(-X(Tshild))
        fl_cube(size=[size.x-Tbutton-Tshild,size.y-2*Tshild,size.z],octant=-X+Z);
    fl_color("silver")
      let(l=size.x,w=size.y,h=size.z)
        linear_extrude(size.z)
          polygon([[-l/2,-w/2],[0,-w/2],[0,+w/2],[-l/2,w/2],[-l/2,w/2-Tshild],[-Tshild,w/2-Tshild],[-Tshild,-w/2+Tshild],[-l/2,-w/2+Tshild]]);
    fl_color(color="beige")
      let(sz=[0.3,0.62,1.5])
        translate(Z(size.z/2))
          for(y=[-2.5,2.5])
            translate(Y(y))
              fl_cube(size=sz,octant=+X);
    fl_color(fl_grey(30))
      translate(+Z(size.z/2))
        fl_cube(size=[1,3.22,1.6],octant=+X);
  }

  module do_cutout() {
    translate(+X(cut_drift)+Z(size.z/2))
      fl_linear_extrude(direction=[+X,0],length=cut_thick)
        offset(r=cut_tolerance)
          fl_square(size=[1.6,3.22]);
  }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_CUTOUT) {
      fl_modifier($modifier) do_cutout();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
