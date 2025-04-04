/*!
 * Screw implementation file for OpenSCAD Foundation Library.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <../../ext/NopSCADlib/core.scad>
include <../../ext/NopSCADlib/vitamins/screws.scad>

include <../foundation/unsafe_defs.scad>

use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>
use <../foundation/hole.scad>
use <../foundation/mngm-engine.scad>


//! screw namespace
FL_SCREW_NS  = "screw";

//! screw dictionary
FL_SCREW_DICT = [
  No632_pan_screw   ,
  M2_cap_screw      ,
  M2_cs_cap_screw   ,
  M2_dome_screw     ,
  M2p5_cap_screw    ,
  M2p5_dome_screw   ,
  M2p5_pan_screw    ,
  M3_cap_screw      ,
  M3_cs_cap_screw   ,
  M3_dome_screw     ,
  M3_grub_screw     ,
  M3_hex_screw      ,
  M3_low_cap_screw  ,
  M3_pan_screw      ,
  M3_shoulder_screw ,
  M4_cap_screw      ,
  M4_cs_cap_screw   ,
  M4_dome_screw     ,
  M4_grub_screw     ,
  M4_hex_screw      ,
  M4_pan_screw      ,
  M4_shoulder_screw ,
  M5_cap_screw      ,
  M5_cs_cap_screw   ,
  M5_dome_screw     ,
  M5_grub_screw     ,
  M5_hex_screw      ,
  M5_pan_screw      ,
  M6_cap_screw      ,
  M6_cs_cap_screw   ,
  M6_grub_screw     ,
  M6_hex_screw      ,
  M6_pan_screw      ,
  M8_cap_screw      ,
  M8_cs_cap_screw   ,
  M8_hex_screw      ,
  No2_screw         ,
  No4_screw         ,
  No6_cs_screw      ,
  No6_screw         ,
  No8_screw
];

/*!
 * return a filter by screw nominal «diameter»
 *
 * This can be used by function fl_list_filter().
 */
function fl_screw_byNominal(diameter) =
  function(nop_screw)
    // nop_screw as returned by the nopSCADLib's lists can be '0', we test
    // thereby if the current screw is a valid one
    (nop_screw && fl_screw_nominal(nop_screw)==diameter);

/*!
 * Return a list of screws from dictionary, matching the passed properties.
 *
 * __NOTE__: when a parameter is undef the corresponding property is not checked.
 */
function fl_screw_search(
  //! search dictionary
  dictionary=FL_SCREW_DICT,
  //! nominal diameter
  d,
  /*!
   * screw type is one of the following:
   *  - hs_cap
   *  - hs_pan
   *  - hs_cs
   *  - hs_hex
   *  - hs_grub
   *  - hs_cs_cap
   *  - hs_dome
   */
  head_type,
  //! bool, when true is required, when false or undef is ignored
  nut,
  //! "no", "default", "penny", "nylon". when "no" or undef is ignored
  washer
) =
assert(is_undef(d)||is_num(d),str("***OFL ERROR***: «d» parameter is not a number"))
[
  for(s=dictionary)
    let(
      chk_washer  = function(screw) let(
        w       = washer!="no" ? screw_washer(screw) : undef,
        w_cond  = washer=="penny" ? w!=undef && penny_washer(w)!=undef
                : (washer=="default"||washer=="nylon") && w!=undef
      ) w_cond
    )
    if (   (is_undef(d)         || fl_screw_nominal(s)==d         )
        && (is_undef(head_type) || screw_head_type(s)==head_type  )
        && (is_undef(nut)       || nut==false   || screw_nut(s)   )
        && (is_undef(washer)    || washer=="no" || chk_washer(s)  )
    ) s
];

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

//! screw nominal diameter
function fl_screw_nominal(nop)  = 2*screw_radius(nop);

//! return the [x,y,z] size of the screw
function fl_screw_size(type,length) = let(
  bbox  = fl_bb_screw(type,length)
) bbox[1]-bbox[0];

/*!
 * Returns the overall length of a screw (according to parameters).
 *
 * Context parameters: see fl_screw{}.
 */
function fl_screw_l(
  type,
  len,
  //! screw washer : "no","default","penny","nylon"
  washer  = "no",
  //! screw nut    : "no","default","nyloc"
  nut     = "no",
  //! extra washer : "no","spring","star"
  xwasher = "no",
  //! nut washer
  nwasher = false,
) = fl_screw_lens(type,len,washer,nut,xwasher,nwasher)[0];

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
 *
 * Context parameters: see fl_screw{}.
 */
function fl_screw_lens(
  type,
  len,
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
    : washer=="penny"   ? let(penny=penny_washer(screw_washer)) penny ? washer_thickness(penny) : 0
    : assert(false,str("Unknown washer value ",washer)),
  thick_xwasher =
      xwasher=="no"     ? 0
    : xwasher=="spring" ? spring_washer_thickness(screw_washer)
    : xwasher=="star"   ? washer_thickness(screw_washer) // missing star_washer_thickness()?!
    : assert(false,str("Unknown extra washer value ",xwasher)),
  thick_nwasher = nwasher ? assert(screw_nut,no_nut_msg) washer_thickness(nut_washer(screw_nut)) : 0,
  thick_all = fl_parm_thickness()+thick_nut+thick_washer+thick_xwasher+thick_nwasher
) [
    len!=undef ?
      len :
      thick_all,fl_parm_thickness(),thick_washer,thick_xwasher,thick_nwasher,thick_nut
  ];

