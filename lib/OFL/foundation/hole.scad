/*!
 * Hole engine implementation.
 *
 * TODO: rename as 'hole-engine'
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <label.scad>

//*****************************************************************************
// Hole properties

function fl_hole_d(hole,value)              = fl_property(hole,"hole/diameter",value);
function fl_hole_depth(hole,value)          = fl_property(hole,"hole/depth",value);
function fl_hole_n(hole,value)              = fl_property(hole,"hole/normal",value);
function fl_hole_pos(hole,value)            = fl_property(hole,"hole/position",value);
function fl_hole_ldir(hole,value)           = fl_optProperty(hole,"hole/label [direction,rotation]",value);
function fl_hole_loct(hole,value)           = fl_optProperty(hole,"hole/label octant",value);
function fl_hole_screw(hole,value,default)  = fl_optProperty(hole,"hole/screw",value,default);

//**** type traits ************************************************************

/*!
 * Hole representation as mandatory properties check:
 * - 3d   : hole position
 * - n    : applied surface normal
 * - d    : hole diameter
 * - depth: hole depth (0 means pass-thru hole)
 */
function fl_tt_isHole(hole) = let(
    3d    = fl_hole_pos(hole),
    d     = fl_hole_d(hole),
    n     = fl_hole_n(hole),
    depth = fl_hole_depth(hole),
    ldir  = fl_hole_ldir(hole),
    loct  = fl_hole_loct(hole),
    screw = fl_hole_screw(hole)
  ) fl_tt_isPointNormal([3d,n])
  && is_num(d)
  && is_num(depth)
  && (is_undef(ldir) || fl_tt_isDirectionRotation(ldir))
  && (is_undef(loct) || fl_tt_isOctant(loct));

//! Checks weather each «list» element is a hole
function fl_tt_isHoleList(list) = fl_tt_isList(list,f=function(hole) fl_tt_isHole(hole));

//! hole constructor in key-value list format
function fl_Hole(
  //! 3d hole position
  position,
  //! hole diameter
  d,
  //! normal vector __exiting__ the surface being drilled
  normal  = +Z,
  //! when depth is null hole is pass-through
  depth = 0,
  //! OPTIONAL label direction in [direction,rotation] format
  ldir,
  //! OPTIONAL label octant
  loct,
  //! OPTIONAL screw
  screw
) = let(
    hole  = assert(fl_tt_isPointNormal([position,normal]),[position,normal]) [
      fl_hole_pos(value=position),
      fl_hole_n(value=normal),
      assert(is_num(d)) fl_hole_d(value=d),
      assert(is_num(depth)) fl_hole_depth(value=depth),
      if (ldir) fl_hole_ldir(value=ldir),
      if (loct) fl_hole_loct(value=loct),
      if (screw) fl_hole_screw(value=screw),
    ]
  ) hole;

/*!
 * prepare context for children() holes
 *
 * - $hole_pos      : hole position
 * - $hole_d        : hole diameter
 * - $hole_depth    : hole depth (set to «thick» for pass-thru)
 * - $hole_direction: [$hole_n,0]
 * - $hole_i        : OPTIONAL hole number
 * - $hole_label    : OPTIONAL string label
 * - $hole_ldir     : [direction,rotation]
 * - $hole_loct     : label octant
 * - $hole_n        : hole normal
 * - $hole_screw    : OPTIONAL hole screw
 */
module fl_hole_Context(
  //! hole instance as returned from fl_Hole()
  hole,
  //! fallback thickness
  thick,
  //! OPTIONAL hole number
  ordinal,
  //! fallback screw
  screw
) {
  opts            = hole[4];
  $hole_i         = ordinal;
  $hole_pos       = fl_hole_pos(hole);
  $hole_n         = fl_hole_n(hole);
  $hole_direction = [$hole_n,0];
  $hole_d         = fl_hole_d(hole);
  $hole_depth     = let(depth=fl_hole_depth(hole)) depth ? depth : thick;
  $hole_screw     = fl_hole_screw(hole,default=screw);
  $hole_label     = is_num(ordinal) ? str("H",ordinal) : undef;
  $hole_ldir      = fl_hole_ldir(hole);
  $hole_loct      = fl_hole_loct(hole);

  // echo($hole_i=$hole_i,$hole_depth=$hole_depth,$hole_ldir=$hole_ldir,$hole_loct=$hole_loct,$hole_screw=$hole_screw,screw=screw);

  children();
}

/*!
 * return a matrix list with each item containing the corresponding hole
 * position translation. Functionally equivalent to translation used during
 * fl_lay_holes{}.
 *
 * TODO: remove if unused
 */
function fl_lay_holes(holes) = [
  for(hole=holes) fl_T(fl_hole_pos(hole))
];

/*!
 * Layouts children along a list of holes.
 *
 * See fl_hole_Context{} for context variables passed to children().
 *
 * **NOTE:** supported normals are x,y or z semi-axis ONLY
 *
 */
module fl_lay_holes(
  //! list of hole specs
  holes,
  //! enabled normals in floating semi-axis list form
  enable  = [-X,+X,-Y,+Y,-Z,+Z],
  /*!
   * pass-through thickness
   *
   * TODO: replace with $fl_thickness?
   */
  thick=0,
  /*!
   * fallback screw
   *
   * TODO: really needed?
   */
  screw
) {
  assert(fl_tt_isHoleList(holes),holes);
  assert(fl_tt_isAxisList(enable),enable);

  for(i=[0:len(holes)-1])
    fl_hole_Context(holes[i],thick,i,screw)
      if (fl_3d_axisIsSet($hole_n,enable))
        translate($hole_pos)
          children();
}

/*!
 * Layouts holes according to their defined positions, depth and enabled normals.
 *
 * **NOTE:** supported normals are x,y or z semi-axis ONLY
 */
module fl_holes(
  //! list of holes specs
  holes,
  //! enabled normals in floating semi-axis list form
  enable  = [-X,+X,-Y,+Y,-Z,+Z],
  //! pass-through thickness
  thick=0,
  //! fallback screw
  screw,
  //! tolerance ⌀
  tolerance=2xNIL
) fl_lay_holes(holes,enable,thick,screw)
    translate(tolerance/2*$hole_n)
      fl_cylinder(h=$hole_depth+tolerance,d=$hole_d+tolerance,direction=[-$hole_n,0]);

/*!
  * Layouts of hole symbols
  *
  * **NOTE:** supported normals are x,y or z semi-axis ONLY
  */
module fl_hole_debug(
  //! list of holes specs
  holes,
  //! enabled normals in floating semi-axis list form
  enable  = [-X,+X,-Y,+Y,-Z,+Z],
  //! pass-through thickness
  thick=0,
  //! fallback screw
  screw
) {
    fl_lay_holes(holes,enable,thick,screw) union() {
      if (fl_dbg_symbols())
        translate(NIL*$hole_n)
          fl_sym_hole($FL_ADD="ON");
      if (fl_dbg_labels())
        fl_label(FL_ADD,$hole_label,size=0.6*$hole_d,thick=0.1,octant=$hole_loct,direction=$hole_ldir,extra=$hole_d,$FL_ADD="ON");
    }
  }
