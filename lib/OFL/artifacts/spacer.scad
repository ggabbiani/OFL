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

use <../foundation/fillet.scad>
use <../foundation/mngm-engine.scad>

//! namespace
FL_SPC_NS  = "spc";

//**** spacer properties ******************************************************

//! external ⌀
function fl_spc_d(type,value)  = fl_property(type,"spc/external ⌀",value);
//! height along Z axis
function fl_spc_h(type,value)  = fl_property(type,"spc/height along Z axis",value);
//! optional nominal screw size
function fl_spc_nominalScrew(type,value)  = fl_optProperty(type,"spc/nominal screw size",value);
//! optional knurl nut
function fl_spc_knut(type,value)  = fl_optProperty(type,"spc/knurl nut",value);

//! Spacer built according to passed constraints.
function fl_Spacer(
  /*!
   * height along Z axis: knurl nut length constraints may override.
   * This parameter is mandatory if no knurl nut is passed.
   *
   * When knurl nut is required, this parameter ignored if shorter than the
   * minimum knurl nut length + 1mm.
   */
  h_min=0,

  /*!
   * External diameter: knurl nut constraints may override.
   * This parameter is mandatory if no knurl nut or screw nominal size is passed.
   *
   * Knurl nuts required a bigger hole to host screws (namely the knurl nut
   * physical dimension plus a minimum wall thick around). When knurl nut is
   * required, this parameter is ignored if too small.
   */
  d_min=0,

  /*!
   * optional screw nominal ⌀, 0 if no screw. This parameter is ignored if a
   * knut is required.
   *
   * Passing a screw size constrains the minimum external ⌀.
   */
  screw_size = 0,

  //! knurl nut: set constrains on both the external ⌀ and minimum height.
  knut
) = let(
  wall  = knut ? let(nominal=fl_nominal(knut)) fl_switch(nominal, FL_KNUT_NOMINAL_DRILL)[2] : undef,
  d     = max(knut ? fl_knut_drillD(knut)+2*wall : 0,d_min),
  kn_h  = knut ? fl_knut_thick(knut)+1 : 0,
  h     = max(h_min,kn_h)
) assert(d && h,"***OFL ERROR***: missing «h» and «d» parameters or «knut» and «screw_size» constrains")
  assert(!screw_size||d>screw_size,"***OFL ERROR***: minimum external ⌀ must be greater than screw size")
  [
  fl_bb_corners(value=fl_bb_cylinder(h,d=d)),
  fl_spc_d(value=d),
  fl_spc_h(value=h),
  if (screw_size) fl_spc_nominalScrew(value=screw_size),
  if (knut) fl_spc_knut(value=knut),
];

// no constructor for spacer since no predefined variable
function fl_bb_spacer(h,r) = fl_bb_cylinder(h,r);

/*!
 * calculates the internal spacer radius.
 */
