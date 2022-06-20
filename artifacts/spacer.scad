/*
 * Spacers with optional screw and knurl nuts.
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

include <../foundation/unsafe_defs.scad>
include <../foundation/tube.scad>
include <../foundation/hole.scad>

include <../vitamins/knurl_nuts.scad>

// namespace
FL_SPC_NS  = "spc";

// FL_SPC_DICT = [
// ];

// no constructor for spacer since no predefined variable
function fl_bb_spacer(h,r) = fl_bb_cylinder(h,r);

/**
 * calculates the internal spacer radius.
 */
function fl_spc_holeRadius(
    // optional screw
    screw,
    // optional knurl nut instance
    knut
  ) =
  let(
    knut  = knut!=undef ? assert(is_list(knut)) knut : undef
  ) knut ? fl_knut_r(knut)-0.3 : screw ? screw_radius(screw) : undef;

/**
 * Children context:
 *
 * $spc_director  - layout direction
 * $spc_screw     - OPTIONAL screw
 * $spc_thick     - thickness along $spc_director
 * $spc_h         - spacer height
 * $spc_holeR     - OPTIONAL internal hole radius
 */
module fl_spacer(
  // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  // height along Z axis
  h,
  // external radius
  r,
  // external diameter (mutually exclusive with «r»)
  d,
  // thickness in fixed form [[-X,+X],[-Y,+Y],[-Z,+Z]] or scalar shortcut
  thick=0,
  // FL_LAYOUT directions in floating semi-axis list
  lay_direction=[+Z,-Z],
  // optional screw
  screw,
  // optional knurl nut
  knut=false,
  // desired direction [director,rotation], native direction when undef ([+Z,0])
  direction,
  // when undef native positioning is used
  octant,
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  fl_trace("thick",thick);
  r       = assert((r && !d) || (!r && d)) r ? r : d/2;
  bbox    = assert(h!=undef) fl_bb_spacer(h,r);
  size    = bbox[1]-bbox[0];
  knut    = knut && screw ? fl_knut_search(screw,h) : undef;
  hole_r  = fl_spc_holeRadius(screw,knut);
  // thickness along ±Z only
  thick   = is_num(thick) ? [thick,thick] : assert(fl_tt_isAxisVList(thick)) thick.z;

  D       = direction ? fl_direction(default=[+Z,+X],direction=direction) : I;
  M       = fl_octant(octant,bbox=bbox);

  module do_add() {
    fl_color()
      if (hole_r)
        fl_tube(h=h,r=r,thick=r-hole_r);
      else
        fl_cylinder(h=h,r=r);
  }

  module do_mount() {
    if (screw) {
      washer  = let(htyp=screw_head_type(screw)) htyp==hs_cs||htyp==hs_cs_cap ? "no" : "nylon";
      translate(+Z(h+thick[1]))
        fl_screw(FL_DRAW,screw,thick=h+thick[0]+thick[1],washer=washer);
    }
  }

  module do_assembly() {
    if (knut)
      translate(+Z(h+NIL)) fl_knut(type=knut,octant=-Z);
  }

  module do_layout() {
    // if (screw) {
      if (fl_3d_axisIsSet(+Z,lay_direction))
        context(+Z) translate($spc_director*h) children();
      if (fl_3d_axisIsSet(-Z,lay_direction))
        context(-Z) children();
    // }
  }

  module do_footprint() {
    fl_cylinder(h=h,r=r);
  }

  module do_drill() {
    do_layout()
      if ($spc_thick) fl_cylinder(h=$spc_thick,r=hole_r,octant=$spc_director);
  }

  /**
  * Set context for children()
  *
  * $spc_director - layout direction
  * $spc_screw    - OPTIONAL screw
  * $spc_thick    - thickness along $spc_director
  * $spc_h        - spacer height
  * $spc_holeR    - OPTIONAL internal hole radius
  */
  module context(
    director
  ) {
    $spc_director = director;
    $spc_screw    = screw;
    $spc_thick    = director==+Z ? thick[1] : thick[0];
    $spc_h        = h;
    $spc_holeR    = hole_r;
    children();
  }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_assembly();

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier) do_drill();

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout()
        children();

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier) do_mount();

    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) do_footprint();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
