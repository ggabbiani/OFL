/*!
 * T-slot nut engine for OpenSCAD Foundation Library.
 *
 * T-slot nuts are used with
 * [T-slot structural framing](https://en.wikipedia.org/wiki/T-slot_structural_framing)
 * to build a variety of industrial structures and machines.
 *
 * T-slot nut are not to be confused with [T-nuts](https://en.wikipedia.org/wiki/T-nut).
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <../vitamins/countersinks.scad>
include <../foundation/dimensions.scad>
include <../vitamins/screw.scad>
include <../foundation/unsafe_defs.scad>

use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>
use <../foundation/hole-engine.scad>
use <../foundation/mngm-engine.scad>

//! namespace
FL_TNUT_NS  = "tnut";

//*****************************************************************************
// T-slot nut properties

/*!
 * The height of a t-nut decomposed in its three components: wall, base, cone.
 *
 * The sum of the three components is always equal to the fl_height() of the
 * t-nut, so conforming to the following assertion
 * `assert(fl_accum(fl_tnut_height(tnut))==fl_height(tnut))`
 */
function fl_tnut_height(type,value) = fl_property(type,"tnut/[wall, base, cone] heights",value);

/*!
 * Constructor returning a T-slot nut.
 *
 * __TOP VIEW__:
 *
 * ![Front view](800x600/fig_tnut_top_view.png)
 *
 * __RIGHT VIEW__:
 *
 * ![Right view](800x600/fig_tnut_right_view.png)
 */
function fl_TNut(
  //! the opening of the T-slot
  opening,
  /*!
   * 2d size in the form [width (X size), length (Z size)], the height (Y size)
   * being calculated from «thickness».
   *
   * The resulting bounding box is: `[width, ∑ thickness, length]`
   */
  size,
  /*!
   * section heights passed as `[wall,base,cone]` thicknesses
   */
  thickness,
  //! an optional screw determining a hole
  nop_screw,
  //! eventual knurl nut
  knut=false,
  //! list of user defined holes usually positioned on the 'opening' side
  holes
) = assert(!nop_screw || !fl_native(nop_screw))
let(
  wall    = thickness[0],
  base    = thickness[1],
  cone    = thickness[2],
  size    = [size.x, fl_accum(thickness), size.y],
  bbox    = [[-size.x/2,-base-cone,0],[+size.x/2,+wall,size.z]],
  hole_d  = nop_screw ? 2*screw_radius(nop_screw) : undef,
  points  = [
    [bbox[1].x-cone,bbox[0].y],
    [bbox[1].x,bbox[0].y+cone],
    [bbox[1].x,bbox[0].y+cone+base],
    [opening/2,bbox[0].y+cone+base],
    [opening/2,bbox[1].y],

    [-opening/2,bbox[1].y],
    [-opening/2,bbox[0].y+cone+base],
    [bbox[0].x,bbox[0].y+cone+base],
    [bbox[0].x,bbox[0].y+cone],
    [bbox[0].x+cone,bbox[0].y],
  ]
) fl_Object(bbox,
  nominal = hole_d,
  others  = [
    ["opening", opening],
    fl_tnut_height(value=thickness),
    ["section points", points],
    if (nop_screw) fl_screw_specs(value=nop_screw),
    if (nop_screw) fl_holes(value=holes ? holes : [fl_Hole([0,bbox[1].y,size.z/2],hole_d,+Y,size.y,nop_screw=nop_screw)]),
    if (knut) let(kn=fl_knut_search(nop_screw,size.y)) assert(kn,"No knurl nut found") ["knut",kn],
    fl_dimensions(value=fl_DimensionPack([
      fl_Dimension(opening, "opening" ),
      fl_Dimension(size.x,  "width"   ),
      fl_Dimension(size.y,  "height"  ),
      fl_Dimension(size.z,  "length"  ),
      if (hole_d) fl_Dimension(hole_d,  "screw d" ),
      fl_Dimension(wall,    "wall"    ),
      fl_Dimension(base,    "base"    ),
      fl_Dimension(cone,    "cone"    ),
    ]))
  ]
);

