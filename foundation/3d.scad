/*!
 * 3d primitives
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
include <bbox.scad>
include <type_trait.scad>

/*!
 * cube defaults for positioning (fl_bb_cornersKV)
 * and direction (fl_directorKV, fl_rotorKV).
 */
function fl_cube_defaults(
  size=[1,1,1]
)  = let(
  size  = is_list(size) ? size : [size,size,size]
) [
  fl_bb_corners(value=[O,size]),  // octant ⇒ +X+Y+Z
  fl_director(value=+Z),
  fl_rotor(value=+X),
];

/*!
 * cube replacement
 */
module fl_cube(
  //! FL_ADD,FL_AXES,FL_BBOX
  verbs     = FL_ADD,
  size      = [1,1,1],
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation] or native direction if undef
  direction
) {
  size  = is_list(size) ? size : [size,size,size];
  defs  = fl_cube_defaults(size);

  D     = direction ? fl_direction(defs,direction=direction)  : I;
  M     = fl_octant(octant,type=defs);

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) cube(size,false);
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) cube(size);  // center=default=false ⇒ +X+Y+Z
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

/*!
 * sphere defaults for positioning (fl_bb_cornersKV)
 * and direction (fl_directorKV, fl_rotorKV).
 */
function fl_sphere_defaults(
  r = [1,1,1],
  d,
) = let(
  r  = is_undef(d) ? (is_list(r) ? r : [r,r,r]) : (is_list(d) ? d : [d,d,d])/2
) [
  fl_bb_corners(value=[-r,+r]),  // simmetric bounding box ⇒ octant==O
  fl_director(value=+Z),
  fl_rotor(value=+X),
];

/*!
 * sphere replacement.
 */
module fl_sphere(
  //! FL_ADD,FL_AXES,FL_BBOX
  verbs   = FL_ADD,
  r       = [1,1,1],
  d,
  //! when undef default positioning is used
  octant,
  //! desired direction [director,rotation], default direction if undef
  direction
) {
  defs  = fl_sphere_defaults(r,d);

  bbox  = fl_bb_corners(defs);
  size  = fl_bb_size(defs); // bbox[1] - bbox[0];
  D     = direction ? fl_direction(defs,direction=direction)  : I;
  M     = fl_octant(octant,type=defs);

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) resize(size) sphere();
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) cube(size,true);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

/*!
 * cylinder defaults for positioning (fl_bb_cornersKV)
 * and direction (fl_directorKV, fl_rotorKV).
 */
function fl_cylinder_defaults(
  //! height of the cylinder or cone
  h,
  //! radius of cylinder. r1 = r2 = r.
  r,
  //! radius, bottom of cone.
  r1,
  //! radius, top of cone.
  r2,
  //! diameter of cylinder. r1 = r2 = d / 2.
  d,
  //! diameter, bottom of cone. r1 = d1 / 2.
  d1,
  //! diameter, top of cone. r2 = d2 / 2.
  d2
) = [
  fl_bb_corners(value=fl_bb_cylinder(h,r,r1,r2,d,d1,d2)),  // +Z
  fl_director(value=+Z),
  fl_rotor(value=+X),
];

function fl_bb_cylinder(
  //! height of the cylinder or cone
  h,
  //! radius of cylinder. r1 = r2 = r.
  r,
  //! radius, bottom of cone.
  r1,
  //! radius, top of cone.
  r2,
  //! diameter of cylinder. r1 = r2 = d / 2.
  d,
  //! diameter, bottom of cone. r1 = d1 / 2.
  d1,
  //! diameter, top of cone. r2 = d2 / 2.
  d2
) =
assert(h && h>=0,h)
let(
  step    = 360/$fn,
  Rbase   = fl_parse_radius(r,r1,d,d1),
  Rtop    = fl_parse_radius(r,r2,d,d2),
  base    = [for(p=fl_bb_circle(r=Rbase)) [p.x,p.y,0]],
  top     = [for(p=fl_bb_circle(r=Rtop))  [p.x,p.y,h]],
  points  = concat(base,top),
  x       = [for(p=points) p.x],
  y       = [for(p=points) p.y],
  z       = [for(p=points) p.z]
) [[min(x),min(y),min(z)],[max(x),max(y),max(z)]];

/*!
 * cylinder replacement
 */
