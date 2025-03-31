/*
 * PCB switches definition file for OpenSCAD Foundation Library.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <../foundation/unsafe_defs.scad>

use <../foundation/2d-engine.scad>
use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>
// use <../foundation/core-symbols.scad>
use <../foundation/mngm-engine.scad>

//! template namespace
FL_SWT_NS  = "swt";

FL_SWT_USWITCH_7p2x3p4x3x2p5  = let(
  Tbutton=1, Tshild=0.1,
  w=7, h = 3.4, l=2.5+Tbutton
) [
  fl_bb_corners(value=[[-l+Tbutton,-w/2,0],[Tbutton,+w/2,h]]),
  // fl_director(value=+X),fl_rotor(value=+Y),
  fl_cutout(value=[FL_X]),
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
  //! FL_CUTOUT direction list. Defaults to 'preferred' cutout direction
  cut_dirs,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  cut_dirs  = is_undef(cut_dirs) ? fl_cutout(type) : cut_dirs;

  Tshild  = 0.1;
  Tbutton = 1;

  module do_add() {
    fl_color(color="beige")
      translate(-X(Tshild))
        fl_cube(size=[$this_size.x-Tbutton-Tshild,$this_size.y-2*Tshild,$this_size.z],octant=-X+Z);
    fl_color("silver")
      let(l=$this_size.x,w=$this_size.y,h=$this_size.z)
        linear_extrude($this_size.z)
          polygon([[-l/2,-w/2],[0,-w/2],[0,+w/2],[-l/2,w/2],[-l/2,w/2-Tshild],[-Tshild,w/2-Tshild],[-Tshild,-w/2+Tshild],[-l/2,-w/2+Tshild]]);
    fl_color(color="beige")
      let(sz=[0.3,0.62,1.5])
        translate(Z($this_size.z/2))
          for(y=[-2.5,2.5])
            translate(Y(y))
              fl_cube(size=sz,octant=+X);
    fl_color(fl_grey(30))
      translate(+Z($this_size.z/2))
        fl_cube(size=[1,3.22,1.6],octant=+X);
  }

  module do_cutout() {
    translate(+X(cut_drift)+Z($this_size.z/2))
      fl_linear_extrude(direction=[+X,0],length=cut_thick)
        offset(r=cut_tolerance)
          fl_square(size=[1.6,3.22]);
  }

  fl_vmanage(verbs,type,octant=octant,direction=direction) {
    if ($verb==FL_ADD)
      do_add();

    else if ($verb==FL_BBOX)
      fl_bb_add($this_bbox);

    else if ($verb==FL_CUTOUT)
      fl_cutoutLoop(cut_dirs,fl_cutout(type)) {
        if ($co_preferred)
          do_cutout();
      }

    else
      fl_error(["unimplemented verb",$this_verb]);
  }
}
