/*!
 * Draw.io helpers.
 * This module is **DEPRECATED** and will be removed in a future.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <core.scad>

use <2d-engine.scad>
use <mngm.scad>

/*!
 * Y invert and scale to size from draw.io coords.
 *
 * Draw.io stores geometries in the domain [0..1], so the final size is just a
 * scale operation.
 *
 * Expressing an actual size in the span [0..1] is just a matter of dividing
 * the actual size for the global X or Y length.
 */
function dio_polyCoords(points,size) =
  assert(points!=undef && is_list(points))
  assert(size!=undef && is_list(size))
  let(
    M = [
      [size.x, 0      ],
      [0,     -size.y ],
    ]
  )
  [for(p=points)  M * p];

module dio_polyCoords(
  //! FL_ADD,FL_AXIS,FL_BBOX
  verbs=FL_ADD,
  //! 2d point list as provided by the Base Polygon Draw.io shape
  points,
  //! 2d size
  size,
  //! native positioning when undef
  quadrant
) {
  points  = dio_polyCoords(points,size);
  bbox    = fl_bb_polygon(points);
  bbsize  = bbox[1]-bbox[0];
  M       = fl_quadrant(quadrant,bbox=bbox);

  fl_trace("points",points);
  fl_trace("bbox",bbox);
  fl_trace("quadrant",quadrant);

  fl_manage(verbs,M) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) polygon(points);
    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        ; // fl_doAxes(size,direction,debug);
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) translate(bbox[0]) square(size=bbsize, center=false);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
