/*!
 * A DIN rail is a metal rail of a standard type widely used for mounting
 * circuit breakers and industrial control equipment inside equipment racks.
 * These products are typically made from cold rolled carbon steel sheet with a
 * zinc-plated or chromated bright surface finish. Although metallic, they are
 * meant only for mechanical support and are not used as a busbar to conduct
 * electric current, though they may provide a chassis grounding connection.
 *
 * The term derives from the original specifications published by Deutsches
 * Institut für Normung (DIN) in Germany, which have since been adopted as
 * European (EN) and international (IEC) standards. The original concept was
 * developed and implemented in Germany in 1928, and was elaborated into the
 * present standards in the 1950s.
 *
 * ![DIN rails](800x600/fig-din_rails.png)
 *
 * ## Organization
 *
 * The package manages three type of objects:
 *
 * - **punches**: ancillary type, eventually moved elsewhere in the future, defining
 *   the punch type to be performed on a rail.
 * - **profiles**: representing the different rail sections available. Currently
 *   supported types are type Ω top head sections.  DIN profile instances are
 *   all prefixed with **TS**. The list of available profiles is contained in
 *   variable FL_DIN_TS_INVENTORY.
 * - **DIN rails**: concrete rail instantiations. DIN rail instances are
 *   prefixed with **TH**. The list of available rails is provided in
 *   variable FL_DIN_RAIL_INVENTORY .
 *
 * ## Legal
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../Round-Anything/polyround.scad>

include <../foundation/dimensions.scad>
include <../foundation/label.scad>
include <../foundation/unsafe_defs.scad>
include <../foundation/util.scad>

use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>
use <../foundation/polymorphic-engine.scad>

//! prefix used for namespacing
FL_DIN_NS  = "DIN";

//**** punch ******************************************************************

/*!
 * Punch constructor: it actually defines only the punch step, while the
 * concrete punch shape is defined by the children passed to the punch engine.
 */
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

//! 4.2 mm stepped punch
FL_DIN_PUNCH_4p2  = concat(
  fl_Punch(20),
  [
    ["DIN/rail/punch_d",    4.2],
    ["DIN/rail/punch_len",  12.2],
  ]
);

//! 6.3 mm stepped punch
FL_DIN_PUNCH_6p3  = concat(
  fl_Punch(25),
  [
    ["DIN/rail/punch_d",    6.3],
    ["DIN/rail/punch_len",  18],
  ]
);

/*!
 * This module defines the punch shape stepped by.
 */
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

//**** profiles ***************************************************************

//! DIN profile points property
function fl_DIN_profilePoints(type,value) = fl_property(type,str(FL_DIN_NS,"/profile/radii points"),value);
//! DIN profile size property
function fl_DIN_profileSize(type,value)   = fl_property(type,str(FL_DIN_NS,"/profile/size"),value);
//! DIN profile thickness property
function fl_DIN_profileThick(type,value)  = fl_property(type,str(FL_DIN_NS,"/profile/thickness"),value);

/*!
 * Constructor for Top hat section (TH), type O, or type Ω, with hat-shaped
 * cross section.
 */
function fl_DIN_TopHatSection(
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
  fl_DIN_profilePoints(value=
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
  ),
  fl_DIN_profileSize(value=size),
  ["DIN/profile/radii",r],
  fl_DIN_profileThick(value=thick),
  [str(FL_DIN_NS,"/dimensions"), fl_DimensionPack([
    fl_Dimension(size[0][0],"Wmin"),
    fl_Dimension(size[0][1],"Wmax"),
    fl_Dimension(size[1],"H"),
    fl_Dimension(thick,"t"),
    fl_Dimension((size[0][1]-size[0][0])/2,"delta"),
  ])],
];

/*!
 * Top hat section profile IEC/EN 60715 – 15×5.5 mm
 *
 * ![FL_DIN_TS15](800x600/fig-TS15_section.png)
 */
FL_DIN_TS15  = fl_DIN_TopHatSection("TS15",size=[[10.5,15],5.5],r=[0.2,0.5]);
/*!
 * Top hat section profile IEC/EN 60715 – 35×7.5 mm
 *
 * ![FL_DIN_TS35](800x600/fig-TS35_section.png)
 */
FL_DIN_TS35  = fl_DIN_TopHatSection("TS35",size=[[27,35],7.5],r=[.8,.8]);
/*!
 * Top hat section profile IEC/EN 60715 – 35×15 mm
 *
 * ![FL_DIN_TS35D](800x600/fig-TS35D_section.png)
 */
FL_DIN_TS35D = fl_DIN_TopHatSection("TS35D",size=[[27,35],15],r=[1.25,1.25],thick=1.5);

//! DIN profile inventory
FL_DIN_TS_INVENTORY = [
  FL_DIN_TS15,
  FL_DIN_TS35,
  FL_DIN_TS35D
];

//**** rails ******************************************************************

//! DIN rail profile property
function fl_DIN_railProfile(type,value)  = fl_property(type,"DIN/rail/profile",value);

