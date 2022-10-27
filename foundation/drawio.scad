/*!
 * Draw.io helpers.
 * This module is **DEPRECATED** and will be removed in a future.
 *
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL).
 *
 * OFL is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * OFL is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with OFL.  If not, see <http://www.gnu.org/licenses/>.
 */

include <2d.scad>

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

  fl_manage(verbs,M,size=size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) polygon(points);
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) translate(bbox[0]) square(size=bbsize, center=false);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
