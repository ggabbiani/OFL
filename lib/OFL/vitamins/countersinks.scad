/*!
 * Countersink definitions, data taken from:
 * https://www.sailornautica.it/viti-metallo-inox-aisi-316-e-304/927-vite-testa-svasata-piana-esagono-incassato-m3-uni-5933-acciaio-inox-aisi-316.html
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <NopSCADlib/lib.scad>
include <NopSCADlib/vitamins/screws.scad>

use <../foundation/bbox-engine.scad>
use <../foundation/mngm-engine.scad>

//! countersinks namespace
FL_CS_NS  = "cs";

//*****************************************************************************
// properties
function fl_cs_d(type,value)        = fl_property(type,"cs/diameter",value);
function fl_cs_angle(type,value)    = fl_property(type,"cs/angle",value);
function fl_cs_nominal(type,value)  = fl_property(type,"cs/nominal diameter",value);

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
  description,
  d,
  angle
) =
  assert(name!=undef)
  assert(d>0)
  assert(angle>0)
  let(
    r           = d/2,
    alpha       = angle/2,
    h           = r/tan(alpha),
    description = description ? description : str("M",d,"countersink")
  ) [
    fl_name(value=name),
    fl_description(value=description),
    fl_cs_d(value=d),
    fl_cs_angle(value=angle),
    fl_bb_corners(value=[[-r,-r,-h],[r,r,0]]),
    fl_cs_nominal(value=d),
  ];

FL_CS_M3  = fl_Countersink("FL_CS_M3","M3 countersink",6+3/5,angle=90);
FL_CS_M4  = fl_Countersink("FL_CS_M4","M4 countersink",8+4/5,angle=90);
FL_CS_M5  = fl_Countersink("FL_CS_M5","M5 countersink",10+5/5,angle=90);
FL_CS_M6  = fl_Countersink("FL_CS_M6","M6 countersink",12+6/5,angle=90);
FL_CS_M8  = fl_Countersink("FL_CS_M8","M8 countersink",16+8/5,angle=90);
FL_CS_M10 = fl_Countersink("FL_CS_M10","M10 countersink",20+10/5,angle=90);
FL_CS_M12 = fl_Countersink("FL_CS_M12","M12 countersink",24+12/5,angle=90);
FL_CS_M16 = fl_Countersink("FL_CS_M16","M16 countersink",30+16/5,angle=90);
FL_CS_M20 = fl_Countersink("FL_CS_M20","M20 countersink",36+20/5,angle=90);

FL_CS_DICT = [
  FL_CS_M3
  ,FL_CS_M4
  ,FL_CS_M5
  ,FL_CS_M6
  ,FL_CS_M8
  ,FL_CS_M10
  ,FL_CS_M12
  ,FL_CS_M16
  ,FL_CS_M20
];

/*!
 * return a countersink fitting the nominal diameter «d» or undef
 */
function fl_cs_search(
  //! nominal diameter
  d
) = let(
  list = [for(cs=FL_CS_DICT) if (fl_cs_nominal(cs)==d) cs]
) list!=[] ? list[0] : undef;

module fl_countersink(
  verbs=FL_ADD,
  type,
  //! tolerance added to countersink's dimensions
  tolerance=0,
  //! desired direction [director,rotation], native direction when undef
  direction,
  //! when undef native positioning is used (+Z)
  octant
) {
  assert(verbs!=undef);

  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  d     = fl_cs_d(type)+tolerance;
  h     = fl_cs_h(type);
  D     = direction!=undef ? fl_direction(direction) : I;
  M     = octant!=undef ? fl_octant(octant=octant,bbox=bbox) : I;
  fl_trace("Verbs: ",verbs);

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD)
      fl_modifier($modifier)
        fl_cylinder(d1=tolerance,d2=d,h=h,octant=-Z);
    else if ($verb==FL_AXES)
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction,debug);
    else if ($verb==FL_BBOX)
      fl_modifier($modifier) translate(Z(NIL)) fl_bb_add(bbox);
    else
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
  }
}
