/*!
 * trimpot engine file
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../ext/NopSCADlib/lib.scad>

include <../foundation/unsafe_defs.scad>

use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>
use <../foundation/mngm-engine.scad>
use <../foundation/type-engine.scad>
use <../foundation/util.scad>

// namespace
FL_TRIM_NS    = "trim";

FL_TRIM_POT10  = let(
  sz    = [9.5,10+1.5,4.8],
  bbox  = [[-sz.x/2,-sz.y/2-1.5/2,0],[sz.x/2,sz.y/2-1.5/2,sz.z]]
) fl_Object(bbox, name="ten turn trimpot", engine=FL_TRIM_NS, others=[fl_cutout(value=[-Y]),]);

FL_TRIM_DICT  = [
  FL_TRIM_POT10,
];

module fl_trimpot(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  type,
  //! thickness for FL_CUTOUT
  cut_thick,
  //! tolerance used during FL_CUTOUT
  cut_tolerance=0,
  //! translation applied to cutout (default 0)
  cut_drift=0,
  //! FL_CUTOUT direction list. Defaults to 'preferred' cutout direction
  cut_dirs,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant
) {
  cut_dirs  = is_undef(cut_dirs) ? fl_cutout(type) : cut_dirs;

  fl_vmanage(verbs,type,octant,direction) {
    if ($verb==FL_ADD) {
      trimpot10();

    } else if ($verb==FL_BBOX) {
      fl_bb_add(bbox);

    } else if ($verb==FL_CUTOUT) {
      fl_cutoutLoop(cut_dirs,fl_cutout(type))
        if ($co_preferred)
          fl_new_cutout($this_bbox,$co_current,drift=cut_drift,$fl_tolerance=cut_tolerance,$fl_thickness=cut_thick,trim=[0,5.1,0])
            trimpot10();

    } else {
      fl_error(["unimplemented verb",$this_verb]);
    }
  }
}