FL_TNUT_M3_CS = fl_TNut(opening=6,size=[10,20],thickness=[1,1,2],nop_screw=M3_cs_cap_screw);
// T-slot nut usable with the Snapmaker enclosure for the AT series
FL_TNUT_M3_SM = fl_TNut(opening=6,size=[10,20],thickness=[2,1,2],nop_screw=M3_cs_cap_screw);
FL_TNUT_M4_CS = fl_TNut(opening=6,size=[10,20],thickness=[1,1.7,2],nop_screw=M4_cs_cap_screw);
FL_TNUT_M5_CS = fl_TNut(opening=6,size=[10,20],thickness=[1,2.2,1.5],nop_screw=M5_cs_cap_screw);
FL_TNUT_M6_CS = fl_TNut(opening=8,size=[18.6,20],thickness=[1.9,1.3,5.3],nop_screw=M6_cs_cap_screw);

FL_TNUT_DICT = [
  FL_TNUT_M3_CS,
  FL_TNUT_M4_CS,
  FL_TNUT_M5_CS,
  FL_TNUT_M6_CS
];

/*!
 * Selects the T-slot nuts from a dictionary matching the screw or a generic
 * nominal ⌀. When the «best» function literal is defined, it is applied to the
 * result for further filtering.
 */
function fl_tnut_select(
  dictionary  = FL_TNUT_DICT,
  //! screw specs to fit into
  nop_screw,
  //! nominal ⌀
  nominal,
  /*!
   * function literal to select the best match (defaults to the first match)
   *
   * **NOTE:** when undefined the result is always a list of all matching T-slot
   * nuts. Otherwise the result type (list or single nut) depends on the
   * implementation of the provided function literal.
   */
  best    = function(matches) matches[0]
) = let(
  nominal =
    nominal   ? assert(is_num(nominal)) nominal :
    nop_screw ? 2*screw_radius(nop_screw) :
    undef,
  result  = [
    for(nut=dictionary)
      if (
        is_undef(nominal) || nominal==fl_nominal(nut)
      ) nut
  ]
) best ? best(result) : result;

/*!
 * T-slot nut engine.
 *
 * See fl_hole_Context{} for context variables passed to children() during
 * FL_LAYOUT.
 *
 */
