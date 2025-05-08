/*!
 * Screw implementation file for OpenSCAD Foundation Library.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <../../ext/NopSCADlib/core.scad>

include <../foundation/unsafe_defs.scad>
include <../foundation/dimensions.scad>

use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>
use <../foundation/hole-engine.scad>
use <../foundation/mngm-engine.scad>
use <../foundation/type-engine.scad>

//! screw namespace
FL_SCREW_NS  = "screw";

// **** properties ************************************************************

//! Screw shaft length (i.e. the length of the screw without the head)
function fl_screw_shaft(type,value)         = fl_property(type,str(FL_SCREW_NS,"/shaft length"),value);

//! screw specifications in NopSCADlib format
function fl_screw_specs(type,value,default) = fl_optProperty(type,"screw specifications",value,default);

// **** getters ***************************************************************

//! Returns the head style (hs_cap, hs_pan, hs_cs, hs_hex, hs_grub, hs_cs_cap or hs_dome)
function fl_screw_headType(type)  = screw_head_type(fl_screw_specs(type));
//! Returns the head ⌀
function fl_screw_headD(type)     = 2*screw_head_radius(fl_screw_specs(type));
//! Returns the head height
function fl_screw_headH(type)     = screw_head_height(fl_screw_specs(type));
//! Returns the default nut
function fl_screw_nut(type)       = screw_nut(fl_screw_specs(type));
/*!
 * Returns the hole ⌀ used during "clearance" FL_DRILL according to the
 * following formula:
 *
 *     hole ⌀ = nominal ⌀ + 2 * $fl_clearance
 *
 * The nominal ⌀ is the screw shaft ⌀ (i.e. the diameter of the screw without
 * the head).
 *
 * The $fl_clearance parameter is used to add a clearance to the hole ⌀. This
 * is useful when the screw is not a perfect fit in the hole.
 *
 * **NOTE:** when $fl_clearance is undef, the NopSCADlib clearance is used for
 * the hole ⌀ calculation.
 *
 * Context variables:
 *
 * | name           | Context   | Description
 * | ---            | ---       | ---
 * | $fl_clearance  | Parameter | See also fl_parm_clearance().
 */
function fl_screw_clearanceD(type) =
  is_undef($fl_clearance) ?
    2*screw_clearance_radius(fl_screw_specs(type)) :
    fl_nominal(type)+$fl_clearance*2;
//! Screw thread ⌀
function fl_screw_threadD(type)    = let(nop=fl_screw_specs(type)) screw_thread_diameter(nop);
//! Max screw thread length
function fl_screw_threadMax(type)  = let(nop=fl_screw_specs(type)) screw_max_thread(nop);

// **** helpers ***************************************************************

//! How far a counter sink head will go into a straight hole ⌀ «d»
function fl_screw_headDepth(type, d=0) = screw_head_depth(fl_screw_specs(type),d);

/*!
 * Screw **specifications** inventory in NopSCADlib format.
 */
FL_SCREW_SPECS_INVENTORY = [for(list = screw_lists, screw=list) if (screw) screw];

/*!
 * Screw assembly stack.
 *
 * The screw assembly stack is a stack of accessory elements mounted on a screw
 * when finally assembled. This type represents a 'generic' not exhaustive
 * logic considering the following elements in a top-down order:
 *
 * - screw head
 * - optional head spring or star washer
 * - optional head washer
 * - optional material thickness
 * - optional nut washer
 * - optional nut spring or star washer
 * - optional nut
 *
 * The returned list includes all the thicknesses that contribute to determining
 * the minimum necessary screw shank length:
 *
 * 0. exact length of the shank resulting from the sum of the thicknesses of
 *    each element of the stack
 * 1. nearest standard screw length ≥ to the previous one
 * 2. head spring or star washer thickness (0 if not present)
 * 3. head washer thickness (0 if not present)
 * 4. material thickness as passed to the function (0 if not present)
 * 5. optional nut washer thickness (0 if not present)
 * 6. optional nut spring or star washer thickness (0 if not present)
 * 7. optional nut thickness (0 if not present)
 *
 * The assembly stack can be built in two ways:
 *
 * - without a prefixed length («shank» parameter set to 0 or undef)
 * - with a prefixed shank («shank» parameter ≠ 0)
 */
