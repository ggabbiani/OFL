/*!
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../ext/Round-Anything/polyround.scad>
include <3d-engine.scad>
include <label.scad>

//! engine for generating profiles
module fl_profile(
  //! supported verbs : FL_ADD,FL_AXES,FL_BBOX]
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
  assert(thick!=undef);
  assert((radius == undef) || (2*radius<thick));
  assert(is_string(type) && len(type)==1 && search(type,"ELTU")!=[]);

  bbox  = assert(size) [-size/2,+size/2];
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

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD)
      fl_modifier($modifier)
        fl_color(material)
          do_add();

    else if ($verb==FL_AXES)
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction);

    else if ($verb==FL_BBOX)
      fl_modifier($modifier) cube(size=size, center=true);

    else
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));

  }
}

/*!
 * Engine for generating bent plates.
 *
 * See also https://metalfabricationsvcs.com/products/bent-plate/
 */
module fl_bentPlate(
  //! supported verbs : FL_ADD,FL_AXES,FL_BBOX]
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
  direction
) {
  bbox  = assert(size) [-size/2,+size/2];
  D     = direction ? fl_direction(direction) : I;
  M     = fl_octant(octant,bbox=bbox);
  r     = radius ? radius : 0;
  R     = assert(thick) r+thick;
  sz    = is_list(size) ? size : [size,size,size];
  radii = type=="L" ? [
    [bbox[0].x,       bbox[1].y,        0 ],  // 0
    [bbox[0].x,       bbox[0].y,        R ],  // 1
    [bbox[1].x,       bbox[0].y,        0 ],  // 2
    [bbox[1].x,       bbox[0].y+thick,  0 ],  // 3
    [bbox[0].x+thick, bbox[0].y+thick,  0 ],  // 4
    [bbox[0].x+thick, bbox[1].y,0        ],   // 5
  ] : type=="U" ? [
    [bbox[0].x,       bbox[1].y,        0 ],  // 0
    [bbox[0].x,       bbox[0].y,        R ],  // 1
    [bbox[1].x,       bbox[0].y,        R ],  // 2
    [bbox[1].x,       bbox[1].y,        0 ],  // 3
    [bbox[1].x-thick, bbox[1].y,        0 ],  // 4
    [bbox[1].x-thick, bbox[0].y+thick,  0 ],  // 5
    [bbox[0].x+thick, bbox[0].y+thick,  0 ],  // 6
    [bbox[0].x+thick, bbox[1].y,        0 ],  // 7
  ] : assert(false,str("Unsupported bent plate type '",type,"'. Please choose one of the following: L,U")) undef;

  assert(R<=sz.y,str("resulting external radius (",R,") exceeds FL_Y dimension (",sz.y,")!"));
  assert(R<=sz.x,str("resulting external radius (",R,") exceeds FL_X dimension (",sz.x,")!"));

  module do_add() {
    debug_enabled = fl_dbg_symbols() || fl_dbg_labels();
    debug_sz      = debug_enabled ? fl_2d_closest(radii)/3 : undef;

    if (debug_enabled)
      #polygon(polyRound(radii,fn=$fn));
    else
      fl_color(material)
        translate(-Z(sz.z/2))
          linear_extrude(height=sz.z)
            polygon(polyRound(radii,fn=$fn));

    if (fl_dbg_symbols())
      for(p=radii)
        fl_sym_point(point=[p.x,p.y,0], size=debug_sz,$FL_ADD="ON");

    if (fl_dbg_labels())
      for(i=[0:len(radii)-1])
        let(p=radii[i]) translate([p.x,p.y,0.5])
          fl_label(string=str("P[",i,"]"),fg="black",size=debug_sz,$FL_ADD="ON");
  }

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD)
      fl_modifier($modifier)
        do_add();

    else if ($verb==FL_AXES)
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction);

    else if ($verb==FL_BBOX)
      fl_modifier($modifier)
        fl_cube(size=size, octant=O);

    else
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
  }
}
