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
use     <layout.scad>
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

function fl_bend_sheet(type,value)    = fl_property(type,"bend/sheet",value);
function fl_bend_faceSet(type,value)  = fl_property(type,"bend/face set",value);

/**
 * folding objects contain bending information
 */
function fl_folding(
  // key/value list of face sizings:
  // key    = one of the eight cartesian semi axes (+X=[1,0,0], -Z=[0,0,1])
  // value  = 3d size [x-size,y-size,z-size]
  // Missing faces means 0-sized.
  // Examples
  // face=[
  //  [-X, [28, 78, 0.5]],
  //  [+Z, [51, 78, 0.5]],
  //  [+Y, [51, 28, 0.5]],
  //  [-Y, [51,  9, 0.5]],
  // ]
  faces,
  material  = "silver"
) = let(
    fcs     = [
      fl_get(faces,-X,[0,0,0]),
      fl_get(faces,+Z,[0,0,0]),
      fl_get(faces,+X,[0,0,0]),
      fl_get(faces,-Z,[0,0,0]),
      fl_get(faces,+Y,[0,0,0]),
      fl_get(faces,-Y,[0,0,0]),
    ],

    flat_w  = fcs[0].x+fcs[1].x+fcs[2].x+fcs[3].x,
    flat_h  = fcs[5].y+fcs[1].y+fcs[4].y,
    flat_t  = fcs[0].z,
    flat_bb = [O,[flat_w,flat_h,flat_t]],

    bent_w  = max(fcs[1].x,fcs[3].x),
    bent_h  = max(fcs[0].y,fcs[1].y,fcs[2].y,fcs[3].y),
    bent_t  = max(fcs[0].x,fcs[2].x,fcs[4].y,fcs[5].y),
    bent_bb = [[0,fcs[5].y,-bent_t],[bent_w,fcs[5].y+bent_h,0]]
  ) [
    fl_bb_corners(value=bent_bb),
    fl_bend_sheet(value=[fl_bb_corners(value=flat_bb)]),
    fl_bend_faceSet(value=fcs),
    fl_material(value=material),
    fl_director(value=FL_Z),fl_rotor(value=FL_X),
  ];

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
 *                         |   [4]   |                   
 *                 D      C|   +Y    |F      H          L
 *                 +=======+=========+=======+==========+
 *                 |       |         |       |          |
 *                 |  [0]  |   [1]   |  [2]  |    [3]   |
 *                 |  -X   |   +Z    |  +X   |    -Z    |
 *                 +=======+=========+=======+==========+
 *                 A      B|         |E      G          I
 *                         |   [5]   |
 *                         |   -Y    |
 * lower corner ⇒ ✛       +=========+
 * (at origin)            O           P
 * 
 * $sheet - an object containing the calculated bounding corners of the sheet
 * $A..$N - 3d values of the corresponding points in the above picture
 * $size  - list of six surface sizings in the order shown in the picture
 * 
 */
module fl_bend(
  // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD, 
  // bend type as constructed from function fl_folding()
  type,
  // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  // verbs       = FL_ADD, 
  // key/value list of face sizing:
  // key    = one of the eight cartesian semi axes (+X=[1,0,0], -Z=[0,0,1])
  // value  = 3d size [x-size,y-size,z-size]
  // Missing faces means 0-sized.
  // faces,
  // when true children 3d surface is not bent
  flat=false,
  // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,            
  // when undef native positioning is used
  octant                
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(type!=undef);

  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  sheet       = fl_bend_sheet(type);
  flat_bbox   = fl_bb_corners(sheet);
  fcs         = fl_bend_faceSet(type);
  bent_bbox   = fl_bb_corners(type);
  // this API has two modes of operation:
  //  - as a 3d object when bent (the default)
  //  - as a 2d object when unfolded (flat=true)
  // use the correct bounding box when calculating the position matrix
  bbox        = flat ? flat_bbox : bent_bbox;
  size        = bbox[1]-bbox[0];
  material    = fl_material(type);

  D = direction ? fl_direction(proto=type,direction=direction)  : I;
  M = octant    ? fl_octant(octant=octant,bbox=bbox) : I;

  module do_add() {
    fl_color(material)
      do_bend() 
        children();
  }

  module always(face,translate) {
    $sheet  = sheet;
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
    // translate on -Z when NOT FLAT so the resulting volume is 
    // coherent with the bent bounding box
    translate(+Z(flat?0:-flat_bbox[1].z))
    intersection() {
      fl_place(bbox=flat_bbox,octant=+X+Y+Z)
        children();
      translate(translate)
        fl_cube(size=face,octant=+X+Y+Z);
    } 
  }

  module do_bend() {
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
          // translate([0,f.z])
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

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_add() children();

      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_bb_add(bbox);

      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=1.2*size);
  }

}
