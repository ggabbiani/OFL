/*!
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../Round-Anything/polyround.scad>
include <3d-engine.scad>
include <label.scad>

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
  D     = direction ? fl_direction(direction) : I;
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

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) fl_color(material) do_add();
    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction);
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
  //! when undef native positioning (see variable FL_O) is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Z])
  direction,
  /*!
   * Debug parameter as returned from fl_parm_Debug(). Currently supported features:
   *
   * | feature    | status  |
   * | ---        | ---     |
   * | components | -       |
   * | dimensions | ✔       |
   * | labels     | ✔       |
   * | symbols    | ✔       |
   */
  debug
) {
  assert(size!=undef);
  assert(thick!=undef);

  bbox  = [-size/2,+size/2];
  D     = direction ? fl_direction(direction) : FL_I;
  M     = fl_octant(octant,bbox=bbox);

  r   = radius == undef ? 0 : radius;
  R   = r+thick;
  sz  = is_list(size) ? size : [size,size,size];
  assert(R<=sz.y,str("resulting external radius (",R,") exceeds FL_Y dimension (",sz.y,")!"));
  assert(R<=sz.x,str("resulting external radius (",R,") exceeds FL_X dimension (",sz.x,")!"));

  function L(sz,footprint) = [
      [bbox[0].x,bbox[1].y,0],                // 0
      [bbox[0].x,bbox[0].y,R],                // 1
      [bbox[1].x,bbox[0].y,0*R],              // 2
      [bbox[1].x,bbox[0].y+thick,0],          // 3
      [bbox[0].x+thick,bbox[0].y+thick,0],    // 4
      [bbox[0].x+thick,bbox[1].y,0],          // 5
    ];

  function U(size,footprint=false) = [
      [bbox[0].x,bbox[1].y,0],                // 0
      [bbox[0].x,bbox[0].y,R],                // 1
      [bbox[1].x,bbox[0].y,R],                // 2
      [bbox[1].x,bbox[1].y,0],                // 3
      [bbox[1].x-thick,bbox[1].y,0],          // 4
      [bbox[1].x-thick,bbox[0].y+thick,0],  // 5
      [bbox[0].x+thick,bbox[0].y+thick,0],    // 6
      [bbox[0].x+thick,bbox[1].y,0],          // 7
    ];

  module do_add(footprint=false) {
    radii =
      (type=="L") ? L(sz,footprint) :
      (type=="U") ? U(sz,footprint) :
      assert(false,str("Unsupported bent plate type '",type,"'. Please choose one of the following: L,U")) [];
    fl_color(material)
      translate(-Z(sz.z/2))
        linear_extrude(height = sz.z)
          polygon(polyRound(radii,fn=$fn));

    if (fl_parm_symbols(debug))
      for(p=radii)
        fl_sym_point(point=[p.x,p.y,0], size=1,$FL_ADD="ON");
    if (fl_parm_labels(debug))
      for(i=[0:len(radii)-1])
        let(p=radii[i]) translate([p.x,p.y,0.5])
          fl_label(string=str("P[",i,"]"),fg="black",size=1,$FL_ADD="ON");
  }

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();
    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction);
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_cube(size=size, octant=O);
    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) do_add(footprint=true);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
