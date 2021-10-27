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

include <unsafe_defs.scad>
use     <2d.scad>
use     <placement.scad>

/* 
 * cube defaults for positioning (fl_bb_cornersKV)
 * and direction (fl_directorKV, fl_rotorKV).
 */
function fl_cube_defaults(
  size=[1,1,1]
)  = let(
  size  = is_list(size) ? size : [size,size,size]
) [
  fl_bb_cornersKV([O,size]),  // octant ⇒ +X+Y+Z
  fl_directorKV(+Z),
  fl_rotorKV(+X),
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
  fl_bb_cornersKV([-r,+r]),  // simmetric bounding box ⇒ octant==O
  fl_directorKV(+Z),
  fl_rotorKV(+X),
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
  fl_bb_cornersKV(fl_bb_cylinder(h,r,r1,r2,d,d1,d2)),  // +Z
  fl_directorKV(+Z),
  fl_rotorKV(+X),
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
  fl_bb_cornersKV(fl_bb_prism(n,l,l1,l2,h)),  // placement: +Z
  fl_directorKV(+Z),
  fl_rotorKV(+X),
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
