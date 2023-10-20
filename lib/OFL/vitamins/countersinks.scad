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

include <../foundation/core.scad>

use <../foundation/bbox-engine.scad>
// use <../foundation/mngm-engine.scad>

//! countersinks namespace
FL_CS_NS  = "cs";

//*****************************************************************************
// properties
function fl_cs_k(type,value)        = fl_property(type,"cs/head height",value);
function fl_cs_dk(type,value)       = fl_property(type,"cs/head ⌀",value);
function fl_cs_angle(type,value)    = fl_property(type,"cs/angle",value);
function fl_cs_nominal(type,value)  = fl_property(type,"cs/nominal ⌀",value);

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
  ) [
    fl_name(value=name),
    fl_description(value=str("M",nominal," countersink")),
    fl_cs_dk(value=dk),
    fl_cs_angle(value=alpha),
    fl_bb_corners(value=[[-rk,-rk,-k],[rk,rk,0]]),
    fl_cs_nominal(value=nominal),
    fl_cs_k(value=k),
  ];

FL_CS_M3  = fl_Countersink("FL_CS_M3",3,6,1.7);
FL_CS_M4  = fl_Countersink("FL_CS_M4",4,8,2.3);
FL_CS_M5  = fl_Countersink("FL_CS_M5",5,10,2.8);
FL_CS_M6  = fl_Countersink("FL_CS_M6",6,12,3.3);
FL_CS_M8  = fl_Countersink("FL_CS_M8",8,16,4.4);
FL_CS_M10 = fl_Countersink("FL_CS_M10",10,20,5.5);
FL_CS_M12 = fl_Countersink("FL_CS_M12",12,24,6.5);
FL_CS_M16 = fl_Countersink("FL_CS_M16",16,30,7.5);
FL_CS_M20 = fl_Countersink("FL_CS_M20",20,36,8.5);

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
 * return a countersink list fitting the passed properties or undef if no match
 * no match found.
 */
function fl_cs_search(
  name,
  //! nominal diameter
  d
) = [
  for(cs=FL_CS_DICT)
    if (
          (is_undef(name) || fl_name(cs)==name    )
      &&  (is_undef(d)    || fl_cs_nominal(cs)==d )
    ) cs
];

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
  assert(type,type);
  assert(tolerance>=0,tolerance);

  bbox    = assert(type,type) fl_bb_corners(type);
  size    =  fl_bb_size(type);
  nominal = fl_cs_nominal(type);
  dk      = fl_cs_dk(type);
  k       = fl_cs_k(type);
  angle   = fl_cs_angle(type);
  dx      = nominal/10*tan(angle/2);
  D       = direction ? fl_direction(direction) : I;
  M       = octant    ? fl_octant(octant=octant,bbox=bbox) : I;

  module tolerant()
    if (tolerance)
      resize(size+[2*tolerance,2*tolerance,tolerance])
        children();
    else
      children();

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD)
      fl_modifier($modifier) let(edge=nominal/10) {
        tolerant()
          intersection() {
            fl_cylinder(d1=nominal,d2=dk+2*dx,h=k,octant=-Z);
            fl_cylinder(d=dk,h=k,octant=-Z);
          }
      }
    else if ($verb==FL_AXES)
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction,debug);
    else if ($verb==FL_BBOX)
      fl_modifier($modifier)
        tolerant()
          fl_bb_add(bbox,$FL_ADD=$FL_BBOX);
    else
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
  }
}