function fl_screw_AssemblyStack(
  //! NopSCADlib screw type
  type,
  //! screw length, when undef or 0 the length is calculated
  shaft,
  //! undef, "spring" or "star"
  head_spring,
  //! undef, "default" or "penny"
  head_washer,
  //! material thickness
  thickness,
  //! undef, "default" or "penny"
  nut_washer,
  //! undef, "spring" or "star"
  nut_spring,
  //! undef, "default" or "nyloc"
  nut,
) =
  assert(type && !fl_native(type))
let(
  // nut_nyloc     = nut=="nyloc",
  screw_nut     = screw_nut(type),
  screw_washer  = screw_washer(type),
  thick_washer  = function(washer)
    is_undef(washer)              ? 0 :
    washer=="default"             ? washer_thickness(screw_washer) :
    assert(washer=="penny",washer)  washer_thickness(penny_washer(screw_washer)) ,
  thick_spring  = function(spring)
    is_undef(spring)            ? 0 :
    spring=="spring"            ? spring_washer_thickness(screw_washer) :
    assert(spring=="star",spring) washer_thickness(screw_washer), // missing star_washer_thickness()?!

  head_spring_t = head_spring ? thick_spring(head_spring) : 0,
  head_washer_t = head_washer ? thick_washer(head_washer) : 0,
  thickness     = thickness ? thickness : 0,
  nut_washer_t  = nut_washer ? thick_washer(nut_washer) : 0,
  nut_spring_t  = nut_spring ? thick_spring(nut_spring) : 0,
  nut_thick     = is_undef(nut) ? 0 : assert((nut=="default" || nut=="nyloc") && !is_undef(screw_nut) && screw_nut,fl_error(["No nut \"",nut,"\" found for screw \"",type[0],"\""])) nut_thickness(screw_nut, nut=="nyloc"),
  thick_all     = shaft ? shaft : thickness + head_spring_t + head_washer_t + nut_washer_t + nut_spring_t + nut_thick
) [thick_all,screw_longer_than(thick_all),head_spring_t,head_washer_t,thickness,nut_washer_t,nut_spring_t,nut_thick];

/*!
 * Screw constructor: build a screw object from specifications and length.
 */
function fl_Screw(
  //! NopSCADlib screw specifications
  nop,
  //! Shaft length
  length,
  //! Shaft length longer or equal than «longer_then»
  longer_than,
  //! Shaft length shorter or equal than «shorter_then»
  shorter_than,
  //! undef, "spring" or "star"
  head_spring,
  //! undef, "default" or "penny"
  head_washer,
  //! material thickness
  thickness,
  //! undef, "default" or "penny"
  nut_washer,
  //! undef, "spring" or "star"
  nut_spring,
  //! undef, "default" or "nyloc"
  nut
) =
  assert(nop)
  let(
    lens    = let(
      length  = length ? length : longer_than ? screw_longer_than(longer_than) : shorter_than ? screw_shorter_than(shorter_than) : undef
    ) fl_screw_AssemblyStack(nop, length, head_spring, head_washer, thickness, nut_washer, nut_spring, nut),
    head_h  = screw_head_height(nop),
    bbox    = let(
      r         = max(screw_radius(nop),screw_head_radius(nop)),
      positive  = lens[2]+lens[3]
    ) [
      [-r,-r,-lens[0] + positive],
      [+r,+r,+head_h  + positive]
    ],
    props = let(
      nominal_d     = 2*screw_radius(nop),
      head_d        = 2*screw_head_radius(nop),
      clearance_d   = function(type,key,value)  is_undef($fl_clearance) ? 2*screw_clearance_radius(nop) : nominal_d+$fl_clearance*2,
      thread_max    = screw_max_thread(nop),
      thickness     = function(type,key,value)  $fl_thickness
    ) [
      fl_screw_specs  (value  = nop       ),
      fl_nominal      (value  = nominal_d ),
      fl_screw_shaft  (value  = lens[0]   ),
      fl_dimensions   (value  = fl_DimensionPack([
        fl_Dimension(lens[0],     "shaft"       ),
        fl_Dimension(head_h,      "head"        ),
        fl_Dimension(head_d,      "head d"      ),
        fl_Dimension(nominal_d,   "nominal d"   ),
        fl_Dimension(clearance_d, "clearance d" ),
        fl_Dimension(thickness,   "thickness"   ),
      ])),
    ]
  ) fl_Object(bbox, name=nop[0], description=nop[1], others=props);

