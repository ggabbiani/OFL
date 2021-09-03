/*
 * 3d primitives for OpenSCAD.
 * 
 * Created  : on Thu Jul 08 2021.
 * Copyright: © 2021 Giampiero Gabbiani.
 * Email    : giampiero@gabbiani.org
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

use     <2d.scad>
include <defs.scad>

$fn       = 50;           // [3:50]
$FL_TRACE    = false;
$FL_RENDER   = false;
$FL_DEBUG    = false;

AXES      = false;
BBOX      = false;

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [+1,+1,+1];  // [-1:+1]

/* [3ds] */

SHAPE   = "cube";     // ["cube", "cylinder", "prism", "sphere"]
// Size for cube and sphere, bottom/top diameter and height for cylinder
SIZE    = [1,1,1]; 

/* [Cylinder] */

// Fix bounding-box for fl_cylinder when $fn is odd
BBFIX = false;

/* [Prism] */

N     = 3; // [3:10]
L_bot = 1.0;
L_top = 1.0;
H     = 1; // [0:10]

/* [Hidden] */

module __test__() {
  octant  = PLACE_NATIVE ? undef : OCTANT;
  verbs=[
    FL_ADD,
    if (BBOX) FL_BBOX,
  ];
  fl_trace("PLACE_NATIVE",PLACE_NATIVE);
  fl_trace("octant",octant);

  module cube(verbs) {
    if (PLACE_NATIVE)
      fl_cube(verbs,size=SIZE,axes=AXES);
    else
      fl_cube(verbs,size=SIZE,octant=octant,axes=AXES);
  }

  module sphere(verbs) {
    if (PLACE_NATIVE)
      fl_sphere(verbs,d=SIZE,axes=AXES);
    else
      fl_sphere(verbs,d=SIZE,octant=octant,axes=AXES);
  }

  module cylinder(verbs) {
    if (PLACE_NATIVE)
      fl_cylinder(verbs,d1=SIZE.x,d2=SIZE.y,h=SIZE.z,bbfix=BBFIX,axes=AXES);
    else
      fl_cylinder(verbs,d1=SIZE.x,d2=SIZE.y,h=SIZE.z,octant=OCTANT,bbfix=BBFIX,axes=AXES);
  }

  module prism(verbs) {
    if (PLACE_NATIVE)
      fl_prism(verbs,n=N,l1=L_bot,l2=L_top,h=H,axes=AXES);
    else
      fl_prism(verbs,n=N,l1=L_bot,l2=L_top,h=H,octant=OCTANT,axes=AXES);
  }

  if      (SHAPE == "cube"    )  cube(verbs);
  else if (SHAPE == "sphere"  )  sphere(verbs);
  else if (SHAPE == "cylinder")  cylinder(verbs);
  else if (SHAPE == "prism"   )  prism(verbs);
}

