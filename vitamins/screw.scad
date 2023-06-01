/*!
 * Screw implementation file for OpenSCAD Foundation Library.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <../foundation/3d.scad>
include <../foundation/mngm.scad>
include <../foundation/unsafe_defs.scad>

include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/screws.scad>

//*****************************************************************************
//! bounding box
function fl_bb_screw(type,length) =
  assert(type!=undef && is_list(type) && !is_string(type),type)
  assert(is_num(length),length)
  // echo(type=type)
  let(
    hr  = screw_head_radius(type),
    hh  = screw_head_height(type),
    nr  = screw_radius(type),
    r   = max(nr,hr)
  ) [[-r,-r,-length],[+r,+r,+hh]];

//*****************************************************************************
// helpers

//! return the [x,y,z] size of the screw
function fl_screw_size(type,length) = let(
  bbox  = fl_bb_screw(type,length)
) bbox[1]-bbox[0];

//! return the overall length of a screw (according to parameters)
function fl_screw_l(
  type,
  len,
  thick   = 0,
  //! screw washer : "no","default","penny","nylon"
  washer  = "no",
  //! screw nut    : "no","default","nyloc"
  nut     = "no",
  //! extra washer : "no","spring","star"
  xwasher = "no",
  //! nut washer
  nwasher = false,
) = fl_screw_lens(type,len,thick,washer,nut,xwasher,nwasher)[0];

/*!
 * return a list with layered thickness (according to parameters):
 *
 * 0. overall screw length
 * 1. passed thickness
 * 2. washer thickness
 * 3. extra washer (spring or star) thickness
 * 4. nut washer thickness
 * 5. nut thickness
 *
 * **Note:** if one layer is "off", the corresponding thickness will be 0
 */
function fl_screw_lens(
  type,
  len,
  thick   = 0,
  //! screw washer : "no","default","penny","nylon"
  washer  = "no",
  //! screw nut    : "no","default","nyloc"
  nut     = "no",
  //! extra washer : "no","spring","star"
  xwasher = "no",
  //! nut washer
  nwasher = false,
) =
let(
  description   = type[0],
  no_nut_msg    = str("No possible NUT for screw ",description),
  nyloc         = nut=="nyloc",
  screw_nut     = screw_nut(type),
  screw_washer  = screw_washer(type),
  thick_nut   =
      nut=="no"       ? 0
    : nut=="default"  ? assert(screw_nut,no_nut_msg) nut_thickness(screw_nut, false)
    : nut=="nyloc"    ? assert(screw_nut,no_nut_msg) nut_thickness(screw_nut, true)
    : assert(false,str("Unknown nut value ",nut)),
  thick_washer  =
      washer=="no"      ? 0
    : washer=="default"||washer=="nylon" ? washer_thickness(screw_washer)
    : washer=="penny"   ? washer_thickness(penny_washer(screw_washer))
    : assert(false,str("Unknown washer value ",washer)),
  thick_xwasher =
      xwasher=="no"     ? 0
    : xwasher=="spring" ? spring_washer_thickness(screw_washer)
    : xwasher=="star"   ? washer_thickness(screw_washer) // missing star_washer_thickness()?!
    : assert(false,str("Unknown extra washer value ",xwasher)),
  thick_nwasher = nwasher ? assert(screw_nut,no_nut_msg) washer_thickness(nut_washer(screw_nut)) : 0,
  thick_all = thick+thick_nut+thick_washer+thick_xwasher+thick_nwasher
) [len!=undef?len:thick_all,thick,thick_washer,thick_xwasher,thick_nwasher,thick_nut];

module fl_screw(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  //! NopSCADlib screw type
  type,
  //! when passed a fixed len will be used instead of fl_screw_l()
  len,
  //! thickness part passed to fl_screw_l() during length calculation
  thick   = 0,
  //! screw washer : "no","default","penny","nylon"
  washer  = "no",
  //! screw nut    : "no","default","nyloc"
  nut     = "no",
  //! extra washer : "no","spring","star"
  xwasher = "no",
  //! nut washer
  nwasher = false,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant,
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  length  = len ? len : fl_screw_l(type,len,thick,washer,nut,xwasher,nwasher);
  fl_trace("length",length);
  fl_trace("type",type);

  screw_nut     = screw_nut(type);
  screw_washer  = screw_washer(type);
  lens          = fl_screw_lens(type,len,thick,washer,nut,xwasher,nwasher);
  thick_washer  = lens[2];
  thick_xwasher = lens[3];
  thick_nwasher = lens[4];
  thick_nut     = lens[5];

  r       = screw_radius(type);
  bbox    = fl_bb_transform(T(Z(thick_washer+thick_xwasher)), fl_bb_screw(type,length));
  size    = fl_screw_size(type,length);
  hole_r  = screw_clearance_radius(type);
  hole_l  = length-(thick_washer+thick_xwasher);
  D       = direction ? fl_direction(direction=direction,default=[+Z,+X]) : I;
  M       = fl_octant(octant,bbox=bbox);

  module do_assembly() {
    if (washer!="no")
      if (washer=="default") washer(screw_washer);
      else if (washer=="nylon") fl_color("DarkSlateGray") washer(screw_washer);
      else penny_washer(screw_washer);
    if (xwasher!="no")
      translate(Z(thick_washer))
        if (xwasher=="spring") spring_washer(screw_washer); else star_washer(screw_washer);
    if (nwasher)
      translate(-Z(thick))
        rotate(180,X)
        washer(nut_washer(screw_nut));
    if (nut!="no")
      translate(-Z(thick+thick_nwasher))
        rotate(180,X)
        nut(screw_nut, nyloc=(nut=="nyloc"), brass = false, nylon = false);
  }

  module do_footprint() {
    rotate(180,Y)
      rotate_extrude()
        intersection() {
          projection()
            fl_direct(direction=[-Y,0],default=[+Z,+X]) screw(type,length);
          translate([0,-screw_head_height(type)])
            square(size=[screw_head_radius(type),length+screw_head_height(type)]);
        }
  }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier)
        translate(Z(thick_washer+thick_xwasher))
          screw(type, length, hob_point = 0, nylon = false);
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);
    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_assembly();
    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier)
        fl_cylinder(FL_ADD,h=hole_l,r=hole_r,octant=-Z);
    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) do_footprint();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