/*!
 * Builds a screw object inventory from specifications selection and shaft length.
 */
function fl_ScrewInventory(
  //! mandatory search inventory
  specs=FL_SCREW_SPECS_INVENTORY,
  //! screw name, ignored when undef
  name,
  //! nominal ⌀, when 0 or undef is ignored
  nominal,
  /*!
   * Either a scalar or a list with each element equal to one of the following:
   *
   *  - hs_cap
   *  - hs_pan
   *  - hs_cs
   *  - hs_hex
   *  - hs_grub
   *  - hs_cs_cap
   *  - hs_dome
   */
  head_type,
  /*!
   * head name is one of the following:
   *
   *  - "cap"
   *  - "pan"
   *  - "cs"
   *  - "hex"
   *  - "grub"
   *  - "cs_cap"
   *  - "dome"
   */
  head_name,
  //! Shaft exact length
  length,
  //! Shaft length longer or equal to «longer_then»
  longer_than,
  //! Shaft length shorter or equal to «shorter_then»
  shorter_than,
  //! undef, "spring" or "star"
  head_spring,
  //! undef, "default" or "penny"
  head_washer,
  //! material thickness
  thickness,
  //! undef, "default" or "penny"
  nut_washer,
  //! undef, "spring" or "star"
  nut_spring,
  //! undef, "default" or "nyloc"
  nut,
) = let(
  head_spring_l = is_undef(head_spring) ? [] : is_list(head_spring) ? head_spring : [head_spring],
  head_washer_l = is_undef(head_washer) ? [] : is_list(head_washer) ? head_washer : [head_washer],
  nut_washer_l  = is_undef(nut_washer)  ? [] : is_list(nut_washer)  ? nut_washer  : [nut_washer],
  nut_spring_l  = is_undef(nut_spring)  ? [] : is_list(nut_spring)  ? nut_spring  : [nut_spring],
  washer_l      = fl_list_unique(concat(head_spring_l,head_washer_l,nut_washer_l,nut_spring_l))
) [
  for(nop=fl_screw_specs_select(specs, name, nominal, head_type, head_name, nut, washer_l))
    fl_Screw(nop, length, longer_than, shorter_than, head_spring, head_washer, thickness=thickness, nut_washer=nut_washer, nut_spring=nut_spring, nut=nut)
];

/*!
 * Return a list of screw **specifications** matching the passed properties from
 * «inventory».
 *
 * **NOTE:** when a parameter is undef the corresponding property is not
 * checked.
 */
