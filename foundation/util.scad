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

/*
 * 3d surface bending on rectangular cuboid faces.
 *
 * «faces» is used for mapping each surface sizings and calculating the total size of the sheet.
 * A sheet object is then created with the overall sheet bounding box.
 *
 * Children context:
 * 
 * 
 *                        N           M               
 *                         +=========+                  ✛ ⇐ upper corner
 *                         |         |                     (at sizing x,y)
 *                         |    4    |                   
 *                 D      C|         |F      H          L
 *                 +=======+=========+=======+==========+
 *                 |       |         |       |          |
 *                 |  0    |    1    |   2   |     3    |
 *                 |       |         |       |          |
 *                 +=======+=========+=======+==========+
 *                 A      B|         |E      G          I
 *                         |    5    |
 *                         |         |
 * lower corner ⇒ ✛       +=========+
 * (at origin)            O           P
 * 
 * $sheet - an object containing the calculated bounding corners of the sheet
 * $A..$N - 3d values of the corresponding points in the above picture
 * $size  - list of six surface sizings in the order shown in the picture
 * 
 */
module fl_bend(
  // key/value list of face sizing:
  // key    = one of the eight cartesian semi axes (+X=[1,0,0], -Z=[0,0,1])
  // value  = 3d size [x-size,y-size,z-size]
  // Missing faces means 0-sized.
  faces,
  // when true children 3d surface is not bent
  flat=false
) {
  fcs = [
    fl_get(faces,-X,[0,0,0]),
    fl_get(faces,+Z,[0,0,0]),
    fl_get(faces,+X,[0,0,0]),
    fl_get(faces,-Z,[0,0,0]),
    fl_get(faces,+Y,[0,0,0]),
    fl_get(faces,-Y,[0,0,0]),
  ];
  bbox  = bbox(fcs);
  size  = bbox[1]-bbox[0];
  type  = fl_bb_new(size=size);
  fl_trace("fcs",fcs);
  fl_trace("sheet metal bounding box:",bbox);

  // calculates the bounding box containing the needed faces
  function bbox(faces) = let(
      width   = faces[0].x+faces[1].x+faces[2].x+faces[3].x,
      height  = faces[5].y+faces[1].y+faces[4].y,
      thick   = faces[0].z
    ) [O,[width,height,thick]];

  module always(face,translate) {
    $sheet  = type;
    $size   = fcs;
    $A      = [0,               $size[5].y,       0];
    $B      = [$size[0].x,      $A.y,             0];
    $C      = [$B.x,            $B.y+$size[0].y,  0];
    $D      = [$A.x,            $C.y,             0];
    $E      = [$B.x+$size[1].x, $B.y,             0];
    $F      = [$E.x,            $C.y,             0];
    $G      = [$E.x+$size[2].x, $E.y,             0];
    $H      = [$G.x,            $F.y,             0];
    $I      = [$G.x+$size[3].x, $G.y,             0];
    $L      = [$I.x,            $H.y,             0];
    $M      = [$F.x,            $F.y+$size[4].y,  0];
    $N      = [$C.x,            $M.y,             0];
    $O      = [$B.x,            0,                0];
    $P      = [$O.x+$size[5].x, 0,                0];
    intersection() {
      fl_place(octant=+X+Y-Z,bbox=bbox)
        children();
      translate(translate)
        fl_cube(size=face,octant=+X+Y-Z);
    } 
  }

  // -X
  let(f=fcs[0]) if (f.x && f.y) 
    if (flat) 
      always(f,translate=[0,fcs[5].y]) children();
    else
      translate([0,0,-f.x]) rotate(-90,Y) always(f,translate=[0,fcs[5].y]) children(); 

  // +Z
  let(f=fcs[1]) if (f.x && f.y)
    if (flat)
      always(f,translate=[fcs[0].x,fcs[5].y]) children();
    else 
      translate([-fcs[0].x,0]) always(f,translate=[fcs[0].x,fcs[5].y]) children(); 

  // +X
  let(f=fcs[2]) if (f.x && f.y)
    if (flat)
      always(f,translate=[fcs[0].x+fcs[1].x,fcs[5].y]) children();
    else 
      translate([fcs[1].x,0])
        rotate(90,Y)
          translate([-fcs[0].x-fcs[1].x,0])
            always(f,translate=[fcs[0].x+fcs[1].x,fcs[5].y]) children();

  // -Z
  let(f=fcs[3]) if (f.x && f.y) 
    if (flat)
      always(f,translate=[fcs[0].x+fcs[1].x+fcs[2].x,fcs[5].y]) children();
    else 
      translate([f.x,0,-max(fcs[0].x,fcs[2].x)])
        rotate(180,Y)
          translate([-fcs[0].x-fcs[1].x-fcs[2].x,0])
            always(f,translate=[fcs[0].x+fcs[1].x+fcs[2].x,fcs[5].y]) children();

  // +Y
  let(f=fcs[4]) if (f.x && f.y)
    if (flat)
      always(f,translate=[fcs[0].x,fcs[5].y+fcs[1].y]) children();
    else 
      translate([-fcs[0].x,fcs[5].y+fcs[1].y])
        translate([0,f.z])
          rotate(-90,X)
            translate([0,-fcs[5].y-fcs[1].y])
              always(f,translate=[fcs[0].x,fcs[5].y+fcs[1].y]) children();

  // -Y
  let(f=fcs[5]) if (f.x && f.y)
    if (flat)
      always(f,translate=[fcs[0].x,0]) children();
    else 
      translate([-fcs[0].x,f.y,-f.y])
        rotate(90,X)
          always(f,translate=[fcs[0].x,0]) children();

}
