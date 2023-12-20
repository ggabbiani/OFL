/*!
 * 3d primitives
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <unsafe_defs.scad>
include <type_trait.scad>

use <2d-engine.scad>
use <bbox-engine.scad>
use <mngm-engine.scad>

module fl_doAxes(
  size,
  direction,
  debug
) {
  sz = 1.2*size;
  fl_axes(sz);
  if (debug && direction && fl_parm_symbols(debug))
    fl_sym_direction(direction=direction,size=sz);
}

/*!
 * cube replacement: if not specified otherwise, the cube has its midpoint centered at origin O
 */
module fl_cube(
  //! FL_ADD,FL_AXES,FL_BBOX
  verbs     = FL_ADD,
  size      = [1,1,1],
  //! debug parameter as returned from fl_parm_Debug()
  debug,
  //! when undef, native positioning is used with cube midpoint centered at origin O
  octant,
  //! desired direction [director,rotation] or native direction if undef
  direction
) {
  size  = is_list(size) ? size : [size,size,size];
  bbox  = [-size/2,+size/2];

  D     = direction ? fl_direction(direction) : I;
  M     = fl_octant(octant,bbox=bbox);

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) cube(size,true);
    } else if ($verb==FL_AXES) {
      fl_modifier($modifier) fl_doAxes(size,direction,debug);
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) cube(size,true);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

/*!
 * sphere defaults for positioning (fl_bb_cornersKV).
 */
function fl_sphere_defaults(
  r = [1,1,1],
  d,
) = let(
  r  = is_undef(d) ? (is_list(r) ? r : [r,r,r]) : (is_list(d) ? d : [d,d,d])/2
) [
  fl_bb_corners(value=[-r,+r]),  // symmetric bounding box ⇒ octant==O
];

/*!
 * sphere replacement.
 */
module fl_sphere(
  //! FL_ADD,FL_AXES,FL_BBOX
  verbs   = FL_ADD,
  r       = [1,1,1],
  d,
  //! debug parameter as returned from fl_parm_Debug()
  debug,
  //! when undef default positioning is used
  octant,
  //! desired direction [director,rotation], default direction if undef
  direction
) {
  defs  = fl_sphere_defaults(r,d);

  bbox  = fl_bb_corners(defs);
  size  = fl_bb_size(defs); // bbox[1] - bbox[0];
  D     = direction ? fl_direction(direction)  : FL_I;
  M     = fl_octant(octant,type=defs);

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) resize(size) sphere();
    } else if ($verb==FL_AXES) {
      fl_modifier($modifier) fl_doAxes(size,direction,debug);
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) cube(size,true);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

/*!
 * cylinder defaults for positioning (fl_bb_cornersKV).
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
  //! debug parameter as returned from fl_parm_Debug()
  debug,
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
  D     = direction ? fl_direction(direction)  : FL_I;
  M     = fl_octant(octant,type=defs);
  Mbbox = fl_T(-[size.x/2,size.y/2,0]);
  fl_trace("octant",octant);
  fl_trace("size",size);

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) cylinder(r1=r_bot,r2=r_top, h=h);   // center=default=false ⇒ +Z
    } else if ($verb==FL_AXES) {
      fl_modifier($modifier) fl_doAxes(size,direction,debug);
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) multmatrix(Mbbox) cube(size=size); // center=default=false ⇒ +X+Y+Z
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

/*!
 * prism defaults for positioning (fl_bb_cornersKV).
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
 */
module fl_prism(
  //! FL_ADD,FL_AXES,FL_BBOX
  verbs  = FL_ADD,
  //! edge number
  n,
  //! edge length
  l,
  //! edge length, bottom
  l1,
  //! edge length, top
  l2,
  //! height
  h,
  //! debug parameter as returned from fl_parm_Debug()
  debug,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
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
  D     = direction ? fl_direction(direction): FL_I;
  M     = fl_octant(octant,type=defs);
  Mbbox = fl_T([-size.x+R,-size.y/2,0]);
  fl_trace("octant",octant);
  fl_trace("direction",direction);
  fl_trace("size",size);

  fl_manage(verbs,M,D)  {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) cylinder(r1=Rbase,r2=Rtop, h=h, $fn=n); // center=default=false ⇒ +Z
    } else if ($verb==FL_AXES) {
      fl_modifier($modifier) fl_doAxes(size,direction,debug);
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) multmatrix(Mbbox) cube(size=size);     // center=default=false ⇒ +X+Y+Z
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