function fl_screw_specs_select(
  //! mandatory search inventory
  inventory=FL_SCREW_SPECS_INVENTORY,
  //! screw name, ignored when undef
  name,
  //! nominal ⌀, when 0 or undef is ignored
  nominal,
  /*!
   * Either a scalar or a list with each element equal to one of the following:
   *
   *  - hs_cap
   *  - hs_pan
   *  - hs_cs
   *  - hs_hex
   *  - hs_grub
   *  - hs_cs_cap
   *  - hs_dome
   */
  head_type,
  /*!
   * head name is one of the following:
   *
   *  - "cap"
   *  - "pan"
   *  - "cs"
   *  - "hex"
   *  - "grub"
   *  - "cs_cap"
   *  - "dome"
   */
  head_name,
  /*!
   * nut support:
   *
   * - undef    : no nut required
   * - "default": default nut required
   * - "nyloc"  : nyloc nut required
   */
  nut,
  /*!
   * washer support, is either a scalar or a list with each element equal to one of:
   *
   * - "default": default washer required
   * - "penny"  : penny washer required
   * - "spring" : spring washer required
   * - "star"   : star washer required
   *
   * **NOTE:** if undef or [] no washer support required
   */
  washer
) = let(
    washer          = is_undef(washer) ? undef : is_list(washer) ? len(washer)==0 ? undef : washer : [washer],
    // verify if «screw» supports «washer_type» (one of "default", "spring", "star" or "penny")
    chk_washer_list = function(screw, lst) let(
      w           = screw_washer(screw),
      chk_washer  = function(washer_type) (
        w && (
            washer_type=="default"  ||
            washer_type=="spring"   ||
            washer_type=="star"     ||
            (assert(washer_type=="penny",washer_type) penny_washer(w))
        )
      )
    ) lst==[] ? true : chk_washer(lst[0]) ? chk_washer_list(screw, fl_pop(lst)) : false,
    head_type     = head_type ?
      assert(is_num(head_type)) head_type :
      assert(is_string(head_name))
      fl_switch(head_name,[
        ["cap"    ,hs_cap     ],
        ["pan"    ,hs_pan     ],
        ["cs"     ,hs_cs      ],
        ["hex"    ,hs_hex     ],
        ["grub"   ,hs_grub    ],
        ["cs cap" ,hs_cs_cap  ],
        ["dome"   ,hs_dome    ]
      ])
)
assert(inventory)
[
  for(s=inventory)
    if (  (is_undef(name)       || s[0]==name   )
      &&  (!nominal             || 2*screw_radius(s)==nominal   )
      &&  (is_undef(head_type)  || (let(ht=screw_head_type(s)) is_list(head_type) ? let(result=search(ht,head_type)) result!=[] : ht==head_type)  )
      &&  (is_undef(nut)        || ((nut=="default" || (nut=="nyloc") && screw_nut(s))))
      &&  (is_undef(washer)     || (chk_washer_list(s,washer)))
    ) s
];

/*!
 * Context variables:
 *
 * | name           | Context   | Description
 * | ---            | ---       | ---
 * | $fl_clearance  | Parameter | used during FL_DRILL. See also fl_parm_clearance()
 * | $fl_thickness  | Parameter | thickness during FL_ASSEMBLY. See also fl_parm_thickness()
 * | $fl_tolerance  | Parameter | used during FL_FOOTPRINT. See also fl_parm_tolerance()
 */
