/*!
 * A DIN rail is a metal rail of a standard type widely used for mounting
 * circuit breakers and industrial control equipment inside equipment racks.
 * These products are typically made from cold rolled carbon steel sheet with a
 * zinc-plated or chromed bright surface finish. Although metallic, they are
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

include <../../ext/Round-Anything/polyround.scad>

include <../foundation/dimensions.scad>
include <../foundation/label.scad>
include <../foundation/unsafe_defs.scad>
include <../foundation/util.scad>

use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>

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
 * Context variables:
 *
 * | Name         | Context   | Description                                 |
 * | ------------ | --------- | ------------------------------------------- |
 * | $punch       | Children  | the punch instance containing stepping data |
 * | $punch_step  | Children  | punch stepping                              |
 * | $punch_thick | Children  | thickness of the performed punch to be used by children |
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
//! DIN profile size in [[width-min,width-max],height] format
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
  sz  = [size.x[1],size.y],
  pts = [
    [-size.x[1]/2,0,0],
    [-(size.x[0]/2-thick),0,r[1]+thick],
    [-(size.x[0]/2-thick),thick-size.y,r[0]],

    [+(size.x[0]/2-thick),thick-size.y,r[0]],
    [+(size.x[0]/2-thick),0,r[1]+thick],
    [+size.x[1]/2,0,0],
    [+size.x[1]/2,-thick,0],
    [+size.x[0]/2,-thick,r[1]],
    [+size.x[0]/2,-size.y,r[0]+thick],

    [-size.x[0]/2,-size.y,r[0]+thick],
    [-size.x[0]/2,-thick,r[1]],
    [-size.x[1]/2,-thick,0]
  ]
) fl_Object(fl_bb_polygon(pts), name=name, description=description, others = [
  fl_DIN_profilePoints(value=pts),
  ["DIN/profile/radii",r],
  fl_DIN_profileThick(value=thick),
  fl_DIN_profileSize(value=size),
  fl_dimensions(value= fl_DimensionPack([
    fl_Dimension(size[0][0],"Wmin"),
    fl_Dimension(size[0][1],"Wmax"),
    fl_Dimension(size[1],"H"),
    fl_Dimension(thick,"t"),
    fl_Dimension((size[0][1]-size[0][0])/2,"delta"),
  ])),
]);

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
  bbox  = let(2d = fl_bb_corners(profile)) [[2d[0].x,2d[0].y,0],[2d[1].x,2d[1].y,length]]
) fl_Object(bbox, engine=FL_DIN_NS, others = [
  assert(profile) fl_DIN_railProfile(value=profile),
  assert(length)  [str(FL_DIN_NS,"/rail/length"), length],
  if (punch)      [str(FL_DIN_NS,"/rail/punch"), punch],
  fl_cutout(value=[+Z,-Z]),
  fl_dimensions(value=fl_DimensionPack([
    fl_Dimension(length,"L"),
  ]))
]);

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
 *
 * Context variables:
 *
 * | Name             | Context   | Description                                           |
 * | ---------------- | --------- | ----------------------------------------------------- |
 * | $fl_thickness    | Parameter | Used during FL_CUTOUT (see also fl_parm_thickness())  |
 * | $fl_tolerance    | Parameter | Used during FL_CUTOUT (see fl_parm_tolerance())       |
 */
module fl_DIN_rail(
  //! supported verbs: FL_ADD, FL_AXES, FL_BBOX, FL_CUTOUT, FL_DRILL, CO_FOOTPRINT, FL_LAYOUT, FL_MOUNT
  verbs = FL_ADD,
  this,
  //! translation applied to cutout (default 0)
  cut_drift=0,
  /*!
   * Cutout direction list in floating semi-axis list (see also fl_tt_isAxisList()).
   *
   * Example:
   *
   *     cut_dirs=[±Z]
   *
   * in this case the rail will perform a cutout along +Z and -Z.
   *
   * **NOTE:** when undefined this parameter defaults to the preferred cutout
   * directions as specified by fl_cutout().
   */
  cut_dirs,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction
) {
  assert($fn,$fn);
  cut_dirs = cut_dirs ? cut_dirs : fl_cutout(this);
  punch   = fl_optional(this,"DIN/rail/punch");
  length  = fl_property(this,"DIN/rail/length");
  profile = fl_DIN_railProfile(this);
  pr_sz   = fl_DIN_profileSize(profile);
  dims    = concat(fl_dimensions(profile),fl_dimensions(this));
  points  = fl_DIN_profilePoints(profile);
  thick   = fl_DIN_profileThick(profile);

  // run with an execution context set by fl_vmanage{}
  module engine() {

    module do_shape(delta=0,footprint=false) {
      fl_extrude_if(!fl_dbg_labels() && !fl_dbg_symbols(), $this_size.z, 3)
        let(points=footprint ? concat([points[0]],fl_list_sub(points,5)) : points)
          offset(delta)
            polygon(polyRound(points,fn=$fn));
      // debug parameters management
      translate(+Z($this_size.z+0*0.5))
        if (!footprint) {
          if (fl_dbg_labels())
            for(i=[0:len(points)-1])
              let(p=points[i])
                translate([p.x,p.y])
                  fl_label(string=str("P[",i,"]"),size=1,$FL_ADD="ON");
          if (fl_dbg_symbols())
            for(p=points)
              fl_sym_point(point=[p.x,p.y], size=0.25, $FL_ADD="ON");
        }
    }

    if ($this_verb==FL_ADD) {
      // fl_render_if()
        difference() {
          do_shape();
          if (punch)
            translate(-Y(pr_sz.y))
              fl_punch(punch,length,thick)
                fl_DIN_puncher();
        }
      if (fl_dbg_dimensions()) let(
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
              fl_dimension(geometry=fl_property(dims,"H"),align="negative");
            }
            let($dim_distr="h-") {
              fl_dimension(geometry=fl_property(dims,"t"),align="negative");
            }
          }
          let($dim_view="right") {
            let($dim_distr="h+") {
              fl_dimension(geometry=fl_property(dims,"L"),align="positive");
            }
            let($dim_distr="v+") {
              fl_dimension(geometry=fl_property(dims,"t"),align="negative")
                fl_dimension(geometry=fl_property(dims,"H"));
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

    } else if ($this_verb==FL_BBOX) {
      fl_bb_add($this_bbox,$FL_ADD=$FL_BBOX);

    } else if ($this_verb==FL_CUTOUT) {
      fl_cutoutLoop(cut_dirs,fl_cutout(this))
        fl_new_cutout($this_bbox,$co_current,cut_drift)
          linear_extrude($this_size.z)
            polygon(polyRound(points,fn=$fn));

    } else if ($this_verb==FL_FOOTPRINT) {
      do_shape($fl_tolerance,true);

    } else if ($this_verb==FL_LAYOUT) {
      // to be implemented ...

    } else if ($this_verb==FL_MOUNT) {
      // to be implemented ...

    } else
      fl_error(["unimplemented verb",$this_verb]);
  }

  // fl_vmanage() manages standard parameters and prepares the execution
  // context for the engine.
  fl_vmanage(verbs,this,octant=octant,direction=direction)
    engine()
      children();
}
