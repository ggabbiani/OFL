/*
 * Created on Thu Jul 08 2021.
 *
 * Copyright © 2021 Giampiero Gabbiani.
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
// Size for fl_cube and fl_sphere, bottom/top diameter and height for fl_cylinder
SIZE    = [1,1,1]; 
// compatibility flag for cube() and cylinder()
CENTER  = "undef";    // ["undef","true","false"]

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
  center = CENTER!="undef" ? CENTER=="true" : undef;
  verbs=[
    FL_ADD,
    if (BBOX) FL_BBOX,
  ];

  module __cube__(verbs) {
    if (PLACE_NATIVE)
      fl_cube(verbs,size=SIZE,center=center,axes=AXES);
    else
      fl_cube(verbs,size=SIZE,octant=OCTANT,axes=AXES);
  }

  module __sphere__(verbs) {
    if (PLACE_NATIVE)
      fl_sphere(verbs,d=SIZE,axes=AXES);
    else
      fl_sphere(verbs,d=SIZE,octant=OCTANT,axes=AXES);
  }

  module __cylinder__(verbs) {
    if (PLACE_NATIVE)
      fl_cylinder(verbs,d1=SIZE.x,d2=SIZE.y,h=SIZE.z,center=center,bbfix=BBFIX,axes=AXES);
    else
      fl_cylinder(verbs,d1=SIZE.x,d2=SIZE.y,h=SIZE.z,octant=OCTANT,center=center,bbfix=BBFIX,axes=AXES);
  }

  module __prism__(verbs) {
    if (PLACE_NATIVE)
      fl_prism(verbs,n=N,l1=L_bot,l2=L_top,h=H,center=center,axes=AXES);
    else
      fl_prism(verbs,n=N,l1=L_bot,l2=L_top,h=H,octant=OCTANT,center=center,axes=AXES);
  }

  if      (SHAPE == "cube"    )  __cube__(verbs);
  else if (SHAPE == "sphere"  )  __sphere__(verbs);
  else if (SHAPE == "cylinder")  __cylinder__(verbs);
  else if (SHAPE == "prism"   )  __prism__(verbs);
}

module fl_cube(
  verbs   = FL_ADD  // FL_ADD,FL_AXES,FL_BBOX
  ,size   = [1,1,1]
  ,octant           // default [1,1,1]
  ,center           // cube() compatibility parameter
                    // alias for octant=[0,0,0] when true, 
                    // octant=[1,1,1] when false
  ,axes   = false
) {
  assert(octant==undef || center==undef);
  o   = center!=undef ? center ? [0,0,0] : [1,1,1] : octant != undef ? octant : [1,1,1];
  sz  = is_list(size) ? size : [size,size,size];
  M   = fl_octant(octant=o,bbox=[[0,0,0],sz]);

  fl_parse(verbs) {
    if ($verb==FL_ADD) {
      multmatrix(M) cube(sz,false);
      if (axes)
        fl_axes(size=sz);
    } else if ($verb==FL_BBOX) {
      multmatrix(M) %cube(size,false);
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
  octant  = FL_O,
  axes    = false
) {
  Rvec  = is_undef(d) ? (is_list(r) ? r : [r,r,r]) : (is_list(d) ? d : [d,d,d])/2;
  size  = 2*Rvec;
  M     = fl_octant(octant=octant,bbox=[[-Rvec,-Rvec,-Rvec],[Rvec,Rvec,Rvec]]);
  fl_trace("M",M);
  
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

// Il bounding box NON è simmetrico rispetto al vertice per i prismi con numero di facce dispari, 
// Il bb size viene modificato di conseguenza e viene aggiunta una traslazione
// aggiuntiva sull'asse FL_X di delta/2 sulla figura quando $fn è dispari.
function fl_cylinderBb(
  ,h                  // height of the cylinder or cone
  ,r                  // radius of cylinder. r1 = r2 = r.
  ,r1                 // radius, bottom of cone.
  ,r2                 // radius, top of cone.
  ,d                  // diameter of cylinder. r1 = r2 = d / 2.
  ,d1                 // diameter, bottom of cone. r1 = d1 / 2.
  ,d2                 // diameter, top of cone. r2 = d2 / 2.
  ,bbfix     = false  // bounding box fix
) = let(
  step  = 360/$fn,
  R     = max(fl_parse_radius(r,r1,d,d1),fl_parse_radius(r,r2,d,d2)),
  angle = __max_sin__($fn)
) bbfix ? [(fl_isOdd($fn) ? R*(1+cos(step/2)) : 2*R), 2*R*sin(angle), h] : [2*R,2*R,h];

module fl_cylinder(
   verbs  = FL_ADD  // FL_ADD,FL_AXES,FL_BBOX
  ,h                  // height of the cylinder or cone
  ,r                  // radius of cylinder. r1 = r2 = r.
  ,r1                 // radius, bottom of cone.
  ,r2                 // radius, top of cone.
  ,d                  // diameter of cylinder. r1 = r2 = d / 2.
  ,d1                 // diameter, bottom of cone. r1 = d1 / 2.
  ,d2                 // diameter, top of cone. r2 = d2 / 2.
  ,octant = +FL_Z
  ,center             // cylinder() compatibility parameter
  ,bbfix  = false     // bounding box fix when $fn is odd
  ,axes   = false
) {
  assert(h>=0);
  fl_trace("center",center);
  fl_trace("octant",octant);
  r_bot = fl_parse_radius(r,r1,d,d1);
  r_top = fl_parse_radius(r,r2,d,d2);
  o     = (center == undef ? octant : (center ? [0,0,0] : +FL_Z));
  sz    = fl_cylinderBb(h=h,r1=r_bot,r2=r_top,bbfix=bbfix);
  step  = 360/$fn;
  R     = max(r_bot,r_top);
  T     = let(delta = fl_isOdd($fn) ? [R*(1-cos(step/2)),0,0] : FL_O) fl_T(-fl_X(delta.x)/2);
  M     = fl_place(octant=o,size=sz);
  Mfix  = bbfix ? M * T : M;

  module do_axes() {
    fl_axes(size=sz);
  }

  fl_parse(verbs)  {
    if ($verb==FL_ADD) {
      multmatrix(Mfix) cylinder(r1=r_bot,r2=r_top, h=h, center=true);
      if (axes)
        do_axes();
    } else if ($verb==FL_BBOX) {
      multmatrix(M) %cube(sz,true);
    } else if ($verb==FL_AXES) {
      do_axes();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

module fl_prism(
   verbs  = FL_ADD  // FL_ADD,FL_AXES,FL_BBOX
  ,n                // edge number
  ,l                // edge length
  ,l1               // edge length, bottom
  ,l2               // edge length, top
  ,h                // height
  ,octant  = +FL_Z
  ,center           // cylinder() compatibility parameter
  ,axes     = false
) {
  fl_trace("center",center);
  fl_trace("octant",octant);
  l_bot = fl_parse_l(l,l1);
  l_top = fl_parse_l(l,l2);
  alpha = 360/n;
  // raggi circonferenze circoscritte alle basi
  r_bot     = l_bot / (2 * sin(alpha/2));
  r_top     = l_top / (2 * sin(alpha/2));
  fl_cylinder(verbs,$fn=n,r1=r_bot,r2=r_top,h=h,octant=octant,center=center,bbfix=true,axes=axes);
}

__test__();