//! DIN Rails constructor
function fl_DIN_Rail(
  //! one of the supported profiles (see variable FL_DIN_TS_INVENTORY)
  profile,
  //! overall rail length
  length,
  //! optional parameter as returned from fl_Punch()
  punch
) = let(
  bbox          = let(
    profile_size  = fl_DIN_profileSize(profile),
    sz            = assert(length) [profile_size.x[1],profile_size.y,length]
  ) [[-sz.x/2,0,0],[+sz.x/2,+sz.y,sz.z]]
) [
  fl_native(value=true),
  fl_bb_corners(value=bbox),
  assert(profile) fl_DIN_railProfile(value=profile),
  assert(length)  ["DIN/rail/length", length],
  if (punch) ["DIN/rail/punch", punch],
  fl_cutout(value=[+Z,-Z]),
  [str(FL_DIN_NS,"/dimensions"), fl_DimensionPack([
    fl_Dimension(length,"L"),
  ])],
];

// Specs taken from [RS PRO | RS PRO Steel Perforated DIN Rail, Mini Top Hat Compatible, 1m x 15mm x 5.5mm | 467-349 | RS Components](https://in.rsdelivers.com/product/rs-pro/rs-pro-steel-perforated-din-rail-mini-top-hat-1m-x/0467349)

//! Constructor for 15mm DIN rail with eventual 4.2mm punch
FL_DIN_RAIL_TH15   = function(length,punched=true)
  fl_DIN_Rail(
    profile     = FL_DIN_TS15,
    punch       = punched ? FL_DIN_PUNCH_4p2 : undef,
    length      = length
  );

//! Constructor for 35mm DIN rail with eventual 6.3mm punch
FL_DIN_RAIL_TH35   = function(length,punched=true)
  fl_DIN_Rail(
    profile     = FL_DIN_TS35,
    punch       = punched ? FL_DIN_PUNCH_6p3 : undef,
    length      = length
  );

//! Constructor for 35mm DIN 'depth' variant rail with eventual 6.3mm punch
FL_DIN_RAIL_TH35D  = function(length,punched=true)
  fl_DIN_Rail(
    profile     = FL_DIN_TS35D,
    punch       = punched ? FL_DIN_PUNCH_6p3 : undef,
    length      = length
  );

/*!
 * DIN rail constructor inventory.
 *
 * Every constructor - while instantiating different concrete rail - has the
 * same signature:
 *
 *     Constructor(length,punched=true);
 */
FL_DIN_RAIL_INVENTORY = [
  FL_DIN_RAIL_TH15,
  FL_DIN_RAIL_TH35,
  FL_DIN_RAIL_TH35D
];

/*!
 * DIN rail engine module.
 */
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
  /*!
   * Debug parameter (see also constructor fl_parm_Debug()) currently
   * supporting:
   *
   * - symbols (points)
   * - labels (points)
   * - dimension lines
   */
  debug
) {
  assert($fn,$fn);
  bbox    = fl_bb_corners(this);
  size    = bbox[1]-bbox[0];
  punch   = fl_optional(this,"DIN/rail/punch");
  length  = fl_property(this,"DIN/rail/length");
  profile = fl_DIN_railProfile(this);
  dims    = concat(fl_property(profile,str(FL_DIN_NS,"/dimensions")),fl_property(this,str(FL_DIN_NS,"/dimensions")));
  points  = fl_DIN_profilePoints(profile);
  thick   = fl_DIN_profileThick(profile);

  module do_shape(delta=0,footprint=false) {
    linear_extrude(size.z)
      let(points=footprint ? concat([points[0]],fl_list_sub(points,5)) : points)
        offset(delta) echo(points=points)
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
            fl_sym_point(point=[p.x,p.y], size=0.25);
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
      if (fl_parm_dimensions(debug)) let(
          $dim_object = this,
          $dim_width  = is_undef($dim_width) ? thick/5 : $dim_width,
          $dim_gap    = is_undef($dim_gap) ? 7*$dim_width : $dim_gap
        ) {
          let($dim_view="top") {
            let($dim_distr="v+") {
              let(delta=fl_property(dims,"delta")) {
                fl_dimension(geometry=delta,align=$this_bbox[0].x,mode="value");
                fl_dimension(geometry=delta,align=$this_bbox[1].x-fl_dim_value(delta),mode="value");
              }
              fl_dimension(geometry=fl_property(dims,"Wmin"))
                fl_dimension(geometry=fl_property(dims,"Wmax"));
            }
            let($dim_distr="h+") {
              fl_dimension(geometry=fl_property(dims,"H"),align="positive");
            }
            let($dim_distr="h-") {
              fl_dimension(geometry=fl_property(dims,"t"),align=size.y-thick);
            }
          }
          let($dim_view="right") {
            let($dim_distr="h+") {
              fl_dimension(geometry=fl_property(dims,"L"),align="positive");
            }
            let($dim_distr="v+") {
              fl_dimension(geometry=fl_property(dims,"t"),align=size.y-thick)
                fl_dimension(geometry=fl_property(dims,"H"),align="positive");
            }
          }
          let($dim_view="front") {
            let($dim_distr="v+") {
              let(delta=fl_property(dims,"delta")) {
                fl_dimension(geometry=delta,align=$this_bbox[0].x,mode="value");
                fl_dimension(geometry=delta,align=$this_bbox[1].x-fl_dim_value(delta),mode="value");
              }
              fl_dimension(geometry=fl_property(dims,"Wmin"))
                fl_dimension(geometry=fl_property(dims,"Wmax"));
            }
            let($dim_distr="h+") {
              fl_dimension(geometry=fl_property(dims,"L"),align="positive");
            }
          }
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
