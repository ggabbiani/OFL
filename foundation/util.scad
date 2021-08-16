/*
 * Created on Fri Jul 16 2021.
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

include <defs.scad>

include <NopSCADlib/lib.scad>

// generates a screw without socket
module meta_screw(screw,len) {
  rotate(180,FL_Y)
    rotate_extrude()
      intersection() {
        projection()
          rotate(90,FL_X)
            screw(screw,len);
        translate([0,-screw_head_height(screw)])
        square(size=[screw_head_radius(screw),len+screw_head_height(screw)]);
      }
}

// use children(0) for making a rail

module rail(
   length=0 // when undef or 0 rail degenerates into children(0)
  ) {
  len = length == undef ? 0 : length;
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
 * For facilitating calculations, ax and bx must be orthogonal to ay and by respectively.
 */
function plane_align(ax,ay,bx,by) =
  assert(ax*ay==0,str("ax=",ax," must be orthogonal to ay=",ay))
  assert(bx*by==0,str("bx=",bx," must be orthogonal to by=",by))
  let (
    aax=ax/norm(ax),aay=ay/norm(ay),bbx=bx/norm(bx),bby=by/norm(by),
    aaz=cross(aax,aay),
    A=[
      [aax.x, aay.x,  aaz.x,  0 ],
      [aax.y, aay.y,  aaz.y,  0 ],
      [aax.z, aay.z,  aaz.z,  0 ],
      [0,     0,      0,      1 ],
    ],
    Ainv=[ // actually the transpose matrix since axis are mutually orthogonal
      [aax.x, aax.y,  aax.z,  0 ],
      [aay.x, aay.y,  aay.z,  0 ],
      [aaz.x, aaz.y,  aaz.z,  0 ],
      [0,     0,      0,      1 ],
    ],
    bbz=cross(bbx,bby),
    B=[
      [bbx.x, bby.x,  bbz.x,  0 ],
      [bbx.y, bby.y,  bbz.y,  0 ],
      [bbx.z, bby.z,  bbz.z,  0 ],
      [0,     0,      0,      1 ],
    ]
  ) B*Ainv;

module plane_align(ax,ay,bx,by,ech=false) {
  multmatrix(plane_align(ax,ay,bx,by)) children();
  if (ech) #children();
}

module cutout(
   len          // cutout length
  ,z=FL_Z          // axis to use as FL_Z (detects the cutout plane on FL_Z==0)
  ,x=FL_X          // axis to use as FL_X 
  ,trim=[0,0,0] // translation applied BEFORE projection() useful for trimming when cut=true
  ,cut=false    // when true only the cutout plane is used for section
  ,debug=false  // echo of children() when true
  ,delta=0      // specifies the distance of the new outline from the original outline
  ) {
  plane_align(FL_Z,FL_X,z,x)
    linear_extrude(len)
      offset(delta)
        projection(cut)
          plane_align(z,x,FL_Z,FL_X)
            translate(trim) 
              children();
  if (debug) #translate(trim) children();
}

