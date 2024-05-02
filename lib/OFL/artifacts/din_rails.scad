/*!
 * DIN rails according to EN 60715 and DIN 50045, 50022 and 50035 standards
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../Round-Anything/polyround.scad>

include <../foundation/label.scad>
include <../foundation/unsafe_defs.scad>
include <../foundation/util.scad>

use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>
use <../foundation/polymorphic-engine.scad>

//! prefix used for namespacing
FL_DIN_NS  = "DIN";

//**** punch ******************************************************************

//! Punch constructor
function fl_Punch(step) = [
  ["punch/step",step],
];

/*!
 * Performs a punch along the Z axis using children.
 *
 * Children context:
 *
 * - $punch: the punch instance containing stepping data
 * - $punch_thick: thickness of the performed punch to be used by children
 * - $punch_step: punch stepping
 *
 * TODO: extend to other generic axes, move source into core library
 */
module fl_punch(
  //! as returned by fl_Punch()
  punch,
  length,
  thick
) let(
    $punch        = punch,
    $punch_thick  = thick,
    $punch_step   = fl_property(punch,"punch/step")
  ) for(z=[0:$punch_step:length])
      translate(+Z(z))
        children();

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
  //! optional parameter as returned from fl_Punch()
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
  if (punch) ["DIN/rail/punch", punch],
  fl_cutout(value=[+Z,-Z]),
];

FL_DIN_PUNCH_4p2  = concat(
  fl_Punch(20),
  [
    ["DIN/rail/punch_d",    4.2],
    ["DIN/rail/punch_len",  12.2],
  ]
);
FL_DIN_PUNCH_6p2  = concat(
  fl_Punch(25),
  [
    ["DIN/rail/punch_d",    6.2],
    ["DIN/rail/punch_len",  15],
  ]
);

module fl_DIN_puncher() {
  d   = fl_property($punch,"DIN/rail/punch_d");
  len = fl_property($punch,"DIN/rail/punch_len");
  dir = [+Y,0];
  translate(+Z($punch_step-len)/2)
    translate(+Z(d/2)-Y(NIL))
      hull() {
        fl_cylinder(h=$punch_thick+2xNIL, d=d, direction=dir);
        translate(+Z(len-d))
          fl_cylinder(h=$punch_thick+2xNIL, d=d, direction=dir);
      }
}

// Specs taken from [RS PRO | RS PRO Steel Perforated DIN Rail, Mini Top Hat Compatible, 1m x 15mm x 5.5mm | 467-349 | RS Components](https://in.rsdelivers.com/product/rs-pro/rs-pro-steel-perforated-din-rail-mini-top-hat-1m-x/0467349)
FL_DIN_TS15   = function(length,punch)
  fl_DIN_Rail(
    profile     = FL_DIN_RP_TS15,
    punch       = punch,
    length      = length
  );
FL_DIN_TS35   = function(length,punch)
  fl_DIN_Rail(
    profile     = FL_DIN_RP_TS35,
    punch       = punch,
    length      = length
  );
FL_DIN_TS35D  = function(length,punch)
  fl_DIN_Rail(
    profile     = FL_DIN_RP_TS35D,
    punch       = punch,
    length      = length
  );

//! rail constructor inventory
FL_DIN_INVENTORY = [
  FL_DIN_TS15,
  FL_DIN_TS35,
  FL_DIN_TS35D
];

module fl_DIN_rail(
  //! supported verbs: FL_ADD, FL_AXES, FL_BBOX, FL_CUTOUT, FL_DRILL, CO_FOOTPRINT, FL_LAYOUT, FL_MOUNT
  verbs = FL_ADD,
  this,
  //! thickness for FL_CUTOUT
  cut_thick,
  //! tolerance used during FL_CUTOUT and FL_FOOTPRINT
  tolerance=0,
  //! translation applied to cutout (default 0)
  cut_drift=0,
  /*!
   * Cutout direction list in floating semi-axis list (see also fl_tt_isAxisList()).
   *
   * Example:
   *
   *     cut_direction=[+X,+Z]
   *
   * in this case the ethernet plug will perform a cutout along +X and +Z.
   *
   * **Note:** axes specified must be present in the supported cutout direction
   * list (retrievable through fl_cutout() getter)
   */
  cut_direction,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! see constructor fl_parm_Debug()
  debug
) {
  bbox    = fl_bb_corners(this);
  size    = bbox[1]-bbox[0];
  punch   = fl_optional(this,"DIN/rail/punch");
  length  = fl_property(this,"DIN/rail/length");
  profile = fl_property(this,"DIN/rail/profile");
  points  = fl_property(profile,"DIN/profile/points");
  thick   = fl_property(profile,"DIN/profile/thick");

  module do_shape(delta=0,footprint=false) {
    linear_extrude(size.z)
      let(points=footprint ? concat([points[0]],fl_list_sub(points,5)) : points)
        offset(delta)
          polygon(polyRound(points,fn=$fn));

    translate(+Z(size.z))
      if (!footprint) {
        if (fl_parm_labels(debug))
            for(i=[0:len(points)-1])
              let(p=points[i])
                translate([p.x,p.y])
                  fl_label(string=str("P[",i,"]"),size=1);
        if (fl_parm_symbols(debug))
          for(p=points)
            fl_sym_point(point=p, size=0.25);
      }
  }

  // run with an execution context set by fl_polymorph{}
  module engine() {

    if ($this_verb==FL_ADD) {
      difference() {
        do_shape();
        if (punch)
          fl_punch(punch,length,thick)
            fl_DIN_puncher();
      }

    } else if ($this_verb==FL_AXES) {
      fl_doAxes($this_size,$this_direction);

    } else if ($this_verb==FL_BBOX) {
      fl_bb_add($this_bbox,auto=true,$FL_ADD=$FL_BBOX);

    } else if ($this_verb==FL_CUTOUT) {
      for(axis=cut_direction)
        if (fl_isInAxisList(axis,fl_cutout(this)))
          let(
            sys = [axis.x ? -Z : X ,O,axis],
            t   = ($this_bbox[fl_list_max(axis)>0 ? 1 : 0]*axis+cut_drift)*axis
          )
          translate(t)
            fl_cutout(cut_thick,sys.z,sys.x,delta=tolerance)
              linear_extrude(size.z)
                polygon(polyRound(points,fn=$fn));
        else
          echo(str("***WARN***: Axis ",axis," not supported"));

    } else if ($this_verb==FL_FOOTPRINT) {
      do_shape(tolerance,true);

    } else if ($this_verb==FL_LAYOUT) {
      // to be implemented ...

    } else if ($this_verb==FL_MOUNT) {
      // to be implemented ...

    } else
      assert(false,str("***OFL ERROR***: unimplemented verb ",$this_verb));
  }

  // fl_polymorph() manages standard parameters and prepares the execution
  // context for the engine.
  fl_polymorph(verbs,this,octant,direction,debug)
    engine()
      children();
}
