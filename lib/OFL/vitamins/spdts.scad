/*!
 * Single pole, double throw switch.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../foundation/core.scad>

use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>
use <../foundation/mngm-engine.scad>

include <../../ext/NopSCADlib/vitamins/spades.scad>

FL_SODAL_SPDT = let(
  len    = 40,
  d      = 19,
  head_d = 22,
  head_h = +2
) [
  fl_name(value="B077HJT92M"),
  fl_description(value="SODIAL(R) SPDT Button Switch 220V"),
  fl_bb_corners(value=[
    [-head_d/2, -head_d/2,  -len+head_h ],  // negative corner
    [+head_d/2, +head_d/2,   head_h     ],  // positive corner
  ]),
  ["nominal diameter",      d],
  ["length",                len],
  ["head diameter",         head_d],
  ["head height",           head_h],
  fl_vendor(value=
    [
      ["Amazon", "https://www.amazon.it/gp/product/B077HJT92M/"],
    ]
  ),
];

FL_SPDT_DICT = [ FL_SODAL_SPDT ];

function fl_spdt_d(type)      = fl_get(type,"nominal diameter");
function fl_spdt_l(type)      = fl_get(type,"length");
function fl_spdt_headH(type)  = fl_get(type,"head height");
function fl_spdt_headD(type)  = fl_get(type,"head diameter");

module fl_spdt(
  //! supported verbs: FL_ADD, FL_BBOX, FL_DRILL
  verbs       = FL_ADD,
  //! prototype
  type,
  //! desired direction [director,rotation], native direction when undef ([+Z,0])
  direction,
  //! when undef native positioning is used
  octant
) {
  assert(verbs!=undef);

  head_h  = fl_spdt_headH(type);
  head_d  = fl_spdt_headD(type);
  bbox    = fl_bb_corners(type);
  size    = fl_bb_size(type);
  d       = fl_spdt_d(type);
  D       = direction ? fl_direction(direction)  : FL_I;
  M       = fl_octant(octant,bbox=bbox);

  module head() {
    difference() {
      cylinder(d1=head_d,d2=16, h=head_h);
      cylinder(d=16, h=head_h);
    }
    cylinder(d=15.5, h=head_h);
  }

  module do_add() {
    fl_color("silver") head();
    let(h=20) translate(-fl_Z(h)) {
      fl_color("silver") cylinder(d=d, h=h);
      let(d=15,h=10) translate(-fl_Z(h)) {
        fl_color("LightSlateGray",0.8) cylinder(d=d, h=h);
        translate([0,-d/2+1,0]) {
          rotate(180,FL_X) spade(spade3,8);
          for(x=[-4.5,0,4.5]) translate([x,+3,0]) rotate(180,FL_X) spade(spade3,8);
        }
        translate([0,+d/2-1,0]) rotate(180,FL_X) spade(spade3,8);
      }
    }
  }

  module do_drill() {
    let(d=19,h=20) translate(-fl_Z(h))
      cylinder(d=d, h=h);
  }

  fl_vloop(verbs,bbox,octant,direction) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) translate(bbox[0]) cube(size=size,center=false);

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier) do_drill();

    } else {
      fl_error(["unimplemented verb",$this_verb]);
    }
  }
}
