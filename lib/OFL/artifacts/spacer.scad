/*!
 * Spacers with optional screw and knurl nuts.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../foundation/3d-engine.scad>
include <../foundation/hole.scad>
include <../foundation/unsafe_defs.scad>
include <../vitamins/knurl_nuts.scad>

use <../foundation/mngm-engine.scad>

//! namespace
FL_SPC_NS  = "spc";

// FL_SPC_DICT = [
// ];

// no constructor for spacer since no predefined variable
function fl_bb_spacer(h,r) = fl_bb_cylinder(h,r);

/*!
 * calculates the internal spacer radius.
 */
function fl_spc_holeRadius(
    //! optional screw
    screw,
    //! optional knurl nut instance
    knut
  ) =
  let(
    knut  = knut!=undef ? assert(is_list(knut)) knut : undef
  ) knut ? fl_knut_drillD(knut)/2 : screw ? screw_radius(screw) : undef;

/*!
 * Children context:
 *
 * - $spc_director: layout direction
 * - $spc_screw   : OPTIONAL screw
 * - $spc_thick   : thickness along $spc_director
 * - $spc_h       : spacer height
 * - $spc_holeR   : OPTIONAL internal hole radius
 */
module fl_spacer(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  //! height along Z axis
  h,
  //! external radius
  r,
  //! external diameter (mutually exclusive with «r»)
  d,
  //! FL_MOUNT thickness as a list of number or scalar shortcut
  /*!
   * List of Z-axis thickness or a scalar value for FL_DRILL and FL_MOUNT
   * operations.
   *
   * A positive value represents thickness along +Z semi-axis.
   * A negative value represents thickness along -Z semi-axis.
   * A scalar value represents thickness for both Z semi-axes.
   *
   * Example 1:
   *
   *     thick = [+3,-1]
   *
   * is interpreted as thickness of 3mm along +Z and 1mm along -Z
   *
   * Example 2:
   *
   *     thick = [-1]
   *
   * is interpreted as thickness of 1mm along -Z
   *
   * Example:
   *
   *     thick = 2
   *
   * is interpreted as a thickness of 2mm along +Z and -Z axes
   *
   */
  thick=0,
  /*!
   * FL_DRILL and FL_LAYOUT directions in floating semi-axis list.
   *
   * __NOTE__: only Z semi-axes are used
   */
  lay_direction=[+Z,-Z],
  //! optional screw
  screw,
  /*!
   * optional knurl nut.
   *
   * __NOTE__: when set true while no usable knurl nut is found an error is thrown
   */
  knut=false,
  //! desired direction [director,rotation], native direction when undef ([+Z,0])
  direction,
  //! when undef native positioning is used
  octant,
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  r       = assert((r && !d) || (!r && d)) r ? r : d/2;
  bbox    = assert(h!=undef) fl_bb_spacer(h,r);
  size    = bbox[1]-bbox[0];
  knut    = knut && screw ? let(kn=fl_knut_search(screw,h)) assert(kn,"No usable knurl nut found: try increasing external radius and/or spacer height!") kn : undef;
  hole_r  = screw ? fl_spc_holeRadius(screw,knut) : undef;
  assert(!screw || r>hole_r,"External radius insufficient for internal hole");

  thick = is_undef(thick) ? [0,0]
    : is_list(thick) ? thick==[] ? [0,0] : let(
      negative = let(m=min(thick)) m<0 ? -m : 0,
      positive = let(m=max(thick)) m>0 ? +m : 0
    ) [negative,positive]
    : assert(is_num(thick),thick) [abs(thick),abs(thick)];
  thicks = fl_accum(thick);

  D       = direction ? fl_direction(direction) : FL_I;
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
      washer  = let(
        htyp  = screw_head_type(screw)
      ) (htyp==hs_cs||htyp==hs_cs_cap) ? "no" : "nylon";

      z=thick[1];
      translate(+Z(h+z))
        fl_screw(FL_DRAW,screw,thick=h+thicks,washer=washer,$FL_ADD=$FL_MOUNT,$FL_ASSEMBLY=$FL_MOUNT);
    }
  }

  module do_assembly() {
    if (knut)
      translate(+Z(h)) fl_knut(type=knut,octant=-Z);
  }

  module do_layout() {
    if (fl_3d_axisIsSet(+Z,lay_direction))
      context(+Z) translate($spc_director*h) children();
    if (fl_3d_axisIsSet(-Z,lay_direction))
      context(-Z) children();
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

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_assembly();

    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox+[[0,0,-NIL],[0,0,NIL]]);

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