function fl_bb_pyramid(points) = fl_bb_polyhedron(points);

/*!
 * return pyramid
 *
 * - native positioning: +Z
 */
function fl_pyramid(
  base,
  apex
) = concat([apex],[for(p=base) [p.x,p.y,0]]);

/*!
 * pyramid
 *
 * - native positioning: +Z
 */
module fl_pyramid(
  //! FL_ADD,FL_AXES,FL_BBOX
  verbs  = FL_ADD,
  base,
  apex,
  //! debug parameter as returned from fl_parm_Debug()
  debug,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction
) {
  points  = fl_pyramid(base, apex);
  bbox    = fl_bb_pyramid(points);
  faces   = [[0,2,1],[0,3,2],[0,4,3],[0,1,4],[1,2,3,4]];
  size    = bbox[1]-bbox[0];
  D       = direction ? fl_direction(direction): I;
  M       = fl_octant(octant,bbox=bbox);

  fl_manage(verbs,M,D)  {
    if ($verb==FL_ADD) {
      fl_modifier($modifier)
        polyhedron(points, faces);
    } else if ($verb==FL_AXES) {
      fl_modifier($modifier) fl_doAxes(size,direction,debug);
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

//**** 3d placement ***********************************************************

/*!
 * Calculates the translation matrix needed for moving a shape in the provided
 * 3d octant.
 */
function fl_octant(
  /*!
   * 3d octant vector, each component can assume one out of four values
   * modifying the corresponding x,y or z position in the following manner:
   *
   * - undef: translation invariant (no translation)
   * - -1: object on negative semi-axis
   * - 0: object midpoint on origin
   * - +1: object on positive semi-axis
   *
   * Example 1:
   *
   *     octant=[undef,undef,undef]
   *
   * no translation in any dimension
   *
   * Example 2:
   *
   *     octant=[0,0,0]
   *
   * object center [midpoint x, midpoint y, midpoint z] on origin
   *
   * Example 3:
   *
   *     octant=[+1,undef,-1]
   *
   *  object on X positive semi-space, no Y translated, on negative Z semi-space
   */
  octant,
  //! type with embedded "bounding corners" property (see fl_bb_corners())
  type,
  //! explicit bounding box corners: overrides «type» settings
  bbox,
  //! returned matrix if «octant» is undef
  default=FL_I
) = octant ? let(
    corner  = bbox ? bbox : fl_bb_corners(type),
    half    = (corner[1] - corner[0]) / 2,
    delta   = [
      is_undef(octant.x) ? undef : sign(octant.x) * half.x,
      is_undef(octant.y) ? undef : sign(octant.y) * half.y,
      is_undef(octant.z) ? undef : sign(octant.z) * half.z
    ],
    t       = [
      is_undef(octant.x) ? 0 : -corner[0].x-half.x+delta.x,
      is_undef(octant.y) ? 0 : -corner[0].y-half.y+delta.y,
      is_undef(octant.z) ? 0 : -corner[0].z-half.z+delta.z
    ]
  ) T(t) : assert(default) default;

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
 * Return the direction matrix transforming native coordinates along new
 * direction.
 *
 * Native coordinate system is represented by two vectors: +Z and +X. +Y axis
 * is the cross product between +Z and +X. So with two vector (+Z,+X) we can
 * represent the native coordinate system +X,+Y,+Z.
 *
 * New direction is expected in [Axis–angle representation](https://en.wikipedia.org/wiki/Axis%E2%80%93angle_representation)
 * in the format
 *
 *     [axis,rotation angle]
 *
 */
function fl_direction(
  //! desired direction in axis-angle representation [axis,rotation about]
  direction
) =
  assert(!fl_debug() || fl_tt_isDirectionRotation(direction),direction)
  let(
    alpha   = direction[1],
    Z_new = fl_versor(direction[0]),
    X_new = fl_transform(fl_align(FL_Z,Z_new),FL_X)
  ) R(Z_new,alpha)                        // rotate «alpha» degrees around new Z
  * fl_planeAlign(FL_Z,FL_X,Z_new,X_new); // align direction

/*!
 * Applies a direction matrix to its children.
 * See also fl_direction() function comments.
 */
module fl_direct(
  //! desired direction in axis-angle representation [axis,rotation about]
  direction
) {
  multmatrix(fl_direction(direction)) children();
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
    ortho = (ax*ay==0) && (bx*by==0),
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
      : assert(!fl_debug() || det(A)!=0,A) matrix_invert(A), // otherwise full calculations
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

//! rotates children to face camera
module fl_lookAtMe()
  rotate($vpr ? $vpr : [70, 0, 315])
    children();

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
 * returns the bounding box corners of a layout.
 *
 * See also fl_bb_accum().
 */
function lay_bb_corners(
  //! layout direction
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
 * and decomposed into axial and planar components. The last bounding box in
 * the list ended up the recursion and is returned as result.
 * If there are still bounding boxes left, a new call is made and its
 * result, decomposed into the axial and planar components, used to produce a
 * new bounding box as follows:
 *
 * - for planar component, the new negative and positive corners are calculated
 *   with the minimum dimensions between the current one and the result of the
 *   recursive call;
 * - for the axial component when «axis» is positive:
 *   - negative corner is equal to the current corner;
 *   - positive corner is equal to the current positive corner PLUS the gap and
 *     the axial dimension of the result;
 *   - when «axis» is negative:
 *     - negative corner is equal to the current one MINUS the gap and the
 *       axial dimension of the result
 *     - the positive corner is equal to the current corner.
 */
function fl_bb_accum(
  //! layout direction
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
  ? len(rest) ? fl_bb_accum(axis,gap,rest) + [FL_O,gap*axis]: [FL_O,FL_O]
  : len(rest) ? fl_bb_accum(axis,gap,rest) - [FL_O,gap*axis]: [FL_O,FL_O],
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
 * There are basically two methods of invocation call:
 *
 * - with as many children as the length of types: in this case each children will
 *   be called explicitly in turn with children($i)
 * - with one child only called repetitively through children(0) with $i equal to the
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
 * TODO: add namespace to children context variables.
 */
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
  D     = direction ? fl_direction(direction)  : FL_I;
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
  fl_trace("object layout #: ",$len);

  module context() {
    for($i=[0:$len-1]) {
      fl_trace("$i",$i);
      $first  = $i!=undef ? $i==0 : undef;
      $last   = $i!=undef ? $i==$len-1 : undef;
      $item   = $i!=undef ? types[$i] : undef;
      $bbox   = $i!=undef ? fl_bb_corners($item) : undef;
      $size   = $i!=undef ? $bbox[1]-$bbox[0] : undef;
      offset  = sum
      ? $i>0 ? bcs[0][1] -bcs[$i][0] : FL_O
      : $i>0 ? bcs[0][0] -bcs[$i][1] : FL_O;
      sz = $i>1 ? fl_accum([for(j=[1:$i-1]) sz[j]]) : FL_O;
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

  fl_manage(verbs,M,D) {
    fl_trace(str("dispatching ",$verb));

    if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction);

    } else if ($verb==FL_BBOX) {
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
 * add a bounding box shape to the scene
 */
module fl_bb_add(
  /*!
   * Bounding box corners in [Low,High] format.
   * see also fl_tt_isBoundingBox()
   */
  corners,
  2d=false
) {
  fl_trace("$FL_ADD",$FL_ADD);
  assert(fl_tt_isBoundingBox(corners),corners)
  translate(corners[0])
    if (!2d) fl_cube(size=corners[1]-corners[0],octant=O0);
    else fl_square(size=corners[1]-corners[0],quadrant=QI);
}

/*****************************************************************************
 * 3d miscellaneous functions
 *****************************************************************************/

/*!
 * Calculates the [geometric center](https://en.wikipedia.org/wiki/Centroid) of
 * the passed points.
 */
function fl_centroid(
  //! Point list defining a polygon/polyhedron with each element p | p∈ℝ^n^
  pts
) = assert(len(pts)>0) fl_accum(pts) / len(pts);

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
  //! axis to retrieve corresponding value
  axis,
  //! full semi-axis value list (see also function fl_tt_isAxisVList())
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
 * Constructor for a full semi-axis value list. The returned value can be built
 * from a list of pairs ("string", value) or from a list of semi-axes name
 * strings
 *
 * | parameter | result                                                                     |
 * | --------- | ------                                                                     |
 * | kvs       | full semi-axis value list initialized from the passed axis/value pair list |
 * | values    | full boolean semi-axis value list from semi-axis literal                   |
 *
 * See also function fl_tt_isAxisVList()
 *
 * example 1:
 *
 *     thick = fl_3d_AxisVList(kvs=[["-x",3],["±Z",4]]);
 *
 * is equivalent to:
 *
 *     thick =
 *     [
 *      [3,0],  // -x and +x value pair
 *      [0,0],  // -y and +y value pair
 *      [4,4]   // -z and +z value pair
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
 *      [true,  false], // -x and +x boolean
 *      [false, false], // -y and +y boolean
 *      [true,  true]   // -z and +z boolean
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
 *      [-1, 0,  0],  // -X semi-axis
 *      [ 0, 0, -1],  // -Z semi-axis
 *      [ 0, 0, +1],  // +Z semi-axis
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

/*!
 * Wether «axis» is present in floating semi-axis «list».
 *
 * TODO: this is a recursive solution that could be more quickly solved by a
 * mere call to the OpenSCAD builtin search() function like in the example
 * below:
 *
 *     function fl_3d_axisIsSet(axis,list) = search([axis],list)!=[[]]
 */
function fl_3d_axisIsSet(
    axis,
    list
  ) = assert(axis!=undef) let(
    len   = len(list),
    curr  = len ? list[0] : undef,
    rest  = len>1 ? [for(i=[1:len-1]) list[i]] : []
  ) curr==axis ? true : len>1 ? fl_3d_axisIsSet(axis,rest) :  false;

/*!
 * Extrusion along arbitrary axis with eventual rotation
 */
module fl_linear_extrude(
  //! direction in [axis,angle] representation
  direction,
  length,
  convexity = 10,
) {
  D = direction ? fl_direction(direction) : FL_I;
  multmatrix(D)
    linear_extrude(height=length,convexity=convexity)
      children();
}

/*!
 * linear_extrude{} with optional fillet radius on each end.
 *
 * Positive radii will expand outward towards their end, negative will shrink
 * inward towards their end
 *
 * Limitations:
 *
 * - individual children of fillet_extrude should be convex
 * - only straight extrudes with no twist or scaling supported
 * - fillets only for 90 degrees between Z axis and top/bottom surface
 */
module fl_fillet_extrude(
  //! total extrusion length including radii
  height=100,
  //! bottom radius
  r1=0,
  //! top radius
  r2=0
) {
  function fragments(r=1) =
    ($fn > 0) ? ($fn >= 3 ? $fn : 3) : ceil(max(min(360.0 / $fa, r*2*PI / $fs), 5));
  assert(abs(r1)+abs(r2) <= height);
  midh = height-abs(r1)-abs(r2);
  eps = 1/1024;
  union() {
    if (r1!=0) {
      fn1 = ceil(fragments(abs(r1))/4); // only covering 90 degrees
      for(i=[0:1:$children-1], j=[1:1:fn1]) {
        a1 = 90*(j-1)/fn1;        a2 = 90*j/fn1;
        h1 = abs(r1)*(1-cos(a1)); h2 = abs(r1)*(1-cos(a2));
        off1 = r1*(1-sin(a1));    off2 = r1*(1-sin(a2));
        hull() {
          translate([0,0,h1]) {
            // in case radius*2 matches width of object, don't make first layer zero width
            off1 = r1 < 0 && j==1 ? off1*(1-eps) : off1;
            linear_extrude(eps) offset(r=off1) children(i);
          }
          translate([0,0,h2])
            linear_extrude(eps) offset(r=off2) children(i);
        }
      }
    }
    if (midh > 0)  {
      translate([0,0,abs(r1)])
        for(i=[0:1:$children-1]) linear_extrude(midh) children(i);
    }
    if (r2!=0) {
      fn2 = ceil(fragments(abs(r2))/4); // only covering 90 degrees
      translate([0,0,height-abs(r2)-eps]) {
      for(i=[0:1:$children-1], j=[1:1:fn2]) {
          a1 = 90*(j-1)/fn2;      a2 = 90*j/fn2;
          h1 = abs(r2)*(sin(a1)); h2 = abs(r2)*(sin(a2));
          off1 = r2*(1-cos(a1));  off2 = r2*(1-cos(a2));
          hull() {
            translate([0,0,h1])
              linear_extrude(eps) offset(r=off1) children(i);
            translate([0,0,h2]) {
              // in case radius*2 matches width of object, don't make last layer zero width
              off2 = r2 < 0 && j==fn2 ? off2*(1-eps) : off2;
              linear_extrude(eps) offset(r=off2) children(i);
            }
          }
        }
      }
    }
  }
}

/*!
 * DXF files import with direction and rotation. By default DXF files are
 * imported in the XY plane with no rotation. The «direction» parameter
 * specifies a normal to the actual import plane and a rotation about it.
 */
module fl_importDxf(
  file,
  layer,
  //! direction in axis-angle representation
  direction
) {
  D = direction ? fl_direction(direction) : FL_I;
  multmatrix(D)
    __dxf__(file,layer);
}

//*****************************************************************************
// 3d symbols

module fl_sym_plug(verbs=[FL_ADD,FL_AXES],type=undef,size=0.5) {
  fl_symbol(verbs,type,size,"plug");
}

module fl_sym_socket(verbs=[FL_ADD,FL_AXES],type=undef,size=0.5) {
  fl_symbol(verbs,type,size,"socket");
}

/*!
 * provides the symbol required in its 'canonical' form:
 * - "plug": 'a piece that fits into a hole in order to close it'
 *          Its canonical form implies an orientation of the piece coherent
 *          with its insertion movement along +Z axis.
 * - "socket": 'a part of the body into which another part fits'
 *          Its canonical form implies an orientation of the piece coherent
 *          with its fitting movement along -Z axis.
 *
 * variable FL_LAYOUT is used for proper label orientation
 *
 * Children context:
 *
 * - $sym_ldir: [axis,angle]
 * - $sym_size: size in 3d format
 */
module fl_symbol(
  //! supported verbs: FL_ADD, FL_LAYOUT
  verbs   = FL_ADD,
  // really needed?
  type    = undef,
  //! default size given as a scalar
  size    = 0.5,
  //! currently "plug" or "socket"
  symbol
  ) {
  assert(verbs!=undef);

  sz      = size==undef ? [0.5,0.5,0.5] : is_list(size) ? size : [size,size,size];
  d1      = sz.x * 2/3;
  d2      = 0;
  overlap = sz.z / 5;
  h       = (sz.z + 2 * overlap) / 3;
  delta   = h - overlap;
  fl_trace("verbs",verbs);
  fl_trace("size",size);
  fl_trace("sz",sz);

  module context() {
    $sym_ldir = symbol=="plug" ? [+Z,0] : [-Z,180];
    $sym_size = sz;

    children();
  }

  module do_add() {
    fl_trace("d1",d1);
    fl_trace("d2",d2);

    color("blue")
      resize(sz)
        translate(Z(symbol=="socket"?-h:0))
          for(i=symbol=="plug"?[0:+2]:[-2:0])
            translate(Z(i*delta))
              cylinder(d1=d1,d2=d2,h=h);

    %translate(symbol=="plug"?-Z(0.1/2):+Z(0.1/2)) cube(size=[sz.x,sz.y,0.1],center=true); // cube(octant=symbol=="plug"?-Z:+Z,size=[sz.x,sz.y,0.1]);
    let(sz=2*sz) {
      color("red") translate(-X(sz.x/2)) fl_vector(X(sz.x),ratio=30);
      color("green") translate(-Y(sz.y/2)) fl_vector(Y(sz.y),ratio=30);
    }
  }

  module do_layout() {
    context() children();
  }

  fl_manage(verbs) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        ; // fl_doAxes(size,direction,debug);

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout() children();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

/*!
 * this symbol uses as input a complete node context.
 *
 * The symbol is oriented according to the hole normal.
 */
module fl_sym_hole(
  //! supported verbs: FL_ADD
  verbs = FL_ADD
) {

  module _torus_(
    //! radius of the circular tube.
    r,
    //! distance from the center of the tube to the center of the torus
    R
  ) {

    function bb(
      //! radius of the circular tube.
      r,
      //! distance from the center of the tube to the center of the torus
      R
    ) = let(
      e     = assert(r) [r,r],
      a     = e[0],
      b     = e[1],
      edge  = assert(R>=a,str("R=",R,",a=",a)) a+R
    ) [[-edge,-edge,-b],[+edge,+edge,+b]];

    bbox    = bb(r,R);
    e       = assert(r) [r,r];
    a       = e[0];
    b       = e[1];
    size    = bbox[1]-bbox[0];

    fn      = $fn;
    rotate_extrude($fn=$fn)
      translate(X(R-a))
        translate(X(r))
          circle(r=r,$fn=fn);
  }

  radius  = $hole_d/2;
  D       = fl_align(from=+Z,to=$hole_n);
  rotor   = fl_transform(D,+X);
  bbox    = [
    [-radius,-radius,-$hole_depth],
    [+radius,+radius,0]
  ];
  size    = bbox[1]-bbox[0];
  fl_trace("verbs",verbs);

  module do_add() {
    let(l=$hole_d*3/2,r=radius/20) {
      fl_color("red")
        translate(-X(l/2))
          rotate(+90,FL_Y) cylinder(r=r,h=l); // direction=[+X,0];
      fl_color("green")
        translate(-Y(l/2))
          rotate(-90,FL_X) cylinder(r=r,h=l); // direction=[+Y,0];
      fl_color("black")
        for(z=[0,-$hole_depth])
          translate(Z(z))
            _torus_(r=r,R=$hole_d/2);
    }
    if ($hole_depth)
      %translate(-Z($hole_depth)) cylinder(d=$hole_d,h=$hole_depth); // octant=-Z;
    fl_color("blue")
      fl_vector($hole_depth*Z);
  }

  fl_manage(verbs,D=D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

/*!
 * display the direction change from a native coordinate system and a new
 * direction specification in [direction,rotation] format.
 *
 * **NOTE:** the native coordinate system (ncs) is now meant to be the standard
 * +X+Y+Z (with direction set by +Z)
 */
module fl_sym_direction(
  //! supported verbs: FL_ADD
  verbs = FL_ADD,
  /*!
   * direction in [Axis–angle representation](https://en.wikipedia.org/wiki/Axis%E2%80%93angle_representation)
   * in the format
   *
   *     [axis,rotation angle]
   */
  direction,
  //! default size given as a scalar
  size    = 0.5
) {
  assert(!fl_debug() || fl_tt_isDirectionRotation(direction));

  // returns the angle between vector «a» and «b»
  function angle(a,b) = let(
    dot_prod = a*b
  ) dot_prod==0 ? 90 : acos(dot_prod/norm(a)/norm(b));

  function projectOnPlane(v,p) = let(
    u1 = fl_versor(p[0]),
    u2 = fl_versor(p[1])
  ) v*(u1+u2);

  fl_trace("start");
  angle   = direction[1];
  sz      = size==undef ? [0.5,0.5,0.5] : is_list(size) ? size : [size,size,size];
  ratio   = 20;
  d       = sz/ratio;
  head_r  = 1.5 * d;
  e       = [sz.x/2,sz.y/2];
  // echo(sz=sz,d=d);

  curr_director = sz.z*FL_Z;
  curr_rotor    = sz.x*FL_X;
  curr_axis     = sz.y*FL_Y;

  dir_color     = fl_palette(+FL_Z);
  rot_color     = fl_palette(+FL_X);
  axis_color    = fl_palette(+FL_Y);

  // invert matrix for original coordinate system representation after
  // the direction change
  m = matrix_invert(fl_align(+FL_Z,direction[0]));

  // old director in the new coordinate system
  old_director  = fl_3(m * fl_4(curr_director));
  old_rotor     = fl_3(m * fl_4(curr_rotor));
  // old_axis      = cross(old_director,old_rotor);

  // assert(!fl_debug() || (old_director*old_rotor<=FL_NIL),old_director*old_rotor);

  // Native Coordinate System DIRECTOR
  color(dir_color) rotate(-angle,curr_director) {
    // current director
    fl_cylinder(h=norm(curr_director), d=d.z, octant=fl_versor(curr_director), direction=[curr_director,0]);

    // angle between [new director, old director]
    dir_rotation  = angle(curr_director,old_director);
    2d            = fl_circleXY(norm(curr_director),dir_rotation);

    // projection matrix the XY plane to the rotation plane of the DIRECTOR
    m = (fl_isParallel(old_director,curr_director,false))
      ? (fl_versor(old_director)==fl_versor(curr_director) // parallel
        ? FL_I  // equality
        : fl_R(curr_director,angle)*fl_Ry(180)*fl_Rx(90)*fl_Rz(90)*fl_Rx(90))  // opposite
      : fl_planeAlign(FL_X,[2d.x,2d.y,0],old_director,curr_director); // parallel

    // rotation angle visualization
    multmatrix(m) {
      r = norm(curr_director);

      if (dir_rotation!=0) let(a=dir_rotation/2)
        translate(fl_circleXY(r-d.z/2,a))
          rotate(90+a,FL_Z)
            translate(-Z(d.z/4))
              linear_extrude(d.z/2)
                fl_ipoly(r=head_r.z,n=3);

      // rotation angle built on XY plane
      translate(-Z(d.z/4))
        linear_extrude(d.z/2)
          fl_arc(r=r,angles=[0,dir_rotation],thick=d.z);
    }

  }

  // Native Coordinate System ROTOR
  color(rot_color) {
    beta  = angle/2;
    // m_bisector   = tan(beta);
    // fl_ellipticArc() defines thickness as a scalar, so we set it to ellipses XY axes average
    elli_thick  = (d.x+d.y)/2;
    // echo(m_bisector=m_bisector);
    // elli  = e-[d.x,d.y]/2;
    elli  = e-[1,1]*elli_thick/2;
    // elli  = [1.2,2.1];
    // for the same reasons we do something similar for the arrow dimension radius
    head_radius = (head_r.x+head_r.y)/2;
    x_d   = d.x;  // harmonizing X axis diameter with its length
    extr_h  = d.x/2;  // harmonizing Z extrusion with X dimensions
    a     = elli[0];
    b     = elli[1];
    // C     = _intersection_(elli,-m_bisector,angle); // echo(C=C);
    C     = fl_ellipseXY(elli,angle=-beta);
    echo(C=C);
    m_tangent   = -b*b/(a*a)*C.x/C.y; // slope of the tangent to e in C
    echo(m_tangent=m_tangent);

    // gamma = abs(angle%180)<=FL_NIL ? 0 : atan(m_tangent);  // atan2(C.y,C.x)
    gamma = atan(m_tangent);  // atan2(C.y,C.x)
    echo(str("atan(m_tangent)=",atan(m_tangent)));

    // X axis
    fl_cylinder(h=norm(curr_rotor), d=x_d, octant=FL_O, direction=[curr_rotor,0]);

    // rotation arrow
    if (angle!=0)
      translate(fl_ellipseXY(elli,angle=-beta))
        echo(gamma=gamma) rotate(gamma,FL_Z)
          translate(-Z(extr_h/2))
            linear_extrude(extr_h) {
              // circle(0.01);
              fl_ipoly(r=head_radius,n=3,quadrant=-FL_X);
              // fl_square(size = [1,0.01]);
            }
    // rotation angle built on [X,Y] plane
    translate(-Z(extr_h/2))
      linear_extrude(extr_h)
        fl_ellipticArc(e=e,angles=[0,-angle],thick=elli_thick);
  }
  fl_trace("end");
}

//**** torus ******************************************************************

function fl_bb_torus(
  //! radius of the circular tube.
  r,
  //! diameter of the circular tube.
  d,
  //! elliptic tube [a,b] form
  e,
  //! distance from the center of the tube to the center of the torus
  R
) = let(
  // e     = r ? assert(!e) [r,r] : assert(len(e)==2) e,
  e       = r ? assert(!e && !d) [r,r] : d ? assert(!e && !r) [d/2,d/2] : assert(!r && !d && len(e)==2) e,
  a     = e[0],
  b     = e[1],
  edge  = assert(R!=undef,"Mandatory parameter 'R' missing") assert(R>=a,str("R=",R,",a=",a)) a+R
) [[-edge,-edge,-b],[+edge,+edge,+b]];

/*!
 * «e» and «R» are mutually exclusive parameters
 */
module fl_torus(
  //! supported verbs: FL_ADD, FL_AXES, FL_BBOX
  verbs       = FL_ADD,
  //! radius of the circular tube.
  r,
  //! diameter of the circular tube.
  d,
  //! elliptic tube [a,b] form
  e,
  //! distance from the center of the tube to the center of the torus
  R,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant
) {
  bbox    = fl_bb_torus(r,d,e,R);
  e       = r ? [r,r] : d ? [d/2,d/2] : e;
  a       = e[0];
  b       = e[1];
  size    = bbox[1]-bbox[0];
  D       = direction ? fl_direction(direction) : I;
  M       = fl_octant(octant,bbox=bbox);

  fn      = $fn;

  fl_trace("D",D);
  fl_trace("M",M);

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) rotate_extrude($fn=$fn) translate(X(R-a)) fl_ellipse(e=e,quadrant=+X,$fn=fn);
    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        ; // fl_doAxes(size,direction,debug);
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

//**** tube *******************************************************************

module fl_tube(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  //! base ellipse in [a,b] form
  base,
  //! «base» alternative radius for circular tubes
  r,
  //! «base» alternative diameter for circular tubes
  d,
  //! pipe height
  h,
  //! tube thickness
  thick,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant,
) {
  assert(h!=undef);
  assert(thick>0,thick);

  obase = r ? [r,r] : d ? [d/2,d/2] : base;
  assert(obase);
  bbox  = let(bbox=fl_bb_ellipse(obase)) [[bbox[0].x,bbox[0].y,0],[bbox[1].x,bbox[1].y,h]];
  size  = bbox[1]-bbox[0];
  D     = direction ? fl_direction(direction) : I;
  M     = fl_octant(octant,bbox=bbox);

  fl_trace("bbox",bbox);
  fl_trace("size",size);

  module do_add() {
    linear_extrude(height=h)
      fl_ellipticArc(e=obase,angles=[0,360],thick=thick);
  }
  module do_fprint() {
    linear_extrude(height=h)
      fl_ellipse(e=obase);
  }

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();
    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction);
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);
    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) do_fprint();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
