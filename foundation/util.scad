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

include <unsafe_defs.scad>
use     <3d.scad>
use     <placement.scad>

use     <scad-utils/spline.scad>
include <NopSCADlib/lib.scad>

// use children(0) for making a rail
module fl_rail(
  length  // when undef or 0 rail degenerates into children(0)
) {
  len = length ? length : 0;
  rotate(-90,FL_X)
    linear_extrude(height = len, center = true)
      projection()
        rotate(90,FL_X)
          children(0);
  for(i=[-1,1])
    translate(i*fl_Y(len/2))
      children(0);
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

module fl_cutout(
   len          // cutout length
  ,z=Z          // axis to use as Z (detects the cutout plane on Z==0)
  ,x=X          // axis to use as X 
  ,trim=[0,0,0] // translation applied BEFORE projection() useful for trimming when cut=true
  ,cut=false    // when true only the cutout plane is used for section
  ,debug=false  // echo of children() when true
  ,delta=0      // specifies the distance of the new outline from the original outline
  ) {
  fl_planeAlign(Z,X,z,x)
    linear_extrude(len)
      offset(delta)
        projection(cut)
          fl_planeAlign(z,x,Z,X)
            translate(trim) 
              children();
  if (debug) #translate(trim) children();
}