module fl_tnut(
  //! supported verbs: `FL_ADD, FL_AXES, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT, FL_MOUNT`
  verbs       = FL_ADD,
  type,
  /*!
   * tolerances added to [nut, hole, countersink] dimensions
   *
   * tolerance=x means [x,x,x]
   */
  tolerance=0,
  countersink=false,
  //! scalar thickness for FL_DRILL
  dri_thick=0,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+Z,0])
  direction,
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  thickness = fl_tnut_height(type);
  wall      = thickness[0];
  base      = thickness[1];
  cone      = thickness[2];
  points    = fl_property(type,"section points");
  screw     = fl_opt_Screw(
    fl_screw_specs(type),
    shorter_than  = (dri_thick+fl_size(type).y)
  );
  tolerance = is_undef(tolerance) ? [0,0,0] : is_num(tolerance) ? [tolerance,tolerance,tolerance] : tolerance;
  nut_t     = tolerance[0];
  hole_t    = tolerance[1];
  cs_t      = tolerance[2];
  holes     = fl_optional(type,"holes");
  knut      = fl_optional(type,"knut");
  ext_r     = knut ? fl_knut_r(knut)+hole_t : undef;
  dims      = fl_dimensions(type);

  module section_extrusion() {
    linear_extrude($this_size.z)
      offset(r=-nut_t)
        polygon(points);
  }

  module do_add() {
    fl_color()
      render() difference() {
        // add section extrusion
        section_extrusion();
        if (screw) { // subtract holes and countersink
          if (knut)
            fl_lay_holes(holes)
              translate(Y(NIL)) // resize([0,fl_bb_size(knut).y+2xNIL],0)
                fl_knut(FL_DRILL,dri_thick=[$hole_depth],type=knut,direction=[-$hole_n,0],octant=+Z,$FL_DRILL=$FL_ADD);
          else
            fl_holes(holes,tolerance=hole_t);
          if (countersink)
            do_layout()
              translate(-Y($this_size.y+NIL))
                fl_countersink(type=FL_CS_ISO_M3,$fl_tolerance=cs_t,direction=[-$hole_n,0],octant=-Z);
        }
        // subtract the cylinder guide for insert
        if (knut)
          let(h=$this_size.y-fl_thick(knut))
          if (h>0)
            do_layout()
              translate(-Y($this_size.y+NIL))
                fl_cylinder(h=h+2xNIL,r=ext_r,direction=[-$hole_n,0],octant=-Z);
      }
    if (fl_dbg_symbols() && holes)
      fl_hole_debug(holes);

    if (fl_dbg_dimensions()) let(
      dim_opening = fl_property(dims,"opening"),
      dim_width   = fl_property(dims,"width"),
      dim_height  = fl_property(dims,"height"),
      dim_length  = fl_property(dims,"length"),
      dim_d       = fl_property(dims,"screw d"),
      dim_wall    = fl_property(dims,"wall"),
      dim_base    = fl_property(dims,"base"),
      dim_cone    = fl_property(dims,"cone")
    ) {
      let(
        $dim_object = type,
        $dim_view   = "top",
        $dim_width  = 0.075,
        $dim_align  = "centered"
      ) {
        fl_dimension(geometry=dim_opening,distr="v+")
          fl_dimension(geometry=dim_width);
        fl_dimension(geometry=dim_d,      distr="v-");
        fl_dimension(geometry=dim_wall,   distr="h+",align="positive");
        fl_dimension(geometry=dim_base,   distr="h+",align="negative");
        fl_dimension(geometry=dim_cone,   distr="h+",align=-base-cone);
        fl_dimension(geometry=dim_height, distr="h-",align=-base-cone);
      }
      let(
        $dim_object = type,
        $dim_view   = "right",
        $dim_width  = 0.1,
        $dim_align  = "centered"
      ) {
        fl_dimension(geometry=dim_length, distr="h+",align="positive");
        fl_dimension(geometry=dim_wall,   distr="v+",align="positive");
        fl_dimension(geometry=dim_base,   distr="v+",align="negative");
        fl_dimension(geometry=dim_cone,   distr="v+",align=-base-cone);
        fl_dimension(geometry=dim_height, distr="v-",align=-base-cone);
      }
    }
  }

  module do_assembly() {
    if (knut)
      do_layout()
        fl_knut(type=knut,direction=[-$hole_n,0],octant=+Z,$FL_ADD=$FL_ASSEMBLY,$FL_AXES=$FL_ASSEMBLY);
  }

  module do_layout() {
    if (holes)
      fl_lay_holes(holes)
        children();
  }

  module do_drill() {
    assert(!is_undef(dri_thick),"FL_DRILL without thickness parameter");
    do_layout() {
      if (knut)
        fl_knut(FL_DRILL,type=knut,dri_thick=[-dri_thick],direction=[-$hole_n,0],octant=+Z);
      else
        fl_cylinder(h=dri_thick,d=$hole_d+hole_t,direction=[$hole_n,0],$FL_ADD=$FL_DRILL);
      // fl_screw(FL_DRILL,screw,len=dri_thick,direction=[-$hole_n,0]);
    }
  }

  module do_mount() {
    if (screw) {
      assert(!is_undef(dri_thick),"FL_MOUNT without thickness parameter");
      do_layout()
        translate($hole_n*dri_thick)
          fl_screw(FL_ADD,screw,direction=[$hole_n,0],$FL_ADD=$FL_MOUNT);
    }
  }

  fl_vmanage(verbs, type, octant=octant, direction=direction) {
    if ($this_verb==FL_ADD)
      do_add();

    else if ($this_verb==FL_ASSEMBLY)
      do_assembly()
        children();

    else if ($this_verb==FL_BBOX)
      fl_bb_add($this_bbox);

    else if ($this_verb==FL_DRILL)
      do_drill();

    else if ($this_verb==FL_FOOTPRINT)
      section_extrusion();

    else if ($this_verb==FL_LAYOUT)
      do_layout()
        children();

    else if ($this_verb==FL_MOUNT)
      do_mount();

    else
      fl_error(["unimplemented verb",$this_verb]);
  }
}
