/*!
 * Countersink definitions based on UNI 5933 and ISO 10642
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../ext/NopSCADlib/lib.scad>
include <../../ext/NopSCADlib/vitamins/screws.scad>

include <../foundation/core.scad>

use <../foundation/bbox-engine.scad>
use <../foundation/mngm-engine.scad>

//! countersinks namespace
FL_CS_NS  = "cs";

//*****************************************************************************
// properties
function fl_cs_k(type,value)        = fl_property(type,"cs/head height",value);
function fl_cs_dk(type,value)       = fl_property(type,"cs/head ⌀",value);
function fl_cs_angle(type,value)    = fl_property(type,"cs/angle",value);

//*****************************************************************************
// getters
function fl_cs_h(type)      = let(
    r     = fl_cs_d(type)/2,
    alpha = fl_cs_angle(type)/2
  ) r / tan(alpha);

//*****************************************************************************
// constructor
function fl_Countersink(
  name,
  //! nominal ⌀
  nominal,
  //! countersink head ⌀
  dk,
  //! head height
  k,
  //! countersink angle
  alpha=90
) =
  assert(name!=undef)
  assert(dk>0,dk)
  assert(nominal>0,nominal)
  assert(alpha>0 && alpha<180,alpha)
  assert(k>0,k)
  let(
    rk  = dk/2
  ) fl_Object([[-rk,-rk,-k],[rk,rk,0]],
    name        = name,
    description = str("M",nominal," countersink"),
    nominal     = nominal,
    others      = [
    fl_cs_dk(value=dk),
    fl_cs_angle(value=alpha),
    fl_cs_k(value=k),
    ]
  ) ;

FL_CS_UNI_M3    = fl_Countersink("Countersink UNI 5933 M3",3,6,1.7);
FL_CS_UNI_M4    = fl_Countersink("Countersink UNI 5933 M4",4,8,2.3);
FL_CS_UNI_M5    = fl_Countersink("Countersink UNI 5933 M5",5,10,2.8);
FL_CS_UNI_M6    = fl_Countersink("Countersink UNI 5933 M6",6,12,3.3);
FL_CS_UNI_M8    = fl_Countersink("Countersink UNI 5933 M8",8,16,4.4);
FL_CS_UNI_M10   = fl_Countersink("Countersink UNI 5933 M10",10,20,5.5);
FL_CS_UNI_M12   = fl_Countersink("Countersink UNI 5933 M12",12,24,6.5);
FL_CS_UNI_M16   = fl_Countersink("Countersink UNI 5933 M16",16,30,7.5);
FL_CS_UNI_M20   = fl_Countersink("Countersink UNI 5933 M20",20,36,8.5);

FL_CS_UNI_DICT = [
  FL_CS_UNI_M3,
  FL_CS_UNI_M4,
  FL_CS_UNI_M5,
  FL_CS_UNI_M6,
  FL_CS_UNI_M8,
  FL_CS_UNI_M10,
  FL_CS_UNI_M12,
  FL_CS_UNI_M16,
  FL_CS_UNI_M20
];

FL_CS_ISO_M2    = fl_Countersink("Countersink ISO 10642 M2",  2,    4.09,   1.350);
FL_CS_ISO_M2p5  = fl_Countersink("Countersink ISO 10642 M2.5",2.5,  5.08,   1.690);
FL_CS_ISO_M3    = fl_Countersink("Countersink ISO 10642 M3",  3,    5.81,   1.860);
FL_CS_ISO_M4    = fl_Countersink("Countersink ISO 10642 M4",  4,    7.96,   2.480);
FL_CS_ISO_M5    = fl_Countersink("Countersink ISO 10642 M5",  5,    10.07,  3.100);
FL_CS_ISO_M6    = fl_Countersink("Countersink ISO 10642 M6",  6,    12.16,  3.720);
FL_CS_ISO_M8    = fl_Countersink("Countersink ISO 10642 M8",  8,    16.43,  4.960);
FL_CS_ISO_M10   = fl_Countersink("Countersink ISO 10642 M10", 10,   20.69,  6.200);
FL_CS_ISO_M12   = fl_Countersink("Countersink ISO 10642 M12", 12,   24.81,  7.440);
FL_CS_ISO_M14   = fl_Countersink("Countersink ISO 10642 M14", 14,   28.31,  8.400);
FL_CS_ISO_M16   = fl_Countersink("Countersink ISO 10642 M16", 16,   30.61,  8.800);
FL_CS_ISO_M20   = fl_Countersink("Countersink ISO 10642 M20", 20,   36.75,  10.160);

FL_CS_ISO_DICT = [
FL_CS_ISO_M2,
FL_CS_ISO_M2p5,
FL_CS_ISO_M3,
FL_CS_ISO_M4,
FL_CS_ISO_M5,
FL_CS_ISO_M6,
FL_CS_ISO_M8,
FL_CS_ISO_M10,
FL_CS_ISO_M12,
FL_CS_ISO_M14,
FL_CS_ISO_M16,
FL_CS_ISO_M20
];

/*!
 * return a countersink list fitting the passed properties or undef if no match
 * no match found.
 */
