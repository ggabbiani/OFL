/*!
 * Spacers with optional screw and knurl nuts.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../foundation/3d-engine.scad>
include <../foundation/unsafe_defs.scad>
include <../vitamins/knurl_nuts.scad>

use <../foundation/fillet.scad>
use <../foundation/hole-engine.scad>
use <../foundation/mngm-engine.scad>

//! namespace for spacer objects
FL_SPC_NS  = "spc";

//**** spacer properties ******************************************************

//! external ⌀ property
function fl_spc_d(type,value)  = fl_property(type,"spc/external ⌀",value);
//! height along Z axis property
function fl_spc_h(type,value)  = fl_property(type,"spc/height along Z axis",value);
//! nominal screw size optional property. TODO: shall this be substituted by fl_nominal()?
function fl_spc_nominalScrew(type,value)  = fl_optProperty(type,"spc/nominal screw size",value);
//! knurl nut optional property
function fl_spc_knut(type,value)  = fl_optProperty(type,"spc/knurl nut",value);

//! Spacer constructor.
function fl_Spacer(
  /*!
   * height along Z axis: knurl nut length constraints may override.
   * This parameter is mandatory if no knurl nut is passed.
   *
   * When a knurl nut is required, this parameter is ignored if shorter than the
   * minimum knurl nut length + 1mm.
   */
  h_min=0,

  /*!
   * External diameter: knurl nut constraints may override.
   * This parameter is mandatory if no knurl nut or screw nominal size is passed.
   *
   * Knurl nuts requires a bigger hole to host screws (namely the knurl nut
   * physical dimension plus a minimum wall thick around). When a knurl nut is
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

  /*!
   * Knurl nut object.
   *
   * This parameter constrains both the external ⌀ and the minimum spacer
   * height.
   */
  knut
) = let(
  wall  = knut ? let(nominal=fl_nominal(knut)) fl_switch(nominal, FL_KNUT_NOMINAL_DRILL)[2] : undef,
  d     = max(knut ? fl_knut_drillD(knut)+2*wall : 0,d_min),
  kn_h  = knut ? fl_thick(knut)+1 : 0,
  h     = max(h_min,kn_h)
) assert(d && h,"***OFL ERROR***: missing «h» or «d» parameters or «knut» and «screw_size» constrains")
  assert(!screw_size||d>screw_size,"***OFL ERROR***: minimum external ⌀ must be greater than screw size")
  fl_Object(fl_bb_cylinder(h,d=d),
    name  = str("Spacer ",d,"mm ⌀ x ",h,"mm length"),
    others = [
      fl_spc_d(value=d),
      fl_spc_h(value=h),
      if (screw_size) fl_spc_nominalScrew(value=screw_size),
      if (knut) fl_spc_knut(value=knut),
    ]
  );

/*!
 * Context variables:
 *
 * | Name           | Type      | Description
 * | ---            | ---       | ---
 * | $spc_director  | Children  | layout direction
 * | $spc_nominal   | Children  | OPTIONAL screw nominal ⌀
 * | $spc_thick     | Children  | scalar thickness (always≥0) along current $spc_director
 * | $spc_thickness | Children  | overall thickness (spacer length + ∑thick[i])
 * | $spc_h         | Children  | spacer height
 * | $spc_holeR     | Children  | OPTIONAL internal hole radius
 * | $spc_verb      | Children  | triggered verb
 *
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
   * is interpreted as thickness of 1mm along -Z 0mm along +Z
   *
   * Example:
   *
   *     thick = 2
   *
   * is interpreted as a thickness of 2mm along ±Z
   *
   */
  thick=0,
  //! anchor directions in floating semi-axis list
  anchor,
  //! when >0 a fillet is added to anchors
  fillet=0,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+Z,0])
  direction
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(spacer && fl_native(spacer),spacer);

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

  module knut(verbs=FL_ADD)
    let(dri_thick=[thick[0]-kn_delta,thick[1]])
      translate(+Z(h))
        fl_knut(verbs,knut,dri_thick=dri_thick,octant=-Z);

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
    // echo($fl_filament=$fl_filament)
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
      knut($FL_ADD=$FL_ASSEMBLY);
  }

  module do_layout() {
    // echo("*** +Z ***")
    context(+Z)
      translate($spc_director*h)
        children();
    // echo("*** -Z ***")
    context(-Z)
      children();
  }

  module do_footprint() {
    shape($FL_ADD=$FL_FOOTPRINT);
  }

  module do_drill()
    if (knut)
      knut(FL_DRILL);
    else if (scr_size)
      do_layout()
        if ($spc_thick)
          translate(-$spc_h*$spc_director)
            fl_cylinder(h=$spc_thick+$spc_h,r=hole_r,octant=$spc_director);

  module context(
    director
  ) {
    $spc_director   = director;
    $spc_nominal    = scr_size;
    $spc_thick      = director==+Z ? thick[1] : -thick[0];
    $spc_thickness  = thickness;
    $spc_h          = h;
    $spc_holeR      = hole_r;
    $spc_verb       = $verb;
    children();
  }

  fl_vmanage(verbs, spacer, octant=octant, direction=direction) {

    if ($this_verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($this_verb==FL_ASSEMBLY) {
      fl_modifier($modifier)
        do_assembly();

    } else if ($this_verb==FL_BBOX) {
      fl_modifier($modifier)
        fl_bb_add(bbox+[[0,0,-NIL],[0,0,NIL]]);

    } else if ($this_verb==FL_DRILL) {
      fl_modifier($modifier) do_drill();

    } else if ($this_verb==FL_LAYOUT) {
      fl_modifier($modifier)
        do_layout()
          children();

    } else if ($this_verb==FL_MOUNT) {
      fl_modifier($modifier)
        do_mount()
          children();

    } else if ($this_verb==FL_FOOTPRINT) {
      fl_modifier($modifier)
        do_footprint();

    } else {
      fl_error(["unimplemented verb",$this_verb]);
    }
  }
}