module fl_cylinder(
  //! FL_ADD,FL_AXES,FL_BBOX
  verbs  = FL_ADD,
  //! height of the cylinder or cone
  h,
  //! radius of cylinder. r1 = r2 = r.
  r,
  //! radius, bottom of cone.
  r1,
  //! radius, top of cone.
  r2,
  //! diameter of cylinder. r1 = r2 = d / 2.
  d,
  //! diameter, bottom of cone. r1 = d1 / 2.
  d1,
  //! diameter, top of cone. r2 = d2 / 2.
  d2,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction
) {
  r_bot = fl_parse_radius(r,r1,d,d1);
  r_top = fl_parse_radius(r,r2,d,d2);
  defs  = fl_cylinder_defaults(h,r,r1,r2,d,d1,d2);
  size  = fl_bb_size(defs);
  step  = 360/$fn;
  R     = max(r_bot,r_top);
  D     = direction ? fl_direction(defs,direction=direction)  : I;
  M     = fl_octant(octant,type=defs);
  Mbbox = fl_T(-[size.x/2,size.y/2,0]);
  fl_trace("octant",octant);
  fl_trace("size",size);

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) cylinder(r1=r_bot,r2=r_top, h=h);   // center=default=false ⇒ +Z
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) multmatrix(Mbbox) cube(size=size); // center=default=false ⇒ +X+Y+Z
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

/*!
 * prism defaults for positioning (fl_bb_cornersKV)
 * and direction (fl_directorKV, fl_rotorKV).
 */
function fl_prism_defaults(
  //! edge number
  n,
  //! edge length
  l,
  //! edge length, bottom
  l1,
  //! edge length, top
  l2,
  //! height of the prism
  h
) = [
  fl_bb_corners(value=fl_bb_prism(n,l,l1,l2,h)),  // placement: +Z
  fl_director(value=+Z),
  fl_rotor(value=+X),
];

function fl_bb_prism(
  //! edge number
  n,
  //! edge length
  l,
  //! edge length, bottom
  l1,
  //! edge length, top
  l2,
  //! height of the prism
  h
) =
assert(h>=0)
assert(n>2)
let(
  l_bot = fl_parse_l(l,l1),
  l_top = fl_parse_l(l,l2),
  step    = 360/n,
  Rbase   = l_bot / (2 * sin(step/2)),
  Rtop    = l_top / (2 * sin(step/2)),
  base    = [for(p=fl_bb_polygon(fl_circle(r=Rbase,$fn=n))) [p.x,p.y,0]],
  top     = [for(p=fl_bb_polygon(fl_circle(r=Rtop,$fn=n)))  [p.x,p.y,h]],
  points  = concat(base,top),
  x       = [for(p=points) p.x],
  y       = [for(p=points) p.y],
  z       = [for(p=points) p.z]
) [[min(x),min(y),min(z)],[max(x),max(y),max(z)]];

/*!
 * prism
 *
 *    native positioning : +Z
 *    native direction   : [+Z,+X]
 */
module fl_prism(
  // FL_ADD,FL_AXES,FL_BBOX
  verbs  = FL_ADD,
  // edge number
  n,
  // edge length
  l,
  // edge length, bottom
  l1,
  // edge length, top
  l2,
  // height
  h,
  // when undef native positioning is used
  octant,
  // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction
) {
  defs  = fl_prism_defaults(n,l,l1,l2,h);
  step  = 360/n;
  l_bot = fl_parse_l(l,l1);
  l_top = fl_parse_l(l,l2);
  Rbase = l_bot / (2 * sin(step/2));
  Rtop  = l_top / (2 * sin(step/2));
  R     = max(Rbase,Rtop);
  size  = fl_bb_size(defs);
  D     = direction ? fl_direction(defs,direction=direction): I;
  M     = fl_octant(octant,type=defs);
  Mbbox = fl_T([-size.x+R,-size.y/2,0]);
  fl_trace("octant",octant);
  fl_trace("direction",direction);
  fl_trace("size",size);

  fl_manage(verbs,M,D,size)  {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) cylinder(r1=Rbase,r2=Rtop, h=h, $fn=n); // center=default=false ⇒ +Z
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) multmatrix(Mbbox) cube(size=size);     // center=default=false ⇒ +X+Y+Z
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

//**** 3d placement ***********************************************************

function fl_octant(
  //! 3d octant
  octant,
  //! type with "bounding corners" property
  type,
  //! bounding box corners, overrides «type» settings
  bbox,
  //! returned matrix if «octant» is undef
  default=I
) = octant ? let(
    corner  = bbox ? bbox : fl_bb_corners(type),
    half    = (corner[1] - corner[0]) / 2,
    delta   = [sign(octant.x) * half.x,sign(octant.y) * half.y,sign(octant.z) * half.z]
  ) T(-corner[0]-half+delta)
  : assert(default) default;

