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

include <3d.scad>

/**
 * ... an unveiled mistery ...
 */
function lay_align_many(axis,types) = let(
  dummy = echo(fl_trace("****DEPRECATED***")) true
)
[
  for(t=types) let(c=fl_bb_corners(t)) [[c[0].x,0,c[0].z],[c[1].x,c[1].y-c[0].y,c[1].z]]
];

/**
 * creates a group with the resulting bounding box corners of a layout
 */
function lay_group(axis,gap,types) = [fl_bb_corners(value=lay_bb_corners(axis,gap,types))];

/**
 * add a bounding box shape
 */
module fl_bb_add(
  corners, // bounding box corners,
  2d=false
) {
  fl_trace("$FL_ADD",$FL_ADD);
  assert(is_list(corners),corners)
  translate(corners[0])
    if (!2d) fl_cube(size=corners[1]-corners[0],octant=+X+Y+Z);
    else fl_square(size=corners[1]-corners[0],quadrant=+X+Y);
}

/*
 * Projection of «vector» onto a cartesian «axis»
 */
function fl_3d_vectorialProjection(
  vector, // 3D vector
  axis    // cartesian axis ([-1,0,0]==[1,0,0]==X)
) =
assert(len(vector)==3,str("vector=",vector))
assert(fl_3d_abs(axis)==+X||fl_3d_abs(axis)==+Y||fl_3d_abs(axis)==+Z)
let(
  axis=fl_3d_abs(axis)
) (vector*axis)*axis;

/*
 * Projection of «vector» onto a cartesian «plane»
 */
function fl_3d_planarProjection(
  vector, // 3D vector
  plane   // cartesian plane by vector with ([-1,+1,0]==[1,1,0]==XY)
) = assert(
    fl_3d_abs(plane)==+X+Y||fl_3d_abs(plane)==+X+Z
  ||fl_3d_abs(plane)==+Y+X||fl_3d_abs(plane)==+Y+Z
  ||fl_3d_abs(plane)==+Z+X||fl_3d_abs(plane)==+Z+Y
) let(
  plane = fl_3d_abs(plane),
  x = fl_3d_vectorialProjection(vector,X) * plane * X,
  y = fl_3d_vectorialProjection(vector,Y) * plane * Y,
  z = fl_3d_vectorialProjection(vector,Z) * plane * Z
) x+y+z;

/*
 * Transforms a vector inside the +X+Y+Z octant
 */
function fl_3d_abs(a) = [abs(a.x),abs(a.y),abs(a.z)];

/**
 * Builds a minor vector
 */
function fl_3d_min(a,b) = [min(a.x,b.x),min(a.y,b.y),min(a.z,b.z)];
/**
 * Builds a max vector
 */
function fl_3d_max(a,b) = [max(a.x,b.x),max(a.y,b.y),max(a.z,b.z)];
/*
 * Cartesian plane from axis
 */
function fl_3d_orthoPlane(
  axis  // cartesian axis ([-1,0,0]==[1,0,0]==X)
) = assert(
  fl_3d_abs(axis)==+X||fl_3d_abs(axis)==+Y||fl_3d_abs(axis)==+Z
) [axis.x?0:1,axis.y?0:1,axis.z?0:1];

/**
 * calculates the overall bounding box size of a layout
 */
function lay_bb_size(axis,gap,types) = let(c = lay_bb_corners(axis,gap,types)) c[1]-c[0];

/**
 * returns the bounding box corners of a layout
 */
function lay_bb_corners(
  axis, // cartesian axis ([-1,0,0]==[1,0,0]==X)
  gap=0,// gap to be inserted between bounding boxes along axis
  types // list of types
) =
  assert(is_list(axis)&&len(axis)==3,str("axis=",axis))
  assert(is_num(gap),gap)
  assert(is_list(types),types)
  let(
    bbcs = [for(t=types) fl_bb_corners(t)]
  ) fl_bb_accum(axis,gap,bbcs);

/**
 * Accumulates a list of bounding boxes along a direction.
 *
 * Recursive algorithm, at each call a bounding box is extracted from «bbcs»
 * and decomposed into axial and planar components. The last bunding box in
 * the list ended up the recursion and is returned as result.
 * If there are still bounding boxes left, a new call is made and its
 * result, decomposed into the axial and planar components, used to produce a
 * new bounding box as follows:
 * - for planar component, the new negative and positive corners are calculated
 *   with the minimum dimensions between the current one and the result of the
 *   recursive call;
 * - for the axial component when axis is positive:
 *   - negative corner is equal to the current corner;
 *   - positive corner is equal to the current positive corner PLUS the gap and
 *     the axial dimension of the result;
 *   - when axis is negative:
 *     - negative corner is equal to the current one MINUS the gap and the
 *       axial dimension of the result
 *     - the positive corner is equal to the current corner.
 */
