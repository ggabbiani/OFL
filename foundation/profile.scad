/*!
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <3d.scad>
include <mngm.scad>

//! engine for generating profiles
module fl_profile(
  verbs     = FL_ADD,
  //! "E","L","T" and "U"
  type,
  //! external radius (square if undef)
  radius,
  size,
  //! actually a color
  material,
  thick,
  //! desired direction [director,rotation], native direction when undef ([+X+Z])
  direction,
  //! when undef native positioning (see variable FL_O) is used
  octant
) {
  assert(size!=undef);
  assert(thick!=undef);
  assert((radius == undef) || (2*radius<thick));
  assert(is_string(type) && len(type)==1 && search(type,"ELTU")!=[]);

  bbox  = [-size/2,+size/2];
  D     = direction ? fl_direction(direction=direction,default=[+Z,+X]) : I;
  M     = fl_octant(octant,bbox=bbox);

  r     = radius ? radius : 0;
  points  = type=="E" ? [
      [-size.x/2+r,       0+r                 ],
      [+size.x/2-r,       0+r                 ],
      [+size.x/2-r,       thick-r             ],
      [-size.x/2+thick-r, thick-r             ],
      [-size.x/2+thick-r, +size.y/2-thick/2+r ],
      [+size.x/2-r,       +size.y/2-thick/2+r ],
      [+size.x/2-r,       +size.y/2+thick/2-r ],
      [-size.x/2+thick-r, +size.y/2+thick/2-r ],
      [-size.x/2+thick-r, +size.y-thick+r     ],
      [+size.x/2-r,       +size.y-thick+r     ],
      [+size.x/2-r,       +size.y-r           ],
      [-size.x/2+r,       +size.y-r           ],
  ]
  : type=="L" ? [
      [-size.x/2+r,       0+r                 ],
      [+size.x/2-r,       0+r                 ],
      [+size.x/2-r,       thick-r             ],
      [-size.x/2+thick-r, thick-r             ],
      [-size.x/2+thick-r, +size.y-r           ],
      [-size.x/2+r,       +size.y-r           ],
  ]
  : type=="T" ? [
      [-size.x/2+r,       +size.y-thick+r     ],
      [-thick/2+r,        +size.y-thick+r     ],
      [-thick/2+r,        0+r                 ],
      [+thick/2-r,        0+r                 ],
      [+thick/2-r,        +size.y-thick+r     ],
      [+size.x/2-r,       +size.y-thick+r     ],
      [+size.x/2-r,       +size.y-r           ],
      [-size.x/2+r,       +size.y-r           ],
  ]
  : /* "U" */ [
    [-size.x/2+r,         0+r                 ],
    [+size.x/2-r,         0+r                 ],
    [+size.x/2-r,         +size.y-r           ],
    [+size.x/2-thick+r,   +size.y-r           ],
    [+size.x/2-thick+r,   +thick-r            ],
    [-size.x/2+thick-r,   +thick-r            ],
    [-size.x/2+thick-r,   +size.y-r           ],
    [-size.x/2+r,         +size.y-r           ],
  ];

  module do_add() {
    translate([0,-size.y/2,-size.z/2])
      linear_extrude(size.z)
        if (r==0)
          polygon(points);
        else minkowski() {
          polygon(points);
          circle(r=radius);
        }
  }

  module do_footprint() {
    do_add();
    if (type=="E") {
      translate(X(r))
        fl_cube(size=size-2*r*[1,1,0],octant=O);
    } else if (type=="L") {
      translate(r*[1/2,1/2,0])
        fl_cube(size=size-r*[1,1,0],octant=O);
    } else if (type=="T") {
      translate(r*[0,-1/2,0])
        fl_cube(size=size-r*[0,1,0],octant=O);
    } else if (type=="U") {
      translate(r*[0,0,0])
        fl_cube(size=size-r*[2,0,0],octant=O);
    }
  }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) fl_color(material) do_add();
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) cube(size=size, center=true);
    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier)
        fl_color(material) do_footprint();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

/*!
 * engine for generating bent plates.
 *
 * See also https://metalfabricationsvcs.com/products/bent-plate/
 */
module fl_bentPlate(
  verbs     = FL_ADD,
  //! "L" or "U"
  type,
  //! fold internal radius (square if undef)
  radius,
  //! dimensioni del profilato [w,h,d]. Uno scalare s indica [s,s,s]
  size,
  //! actually a color
  material,
  //! sheet thickness
  thick,
  //! desired direction [director,rotation], native direction when undef ([+X+Z])
  direction,
  //! when undef native positioning (see variable FL_O) is used
  octant
) {
  assert(size!=undef);
  assert(thick!=undef);

  bbox  = [-size/2,+size/2];
  D     = direction ? fl_direction(direction=direction,default=[+Z,+X]) : I;
  M     = fl_octant(octant,bbox=bbox);

  r   = radius == undef ? 0 : radius;
  R   = r+thick;
  sz  = is_list(size) ? size : [size,size,size];
  assert(R<=sz.y,str("resulting external radius (",R,") exceeds FL_Y dimension (",sz.y,")!"));
  assert(R<=sz.x,str("resulting external radius (",R,") exceeds FL_X dimension (",sz.x,")!"));
  fl_trace("R",R);
  fl_trace("sz",sz);

  module L(sz,footprint) {
    multmatrix(T(-sz/2+[R,R,0])) {
      linear_extrude(height = sz.z) {
        // Y segment or square when footprint
        let(
          segment = [thick,sz.y-R],
          square  = [sz.x,sz.y-R],
          size    = footprint ? square : segment,
          trans   = [size.x/2-R, size.y/2]
        ) translate(trans)
          square(size=size,center=true);
        // arc or sector when footprint
        if (footprint)
          fl_sector(r=R,angles=[-90,-180]);
        else
          fl_arc(r=R,angles=[-90,-180],thick=thick);
        // X segment or square when footprint
        let(
          segment = [sz.x-R,thick],
          square  = [sz.x-R,sz.y],
          size    = footprint ? square : segment,
          trans   = [size.x/2, -size.y/2-(R-size.y)]
        ) translate(trans)
          square(size=size,center=true);
      }
    }
  }

  module U(size,footprint=false) {
    for(i=[-1,1])
      translate(-i*fl_X(size.x/4))
        rotate(-90*i+90,FL_Y)
          L([size.x/2,size.y,size.z],footprint);
  }

  module do_add(footprint=false) {
    fl_color(material)
      if      (type=="L") L(sz,footprint);
      else if (type=="U") U(sz,footprint);
      else assert(false,str("Unsupported bent plate type '",type,"'. Please choose one of the following: L,U"));
  }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_cube(size=size, octant=FL_O);
    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) do_add(footprint=true);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