module fl_place(
  type,
  //! 3d octant
  octant,
  //! 2d quadrant
  quadrant,
  //! bounding box corners
  bbox
) {
  bbox  = bbox ? bbox : assert(type) fl_bb_corners(type);
  M     = octant  ? assert(!quadrant) fl_octant(octant,bbox=bbox)
                  : assert(quadrant)  fl_quadrant(quadrant,bbox=bbox);
  fl_trace("M",M);
  fl_trace("bbox",bbox);
  fl_trace("octant",octant);
  multmatrix(M) children();
}

module fl_placeIf(
  //! when true placement is ignored
  condition,
  type,
  //! 3d octant
  octant,
  //! 2d quadrant
  quadrant,
  //! bounding box corners
  bbox
) {
  fl_trace("type",type);
  fl_trace("bbox",bbox);
  fl_trace("condition",condition);
  if (condition) fl_place(type,octant,quadrant,bbox) children();
  else children();
}

/*!
 * Direction matrix transforming native coordinates along new direction.
 *
 * Native coordinate system is represented by two vectors either retrieved
 * from «proto» or passed explicitly through «default» in the format
 *
 *     [direction axis (director),orthonormal vector (rotor)]
 *
 * New direction is expected in [Axis–angle representation](https://en.wikipedia.org/wiki/Axis%E2%80%93angle_representation)
 * in the format
 *
 *     [axis,rotation angle]
 *
 */