function fl_spc_holeRadius(
    //! optional nop screw object
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
 * - $spc_director  : layout direction
 * - $spc_screw     : OPTIONAL screw
 * - $spc_thick     : scalar thickness along $spc_director
 * - $spc_thickness : overall thickness (spacer length + ∑thick[i]),
 * - $spc_h         : spacer height
 * - $spc_holeR     : OPTIONAL internal hole radius
 * - $spc_verb      : triggered verb
 */
module fl_spacer(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  //! OFL spacer
  spacer,
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
  //! anchor directions in floating semi-axis list
  anchor,
  //! when >0 a fillet is added to anchors
  fillet=0,
  //! desired direction [director,rotation], native direction when undef ([+Z,0])
  direction,
  //! when undef native positioning is used
  octant,
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  r         = fl_spc_d(spacer)/2;
  h         = fl_spc_h(spacer);
  bbox      = fl_bb_corners(spacer);
  size      = bbox[1]-bbox[0];
  knut      = fl_spc_knut(spacer);
  kn_delta  = knut ? size.z-fl_bb_size(knut).z : 0;
  scr_size  = fl_spc_nominalScrew(spacer);
  hole_r    = knut ? fl_knut_drillD(knut)/2 : scr_size ? scr_size/2 : undef;
  thick     = fl_parm_SignedPair(thick);
  thickness = abs(thick[0])+thick[1]+h;

  anchor  = is_undef(anchor) ? [] : anchor;
  anchor_sz = [r,2*r,h];

  // anchor status
  xp  = fl_3d_axisIsSet(+X,anchor);
  xn  = fl_3d_axisIsSet(-X,anchor);
  yp  = fl_3d_axisIsSet(+Y,anchor);
  yn  = fl_3d_axisIsSet(-Y,anchor);
  zn  = fl_3d_axisIsSet(-Z,anchor);

  D       = direction ? fl_direction(direction) : FL_I;
  M       = fl_octant(octant,bbox=bbox);

  module knut(verbs=FL_ADD)
    translate(+Z(h))
      fl_knut(verbs,knut,dri_thick=[thick[0]-kn_delta,thick[1]],octant=-Z);

  module shape() {
    fl_cylinder(h=h,r=r);
    if (xp)
      fl_cube(size=anchor_sz, octant=+X+Z);
    if (xn)
      fl_cube(size=anchor_sz, octant=-X+Z);
    if (yp)
      fl_cube(size=[2*r,r,h], octant=+Y+Z);
    if (yn)
      fl_cube(size=[2*r,r,h], octant=-Y+Z);

    if (fillet) {
    }
  }

  module do_add() {
    // quadrant angles
    q1  = [0,90];
    q2  = [90,180];
    q3  = [180,270];
    q4  = [270,360];

    fl_color() difference() {
      union() {
        shape();
        if (fillet) {
          if (xp) {
            if (!yp)
              translate([r,r,0]) fl_fillet(r=fillet,h=h,direction=[+Z,90]);
            if (!yn)
              translate([r,-r,0]) fl_fillet(r=fillet,h=h,direction=[+Z,-180]);
          }
          if (xn) {
            if (!yp)
              translate([-r,r,0]) fl_fillet(r=fillet,h=h,direction=[+Z,0]);
            if (!yn)
              translate([-r,-r,0]) fl_fillet(r=fillet,h=h,direction=[+Z,-90]);
          }
          if (yp) {
            if (!xp)
              translate([r,r,0]) fl_fillet(r=fillet,h=h,direction=[+Z,-90]);
            if (!xn)
              translate([-r,r,0]) fl_fillet(r=fillet,h=h,direction=[+Z,-180]);
          }
          if (yn) {
            if (!xn)
              translate([-r,-r,0]) fl_fillet(r=fillet,h=h,direction=[+Z,90]);
            if (!xp)
              translate([r,-r,0]) fl_fillet(r=fillet,h=h,direction=[+Z,0]);
          }
          if (zn) {
            if (xp) {
              if (!yn)
                translate(-Y(r))
                  fl_fillet(r=fillet, h=r,direction=[+X,180],$FL_ADD="ON");
              if (!yp)
                translate(+Y(r))
                  fl_fillet(r=fillet, h=r,direction=[+X,90],$FL_ADD="ON");
            }
            if (xn) {
              if (!yn)
                translate(-Y(r))
                  fl_fillet(r=fillet, h=r,direction=[-X,90],$FL_ADD="ON");
              if (!yp)
                translate(+Y(r))
                  fl_fillet(r=fillet, h=r,direction=[-X,0],$FL_ADD="ON");
            }
            if (yp) {
              if (!xn)
                translate(-X(r))
                  fl_fillet(r=fillet, h=r,direction=[+Y,180],$FL_ADD="ON");
              if (!xp)
                translate(+X(r))
                  fl_fillet(r=fillet, h=r,direction=[+Y,-90],$FL_ADD="ON");
            }
            if (yn) {
              if (!xn)
                translate(-X(r))
                  fl_fillet(r=fillet, h=r,direction=[-Y,90],$FL_ADD="ON");
              if (!xp)
                translate(+X(r))
                  fl_fillet(r=fillet, h=r,direction=[-Y,0],$FL_ADD="ON");
            }
            fl_fillet_extrude(height=fillet, r1=fillet) {
              if (!xp && !yp) fl_sector(r=r, angles=q1);
              if (!xn && !yp) fl_sector(r=r, angles=q2);
              if (!xn && !yn) fl_sector(r=r, angles=q3);
              if (!xp && !yn) fl_sector(r=r, angles=q4);
            }
          }
        }
      }
      if (hole_r)
        translate(-Z(NIL))
          fl_cylinder(h=h+2xNIL,r=hole_r);
    }
  }

  module do_mount() {
    translate(+Z(h+thick[1]))
      context(+Z)
        children();
  }

  module do_assembly() {
    if (knut)
      knut();
  }

  module do_layout() {
    if (fl_3d_axisIsSet(+Z,lay_direction))
      context(+Z)
        translate($spc_director*h)
          children();
    if (fl_3d_axisIsSet(-Z,lay_direction))
      context(-Z)
        children();
  }

  module do_footprint() {
    shape($FL_ADD=$FL_FOOTPRINT);
  }

  module do_drill()
    if (knut)
      knut(FL_DRILL);
    else if (screw)
      do_layout()
        if ($spc_thick) fl_cylinder(h=$spc_thick,r=hole_r,octant=$spc_director);

  module context(
    director
  ) {
    $spc_director   = director;
    $spc_screw      = screw;
    $spc_thick      = director==+Z ? thick[1] : -thick[0];
    $spc_thickness  = thickness;
    $spc_h          = h;
    $spc_holeR      = hole_r;
    $spc_verb       = $verb;
    children();
  }

  fl_manage(verbs,M,D) {

    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier)
        do_assembly();

    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier)
        fl_bb_add(bbox+[[0,0,-NIL],[0,0,NIL]]);

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier) do_drill();

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier)
        do_layout()
          children();

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier)
        do_mount()
          children();

    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier)
        do_footprint();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
