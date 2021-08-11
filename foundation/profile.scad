/*
 * OpenSCAD Foundation Library profile PRIMITIVES.
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
use <2d.scad>
use <3d.scad>

$fn       = 50;           // [3:50]
$FL_TRACE  = false;
$FL_RENDER = false;
$FL_DEBUG  = false;

ADD       = true;
AXES      = false;
BBOX      = false;
// PLOAD is unsupported
PLOAD     = false;
FPRINT    = false;

FILAMENT_COLOR  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Commons] */
// thickness 
T         = 2.5;
// Type
TYPE      = "Pofile";     // ["Profile", "Bent sheet"]
SIZE      = [150,40,200]; // [1:0.1:100] 
// radius in case of rounded angles (square if 0)
RADIUS    = 1.1;

/* [Profiles] */
// Profile types
PR_TYPE   = "L"; // ["E", "L", "T", "U"]

/* [Folded plates] */
// Bent sheet types
BS_TYPE     = "L"; // ["L", "U"]

/* [Hidden] */

module __test__() {
  verbs=[
    if (ADD)    FL_ADD,
    if (AXES)   FL_AXES,
    if (BBOX)   FL_BBOX,
    if (FPRINT) FL_FOOTPRINT,
    if (PLOAD)  FL_PAYLOAD,
  ];
  radius  = RADIUS!=0 ? RADIUS : undef;

  fl_placeIf(!PLACE_NATIVE,octant=OCTANT,size=SIZE)
    if (TYPE=="Profile")
      profile(verbs,type=PR_TYPE,size=SIZE,thick=T,radius=radius,material=FILAMENT_COLOR);
    else
      bent_sheet(verbs,type=BS_TYPE,size=SIZE,thick=T,radius=radius,material=FILAMENT_COLOR);
}

// engine for generating profiles
module profile(
  verbs     = FL_ADD,
  preset,             // preset profiles
  type,               // "E","L","T" and "U"
  radius,             // external radius (square if undef)
  size,
  material,           // actually a color
  thick,
  fl_axes = false
) {
  assert(size!=undef);
  assert(thick!=undef);
  assert((radius == undef) || (2*radius<thick));
  assert(is_string(type) && len(type)==1 && search(type,"ELTU")!=[]);

  r       = radius == undef ? 0 : radius;
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
    fl_color(material) 
      translate([0,-size.y/2,-size.z/2])
        linear_extrude(size.z)
          if (r==0)
            polygon(points);
          else minkowski() {
            polygon(points);
            circle(r=radius);
          }
  }

  module do_bb() {
    %cube(size=size, center=true);
  }

  fl_parse(verbs)  {
    if ($verb==FL_ADD) {
      do_add();
      if (fl_axes)
        fl_axes(size=size);
    } else if ($verb==FL_BBOX) {
      do_bb();
    } else if ($verb==FL_AXES) {
      fl_axes(size=size);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

// engine for generating profiles
module bent_sheet(
  verbs     = FL_ADD,
  preset,             // preset profiles
  type,               // "L" or "U"
  radius,             // fold internal radius (square if undef)
  size,               // dimensioni del profilato [w,h,d]. Uno scalare s indica [s,s,s]
  material,           // actually a color
  thick,              // sheet thickness
  fl_axes      = false
) {
  assert(size!=undef);
  assert(thick!=undef);

  r   = radius == undef ? 0 : radius;
  R   = r+thick;
  sz  = is_list(size) ? size : [size,size,size];
  assert(R<=sz.y,str("resulting external radius (",R,") exceeds FL_Y dimension (",sz.y,")!"));
  assert(R<=sz.x,str("resulting external radius (",R,") exceeds FL_X dimension (",sz.x,")!"));
  fl_trace("R",R);
  fl_trace("sz",sz);

  module L(sz,footprint) {
    multmatrix(fl_T(-sz/2+[R,R,0])) {
      linear_extrude(height = sz.z) {
        // FL_Y segment or square when footprint
        let(
          segment = [thick,sz.y-R],
          square  = [sz.x,sz.y-R],
          size    = footprint ? square : segment,
          trans   = [size.x/2-R, size.y/2]
        ) translate(trans)
          square(size=size,center=true);
        // arc or sector when footprint
        if (footprint)
          fl_sector(R,[-90,-180]);
        else
          fl_arc(r,[-90,-180],thick);
        // FL_X segment or square when footprint
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
      else 
        assert(false,str("Unsupported type '",type,"'"));
  }

  fl_parse(verbs)  {
    if ($verb==FL_ADD) {
      do_add();
      if (fl_axes)
        fl_axes(size=size);
    } else if ($verb==FL_BBOX) {
      %fl_cube(size=size, center=true);
    } else if ($verb==FL_FOOTPRINT) {
      do_add(footprint=true);
    } else if ($verb==FL_AXES) {
      fl_axes(size=size);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

__test__();