module fl_screw(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  //! NopSCADlib screw type
  type,
  //! undef, "spring" or "star"
  head_spring,
  //! undef, "default", "penny" or "nylon"
  head_washer,
  //! undef, "default", "penny" or "nylon"
  nut_washer,
  //! undef, "spring" or "star"
  nut_spring,
  //! undef, "default" or "nyloc"
  nut,
  //! drill type: "clearance" or "tap"
  dri_type  = "clearance",
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant,
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(fl_native(type),type);
  nop           = fl_screw_specs(type);
  screw_nut     = screw_nut(nop);
  screw_washer  = screw_washer(nop);
  shaft         = fl_screw_shaft(type);
  lens          = fl_screw_AssemblyStack(
    type        = nop,
    shaft       = shaft,
    head_spring = head_spring,
    head_washer = head_washer,
    thickness   = fl_parm_thickness(),
    nut_washer  = nut_washer,
    nut_spring  = nut_spring,
    nut         = nut);
  head_spring_t = lens[2];
  head_washer_t = lens[3];
  nut_washer_t  = lens[5];
  nut_spring_t  = lens[6];
  nut_t         = lens[7];
  clearance_d   = fl_screw_clearanceD(type);
  nominal_d     = fl_nominal(type);
  hole_r        = dri_type=="clearance" ? clearance_d/2 : nominal_d/2;
  dims          = fl_dimensions(type);
  Z_delta       = head_washer_t+head_spring_t;

  module do_assembly() {

    module my_washer(w_type)
      if (w_type=="default") washer(screw_washer);
      else if (w_type=="nylon") fl_color("DarkSlateGray") washer(screw_washer);
      else penny_washer(screw_washer);

    // positive Z
    if (head_washer)
      my_washer(w_type = head_washer);
    translate(+Z(head_washer_t))
      if (head_spring)
        if (head_spring=="spring") spring_washer(screw_washer); else star_washer(screw_washer);

    // negative Z below thickness
    translate(-Z($fl_thickness)) {
      if (nut_washer)
        rotate(180,X)
          my_washer(w_type = nut_washer);
      translate(-Z(nut_washer_t)) {
        if (nut_spring)
          rotate(180,X)
            if (nut_spring=="spring") spring_washer(screw_washer); else star_washer(screw_washer);

        translate(-Z(nut_spring_t))
          if (nut)
            assert(!is_undef(screw_nut)&&screw_nut!=false,fl_error(["No nut \"",nut,"\" found for screw \"",nop[0],"\""]))
            rotate(180,X)
              nut(screw_nut, nyloc=(nut=="nyloc"), brass = false, nylon = false);
      }
    }
  }

  module do_footprint() {
    translate(+Z(NIL))
      translate(Z(Z_delta))
        resize($this_size+2*$fl_tolerance*[1,1,1])
          rotate(180,Y)
            rotate_extrude()
              intersection() {
                projection()
                  fl_direct(direction=[-Y,0])
                    screw(nop,shaft);
                let(h=screw_head_height(nop))
                  translate([0,-h])
                    let(w=let(r=screw_head_radius(nop)) r?r:screw_radius(nop))
                      square(size=[w,shaft+h]);
              }
  }

  module dimensionLines() {
    $dim_width  = 0.1;
    $dim_object = type;
    // right view
    let(
      shaft       = fl_property(dims,"shaft"),
      head        = fl_property(dims,"head"),
      clearance   = fl_property(dims,"clearance d"),
      nominal     = fl_property(dims,"nominal d"),
      head_d      = fl_property(dims,"head d"),
      thickness   = fl_property(dims,"thickness"),
      $dim_view   = "right"
    ) {
      fl_dimension(geometry=thickness,align="negative",distr="h+");

      translate(+Z(Z_delta)) {
        fl_dimension(geometry=shaft,align="negative",distr="h+",$dim_level=+1);
        fl_dimension(geometry=head,align="positive",distr="h+",$dim_level=1);


      }
      fl_dimension(geometry=head_d,distr="v+");
      fl_dimension(geometry=nominal,distr="v-")
        fl_dimension(geometry=clearance,distr="v-");
    }
  }

  fl_vmanage(verbs,type,octant,direction) {
    if ($verb==FL_ADD) {
      translate(Z(Z_delta))
        screw(nop, shaft);
        // screw_and_washer(nop, shaft, star =true, penny =true);

      if (fl_dbg_dimensions())
        dimensionLines();

    } else if ($verb==FL_BBOX) {
      fl_bb_add($this_bbox,$FL_ADD=$FL_BBOX);

    } else if ($verb==FL_ASSEMBLY) {
      do_assembly();

    } else if ($verb==FL_DRILL) {
      translate(Z(Z_delta+NIL))
        fl_cylinder(FL_ADD,h=shaft+2xNIL,r=hole_r,octant=-Z,$FL_ADD=$FL_DRILL);

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
  //! fallback NopSCADlib screw specs
  nop_screw,
  //! drill type ("clearance" or "tap")
  type="clearance",
  /*
   * tolerance applied to screw countersink and length
   *
   * TODO: replace with $fl_tolerance
   */
  tolerance=0,
  countersunk=false
) {
  $fl_thickness = is_undef($fl_thickness) ? 0 : fl_optProperty($fl_thickness, $this_verb, default=$fl_thickness );
  fl_lay_holes(holes,enable,depth) let(
    nop     = $hole_screw ?  $hole_screw : nop_screw,
    len     = ($hole_depth ? $hole_depth : depth)+$fl_thickness,
    screw   = fl_Screw(nop,len)
  )  {
    translate(+Z(NIL))
      resize([0,0,len+tolerance+2xNIL],auto=true)
        fl_screw([FL_DRILL],screw,dri_type=type,$FL_DRILL="ON");
    if (countersunk) let(
      head_d  = fl_screw_headD(screw)
    ) resize((head_d+2*tolerance)*[1,1,0],auto=true)
        screw_countersink(nop);
  }
}
