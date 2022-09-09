/*!
 * General algorithm package.
 *
 * __TODO:__
 *
 * 1) better example (SATA plug?)
 * 2) orientation?
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
 * along with OFL.  If not, see <http: //www.gnu.org/licenses/>.
 */

include <3d.scad>

/*!
 * draws the three orthogonal planes dividing space into octants
 */
module fl_planes(
  size=1,
  //! alpha channel for transparency
  alpha=0.2
) {
  nil = 0.01;
  fl_trace("size",size);
  sz  = is_list(size)
      ? assert(size.x>=0 && size.y>=0 && size.z>=0) size
      : assert(size>=0) [size,size,size];
  fl_trace("sz",sz);
  color("red",alpha=alpha)   fl_cube(size=[sz.x,sz.y,nil],octant=O);
  color("green",alpha=alpha) fl_cube(size=[nil,sz.y,sz.z],octant=O);
  color("blue",alpha=alpha)  fl_cube(size=[sz.x,nil,sz.z],octant=O);
}

/*!
 * build a 2d/3d pattern from data 
 */
function fl_algo_pattern(
  //! number of items to be taken from data
  n,
  //! data index pattern
  pattern,
  //! list of item containing 2d/3d data in their 2nd element
  data
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

/*!
 * add a 2d/3d pattern from data 
 */
module fl_algo_pattern(
  //! number of items to be taken from data
  n,
  //! data index pattern
  pattern,
  //! data
  data,
  //! spatial drift between centers
  deployment,
  //! internal alignment
  align  = O,
  octant = O
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

  result  = fl_algo_pattern(n,pattern,data);
  size    = sz(deployment,result);
  on = [sign(deployment.x),sign(deployment.y),sign(deployment.z)];

  T = fl_T([-on.x*size.x/2,-on.y*size.y/2,-on.z*size.z/2]);
  // verifico che il prodotto scalare sia uguale a zero
  // ossia che il dispiegamento e l'allineamento siano ORTOGONALI
  assert(deployment*align==0,"Alignment and deployment must be orthogonal");

  fl_trace("octant",octant);
  bbox=[-size/2,size/2];
  M = fl_octant(octant=octant,bbox=bbox) * fl_octant(octant=-align,bbox=bbox);

  multmatrix(M*T) {
    multmatrix(fl_octant(octant=align,bbox=[-size/2,+size/2]))
      for (i=[0:len(result)-1]) {
        data=result[i];
        assert(len(data)>1 && len(data)<4);
        fl_trace("data",data);
        // matrice di allineamento del segmento i-esimo
        A = fl_octant(octant=align,bbox=[-data/2,+data/2]);
        // matrice di dispiegamento del segmento i-esimo
        D = fl_T(i*deployment);
        multmatrix(A*D)
          if (len(data)<3) square(size=data, center=true);
          else fl_cube(size=data, octant=on);
      }
    }
}
