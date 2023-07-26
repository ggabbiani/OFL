/*
 * Generic vitamin module
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../foundation/defs.scad>

use <../foundation/2d-engine.scad>
use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>
use <../foundation/mngm.scad>

FL_GENERIC_NS = "GENERIC";

/*
 * generic vitamin constructor
 */
function fl_generic_Vitamin(
  name,
  bbox,
  // when true FL_ADD is a no-op.
  ghost=true,
  /*
   * cut directions in floating semi-axis list format. This parameter defines
   * the cut out directions available.
   * See also fl_tt_isAxisList()
   */
  cut_directions

) =
assert(bbox)
assert(cut_directions && (!fl_debug() || fl_tt_isAxisList(cut_directions)))
[
  fl_name(value=name?name:str("Generic vitamin ",bbox[1]-bbox[0])),
  fl_bb_corners(value=bbox),
  fl_cutout(value=cut_directions),
  // ["cut directions",cut_directions],
  ["ghost", ghost],
];

/*
 * generic vitamin engine, usable when a cut out operation is needed for
 * a component not yet available as vitamin.
 */
module fl_generic_vitamin(
  // supported verbs: FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT
  verbs       = FL_ADD,
  type,
  // thickness for FL_CUTOUT as scalar or full semi axis value list (see fl_tt_isAxisVList())
  cut_thick=0,
  // tolerance used during FL_CUTOUT
  cut_tolerance=0,
  // translation applied to cutout as scalar or full semi axis value list (see fl_tt_isAxisVList())
  cut_drift=0,
  // debug parameter as returned from fl_parm_Debug()
  debug,
  // when undef native positioning is used
  octant,
  // desired direction [director,rotation], native direction when undef
  direction
) {
  assert(!fl_debug() || (is_num(cut_thick) || fl_tt_isAxisVList(cut_thick)));
  cut_thick       = is_num(cut_thick) ? [[cut_thick,cut_thick],[cut_thick,cut_thick],[cut_thick,cut_thick]] : cut_thick;
  cut_drift       = is_num(cut_drift) ? [[cut_drift,cut_drift],[cut_drift,cut_drift],[cut_drift,cut_drift]] : cut_drift;
  cut_directions  = fl_cutout(type);
  ghost           = fl_property(type,"ghost");

  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  D     = direction ? fl_direction(direction)  : FL_I;
  M     = fl_octant(octant,bbox=bbox);

  // return true if «axis» is present in «list»
  function isAxisInList(axis,list) = (search([axis],list)!=[[]]);

  module do_cutout() {
    // echo(cut_thick=cut_thick);
    2tol_2d = 2*[cut_tolerance,cut_tolerance];
    // echo(str("Axis -X in list: ",isAxisInList(-X,cut_directions)));
    // echo(str("Axis +X in list: ",isAxisInList(+X,cut_directions)));
    // echo(str("Axis -Y in list: ",isAxisInList(-Y,cut_directions)));
    // echo(str("Axis +Y in list: ",isAxisInList(+Y,cut_directions)));
    // echo(str("Axis -Z in list: ",isAxisInList(-Z,cut_directions)));
    // echo(str("Axis +Z in list: ",isAxisInList(+Z,cut_directions)));
    if (cut_thick.x[0] && isAxisInList(-X,cut_directions)) { // cut-out along -X semi axis
      T     = cut_thick.x[0];
      drift = cut_drift.x[0];
      sz    = [size.y,size.z]+2tol_2d;
      translate([bbox[0].x,bbox[0].y,bbox[0].z]+[-T-drift,-cut_tolerance,-cut_tolerance])
      rotate(90,FL_Z)
        rotate(90,FL_X)
          linear_extrude(height = T)
            fl_square(size=sz,corners=cut_tolerance,quadrant=+FL_X+FL_Y);
    }
    if (cut_thick.x[1] && isAxisInList(+X,cut_directions)) { // cut-out along +X semi axis
      T     = cut_thick.x[1];
      drift = cut_drift.x[1];
      sz    = [size.y,size.z]+2tol_2d;
      translate([bbox[1].x,bbox[0].y,bbox[0].z]+[drift,-cut_tolerance,-cut_tolerance])
      rotate(90,FL_Z)
        rotate(90,FL_X)
          linear_extrude(height = T)
            fl_square(size=sz,corners=cut_tolerance,quadrant=+FL_X+FL_Y);
    }
    if (cut_thick.y[0] && isAxisInList(-Y,cut_directions)) { // cut-out along -Y semi axis
      T     = cut_thick.y[0];
      drift = cut_drift.y[0];
      sz    = [size.x,size.z]+2tol_2d;
      translate([bbox[0].x,bbox[0].y,bbox[0].z]+[-cut_tolerance,-drift,-cut_tolerance])
        rotate(90,FL_X)
          linear_extrude(height = T)
            fl_square(size=sz,corners=cut_tolerance,quadrant=+FL_X+FL_Y);
    }
    if (cut_thick.y[1] && isAxisInList(+Y,cut_directions)) { // cut-out along +Y semi axis
      T     = cut_thick.y[1];
      drift = cut_drift.y[1];
      sz    = [size.x,size.z]+2tol_2d;
      translate([bbox[0].x,bbox[1].y,bbox[0].z]+[-cut_tolerance,T+drift,-cut_tolerance])
        rotate(90,FL_X)
          linear_extrude(height = T)
            fl_square(size=sz,corners=cut_tolerance,quadrant=+FL_X+FL_Y);
    }
    if (cut_thick.z[0] && isAxisInList(-Z,cut_directions)) { // cut-out along -Z semi axis
      T     = cut_thick.z[0];
      drift = cut_drift.z[0];
      sz    = [size.x,size.y]+2tol_2d;
      translate(bbox[0]-[cut_tolerance,cut_tolerance,T+drift])
        linear_extrude(height = T)
          fl_square(size=sz,corners=cut_tolerance,quadrant=+FL_X+FL_Y);
    }
    if (cut_thick.z[1] && isAxisInList(+Z,cut_directions)) { // cut-out along +Z semi axis
      T     = cut_thick.z[1];
      drift = cut_drift.z[1];
      sz    = [size.x,size.y]+2tol_2d;;
      translate([bbox[0].x-cut_tolerance,bbox[0].y-cut_tolerance,bbox[1].z+drift])
        linear_extrude(height = T)
          fl_square(size=sz,corners=cut_tolerance,quadrant=+FL_X+FL_Y);
    }

  }

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      if (!ghost) fl_modifier($modifier) translate(bbox[0])  fl_cube(size=size);

    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction,debug);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox,$FL_ADD=$FL_BBOX);

    } else if ($verb==FL_CUTOUT) {
      fl_modifier($modifier) do_cutout();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
