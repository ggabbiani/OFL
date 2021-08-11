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

use <3d.scad>
include <defs.scad>

$fn       = 50;           // [3:50]
$FL_TRACE  = false;
$FL_RENDER = false;
$FL_DEBUG  = false;

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Algo] */

DEPLOYMENT  = [10,0,0];
ALIGN       = [0,0,0];  // [-1:+1]

/* [Hidden] */

module __test__() {
  data    = [
    ["zero",    [1,11,111]],
    ["first",   [2,22,1]],
    ["second",  [3,33,1]],
  ];
  pattern = [0,1,1,2];

  fl_trace("result",fl_algo_pattern(10,pattern,data));
  fl_algo_pattern(10,pattern,data,deployment=DEPLOYMENT,octant=OCTANT,fl_align=ALIGN);
}

function fl_algo_pattern(
  n         // number of items to be taken from data
  ,pattern  // data index pattern
  ,data     // list of item containing 2d/3d data in their 2nd element
) = 
  assert(n!=undef)
  assert(pattern!=undef)
  assert(data!=undef)
  let(
    m = len(pattern)
  ) [for(i=[0:n-1]) let(
    resto = i%m,
    index = pattern[resto],
    d     = data[index][1]
  ) /* echo(pattern=pattern) echo(i=i) echo(index=index) echo(d=d) */ d ];

module fl_algo_pattern(
  n           // number of items to be taken from data
  ,pattern    // data index pattern
  ,data       // data
  ,deployment // spatial drift between centers
  ,fl_align  = FL_O // internal alignment
  ,octant = FL_O
) {

  function sz(step,items,prev_steps=[0,0,0]) = 
    assert(is_list(step))
    assert(is_list(items))
    let(curr = items[0])
    len(items)==1 ? prev_steps+curr
    : let(
        curr_sz   = prev_steps + [max(step.x,curr.x),max(step.y,curr.y),max(step.z,curr.z)],
        others    = [for(i=[1:len(items)-1]) items[i]],
        others_sz = sz(step,others,prev_steps+step)
      ) [max(curr_sz.x,others_sz.x),max(curr_sz.y,others_sz.y),max(curr_sz.z,others_sz.z)];

  assert(is_list(deployment));
  // echo(deployment=deployment);

  result  = fl_algo_pattern(n,pattern,data);
  size    = sz(deployment,result);
  on = [sign(deployment.x),sign(deployment.y),sign(deployment.z)];


  // echo(size=size);
  // M   = FL_I;
  T = fl_T([-on.x*size.x/2,-on.y*size.y/2,-on.z*size.z/2]);
  // verifico che il prodotto scalare sia uguale a zero
  // ossia che il dispiegamento e l'allineamento siano ORTOGONALI
  assert(deployment*fl_align==0,"Alignment and deployment must be orthogonal");
  a = fl_align;
  // a = [deployment.x==0?fl_align.x:0,deployment.y==0?fl_align.y:0,deployment.z==0?fl_align.z:0];
  // assert(a*octant==0,"Alignment and anchor must be orthogonal");
  // o = [a.x==0?octant.x:0,a.y==0?octant.y:0,a.z==0?octant.z:0];
  o = octant;
  // M = anchor(o,size) * anchor(-a,size);
  M = fl_place(octant=o,size=size) * fl_place(octant=-a,size=size);

  multmatrix(M*T) {
    // multmatrix(anchor(a,size))
    multmatrix(fl_place(octant=a,size=size))
      // %fl_cube(size=size,octant=on);
      for (i=[0:len(result)-1]) {
        data=result[i];
        assert(len(data)>1&&len(data)<4);
        fl_trace("data",data);
        // A = anchor(a,data);   // matrice di allineamento del segmento i-esimo
        A = fl_place(octant=a,size=data);   // matrice di allineamento del segmento i-esimo
        D = fl_T(i*deployment);  // matrice di dispiegamento del segmento i-esimo
        multmatrix(A*D)
          if (len(data)<3) square(size=data, center=true);
          else fl_cube(size=data, octant=on);
      }
    }
}

__test__();
