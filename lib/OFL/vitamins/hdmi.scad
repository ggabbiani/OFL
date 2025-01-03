/*!
 * NopSCADlib HDMI engine wrapper.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

use     <../../ext/NopSCADlib/vitamins/pcb.scad>

use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>
use <../foundation/util.scad>
use <../foundation/mngm-engine.scad>


FL_HDMI_NS = "hdmi";

function fl_hdmi_new(nop_type) = let(
    l   = hdmi_depth(nop_type),
    iw1 = hdmi_width1(nop_type),
    iw2 = hdmi_width2(nop_type),
    ih1 = hdmi_height1(nop_type),
    ih2 = hdmi_height2(nop_type),
    h   = hdmi_height(nop_type),
    t   = hdmi_thickness(nop_type),
    bbox  = let(d=max(iw1,iw2)+2*t) [[-l/2,-d/2,h-2*t-ih2],[+l/2,+d/2,h]]
) [
  fl_nopSCADlib(value=nop_type),
  fl_bb_corners(value=bbox),
  // fl_director(value=+FL_X),fl_rotor(value=+FL_Y),
  fl_cutout(value=[+FL_X]),
];

// following HDMI socket definitions are taken from NopSCADlib/vitamins/pcb.scad
FL_HDMI_TYPE_A  = fl_hdmi_new(
  [ "hdmi_full", "HDMI socket",        12,   14,   10,  3,    4.5, 6.5, 0.5 ]
);
FL_HDMI_TYPE_C  = fl_hdmi_new(
  [ "hdmi_mini", "Mini HDMI socket",    7.5, 10.5, 8.3, 1.28, 2.5, 3.2, 0.35 ]
);
FL_HDMI_TYPE_D  = fl_hdmi_new(
  [ "hdmi_micro", "Micro HDMI socket", 8.5,  5.9, 4.43, 1.4, 2.3, 3,   0.3 ]
);

FL_HDMI_DICT = [
  FL_HDMI_TYPE_A,
  FL_HDMI_TYPE_C,
  FL_HDMI_TYPE_D
];

//*****************************************************************************
// keys
function fl_hdmi_nameKV(value)         = fl_kv("name",value);

/*!
 * Context variables:
 *
 * | Name | Type  | Description |
 * | ---  | ---   | ---         |
 * | $fl_thickness  | Parameter | thickness for FL_CUTOUT (see variable FL_CUTOUT)          |
 * | $fl_tolerance  | Parameter | tolerance used during FL_CUTOUT (see variable FL_CUTOUT)  |
 */
module fl_hdmi(
  //! supported verbs: FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT
  verbs       = FL_ADD,
  type,
  //! translation applied to cutout
  cut_drift=0,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(type);

  nop = fl_nopSCADlib(type);

  fl_vmanage(verbs, type, octant=octant, direction=direction) {
    if ($this_verb==FL_ADD) {
      fl_modifier($modifier) hdmi(nop,false);
    } else if ($this_verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add($this_bbox,auto=true);
    } else if ($this_verb==FL_CUTOUT) {
      assert($fl_thickness!=undef);
      fl_modifier($modifier)
        translate(X($this_size.x/2+cut_drift)) fl_cutout(len=$fl_thickness,z=FL_X,x=-FL_Z,delta=$fl_tolerance) hdmi(nop,false);
    } else {
      fl_error(["unimplemented verb",$this_verb]);
    }
  }
}