function fl_bb_accum(
  axis,   // cartesian axis ([-1,0,0]==[1,0,0]==X)
  gap=0,  // gap to be inserted between bounding boxes along axis
  bbcs    // bounding box corners
) =
assert(fl_3d_abs(axis)==+X||fl_3d_abs(axis)==+Y||fl_3d_abs(axis)==+Z)
assert(len(bbcs))
let(
  len   = len(bbcs),
  plane = fl_3d_orthoPlane(axis),
  sum   = axis*[1,1,1]>0,

  curr_result = bbcs[0],
  curr_plane  = [fl_3d_planarProjection(curr_result[0],plane),fl_3d_planarProjection(curr_result[1],plane)],
  curr_axis   = [fl_3d_vectorialProjection(curr_result[0],axis),fl_3d_vectorialProjection(curr_result[1],axis)],

  rest      = len(bbcs)>1 ? [for(i=[1:len(bbcs)-1]) bbcs[i]] : [],
  rest_result  = sum
  ? len(rest) ? fl_bb_accum(axis,gap,rest) + [O,gap*axis]: [O,O]
  : len(rest) ? fl_bb_accum(axis,gap,rest) - [O,gap*axis]: [O,O],
  rest_plane  = [fl_3d_planarProjection(rest_result[0],plane),fl_3d_planarProjection(rest_result[1],plane)],
  rest_axis = [fl_3d_vectorialProjection(rest_result[0],axis),fl_3d_vectorialProjection(rest_result[1],axis)],

  result_plane  = [fl_3d_min(curr_plane[0],rest_plane[0]),fl_3d_max(curr_plane[1],rest_plane[1])],
  result_axis_size  = rest_axis[1]-rest_axis[0],
  result_axis = sum
  ? [curr_axis[0],curr_axis[1]+result_axis_size]
  : [curr_axis[0]-result_axis_size,curr_axis[1]]
) result_plane + result_axis;

/**
 * layout of types along a direction.
 * There are basically two methods of invokation call:
 * - with as many children as the length of types: in this case each children will
 *   be called explicitly in turn with children($i)
 * - with one child only called repetitely through children(0) with $i equal to the
 *   current execution number.
 * Called children can use the following special variables:
 *  $i      - current item index
 *  $first  - true when $i==0
 *  $last   - true when $i==len(types)-1
 *  $item   - equal to types[$i]
 *  $len    - equal to len(types)
 *  $size   - equal to bounding box size of $item
 *
 */
module fl_layout(
  verbs = FL_LAYOUT, // supported verbs: FL_AXES, FL_BBOX, FL_LAYOUT
  axis,     // layout direction
  gap=0,    // gap inserted along «axis»
  types,    // list of types to be arranged
  direction,// desired direction in [vector,rotation] form, native direction when undef ([+X+Y+Z])
  octant    // when undef native positioning is used
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(len(axis)==3,axis);
  assert(is_num(gap),gap);
  assert(is_list(types),types);

  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);
  bbox  = lay_bb_corners(axis,gap,types);
  size  = bbox[1]-bbox[0]; // resulting size
  D     = direction ? fl_direction(direction=direction,default=[+Z,+X])  : I;
  M     = octant    ? fl_octant(octant=octant,bbox=bbox)                : I;

  fl_trace("$children",$children);
  $len  = len(types);
  sum   = axis*[1,1,1]>0;
  fac   = sum ? 1 : -1;
  bcs   = [for(t=types)
    let(cs=fl_bb_corners(t))
    [fl_3d_vectorialProjection(cs[0],axis),fl_3d_vectorialProjection(cs[1],axis)]];
  // composite sizes list
  sz    = [for(c=bcs) c[1]-c[0]];
  fl_trace("bcs",bcs);
  fl_trace("sz",sz);

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_bb_add(bbox);

      } else if ($verb==FL_LAYOUT) {
        fl_modifier($FL_LAYOUT)
          for($i=[0:$len-1]) {
            fl_trace("$i",$i);
            $first  = $i==0;
            $last   = $i==$len-1;
            $item   = types[$i];
            $size   = let(corner=fl_bb_corners($item)) corner[1]-corner[0];
            offset = sum
            ? $i>0 ? bcs[0][1] -bcs[$i][0] : O
            : $i>0 ? bcs[0][0] -bcs[$i][1] : O;
            sz = $i>1 ? fl_accum([for(j=[1:$i-1]) sz[j]]) : O;
            fl_trace("sz",sz);
            fl_trace("delta",$i*gap*axis);
            fl_trace("offset",offset);
            translate(offset+fac*sz+$i*gap*axis)
              if ($children>1) children($i); else children(0);
          };

      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=size);
  }
}
