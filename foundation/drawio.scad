/*
 * Draw.io helpers.
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
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
 * along with OFL.  If not, see <http: //www.gnu.org/licenses/>.
 */

include <unsafe_defs.scad>
use     <2d.scad>
use     <placement.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

/* [Supported verbs] */

// adds shapes to scene.
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
QUADRANT      = [+1,+1];  // [-1:+1]

/* [Draw.io] */

POLYCOORDS  = [[0.25,0],[0.75,0],[0.4,0.7],[0.6,0.7],[0.75,1],[0.25,1],[0.3,0.7],[0.2,0.5]];
SIZE        = [100,100];

/* [Hidden] */

module __test__() {
  verbs = [
    if (ADD!="OFF")   FL_ADD,
    if (AXES!="OFF")  FL_AXES,
    if (BBOX!="OFF")  FL_BBOX,
  ];
  quadrant  = PLACE_NATIVE ? undef : QUADRANT;
  dio_polyCoords(verbs, POLYCOORDS, SIZE, quadrant, $FL_ADD=ADD, $FL_AXES=AXES, $FL_BBOX=BBOX);
}

// Y invert and scale to size from draw.io coords
// Draw.io store geometries in the domain [0..1]
// So the final size is just a scale operation.
// Expressing an actual size in the span [0..1] is
// just a matter of dividing the actual size for the
// global X or Y length.
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
  verbs=FL_ADD, // FL_ADD,FL_AXIS,FL_BBOX
  points,       // 2d point list as provided by the Base Polygon Draw.io shape
  size,         // 2d size 
  quadrant      // native positioning when undef
) {
  axes    = fl_list_has(verbs,FL_AXES);
  verbs   = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);
  points  = dio_polyCoords(points,size);
  bbox    = fl_bb_polygon(points);
  bbsize  = bbox[1]-bbox[0];
  M       = quadrant ? fl_quadrant(quadrant=quadrant,bbox=bbox) : I;

  fl_trace("points",points);
  fl_trace("bbox",bbox);
  fl_trace("quadrant",quadrant);

  multmatrix(M) fl_parse(verbs) {
    if ($verb==FL_ADD) {
      fl_modifier($FL_ADD) polygon(points);
    } else if ($verb==FL_BBOX) {
      fl_modifier($FL_BBOX) translate(bbox[0]) square(size=bbsize, center=false);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
  if (axes)
    fl_modifier($FL_AXES) fl_axes(size=size);
}

  __test__();
