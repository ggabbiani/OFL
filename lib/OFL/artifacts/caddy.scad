/*!
 * Generic caddy artifact.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../foundation/core.scad>

use <../foundation/bbox-engine.scad>
use <../foundation/fillet.scad>
use <../foundation/mngm-engine.scad>
use <../foundation/polymorphic-engine.scad>

//! Caddy's namespace
FL_NS_CAD = "cad";

/*!
 * Builds a caddy around the passed object «type».
 * Even if not mandatory - when passed - children will be used during
 * FL_ADD (for drilling), FL_ASSEMBLY (for rendering) and FL_LAYOUT.
 *
 * Children must implement the following verbs:
 *
 * - FL_DRILL,FL_CUTOUT (used during FL_ADD)
 * - FL_ADD,FL_ASSEMBLY (used during FL_ASSEMBLY)
 *
 * Context passed to children:
 *
 * - $cad_thick     : see «thick» parameter
 * - $cad_tolerance : see tolerance
 * - $cad_verbs     : list of verbs to be executed by children()
 *
 * TODO: FL_DRILL implementation
 */
module fl_caddy(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  type,
  /*!
   * walls thickness in the fixed form: `[[-x,+x],[-y,+y],[-z+z]]`
   *
   * Passed as scalar means same thickness for all the six walls:
   * `[[«thick»,«thick»],[«thick»,«thick»],[«thick»«thick»]]`.
   *
   * examples:
   *
   * ```
   * thick=[[0,2.5],[0,0],[5,0]]
   * thick=2.5
   * ```
   */
  thick,
  //! faces defined by their orthonormal axis in floating semi-axis list format
  faces,
  //! SCALAR added to each internal payload dimension.
  tolerance   = fl_JNgauge,
  //! fillet radius, when > 0 a fillet is inserted where needed
  fillet      = 0,
  //! defines the value of $cad_verbs passed to children
  lay_verbs   =[],
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(thick);
  assert(faces);

  // delta to add to children thicknesses
  t_deltas  = let(d=(tolerance+fillet)) [
    [fl_isSet(-FL_X,faces)?d:0,fl_isSet(+FL_X,faces)?d:0],
    [fl_isSet(-FL_Y,faces)?d:0,fl_isSet(+FL_Y,faces)?d:0],
    [fl_isSet(-FL_Z,faces)?tolerance:0,fl_isSet(+FL_Z,faces)?tolerance:0]
  ];
  // thickness without tolerance and fillet
  thick     = is_num(thick) ? [[thick,thick],[thick,thick],[thick,thick]] : thick;
  // payload with tolerance and fillet
  pload     = let(
                d     = tolerance+fillet,
                pload = fl_bb_corners(type),
                delta = [
                    [fl_isSet(-FL_X,faces)?d:0, fl_isSet(-FL_Y,faces)?d:0, fl_isSet(-FL_Z,faces)?tolerance:0],
                    [fl_isSet(+FL_X,faces)?d:0, fl_isSet(+FL_Y,faces)?d:0, fl_isSet(+FL_Z,faces)?tolerance:0]
                  ]) [pload[0]-delta[0],pload[1]+delta[1]];
  // bounding box = payload + spessori
  bbox      = let(
                delta = [
                    [fl_isSet(-FL_X,faces)?thick.x[0]:0, fl_isSet(-FL_Y,faces)?thick.y[0]:0, fl_isSet(-FL_Z,faces)?thick.z[0]:0],
                    [fl_isSet(+FL_X,faces)?thick.x[1]:0, fl_isSet(+FL_Y,faces)?thick.y[1]:0, fl_isSet(+FL_Z,faces)?thick.z[1]:0]
                  ]) [pload[0]-delta[0],pload[1]+delta[1]];
  size      = bbox[1]-bbox[0];

  module context(verbs=[]) let(
    $cad_thick      = thick+t_deltas,
    $cad_tolerance  = tolerance,
    $cad_verbs      = verbs
  ) children();

  module do_add() {
    difference() {
      translate(bbox[0]) {
        for(f=faces)
          if (f==+FL_X) {
            translate(+fl_X(size.x)) fl_cube(size=[thick.x[1],size.y,size.z],octant=-FL_X+FL_Y+FL_Z);
          } else if (f==-FL_X) {
            fl_cube(size=[thick.x[0],size.y,size.z],octant=+FL_X+FL_Y+FL_Z);
          } else if (f==+FL_Y) {
            translate(+fl_Y(size.y)) fl_cube(size=[size.x,thick.y[1],size.z],octant=+FL_X-FL_Y+FL_Z);
          } else if (f==-FL_Y) {
            fl_cube(size=[size.x,thick.y[0],size.z],octant=+FL_X+FL_Y+FL_Z);
          } else if (f==+FL_Z) {
            translate(+fl_Z(size.z)) fl_cube(size=[size.x,size.y,thick.z[1]],octant=+FL_X+FL_Y-FL_Z);
          } else if (f==-FL_Z) {
            fl_cube(size=[size.x,size.y,thick.z[0]],octant=+FL_X+FL_Y+FL_Z);
          }
        if (fillet) {
          if (fl_isSet(+FL_X,faces) && fl_isSet(-FL_Z,faces))
            translate([size.x-thick.x[1],0,thick.z[0]]) fl_fillet([FL_ADD],r=fillet,h=size.y,direction=[+FL_Y,180]);
          if (fl_isSet(+FL_X,faces) && fl_isSet(+FL_Z,faces))
            translate([size.x-thick.x[1],0,size.z-thick.z[1]]) fl_fillet([FL_ADD],r=fillet,h=size.y,direction=[+FL_Y,90]);
          if (fl_isSet(+FL_Z,faces) && fl_isSet(-FL_X,faces))
            translate([thick.x[0],0,size.z-thick.z[1]]) fl_fillet([FL_ADD],r=fillet,h=size.y,direction=[+FL_Y,0]);
          if (fl_isSet(-FL_X,faces) && fl_isSet(-FL_Z,faces))
            translate([thick.x[0],0,thick.z[0]]) fl_fillet([FL_ADD],r=fillet,h=size.y,direction=[+FL_Y,-90]);
          if (fl_isSet(-FL_Y,faces) && fl_isSet(-FL_Z,faces))
            translate([0,thick.y[0],thick.z[0]]) fl_fillet([FL_ADD],r=fillet,h=size.x,direction=[+FL_X,+90]);
          if (fl_isSet(+FL_Z,faces) && fl_isSet(-FL_Y,faces))
            translate([0,thick.y[0],size.z-thick.z[1]]) fl_fillet([FL_ADD],r=fillet,h=size.x,direction=[+FL_X,0]);
          if (fl_isSet(+FL_Z,faces) && fl_isSet(+FL_Y,faces))
            translate([0,size.y-thick.y[1],size.z-thick.z[1]]) fl_fillet([FL_ADD],r=fillet,h=size.x,direction=[+FL_X,-90]);
          if (fl_isSet(-FL_Z,faces) && fl_isSet(+FL_Y,faces))
            translate([0,size.y-thick.y[1],thick.z[0]]) fl_fillet([FL_ADD],r=fillet,h=size.x,direction=[+FL_X,+180]);
        }
      }
      context([FL_DRILL,FL_CUTOUT])  children();
    }
  }

  module engine()
    if ($verb==FL_ADD)
      fl_modifier($modifier)
        fl_color()
          do_add() children();
    else if ($verb==FL_ASSEMBLY)
      fl_modifier($modifier) context(FL_DRAW) children();
    else if ($verb==FL_AXES)
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction);
    else if ($verb==FL_BBOX)
      fl_modifier($modifier) fl_bb_add(corners=bbox,$FL_ADD=$FL_BBOX);
    else if ($verb==FL_CUTOUT)
      fl_modifier($modifier) context([FL_CUTOUT]) children();
    else if ($verb==FL_DRILL)
      fl_modifier($modifier) context([FL_DRILL]) children();
    else if ($verb==FL_FOOTPRINT)
      fl_modifier($modifier) context(lay_verbs) fl_bb_add(corners=bbox,$FL_ADD=$FL_BBOX);
    else if ($verb==FL_LAYOUT)
      fl_modifier($modifier) context(lay_verbs) children();
    else if ($verb==FL_MOUNT)
      fl_modifier($modifier) context([FL_MOUNT]) children();
    else if ($verb==FL_PAYLOAD)
      fl_modifier($modifier) fl_bb_add(pload);
    else
      fl_error(["unimplemented verb: ",$verb]);

  fl_polymorph(verbs,type,octant=octant,direction=direction)
    engine()
      children();

}