/*!
 * Context parameters:
 *
 * | name           | Description   |
 * | -------------- | ------------  |
 * | $fl_thickness  |  material thickness to be drilled, see also fl_parm_thickness() |
 */
module fl_screw(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  //! NopSCADlib screw type
  type,
  //! when passed a fixed len will be used instead of fl_screw_l()
  len,
  //! screw washer : "no","default","penny","nylon"
  washer  = "no",
  //! screw nut    : "no","default","nyloc"
  nut     = "no",
  //! extra washer : "no","spring","star"
  xwasher = "no",
  //! nut washer
  nwasher = false,
  //! drill type: "clearance" or "tap"
  dri_type  = "clearance",
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant,
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(type,type);

  screw_nut     = screw_nut(type);
  screw_washer  = screw_washer(type);
  lens          = fl_screw_lens(type,len,washer,nut,xwasher,nwasher);
  thick_washer  = lens[2];
  thick_xwasher = lens[3];
  thick_nwasher = lens[4];
  thick_nut     = lens[5];
  length        = len ? len : fl_screw_l(type,len,washer,nut,xwasher,nwasher);

  r       = screw_radius(type);
  bbox    = fl_bb_transform(T(Z(thick_washer+thick_xwasher)), fl_bb_screw(type,length));
  size    = fl_screw_size(type,length);
  hole_r  = dri_type=="clearance" ? screw_clearance_radius(type) : fl_screw_nominal(type)/2;
  hole_l  = length-(thick_washer+thick_xwasher);

  module do_assembly() {
    if (washer!="no")
      if (washer=="default") washer(screw_washer);
      else if (washer=="nylon") fl_color("DarkSlateGray") washer(screw_washer);
      else penny_washer(screw_washer);
    if (xwasher!="no")
      translate(Z(thick_washer))
        if (xwasher=="spring") spring_washer(screw_washer); else star_washer(screw_washer);
    if (nwasher)
      translate(-Z($fl_thickness))
        rotate(180,X)
        washer(nut_washer(screw_nut));
    if (nut!="no")
      translate(-Z($fl_thickness+thick_nwasher))
        rotate(180,X)
        nut(screw_nut, nyloc=(nut=="nyloc"), brass = false, nylon = false);
  }

  module do_footprint() {
    rotate(180,Y)
      rotate_extrude()
        intersection() {
          projection()
            fl_direct(direction=[-Y,0])
              screw(type,length);
          let(h=screw_head_height(type))
            translate([0,-h])
              let(w=let(r=screw_head_radius(type)) r?r:screw_radius(type))
                square(size=[w,length+h]);
        }
  }

  fl_vloop(verbs,bbox,octant,direction) fl_modifier($modifier) {
    if ($verb==FL_ADD) {
      translate(Z(thick_washer+thick_xwasher))
        screw(type, length, hob_point = 0, nylon = false);

    } else if ($verb==FL_BBOX) {
      fl_bb_add(bbox,$FL_ADD=$FL_BBOX,auto=true);

    } else if ($verb==FL_ASSEMBLY) {
      do_assembly();

    } else if ($verb==FL_DRILL) {
      translate(Z(NIL))
        fl_cylinder(FL_ADD,h=hole_l+2xNIL,r=hole_r,octant=-Z,$FL_ADD=$FL_DRILL);

    } else assert($verb==FL_FOOTPRINT,fl_error(["unimplemented verb",$verb])) {
      do_footprint();

    }
  }
}

/*!
 * Screw driven hole execution. The main difference between this module and
 * fl_lay_holes{} is that the FL_DRILL verb is delegated to screws.
 *
 * See fl_hole_Context{} for context variables passed to children().
 *
 * Runtime environment:
 *
 * - $fl_thickness: added to the hole depth
 *
 * **NOTE:** supported normals are x,y or z semi-axis ONLY
 *
 */
module fl_screw_holes(
  //! list of hole specs
  holes,
  //! enabled normals in floating semi-axis list form
  enable  = [-X,+X,-Y,+Y,-Z,+Z],
  //! pass-through hole depth
  depth=0,
  //! fallback screw
  screw,
  //! drill type ("clearance" or "tap")
  type="clearance",
  //! tolerance ⌀
  tolerance=0,
  countersunk=false
) {
  $fl_thickness = is_undef($fl_thickness) ? 0 : fl_optProperty($fl_thickness, $this_verb, default=$fl_thickness );
  fl_lay_holes(holes,enable,depth) let(
    screw = $hole_screw ? $hole_screw : screw,
    len   = ($hole_depth ? $hole_depth : depth)+$fl_thickness,
    d     = screw_head_radius(screw)*2
  ) assert(screw) {
    translate(+Z(NIL))
      resize([0,0,len+tolerance+2xNIL],auto=true)
        fl_screw(FL_DRILL,screw,len,dri_type=type);
    if (countersunk)
      resize([d+tolerance,0,0],auto=true)
        screw_countersink(screw);
  }
}
