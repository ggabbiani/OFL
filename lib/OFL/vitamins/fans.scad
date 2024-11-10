/*!
 * NopSCADlib fan wrapper library. This library wraps NopSCADlib fan instances
 * into the OFL APIs.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../ext/NopSCADlib/core.scad>
include <../../ext/NopSCADlib/vitamins/screws.scad>
include <../../ext/NopSCADlib/vitamins/fans.scad>

include <../foundation/unsafe_defs.scad>

use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>
use <../foundation/polymorphic-engine.scad>

//! prefix used for namespacing
FL_FAN_NS  = "fan";

FL_FAN_120x25 = fl_Fan(fan120x25);
FL_FAN_80x38  = fl_Fan(fan80x38);
FL_FAN_80x25  = fl_Fan(fan80x25);
FL_FAN_70x15  = fl_Fan(fan70x15);
FL_FAN_60x25  = fl_Fan(fan60x25);
FL_FAN_60x15  = fl_Fan(fan60x15);
FL_FAN_50x15  = fl_Fan(fan50x15);
FL_FAN_40x11  = fl_Fan(fan40x11);
FL_FAN_30x10  = fl_Fan(fan30x10);
FL_FAN_25x10  = fl_Fan(fan25x10);
FL_FAN_17x8   = fl_Fan(fan17x8 );

//! package inventory as a list of pre-defined and ready-to-use 'objects'
FL_FAN_INVENTORY = [
  FL_FAN_17x8 ,
  FL_FAN_25x10,
  FL_FAN_30x10,
  FL_FAN_40x11,
  FL_FAN_50x15,
  FL_FAN_60x15,
  FL_FAN_60x25,
  FL_FAN_70x15,
  FL_FAN_80x25,
  FL_FAN_80x38,
  FL_FAN_120x25,
];

//! inventory item names
FL_FAN_NAMES = [
  for(fan=FL_FAN_INVENTORY) fl_name(fan)
];

/*!
 * Unwraps the nop screw from the OFL fan instance.
 *
 * __NOTE__: the returned value is a **NopSCADlib** list.
 */
function fl_fan_screw(type)  = fan_screw(fl_nopSCADlib(type));

/*!
 * Wraps a nop fan inside the corresponding OFL instance. The fl_nominal() is
 * equal to its diameter.
 */
function fl_Fan(
  nop,
  //! optional description
  description
)  = let(
  w           = fan_width(nop),
  d           = fan_depth(nop),
  description = str(w,"mm fan (",d,"mm depth)"),
  name        = str(w,"x",w,"x",d,"mm fan"),
  bbox        = [[-w/2,-w/2,-d],[+w/2,+w/2,0]]+NIL*[-[1,1,1],[1,1,1]]
) [
  fl_native(value=true),
  fl_bb_corners(value=bbox),
  fl_name(value=name),
  fl_description(value=description),
  fl_nominal(value=w),
  assert(nop) fl_nopSCADlib(value=nop)
];

/*!
 * OFL fan module.
 *
 * Children context during FL_LAYOUT:
 *
 * - $fan_director: direction axis
 * - $fan_direction: direction in [$fan_director,0] form
 * - $fan_thick: non negative scalar expressing the current child invocation thickness
 * - $fan_verb: current child invocation verb
 *
 */
module fl_fan(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  this,
  /*!
   * List of Z-axis thickness or a scalar value for FL_DRILL and FL_MOUNT
   * operations.
   *
   * A positive value represents thickness along +Z semi-axis.
   * A negative value represents thickness along -Z semi-axis.
   * One scalar value will used for both Z semi-axes.
   *
   * Example 1:
   *
   *     thick = [+3,-1]
   *
   * is interpreted as thickness of 3mm along +Z and 1mm along -Z
   *
   * Example 2:
   *
   *     thick = [-1]
   *
   * is interpreted as thickness of 1mm along -Z 0mm along +Z
   *
   * Example:
   *
   *     thick = 2
   *
   * is interpreted as a thickness of 2mm along ±Z
   *
   */
  thick=0,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction [+Z,0] when undef
  direction
) {
  bbox  = fl_bb_corners(this);
  nop   = fl_nopSCADlib(this);
  depth = (bbox[1]-bbox[0]).z;
  thick = fl_parm_SignedPair(thick);
  fan_t = fan_thickness(nop);
  screw = fl_fan_screw(this);

  module aperture()
    intersection() {
      square(fan_bore(nop), center=true);
      circle(d=fan_aperture(nop));
    }

  module bore(thick)
    linear_extrude(thick)
      aperture();

  module body() {

    module section()
      intersection() {
        square(fan_width(nop), center=true);
        circle(d=fan_outer_diameter(nop));
      }

    linear_extrude(depth)
      section();
  }

  //! check for full X axis equality
  function fl_is_X(axis) = let(
    sgn = fl_vector_sign(axis)
  ) sgn.x && !sgn.y && !sgn.z;

  //! check for full Y axis equality
  function fl_is_Y(axis) = let(
    sgn = fl_vector_sign(axis)
  ) !sgn.x && sgn.y && !sgn.z;

  //! check for full Z axis equality
  function fl_is_Z(axis) = let(
    sgn = fl_vector_sign(axis)
  ) !sgn.x && !sgn.y && sgn.z;


  module context(
    // layout direction passed as semi-axis (±Z ONLY)
    director
  ) {
    $fan_director   = director;
    $fan_direction  = [$fan_director,0];
    $fan_thick      = assert(fl_is_Z(director)) (director==+Z ? thick[1] : -thick[0]) + fan_t;
    $fan_verb       = $verb;
    children();
  }

  module do_layout() {
    fan_hole_positions(nop,0) {

      context(+Z)
        translate(+Z(thick[1]))
          children();

      context(-Z)
        translate(+Z(thick[0]))
          translate($fan_director*depth)
            children();
    }
  }

  // run with an execution context set by fl_polymorph{}
  module engine() let(
  ) if ($this_verb==FL_ADD) {
      translate(-Z(depth/2))
        fan(nop);

    } else if ($this_verb==FL_AXES) {
      fl_doAxes($this_size,$this_direction);

    } else if ($this_verb==FL_BBOX) {
      fl_bb_add(corners=$this_bbox,$FL_ADD=$FL_BBOX);

    } else if ($this_verb==FL_DRILL) {
      do_layout()
        fl_screw(FL_DRILL, screw, thick=$fan_thick, direction=[$fan_director,0]);
      // bore(thick[1]);
      // let(h=-thick[0])
      //   translate(-Z(-thick[0]+depth))
      //     bore(h);
      translate(-Z(depth))
        resize([fan_width(nop)+2xNIL,0,0],auto=[true,true,false])
          body();

    } else if ($this_verb==FL_FOOTPRINT) {
      fl_linear_extrude([-Z,0],fan_depth(nop))
        let(width=fan_width(nop))
          fl_square(size=width, corners=width/2-fan_hole_pitch(nop),$FL_ADD=$FL_FOOTPRINT);

    } else if ($this_verb==FL_LAYOUT) {
      do_layout()
        children();

    } else if ($this_verb==FL_MOUNT) {
      translate(-Z(fan_t))
        fan_assembly(nop,thickness=thick[1]+fan_t,include_fan=false);

    } else
      assert(false,str("***OFL ERROR***: unimplemented verb ",$this_verb));

  // fl_polymorph() manages standard parameters and prepares the execution
  // context for the engine.
  fl_polymorph(verbs,this,octant=octant,direction=direction)
    engine()
      children();
}
