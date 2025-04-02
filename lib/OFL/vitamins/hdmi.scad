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
use <../foundation/mngm-engine.scad>

include <../foundation/util.scad>

FL_HDMI_NS = "hdmi";

function fl_hdmi_new(nop) = let(
    l     = hdmi_depth(nop),
    iw1   = hdmi_width1(nop),
    iw2   = hdmi_width2(nop),
    ih1   = hdmi_height1(nop),
    ih2   = hdmi_height2(nop),
    h     = hdmi_height(nop),
    t     = hdmi_thickness(nop),
    bbox  = let(d=max(iw1,iw2)+2*t) [[-l/2,-d/2,h-2*t-ih2],[+l/2,+d/2,h]]
) fl_Object(bbox,name=nop[0],description=nop[1],others=[
    fl_nopSCADlib(value=nop),
    fl_cutout(value=[+X]),
  ]);

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
// function fl_hdmi_nameKV(value)         = fl_kv("name",value);

/*!
 * Context variables:
 *
 * | Name           | Type      | Description                                 |
 * | -------------  | -------   | ------------------------------------------- |
 * | $fl_thickness  | Parameter | thickness in FL_CUTOUT (see variable FL_CUTOUT)          |
 * | $fl_tolerance  | Parameter | tolerance in FL_CUTOUT and FL_FOOTPRINT (see variable FL_CUTOUT and variable FL_FOOTPRINT)  |
 */
module fl_hdmi(
  //! supported verbs: FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT
  verbs       = FL_ADD,
  type,
  //! translation applied to cutout
  cut_drift=0,
  /*!
   * Cutout direction list in floating semi-axis list (see also fl_tt_isAxisList()).
   *
   * Example:
   *
   *     cut_dirs=[+X,+Z]
   *
   * in this case the cutout is performed along +X and +Z.
   *
   */
  cut_dirs,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(type);

  nop       = fl_nopSCADlib(type);
  l         = hdmi_depth(nop);
  cut_dirs  = fl_cut_dirs(cut_dirs,type);

  module D() let(
    iw1 = hdmi_width1(nop),
    iw2 = hdmi_width2(nop),
    ih1 = hdmi_height1(nop),
    ih2 = hdmi_height2(nop),
    h   = hdmi_height(nop),
    t   = hdmi_thickness(nop)
  ) hull() {
    translate([-iw1 / 2, h - t - ih1])
      square([iw1, ih1]);
    translate([-iw2 / 2, h - t - ih2])
      square([iw2, ih2]);
  }

  module do_footprint()
    rotate([90, 0, 90])
      linear_extrude(l, center=true)
        offset($fl_tolerance)
          D();

  fl_vmanage(verbs, type, octant=octant, direction=direction)

    if ($this_verb==FL_ADD)
      fl_modifier($modifier) hdmi(nop,false);

    else if ($this_verb==FL_BBOX)
      fl_modifier($modifier) fl_bb_add($this_bbox,auto=true);

    else if ($this_verb==FL_CUTOUT) {
      fl_cutoutLoop(cut_dirs, fl_cutout($this))
        if ($co_preferred)
          fl_new_cutout($this_bbox,$co_current,drift=cut_drift,$fl_tolerance=$fl_tolerance+2xNIL)
            do_footprint();

    } else if ($this_verb==FL_FOOTPRINT)
      do_footprint();

    else
      fl_error(["unimplemented verb",$this_verb]);

}
