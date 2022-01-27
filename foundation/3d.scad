/*
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

include <2d.scad>

/*
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

/*
 * cube replacement
 */
module fl_cube(
  verbs     = FL_ADD, // FL_ADD,FL_AXES,FL_BBOX
  size      = [1,1,1],
  octant,             // when undef native positioning is used
  direction           // desired direction [director,rotation] or native direction if undef
) {
  size  = is_list(size) ? size : [size,size,size];
  defs  = fl_cube_defaults(size);

  D     = direction ? fl_direction(defs,direction=direction)  : I;
  M     = octant    ? fl_octant(defs,octant=octant)           : I;

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($FL_ADD) cube(size,false);
    } else if ($verb==FL_BBOX) {
      fl_modifier($FL_BBOX) cube(size);  // center=default=false ⇒ +X+Y+Z
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
    fl_modifier($FL_AXES) fl_axes(size=size);
  }
}

/*
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

/*
 * sphere replacement.
 */
module fl_sphere(
  verbs   = FL_ADD,   // FL_ADD,FL_AXES,FL_BBOX
  r       = [1,1,1],
  d,
  octant,             // when undef default positioning is used
  direction           // desired direction [director,rotation], default direction if undef
) {
  defs  = fl_sphere_defaults(r,d);

  bbox  = fl_bb_corners(defs);
  size  = fl_bb_size(defs); // bbox[1] - bbox[0];
  D     = direction ? fl_direction(defs,direction=direction)  : I;
  M     = octant    ? fl_octant(defs,octant=octant)           : I;

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($FL_ADD) resize(size) sphere();
    } else if ($verb==FL_BBOX) {
      fl_modifier($FL_BBOX) cube(size,true);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
    fl_modifier($FL_AXES) fl_axes(size=size);
  }
}
/*
 * cylinder defaults for positioning (fl_bb_cornersKV)
 * and direction (fl_directorKV, fl_rotorKV).
 */
function fl_cylinder_defaults(
  h,                  // height of the cylinder or cone
  r,                  // radius of cylinder. r1 = r2 = r.
  r1,                 // radius, bottom of cone.
  r2,                 // radius, top of cone.
  d,                  // diameter of cylinder. r1 = r2 = d / 2.
  d1,                 // diameter, bottom of cone. r1 = d1 / 2.
  d2                  // diameter, top of cone. r2 = d2 / 2.
) = [
  fl_bb_corners(value=fl_bb_cylinder(h,r,r1,r2,d,d1,d2)),  // +Z
  fl_director(value=+Z),
  fl_rotor(value=+X),
];

function fl_bb_cylinder(
  h,                  // height of the cylinder or cone
  r,                  // radius of cylinder. r1 = r2 = r.
  r1,                 // radius, bottom of cone.
  r2,                 // radius, top of cone.
  d,                  // diameter of cylinder. r1 = r2 = d / 2.
  d1,                 // diameter, bottom of cone. r1 = d1 / 2.
  d2                  // diameter, top of cone. r2 = d2 / 2.
) =
assert(h>=0,"Only positive height are accepted")
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

/*
 * cylinder replacement
 */
module fl_cylinder(
  verbs  = FL_ADD,  // FL_ADD,FL_AXES,FL_BBOX
  h,                // height of the cylinder or cone
  r,                // radius of cylinder. r1 = r2 = r.
  r1,               // radius, bottom of cone.
  r2,               // radius, top of cone.
  d,                // diameter of cylinder. r1 = r2 = d / 2.
  d1,               // diameter, bottom of cone. r1 = d1 / 2.
  d2,               // diameter, top of cone. r2 = d2 / 2.
  octant,           // when undef native positioning is used
  direction         // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
) {
  r_bot = fl_parse_radius(r,r1,d,d1);
  r_top = fl_parse_radius(r,r2,d,d2);
  defs  = fl_cylinder_defaults(h,r,r1,r2,d,d1,d2);
  size  = fl_bb_size(defs);
  step  = 360/$fn;
  R     = max(r_bot,r_top);
  D     = direction ? fl_direction(defs,direction=direction)  : I;
  M     = octant    ? fl_octant(defs,octant=octant)           : I;
  Mbbox = fl_T(-[size.x/2,size.y/2,0]);
  fl_trace("octant",octant);
  fl_trace("size",size);

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($FL_ADD) cylinder(r1=r_bot,r2=r_top, h=h);   // center=default=false ⇒ +Z
    } else if ($verb==FL_BBOX) {
      fl_modifier($FL_BBOX) multmatrix(Mbbox) %cube(size=size); // center=default=false ⇒ +X+Y+Z
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
    fl_modifier($FL_AXES) fl_axes(size=[size.x,size.y,5/4*size.z]);
  }
}

/*
 * prism defaults for positioning (fl_bb_cornersKV)
 * and direction (fl_directorKV, fl_rotorKV).
 */
function fl_prism_defaults(
  n,  // edge number
  l,  // edge length
  l1, // edge length, bottom
  l2, // edge length, top
  h   // height of the prism
) = [
  fl_bb_corners(value=fl_bb_prism(n,l,l1,l2,h)),  // placement: +Z
  fl_director(value=+Z),
  fl_rotor(value=+X),
];

function fl_bb_prism(
  n,  // edge number
  l,  // edge length
  l1, // edge length, bottom
  l2, // edge length, top
  h   // height of the prism
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

/*
 * prism
 * native positioning : +Z
 * native direction   : [+Z,+X]
 */
module fl_prism(
  verbs  = FL_ADD,  // FL_ADD,FL_AXES,FL_BBOX
  n,                // edge number
  l,                // edge length
  l1,               // edge length, bottom
  l2,               // edge length, top
  h,                // height
  octant,           // when undef native positioning is used
  direction         // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
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
  M     = octant    ? fl_octant(defs,octant=octant)         : I;
  Mbbox = fl_T([-size.x+R,-size.y/2,0]);
  fl_trace("octant",octant);
  fl_trace("direction",direction);
  fl_trace("size",size);

  fl_manage(verbs,M,D)  {
    if ($verb==FL_ADD) {
      fl_modifier($FL_ADD) cylinder(r1=Rbase,r2=Rtop, h=h, $fn=n); // center=default=false ⇒ +Z
    } else if ($verb==FL_BBOX) {
      fl_modifier($FL_BBOX) multmatrix(Mbbox) %cube(size=size);     // center=default=false ⇒ +X+Y+Z
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
    fl_modifier($FL_AXES) fl_axes(size=size);
  }
}

//**** 3d placement ***********************************************************

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
  proto,      // prototype with fl_director and fl_rotor properties
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

/*
 * from [Rotation matrix from plane A to B](https://math.stackexchange.com/questions/1876615/rotation-matrix-from-plane-a-to-b)
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

/**
 * calculates the overall bounding box size of a layout
 */
function lay_bb_size(axis,gap,types) = let(c = lay_bb_corners(axis,gap,types)) c[1]-c[0];

/**
 * creates a group with the resulting bounding box corners of a layout
 */
function lay_group(axis,gap,types) = [fl_bb_corners(value=lay_bb_corners(axis,gap,types))];

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
  assert(len(axis)==3,axis);
  assert(is_num(gap),gap);
  assert(is_list(types),types);

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

  fl_manage(verbs) {
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
    fl_modifier($FL_AXES) fl_axes(size=size);
  }
}

/*****************************************************************************
 * bounding box
 *****************************************************************************/

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

/*****************************************************************************
 * 3d miscellanous
 *****************************************************************************/

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