function fl_direction(
  //! prototype with fl_director and fl_rotor properties
  proto,
  //! desired direction in axis-angle representation [axis,rotation about]
  direction,
  //! default coordinate system by [director,rotor], overrides «proto» settings
  default
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

/*!
 * Applies a direction matrix to its children.
 * See also fl_direction() function comments.
 */
module fl_direct(
  //! prototype for native coordinate system
  proto,
  //! desired direction in axis-angle representation [axis,rotation about]
  direction,
  //! default coordinate system by [director,rotor], overrides «proto» settings
  default
) {
  multmatrix(fl_direction(proto,direction,default)) children();
}

/*!
 * From [Rotation matrix from plane A to B](https://math.stackexchange.com/questions/1876615/rotation-matrix-from-plane-a-to-b)
 *
 * Returns the rotation matrix R aligning the plane A(ax,ay),to plane B(bx,by)
 * When ax and bx are orthogonal to ay and by respectively calculation are simplified.
 */
function fl_planeAlign(ax,ay,bx,by,a,b) =
  assert(fl_XOR(ax && ay,a),str("ax,ay parameters are mutually exclusive with a: ax=",ax,",ay=",ay,",a=",a))
  assert(fl_XOR(bx && by,b),str("bx,by parameters are mutually exclusive with b: bx=",bx,",by=",by,",b=",b))
  // assert(!ortho||ax*ay==0,str("ax=",ax," must be orthogonal to ay=",ay))
  // assert(!ortho||bx*by==0,str("bx=",bx," must be orthogonal to by=",by))
  let (
    ax    = fl_versor(a?a.x:ax),ay=fl_versor(a?a.y:ay),bx=fl_versor(b?b.x:bx),by=fl_versor(b?b.y:by),
    az    = cross(ax,ay),
    ortho = ax*ay==0 && bx*by==0,
    A=[
      [ax.x, ay.x,  az.x,  0 ],
      [ax.y, ay.y,  az.y,  0 ],
      [ax.z, ay.z,  az.z,  0 ],
      [0,     0,      0,   1 ],
    ],
    Ainv  = ortho
      ? [ // actually the transpose matrix since axis are mutually orthogonal
          [ax.x, ax.y,  ax.z,  0 ],
          [ay.x, ay.y,  ay.z,  0 ],
          [az.x, az.y,  az.z,  0 ],
          [0,    0,     0,     1 ],
        ]
      : matrix_invert(A), // otherwise full calculations
    bz=cross(bx,by),
    B=[
      [bx.x, by.x,  bz.x,  0 ],
      [bx.y, by.y,  bz.y,  0 ],
      [bx.z, by.z,  bz.z,  0 ],
      [0,    0,     0,     1 ],
    ]
  ) B*Ainv;

module fl_planeAlign(ax,ay,bx,by,ech=false) {
  multmatrix(fl_planeAlign(ax,ay,bx,by)) children();
  if (ech) #children();
}

/*****************************************************************************
 * layout
 *****************************************************************************/

/*!
 * calculates the overall bounding box size of a layout
 */
function lay_bb_size(axis,gap,types) = let(c = lay_bb_corners(axis,gap,types)) c[1]-c[0];

/*!
 * creates a group with the resulting bounding box corners of a layout
 */
function lay_group(axis,gap,types) = [fl_bb_corners(value=lay_bb_corners(axis,gap,types))];

/*!
 * returns the bounding box corners of a layout
 */
function lay_bb_corners(
  //! cartesian axis ([-1,0,0]==[1,0,0]==X)
  axis,
  //! gap to be inserted between bounding boxes along axis
  gap=0,
  //! list of types
  types
) =
  assert(is_list(axis)&&len(axis)==3,str("axis=",axis))
  assert(is_num(gap),gap)
  assert(is_list(types),types)
  let(
    bbcs = [for(t=types) fl_bb_corners(t)]
  ) fl_bb_accum(axis,gap,bbcs);

/*!
 * Accumulates a list of bounding boxes along a direction.
 *
 * Recursive algorithm, at each call a bounding box is extracted from «bbcs»
 * and decomposed into axial and planar components. The last bunding box in
 * the list ended up the recursion and is returned as result.
 * If there are still bounding boxes left, a new call is made and its
 * result, decomposed into the axial and planar components, used to produce a
 * new bounding box as follows:
 *
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
  //! cartesian axis ([-1,0,0]==[1,0,0]==X)
  axis,
  //! gap to be inserted between bounding boxes along axis
  gap=0,
  //! bounding box corners
  bbcs
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

/*!
 * Layout of types along a direction.
 *
 * There are basically two methods of invokation call:
 *
 * - with as many children as the length of types: in this case each children will
 *   be called explicitly in turn with children($i)
 * - with one child only called repetitely through children(0) with $i equal to the
 *   current execution number.
 *
 * Called children can use the following special variables:
 *
 *     $i      - current item index
 *     $first  - true when $i==0
 *     $last   - true when $i==len(types)-1
 *     $item   - equal to types[$i]
 *     $len    - equal to len(types)
 *     $size   - equal to bounding box size of $item
 *
 */
 // TODO: add namespace
module fl_layout(
  //! supported verbs: FL_AXES, FL_BBOX, FL_LAYOUT
  verbs = FL_LAYOUT,
  //! layout direction vector
  axis,
  //! gap inserted along «axis»
  gap=0,
  //! list of types to be arranged
  types,
  /*!
   * Internal type alignment into the resulting bounding box surfaces.
   *
   * Is managed through a vector whose x,y,z components can assume -1,0 or +1 values.
   *
   * [-1,0,+1] means aligned to the -X and +Z surfaces, centered on y axis.
   *
   * Passing a scalar means [scalar,scalar,scalar]
   */
  align=0,
  //! desired direction in [vector,rotation] form, native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant
) {
  assert(len(axis)==3,axis);
  assert(is_num(gap),gap);
  assert(is_list(types),types);

  align = is_num(align)
        ? assert(align==-1||align==0||align==+1) [align,align,align]
        : assert(len(align)==3) align;
  bbox  = lay_bb_corners(axis,gap,types);
  size  = bbox[1]-bbox[0]; // resulting size
  D     = direction ? fl_direction(direction=direction,default=[+Z,+X])  : I;
  M     = fl_octant(octant,bbox=bbox);

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

  module context() {
    for($i=[0:$len-1]) {
      fl_trace("$i",$i);
      $first  = $i!=undef ? $i==0 : undef;
      $last   = $i!=undef ? $i==$len-1 : undef;
      $item   = $i!=undef ? types[$i] : undef;
      $bbox   = $i!=undef ? fl_bb_corners($item) : undef;
      $size   = $i!=undef ? $bbox[1]-$bbox[0] : undef;
      offset  = sum
      ? $i>0 ? bcs[0][1] -bcs[$i][0] : O
      : $i>0 ? bcs[0][0] -bcs[$i][1] : O;
      sz = $i>1 ? fl_accum([for(j=[1:$i-1]) sz[j]]) : O;
      fl_trace("sz",sz);
      fl_trace("delta",$i*gap*axis);
      fl_trace("offset",offset);


      Talign  = let(delta=bbox-$bbox) [
        align.x<0 ? delta[0].x : align.x>0 ? delta[1].x : 0,
        align.y<0 ? delta[0].y : align.y>0 ? delta[1].y : 0,
        align.z<0 ? delta[0].z : align.z>0 ? delta[1].z : 0,
      ];
      translate(offset+fac*sz+$i*gap*axis+Talign)
        children();
    }
  }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_BBOX) {
      fl_modifier($modifier,false) fl_bb_add(bbox);

    } else if ($verb==FL_LAYOUT) fl_modifier($modifier,false) {
      assert(axis*align==0,"Alignment and layout direction must be orthogonal");
      context() children();

    } else {
      // fl_modifier($modifier,false) context() children();
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

/*****************************************************************************
 * bounding box
 *****************************************************************************/

/*!
 * add a bounding box shape
 */
module fl_bb_add(
  //! bounding box corners
  corners,
  2d=false
) {
  fl_trace("$FL_ADD",$FL_ADD);
  assert(is_list(corners),corners)
  translate(corners[0])
    if (!2d) fl_cube(size=corners[1]-corners[0],octant=+X+Y+Z);
    else fl_square(size=corners[1]-corners[0],quadrant=+X+Y);
}

/*****************************************************************************
 * 3d miscellanous functions
 *****************************************************************************/

/*!
 * Projection of «vector» onto a cartesian «axis»
 */
function fl_3d_vectorialProjection(
  //! 3D vector
  vector,
  //! cartesian axis ([-1,0,0]==[1,0,0]==X)
  axis
) =
assert(len(vector)==3,str("vector=",vector))
assert(fl_3d_abs(axis)==+X||fl_3d_abs(axis)==+Y||fl_3d_abs(axis)==+Z)
let(
  axis=fl_3d_abs(axis)
) (vector*axis)*axis;

/*!
 * Projection of «vector» onto a cartesian «plane»
 */
function fl_3d_planarProjection(
  //! 3D vector
  vector,
  //! cartesian plane by vector with ([-1,+1,0]==[1,1,0]==XY)
  plane
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

/*!
 * Transforms a vector inside the +X+Y+Z octant
 */
function fl_3d_abs(a) = [abs(a.x),abs(a.y),abs(a.z)];

/*!
 * Builds a minor vector
 */
function fl_3d_min(a,b) = [min(a.x,b.x),min(a.y,b.y),min(a.z,b.z)];

/*!
 * Builds a max vector
 */
function fl_3d_max(a,b) = [max(a.x,b.x),max(a.y,b.y),max(a.z,b.z)];

/*!
 * Cartesian plane from axis
 */
function fl_3d_orthoPlane(
  axis  // cartesian axis ([-1,0,0]==[1,0,0]==X)
) = assert(
  fl_3d_abs(axis)==+X||fl_3d_abs(axis)==+Y||fl_3d_abs(axis)==+Z
) [axis.x?0:1,axis.y?0:1,axis.z?0:1];

//! returns the sign of a semi-axis (-1,+1)
function fl_3d_sign(axis) = let(
    s = sign(axis*[1,1,1])
  ) assert(s!=0) s;

//! returns the «axis» value from a full semi-axis value list
function fl_3d_axisValue(
    axis,
    values
  ) = let(
    r = axis==-X ? values[0][0]
      : axis==+X ? values[0][1]
      : axis==-Y ? values[1][0]
      : axis==+Y ? values[1][1]
      : axis==-Z ? values[2][0]
      : axis==+Z ? values[2][1]
      : undef
  ) assert(r!=undef,r) r;

/*!
 * Build an full semi-axis value list from the key/value list «kvs».
 * Build a full boolean semi-axis value list from literal semi-axis list «axes»
 *
 * example 1:
 *
 *     values = fl_3d_AxisVList(kvs=[["-x",3],["±Z",4]]);
 *
 * is equivalent to:
 *
 *     values =
 *     [
 *      [3,0],
 *      [0,0],
 *      [4,4]
 *     ];
 *
 * example 2:
 *
 *     values = fl_3d_AxisVList(axes=["-x","±Z"]);
 *
 * is equivalent to:
 *
 *     values =
 *     [
 *      [true,  false],
 *      [false, false],
 *      [true,  true]
 *     ];
 */
function fl_3d_AxisVList(
  //! semi-axis key/value list (es. [["-x",3],["±Z",4]])
  kvs,
  //! semi-axis list (es.["-x","±Z"])
  axes
) = assert(fl_XOR(kvs!=undef,axes!=undef))
  let(
    r= kvs!=undef
    //          0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17
    ? search(["-x","+x","±x","-y","+y","±y","-z","+z","±z","-X","+X","±X","-Y","+Y","±Y","-Z","+Z","±Z"],kvs)
    : search(["-x","+x","±x","-y","+y","±y","-z","+z","±z","-X","+X","±X","-Y","+Y","±Y","-Z","+Z","±Z"],axes)
  ) kvs!=undef
  ? [
      [
        r[0]!=[] ? kvs[r[0]][1] : r[2]!=[] ? kvs[r[2]][1] : r[0+9]!=[] ? kvs[r[0+9]][1] : r[2+9]!=[] ? kvs[r[2+9]][1] : 0,
        r[1]!=[] ? kvs[r[1]][1] : r[2]!=[] ? kvs[r[2]][1] : r[1+9]!=[] ? kvs[r[1+9]][1] : r[2+9]!=[] ? kvs[r[2+9]][1] : 0
      ],
      [
        r[3]!=[] ? kvs[r[3]][1] : r[5]!=[] ? kvs[r[5]][1] : r[3+9]!=[] ? kvs[r[3+9]][1] : r[5+9]!=[] ? kvs[r[5+9]][1] : 0,
        r[4]!=[] ? kvs[r[4]][1] : r[5]!=[] ? kvs[r[5]][1] : r[4+9]!=[] ? kvs[r[4+9]][1] : r[5+9]!=[] ? kvs[r[5+9]][1] : 0
      ],
      [
        r[6]!=[] ? kvs[r[6]][1] : r[8]!=[] ? kvs[r[8]][1] : r[6+9]!=[] ? kvs[r[6+9]][1] : r[8+9]!=[] ? kvs[r[8+9]][1] : 0,
        r[7]!=[] ? kvs[r[7]][1] : r[8]!=[] ? kvs[r[8]][1] : r[7+9]!=[] ? kvs[r[7+9]][1] : r[8+9]!=[] ? kvs[r[8+9]][1] : 0
      ]
    ]
  : [
    [
      r[0]!=[] || r[2]!=[] || r[0+9]!=[] || r[2+9]!=[],
      r[1]!=[] || r[2]!=[] || r[1+9]!=[] || r[2+9]!=[],
    ],
    [
      r[3]!=[] || r[5]!=[] || r[3+9]!=[] || r[5+9]!=[],
      r[4]!=[] || r[5]!=[] || r[4+9]!=[] || r[5+9]!=[],
    ],
    [
      r[6]!=[] || r[8]!=[] || r[6+9]!=[] || r[8+9]!=[],
      r[7]!=[] || r[8]!=[] || r[7+9]!=[] || r[8+9]!=[],
    ]
  ];

/*!
 * Build a floating semi-axis list from literal semi-axis list.
 *
 * example:
 *
 *     list = fl_3d_AxisList(axes=["-x","±Z"]);
 *
 * is equivalent to:
 *
 *     list =
 *     [
 *      [-1, 0,  0],
 *      [ 0, 0, -1],
 *      [ 0, 0, +1],
 *     ];
 */
function fl_3d_AxisList(
  //! semi-axis list (es.["-x","±Z"])
  axes
) = let(
    //            0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17
    r = search(["-x","+x","±x","-y","+y","±y","-z","+z","±z","-X","+X","±X","-Y","+Y","±Y","-Z","+Z","±Z"],axes)
  ) [
    if (r[0]!=[] || r[2]!=[] || r[0+9]!=[] || r[2+9]!=[]) -X,
    if (r[1]!=[] || r[2]!=[] || r[1+9]!=[] || r[2+9]!=[]) +X,
    if (r[3]!=[] || r[5]!=[] || r[3+9]!=[] || r[5+9]!=[]) -Y,
    if (r[4]!=[] || r[5]!=[] || r[4+9]!=[] || r[5+9]!=[]) +Y,
    if (r[6]!=[] || r[8]!=[] || r[6+9]!=[] || r[8+9]!=[]) -Z,
    if (r[7]!=[] || r[8]!=[] || r[7+9]!=[] || r[8+9]!=[]) +Z,
  ];

//! wether «axis» is present in floating semi-axis list
function fl_3d_axisIsSet(
    axis,
    list
  ) = assert(axis!=undef) let(
    len   = len(list),
    curr  = len ? list[0] : undef,
    rest  = len>1 ? [for(i=[1:len-1]) list[i]] : []
  ) curr==axis ? true : len>1 ? fl_3d_axisIsSet(axis,rest) :  false;
