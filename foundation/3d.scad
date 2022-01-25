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

// include <unsafe_defs.scad>
include <2d.scad>
// include <placement.scad>

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
  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  size  = is_list(size) ? size : [size,size,size];
  defs  = fl_cube_defaults(size);

  D     = direction ? fl_direction(defs,direction=direction)  : I;
  M     = octant    ? fl_octant(defs,octant=octant)           : I;

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) cube(size,false);
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) cube(size);  // center=default=false ⇒ +X+Y+Z
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
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
  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);
  defs  = fl_sphere_defaults(r,d);

  bbox  = fl_bb_corners(defs);
  size  = fl_bb_size(defs); // bbox[1] - bbox[0];
  D     = direction ? fl_direction(defs,direction=direction)  : I;
  M     = octant    ? fl_octant(defs,octant=octant)           : I;

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) resize(size) sphere();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) cube(size,true);
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
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
  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

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

  multmatrix(D) {
    multmatrix(M) fl_parse(fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES)) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) cylinder(r1=r_bot,r2=r_top, h=h);   // center=default=false ⇒ +Z
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) multmatrix(Mbbox) %cube(size=size); // center=default=false ⇒ +X+Y+Z
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
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
  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

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

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs)  {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) cylinder(r1=Rbase,r2=Rtop, h=h, $fn=n); // center=default=false ⇒ +Z
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) multmatrix(Mbbox) %cube(size=size);     // center=default=false ⇒ +X+Y+Z
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
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
