/*
 * Generic vitamin module
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../foundation/core.scad>

use <../foundation/2d-engine.scad>
use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>
use <../foundation/hole.scad>
use <../foundation/mngm-engine.scad>

FL_GENERIC_NS = "GENERIC";

function fl_generic_ghost(type,value) = fl_property(type,"generic/ghost (boolean)",value);

/*!
 * Generic vitamin constructor
 */
function fl_generic_Vitamin(
  //! bounding box
  bbox,
  //! optional name, a default is created if 'undef'
  name,
  /*!
   * optional hole list.
   *
   * **NOTE**: the hole list will drive FL_DRILL operations.
   */
  holes,
  //! when true FL_ADD is a no-op.
  ghost=true,
  /*!
   * cut directions in floating semi-axis list format.
   *
   * See also fl_tt_isAxisList() and fl_3d_AxisList()
   */
  cut_directions,
  engine="Generic",
  specs=[]
) =
assert(!cut_directions || (!fl_debug() || fl_tt_isAxisList(cut_directions)))
assert(is_undef(holes) || (!fl_debug() || fl_tt_isHoleList(holes)))
  concat(
    [
      fl_name(value=name?name:str("Generic vitamin ",bbox[1]-bbox[0])),
      fl_generic_ghost(value=ghost),
      assert(bbox)        fl_bb_corners(value=bbox),
      if (cut_directions) fl_cutout(value=cut_directions),
      if (holes)          fl_holes(value=holes),
    ],
    specs
  );

/*!
 * Generic vitamin engine, usable when a cut out, drill or layout operation is
 * needed for a component not yet available as vitamin.
 *
 * Children context: the whole hole context is passed during FL_LAYOUT (see also
 * fl_hole_Context()).
 */
module fl_generic_vitamin(
  //! supported verbs: FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT,FL_DRILL
  verbs       = FL_ADD,
  this,
  /*!
   * Scalar or full semi axis value list for FL_CUTOUT, FL_DRILL and FL_LAYOUT
   * thickness (see fl_tt_isAxisVList()).
   *
   * This parameter represents the surface thickness along semi-axes to be
   * drilled and/or cut out.
   */
  thick=0,
  //! tolerance used during FL_CUTOUT
  cut_tolerance=0,
  /*!
   * Scalar or full semi axis value list for translation applied to cutout
   * (see  fl_tt_isAxisVList())
   */
  cut_drift=0,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef
  direction
) {
  assert(!fl_debug() || (is_num(thick) || fl_tt_isAxisVList(thick)));
  thick           = is_num(thick) ? [[thick,thick],[thick,thick],[thick,thick]] : thick;
  cut_drift       = is_num(cut_drift) ? [[cut_drift,cut_drift],[cut_drift,cut_drift],[cut_drift,cut_drift]] : cut_drift;
  cut_directions  = fl_cutout(this,default=[]);
  ghost           = fl_generic_ghost(this);
  holes           = fl_optional(this,key=fl_holes()[0]);
  // layouts         = fl_optional(this,key=fl_layouts()[0]);
  // echo(holes=holes,layouts=layouts);

  bbox  = fl_bb_corners(this);
  size  = fl_bb_size(this);
  D     = direction ? fl_direction(direction)  : FL_I;
  M     = fl_octant(octant,bbox=bbox);

  module do_cutout() {
    2tol_2d = 2*[cut_tolerance,cut_tolerance];
    if (thick.x[0] && fl_3d_axisIsSet(-X,cut_directions)) { // cut-out along -X semi axis
      T     = thick.x[0];
      drift = cut_drift.x[0];
      sz    = [size.y,size.z]+2tol_2d;
      translate([bbox[0].x,bbox[0].y,bbox[0].z]+[-T-drift,-cut_tolerance,-cut_tolerance])
      rotate(90,FL_Z)
        rotate(90,FL_X)
          linear_extrude(height = T)
            fl_square(size=sz,corners=cut_tolerance,quadrant=+FL_X+FL_Y);
    }
    if (thick.x[1] && fl_3d_axisIsSet(+X,cut_directions)) { // cut-out along +X semi axis
      T     = thick.x[1];
      drift = cut_drift.x[1];
      sz    = [size.y,size.z]+2tol_2d;
      translate([bbox[1].x,bbox[0].y,bbox[0].z]+[drift,-cut_tolerance,-cut_tolerance])
      rotate(90,FL_Z)
        rotate(90,FL_X)
          linear_extrude(height = T)
            fl_square(size=sz,corners=cut_tolerance,quadrant=+FL_X+FL_Y);
    }
    if (thick.y[0] && fl_3d_axisIsSet(-Y,cut_directions)) { // cut-out along -Y semi axis
      T     = thick.y[0];
      drift = cut_drift.y[0];
      sz    = [size.x,size.z]+2tol_2d;
      translate([bbox[0].x,bbox[0].y,bbox[0].z]+[-cut_tolerance,-drift,-cut_tolerance])
        rotate(90,FL_X)
          linear_extrude(height = T)
            fl_square(size=sz,corners=cut_tolerance,quadrant=+FL_X+FL_Y);
    }
    if (thick.y[1] && fl_3d_axisIsSet(+Y,cut_directions)) { // cut-out along +Y semi axis
      T     = thick.y[1];
      drift = cut_drift.y[1];
      sz    = [size.x,size.z]+2tol_2d;
      translate([bbox[0].x,bbox[1].y,bbox[0].z]+[-cut_tolerance,T+drift,-cut_tolerance])
        rotate(90,FL_X)
          linear_extrude(height = T)
            fl_square(size=sz,corners=cut_tolerance,quadrant=+FL_X+FL_Y);
    }
    if (thick.z[0] && fl_3d_axisIsSet(-Z,cut_directions)) { // cut-out along -Z semi axis
      T     = thick.z[0];
      drift = cut_drift.z[0];
      sz    = [size.x,size.y]+2tol_2d;
      translate(bbox[0]-[cut_tolerance,cut_tolerance,T+drift])
        linear_extrude(height = T)
          fl_square(size=sz,corners=cut_tolerance,quadrant=+FL_X+FL_Y);
    }
    if (thick.z[1] && fl_3d_axisIsSet(+Z,cut_directions)) { // cut-out along +Z semi axis
      T     = thick.z[1];
      drift = cut_drift.z[1];
      sz    = [size.x,size.y]+2tol_2d;;
      translate([bbox[0].x-cut_tolerance,bbox[0].y-cut_tolerance,bbox[1].z+drift])
        linear_extrude(height = T)
          fl_square(size=sz,corners=cut_tolerance,quadrant=+FL_X+FL_Y);
    }

  }

  module do_add() {
    if (!ghost)
      difference() {
        translate(bbox[0])
          fl_cube(size=size,octant=O0);
        if (holes)
          fl_holes(holes);
    }
    if (holes)
      fl_hole_debug(holes=holes);
  }

  module do_drill(enable=[+X,-X,+Y,-Y,+Z,-Z]) {
    fl_holes(holes,enable);
  }

  module do_layout() {
    fl_lay_holes(holes)
      children();
  }

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier)
        do_add();

    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox,$FL_ADD=$FL_BBOX);

    } else if ($verb==FL_CUTOUT) {
      fl_modifier($modifier) do_cutout();

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier) do_drill();

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout() children();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
