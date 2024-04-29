/*!
 * DIN rails according to EN 60715 and DIN 50045, 50022 and 50035 standards
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <Round-Anything/polyround.scad>

include <../foundation/unsafe_defs.scad>
use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>
use <../foundation/polymorphic-engine.scad>

//! prefix used for namespacing
FL_DIN_NS  = "DIN";

//**** profiles ***************************************************************

//! helper for new 'object' definition
function fl_DIN_RailProfile(
  name,
  //! optional description
  description,
  //! Rails size in [[width-min,width-max],height]
  size,
  //! internal radii [upper radius,lower radius]
  r,
  thick=1
)  = let(
  sz  = [size.x[1],size.y]
) [
  fl_native(value=true),
  assert(name) fl_name(value=name),
  if (description) fl_description(value=description),
  [
    "DIN/profile/points",
    [
      [-size.x[1]/2,size.y,0],
      [-(size.x[0]/2-thick),size.y,r[1]+thick],
      [-(size.x[0]/2-thick),thick,r[0]],

      [+(size.x[0]/2-thick),thick,r[0]],
      [+(size.x[0]/2-thick),size.y,r[1]+thick],
      [+size.x[1]/2,size.y,0],
      [+size.x[1]/2,size.y-thick,0],
      [+size.x[0]/2,size.y-thick,r[1]],
      [+size.x[0]/2,0,r[0]+thick],

      [-size.x[0]/2,0,r[0]+thick],
      [-size.x[0]/2,size.y-thick,r[1]],
      [-size.x[1]/2,size.y-thick,0]
    ]
  ],
  ["DIN/profile/size",size],
  ["DIN/profile/radii",r],
  ["DIN/profile/thick",thick],
];

FL_DIN_RP_TS15  = fl_DIN_RailProfile("TS15",size=[[10.5,15],5.5],r=[0.2,0.5]);
FL_DIN_RP_TS35  = fl_DIN_RailProfile("TS35",size=[[27,35],7.5],r=[.8,.8]);
FL_DIN_RP_TS35D = fl_DIN_RailProfile("TS35D",size=[[27,35],15],r=[1.25,1.25],thick=1.5);

//! profile inventory
FL_DIN_RP_INVENTORY = [
  FL_DIN_RP_TS15,
  FL_DIN_RP_TS35,
  FL_DIN_RP_TS35D
];

//**** rails ******************************************************************

//! DIN Rails constructor
function fl_DIN_Rail(
  //! one of the supported profiles (see variable FL_DIN_RP_INVENTORY)
  profile,
  //! overall rail length
  length,
  //! in [radius,length,step] format
  punch
) = let(
  bbox          = let(
    profile_size  = fl_property(profile,"DIN/profile/size"),
    sz            = assert(length) [profile_size.x[1],profile_size.y,length]
  ) [[-sz.x/2,0,0],[+sz.x/2,+sz.y,sz.z]]
) [
  fl_native(value=true),
  fl_bb_corners(value=bbox),
  assert(profile) ["DIN/rail/profile", profile],
  assert(length)  ["DIN/rail/length", length],
  if (punch) ["DIN/rail/punch", punch]
];

// Specs taken from [RS PRO | RS PRO Steel Perforated DIN Rail, Mini Top Hat Compatible, 1m x 15mm x 5.5mm | 467-349 | RS Components](https://in.rsdelivers.com/product/rs-pro/rs-pro-steel-perforated-din-rail-mini-top-hat-1m-x/0467349)
FL_DIN_TS15   = function(length,punched=false)
  fl_DIN_Rail(
    profile     = FL_DIN_RP_TS15,
    punch       = punched ? let(d=4.2,len=12.2-d,step=20) [d,len,step] : undef,
    length      = length
  );
FL_DIN_TS35   = function(length,punched=false)
  fl_DIN_Rail(
    profile     = FL_DIN_RP_TS35,
    punch       = punched ? let(d=6.2,len=15-d,step=25) [d,len,step] : undef,
    length      = length
  );
FL_DIN_TS35D  = function(length,punched=false)
  fl_DIN_Rail(
    profile     = FL_DIN_RP_TS35D,
    punch       = punched ? let(d=6.2,len=15-d,step=25) [d,len,step] : undef,
    length      = length
  );

//! rail constructor inventory
FL_DIN_INVENTORY = [
  FL_DIN_TS15,
  FL_DIN_TS35,
  FL_DIN_TS35D
];

module fl_DIN_rail(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  this,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! see constructor fl_parm_Debug()
  debug
) {

  // run with an execution context set by fl_polymorph{}
  module engine() let(
    size    = $this_bbox[1]-$this_bbox[0],
    profile = fl_property(this,"DIN/rail/profile"),
    points  = fl_property(profile,"DIN/profile/points"),
    thick   = fl_property(profile,"DIN/profile/thick"),
    punch   = fl_optional(this,"DIN/rail/punch"),
    length  = fl_optional(this,"DIN/rail/length")

  ) if ($this_verb==FL_ADD) {
    difference() {
      linear_extrude(size.z)
        polygon(polyRound(points,fn=$fn));
      if (punch) {
        d     = punch[0];
        len   = punch[1];
        step  = punch[2];
        translate(+Z(step-len)/2)
          for(z=[0:step:length])
            translate(+Z(z)-Y(NIL)) hull() {
              fl_cylinder(h=thick+2xNIL, d=d,direction=[+Y,0]);
              translate(+Z(len))
                fl_cylinder(h=thick+2xNIL, d=d,direction=[+Y,0]);
            }
      }
    }

  } else if ($this_verb==FL_AXES)
    fl_doAxes($this_size,$this_direction);

  else if ($this_verb==FL_BBOX)
    fl_bb_add(corners=$this_bbox+[-NIL*[1,1,1],NIL*[1,1,1]],$FL_ADD=$FL_BBOX);

  else if ($this_verb==FL_LAYOUT) {
    // to be implemented ...

  } else if ($this_verb==FL_MOUNT) {
    // to be implemented ...

  } else
    assert(false,str("***OFL ERROR***: unimplemented verb ",$this_verb));

  // fl_polymorph() manages standard parameters and prepares the execution
  // context for the engine.
  fl_polymorph(verbs,this,octant,direction,debug)
    engine()
      children();
}
