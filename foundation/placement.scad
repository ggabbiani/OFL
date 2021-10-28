/*
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org).
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

include <defs.scad>
include <unsafe_defs.scad>

use     <layout.scad>
use     <util.scad>

function fl_octant(
  type    // type with "bounding corners" property
  ,octant // 3d octant
  ,bbox   // bounding box corners, overrides «type» settings
) = assert(type!=undef || bbox!=undef,str("type=",type,", bbox=",bbox))
let(
  corner  = bbox!=undef ? bbox : fl_bb_corners(type),
  size    = assert(corner!=undef) corner[1] - corner[0],
  half    = size / 2,
  delta   = [sign(octant.x) * half.x,sign(octant.y) * half.y,sign(octant.z) * half.z]
) T(-corner[0]-half+delta);

function fl_quadrant(
  type
  ,quadrant // 2d quadrant
  ,bbox     // bounding box corners
) = let(
  corner    = bbox!=undef ? bbox : fl_bb_corners(type),
  c0        = assert(corner!=undef) 
              let(c=corner[0]) [c.x,c.y,c.z==undef?0:c.z], 
  c1        = let(c=corner[1]) [c.x,c.y,c.z==undef?0:c.z]
) fl_octant(octant=[quadrant.x,quadrant.y,0],bbox=[c0,c1]);

module fl_place(
  type
  ,octant   // 3d octant
  ,quadrant // 2d quadrant
  ,bbox     // bounding box corners
) {
  assert(type!=undef || bbox!=undef,str("type=",type,", bbox=",bbox));
  assert(fl_XOR(octant!=undef,quadrant!=undef));
  bbox  = bbox!=undef ? bbox : fl_bb_corners(type);
  M     = octant!=undef 
    ? fl_octant(octant=octant,bbox=bbox) 
    : fl_quadrant(quadrant=quadrant,bbox=bbox);
  fl_trace("M",M);
  fl_trace("bbox",bbox);
  fl_trace("octant",octant);
  multmatrix(M) children();
}

module fl_placeIf(
  condition // when true placement is ignored
  ,type
  ,octant   // 3d octant
  ,quadrant // 2d quadrant
  ,bbox     // bounding box corners
) {
  assert(type!=undef || bbox!=undef,str("type=",type,", bbox=",bbox));
  assert(fl_XOR(octant!=undef,quadrant!=undef));
  fl_trace("type",type);
  fl_trace("bbox",bbox);
  fl_trace("condition",condition);
  if (condition) fl_place(type=type,octant=octant,quadrant=quadrant,bbox=bbox) children();
  else children();
}

/*
 * Direction matrix transforming native coordinates along new direction.
 *
 * Native coordinate system is represented by two vectors either retrieved 
 * from «proto» or passed explicitly through «default» in the format 
 * [direction axis (director),orthonormal vector (rotor)]
 *
 * New direction is expected in [Axis–angle representation](https://en.wikipedia.org/wiki/Axis%E2%80%93angle_representation) 
 * in the format [axis,rotation angle]
 *
 */
function fl_direction(
  proto,      // prototype with fl_directorKV and fl_rotorKV properties
  direction,  // desired direction in axis-angle representation [axis,rotation about]
  default     // default coordinate system by [director,rotor], overrides «proto» settings
) = 
assert(is_list(direction)&&len(direction)==2,str("direction=",direction))
assert(proto!=undef || default!=undef)
// echo(default=default,direction=direction)
let(
  def_dir = default==undef ? fl_director(proto) : default[0],
  def_rot = default==undef ? fl_rotor(proto)    : default[1],
  alpha   = direction[1],
  new_dir = fl_versor(direction[0]),
  new_rot = fl_transform(fl_align(def_dir,new_dir),def_rot)
) R(new_dir,alpha)                                // rotate «alpha» degrees around «new_dir»
* fl_planeAlign(def_dir,def_rot,new_dir,new_rot); // align direction

/*
 * Applies a direction matrix to its children.
 * See also fl_direction() function comments.
 */
module fl_direct(
  proto,      // prototype for native coordinate system
  direction,  // desired direction in axis-angle representation [axis,rotation about]
  default     // default coordinate system by [director,rotor], overrides «proto» settings
) {
  multmatrix(fl_direction(proto,direction,default)) children();
}
