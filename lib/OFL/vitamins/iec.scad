/*!
 * NopSCADlib IEC wrapper library. This library wraps NopSCADlib IEC instances
 * into the OFL APIs.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../NopSCADlib/core.scad>
include <../../NopSCADlib/vitamins/iecs.scad>

include <../foundation/unsafe_defs.scad>
include <../foundation/polymorphic-engine.scad>
include <screw.scad>

FL_IEC_NS="iec";

/*!
 * IEC fused inlet JR-101-1F.
 *
 * ![FL_IEC_FUSED_INLET](256x256/fig_FL_IEC_FUSED_INLET.png)
 */
FL_IEC_FUSED_INLET                  = fl_IEC(IEC_fused_inlet);
/*!
 * IEC fused inlet old.
 *
 * ![FL_IEC_FUSED_INLET](256x256/fig_FL_IEC_FUSED_INLET2.png)
 */
FL_IEC_FUSED_INLET2                 = fl_IEC(IEC_fused_inlet2);
/*!
 * IEC320 C14 switched fused inlet module.
 *
 * ![FL_IEC_320_C14_SWITCHED_FUSED_INLET](256x256/fig_FL_IEC_320_C14_SWITCHED_FUSED_INLET.png)
 */
FL_IEC_320_C14_SWITCHED_FUSED_INLET = fl_IEC(IEC_320_C14_switched_fused_inlet);
/*!
 * IEC inlet.
 *
 * ![FL_IEC_INLET](256x256/fig_FL_IEC_INLET.png)
 */
FL_IEC_INLET                        = fl_IEC(IEC_inlet);
/*!
 * IEC inlet for ATX.
 *
 * ![FL_IEC_INLET_ATX](256x256/fig_FL_IEC_INLET_ATX.png)
 */
FL_IEC_INLET_ATX                    = fl_IEC(IEC_inlet_atx);
/*!
 * IEC die cast inlet for ATX.
 *
 * ![FL_IEC_INLET_ATX2](256x256/fig_FL_IEC_INLET_ATX2.png)
 */
FL_IEC_INLET_ATX2                   = fl_IEC(IEC_inlet_atx2);
/*!
 * IEC inlet filtered.
 *
 * ![FL_IEC_YUNPEN](256x256/fig_FL_IEC_YUNPEN.png)
 */
FL_IEC_YUNPEN                       = fl_IEC(IEC_yunpen);
/*!
 * IEC outlet RS 811-7193.
 *
 * ![FL_IEC_OUTLET](256x256/fig_FL_IEC_OUTLET.png)
 */
FL_IEC_OUTLET                       = fl_IEC(IEC_outlet);

FL_IEC_DICT = [
  FL_IEC_FUSED_INLET,
  FL_IEC_FUSED_INLET2,
  FL_IEC_320_C14_SWITCHED_FUSED_INLET,
  FL_IEC_INLET,
  FL_IEC_INLET_ATX,
  FL_IEC_INLET_ATX2,
  FL_IEC_YUNPEN,
  FL_IEC_OUTLET,
];

/*!
 * IEC mains inlets and outlet constructor. It wraps the corresponding
 * NopSCADlib object.
 */
function fl_IEC(nop,name,description) = let(
  w           = iec_width(nop),
  h           = iec_flange_h(nop),
  spades      = iec_spades(nop),
  description = description ? description : nop[1]
) [
  fl_native(value=true),
  if (name) fl_name(value=name),
  if (description) fl_description(value=description),
  fl_bb_corners(value=[[-w/2,-h/2,-iec_depth(nop)-spades[0][1]],[+w/2,+h/2,+iec_flange_t(nop)+iec_bezel_t(nop)]]),
  fl_nopSCADlib(value=nop),
  fl_screw(value=iec_screw(nop)),
  fl_engine(value=FL_IEC_NS),
];

module fl_iec(
  // supported verbs: FL_ADD, FL_AXES, FL_BBOX, FL_CUTOUT, FL_DRILL, FL_LAYOUT, FL_MOUNT
  verbs       = FL_ADD,
  this,
  //! thickness for FL_DRILL and FL_CUTOUT
  thick,
  // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  // when undef native positioning is used
  octant
) {

  module engine(thick) let(
    nop   = fl_nopSCADlib($this),
    screw = iec_screw(nop)
  ) if ($this_verb==FL_ADD)
      iec(nop);

    else if ($this_verb==FL_AXES)
      fl_doAxes($this_size,$this_direction);

    else if ($this_verb==FL_BBOX)
      fl_bb_add(corners=$this_bbox,$FL_ADD=$FL_BBOX);

    else if ($this_verb==FL_CUTOUT) {
      assert(is_num(thick))
      if (thick>=0)
        iec_holes(nop, h=thick+iec_flange_t(nop));

    } else if ($this_verb==FL_DRILL) {
      assert(is_num(thick))
      if (thick)
        iec_screw_positions(nop)
          fl_screw(FL_DRILL,screw,thick=thick);

    } else if ($this_verb==FL_LAYOUT) {
      translate(+Z(iec_flange_t(nop)))
        iec_screw_positions(nop) let(
          $iec_screw = screw
        ) children();

    } else if ($this_verb==FL_MOUNT)
      assert(is_num(thick)&&thick>=0)
      iec_assembly(nop, thick);
    else
      assert(false,str("***OFL ERROR***: unimplemented verb ",$this_verb));

  fl_polymorph(verbs,this,direction=direction,octant=octant)
    engine(thick)
      children();
}