module fl_cube(
  verbs   = FL_ADD  // FL_ADD,FL_AXES,FL_BBOX
  ,size   = [1,1,1]
  ,octant           
  ,axes   = false
) {
  sz  = is_list(size) ? size : [size,size,size];
  M   = octant!=undef ? fl_octant(octant=octant,bbox=[[0,0,0],sz]) : FL_I;
  fl_trace("M",M);

  fl_parse(verbs) {
    if ($verb==FL_ADD) {
      multmatrix(M) cube(sz,false);
      if (axes)
        fl_axes(size=sz);
    } else if ($verb==FL_BBOX) {
      multmatrix(M) %cube(size); // center=default=false ⇒ +X+Y+Z
    } else if ($verb==FL_AXES) {
      fl_axes(size=sz);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

module fl_sphere(
  verbs   = FL_ADD,   // FL_ADD,FL_AXES,FL_BBOX
  r       = [1,1,1],
  d,
  octant,
  axes    = false
) {
  Rvec  = is_undef(d) ? (is_list(r) ? r : [r,r,r]) : (is_list(d) ? d : [d,d,d])/2;
  size  = 2*Rvec;
  M     = octant!=undef ? fl_octant(octant=octant,bbox=[-Rvec,Rvec]) : FL_I;
  fl_trace("M",M);
  fl_trace("Rvec",Rvec);
  
  module do_axes() {
    fl_axes(size=Rvec*2);
  }

  fl_parse(verbs)  {
    if ($verb==FL_ADD) {
      multmatrix(M) resize(size) sphere();
      if (axes)
        do_axes();
    } else if ($verb==FL_BBOX) {
      multmatrix(M) %cube(size,true);
    } else if ($verb==FL_AXES) {
      do_axes();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

// restituisce il multiplo di 360/n con il massimo seno() 
function __max_sin__(n,val=0) = 
  let(max=90,step=360/n)
  val+step >= max ? (sin(val)>sin(val+step) ? val : val+step) : __max_sin__(n,val+step);

function fl_bb_cylinder(
  ,h                  // height of the cylinder or cone
  ,r                  // radius of cylinder. r1 = r2 = r.
  ,r1                 // radius, bottom of cone.
  ,r2                 // radius, top of cone.
  ,d                  // diameter of cylinder. r1 = r2 = d / 2.
  ,d1                 // diameter, bottom of cone. r1 = d1 / 2.
  ,d2                 // diameter, top of cone. r2 = d2 / 2.
) =
assert(h>=0)
let(
  step    = 360/$fn,
  Rbase   = fl_parse_radius(r,r1,d,d1),
  Rtop    = fl_parse_radius(r,r2,d,d2),
  base    = [for(p=fl_bb_circle(Rbase)) [p.x,p.y,0]],
  top     = [for(p=fl_bb_circle(Rtop))  [p.x,p.y,h]],
  points  = concat(base,top),
  x       = [for(p=points) p.x],
  y       = [for(p=points) p.y],
  z       = [for(p=points) p.z]
) [[min(x),min(y),min(z)],[max(x),max(y),max(z)]];

module fl_cylinder(
   verbs  = FL_ADD  // FL_ADD,FL_AXES,FL_BBOX
  ,h                  // height of the cylinder or cone
  ,r                  // radius of cylinder. r1 = r2 = r.
  ,r1                 // radius, bottom of cone.
  ,r2                 // radius, top of cone.
  ,d                  // diameter of cylinder. r1 = r2 = d / 2.
  ,d1                 // diameter, bottom of cone. r1 = d1 / 2.
  ,d2                 // diameter, top of cone. r2 = d2 / 2.
  ,octant
  ,bbfix  = false     // bounding box fix when $fn is odd
  ,axes   = false
) {
  r_bot = fl_parse_radius(r,r1,d,d1);
  r_top = fl_parse_radius(r,r2,d,d2);
  bbox  = fl_bb_cylinder(h=h,r1=r_bot,r2=r_top);
  sz    = bbox[1]-bbox[0];
  step  = 360/$fn;
  R     = max(r_bot,r_top);
  M     = octant!=undef ? fl_octant(octant=octant,bbox=bbox) : FL_I;
  Mbbox = M * fl_T(-[sz.x/2,sz.y/2,0]);
  fl_trace("octant",octant);
  fl_trace("bbox",bbox);
  fl_trace("sz",sz);

  module do_axes() {
    fl_axes(size=sz);
  }

  fl_parse(verbs)  {
    if ($verb==FL_ADD) {
      // multmatrix(Mfix) cylinder(r1=r_bot,r2=r_top, h=h, center=true);
      multmatrix(M) cylinder(r1=r_bot,r2=r_top, h=h/* , center=false */); // center=default=false ⇒ +Z
      if (axes)
        do_axes();
    } else if ($verb==FL_BBOX) {
      multmatrix(Mbbox) %cube(size=sz/*,center=false*/); // center=default=false ⇒ +X+Y+Z
    } else if ($verb==FL_AXES) {
      do_axes();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

function fl_bb_prism(
  h,  // height of the prism
  n,  // edge number
  l,  // edge length
  l1, // edge length, bottom
  l2  // edge length, top
) = 
assert(h>=0) 
assert(n>2) 
let(
  l_bot = fl_parse_l(l,l1),
  l_top = fl_parse_l(l,l2),
  step    = 360/n,
  Rbase   = l_bot / (2 * sin(step/2)),
  Rtop    = l_top / (2 * sin(step/2)),
  base    = [for(p=fl_bb_polygon(fl_circle(Rbase,$fn=n))) [p.x,p.y,0]],
  top     = [for(p=fl_bb_polygon(fl_circle(Rtop,$fn=n)))  [p.x,p.y,h]],
  points  = concat(base,top),
  x       = [for(p=points) p.x],
  y       = [for(p=points) p.y],
  z       = [for(p=points) p.z]
) [[min(x),min(y),min(z)],[max(x),max(y),max(z)]];

module fl_prism(
   verbs  = FL_ADD  // FL_ADD,FL_AXES,FL_BBOX
  ,n                // edge number
  ,l                // edge length
  ,l1               // edge length, bottom
  ,l2               // edge length, top
  ,h                // height
  ,octant
  ,axes     = false
) {
  step  = 360/n;
  l_bot = fl_parse_l(l,l1);
  l_top = fl_parse_l(l,l2);
  Rbase = l_bot / (2 * sin(step/2));
  Rtop  = l_top / (2 * sin(step/2));
  R     = max(Rbase,Rtop);
  bbox  = fl_bb_prism(h,n,l1=l_bot,l2=l_top);
  sz    = bbox[1]-bbox[0];
  M     = octant!=undef ? fl_octant(octant=octant,bbox=bbox) : FL_I;
  Mbbox = M * fl_T([-sz.x+R,-sz.y/2,0]);
  fl_trace("octant",octant);
  fl_trace("bbox",bbox);
  fl_trace("sz",sz);

  fl_parse(verbs)  {
    if ($verb==FL_ADD) {
      multmatrix(M) cylinder(r1=Rbase,r2=Rtop, h=h, $fn=n); // center=default=false ⇒ +Z
      if (axes)
        fl_axes(size=sz);
    } else if ($verb==FL_BBOX) {
      multmatrix(Mbbox) %cube(size=sz); // center=default=false ⇒ +X+Y+Z
    } else if ($verb==FL_AXES) {
      fl_axes(size=sz);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }

}

__test__();