function fl_cs_select(
  dictionary=FL_CS_ISO_DICT,
  //! countersink name, when undef all names are matched
  name,
  //! nominal , when undef all nominal are matched
  nominal
) = [
  for(cs=dictionary)
    if (
          (is_undef(name)     || fl_name(cs)==name        )
      &&  (is_undef(nominal)  || fl_nominal(cs)==nominal  )
    ) cs
];

/*!
 * Context variables:
 *
 * | Name           | Context   | Description |
 * | -------------  | --------- | ---         |
 * | $fl_thickness  | Parameter | thickness of the surface to be FL_DRILLed. Can be verb-dependant (see fl_parm_thickness()). |
 * | $fl_tolerance  | Parameter | tolerance added to countersink's dimensions during FL_ADD, FL_BBOX and FL_FOOTPRINT. Can be verb-dependant (see fl_parm_tolerance()). |
 */
module fl_countersink(
  //! supported verbs: FL_ADD, FL_AXES, FL_BBOX, FL_DRILL, FL_FOOTPRINT.
  verbs=FL_ADD,
  type,
  //! desired direction [director,rotation], native direction when undef
  direction,
  //! when undef native positioning is used (+Z)
  octant
) {
  assert(verbs!=undef);
  assert(type,type);

  bbox          = assert(type,type) fl_bb_corners(type);
  size          = fl_bb_size(type);
  nominal       = fl_nominal(type);
  dk            = fl_cs_dk(type);
  k             = fl_cs_k(type);
  angle         = fl_cs_angle(type);
  dx            = nominal/10*tan(angle/2);

  module tolerant()
    if ($fl_tolerance)
      resize(size+$fl_tolerance*[2,2,1])
        children();
    else
      children();

  module doAdd() let(
    edge  = nominal/10
  ) intersection() {
    fl_cylinder(d=dk,h=k,octant=-Z);
    fl_cylinder(d1=nominal,d2=dk+2*dx,h=k,octant=-Z);
  }

  module engine()
    assert($fl_tolerance>=0,$fl_tolerance)

    if ($this_verb==FL_ADD)
      fl_modifier($modifier)
        doAdd();

    else if ($this_verb==FL_BBOX)
      fl_modifier($modifier)
        fl_bb_add(bbox,auto=true,$FL_ADD=$FL_BBOX);

    else if ($this_verb==FL_DRILL) {
      fl_modifier($modifier)
        if ($fl_thickness)
          fl_cylinder(d=dk+2*$fl_tolerance,h=$fl_thickness+$fl_tolerance,octant=+Z,$FL_ADD=$FL_DRILL);

    } else if ($this_verb==FL_FOOTPRINT)
      fl_modifier($modifier)
        tolerant()
          doAdd($FL_ADD=$FL_FOOTPRINT);

    else
      assert(false,str("***UNIMPLEMENTED VERB***: ",$this_verb));

  fl_vmanage(verbs,type,octant=octant,direction=direction)
    engine()
      children();
}
