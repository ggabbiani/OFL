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

include <defs.scad>
include <unsafe_defs.scad>

use     <2d.scad>
use     <3d.scad>
use     <placement.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Supported verbs] */

// adds shapes to scene.
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
FPRINT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [+1,+1,+1];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Commons] */

// thickness 
T         = 2.5;
// Type
TYPE    = "Profile";     // ["Profile", "Bent plate"]
SIZE    = [150,40,200]; // [1:0.1:100] 
// radius in case of rounded angles (square if 0)
RADIUS  = 1.1;
SECTION = "L"; // ["E", "L", "T", "U"]

/* [Hidden] */

module __test__() {
  direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
  octant    = PLACE_NATIVE  ? undef : OCTANT;
  verbs=[
    if (ADD!="OFF")     FL_ADD,
    if (AXES!="OFF")    FL_AXES,
    if (BBOX!="OFF")    FL_BBOX,
    if (FPRINT!="OFF")  FL_FOOTPRINT,
  ];
  radius  = RADIUS!=0 ? RADIUS : undef;
  fl_trace("TYPE",TYPE);

  $FL_ADD=ADD;$FL_AXES=AXES;$FL_BBOX=BBOX;$FL_FOOTPRINT=FPRINT;
  if (TYPE=="Profile")
    fl_profile(verbs,type=SECTION,size=SIZE,thick=T,radius=radius,material=FILAMENT,octant=octant,direction=direction);
  else
    fl_bentPlate(verbs,type=SECTION,size=SIZE,thick=T,radius=radius,material=FILAMENT,octant=octant,direction=direction);
}

// engine for generating profiles
// default octant     : O
// default direction  : [+Z,+X]
module fl_profile(
  verbs     = FL_ADD,
  preset,     // preset profiles
  type,       // "E","L","T" and "U"
  radius,     // external radius (square if undef)
  size,
  material,   // actually a color
  thick,
  direction,  // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant      // when undef native positioning is used
) {
  assert(size!=undef);
  assert(thick!=undef);
  assert((radius == undef) || (2*radius<thick));
  assert(is_string(type) && len(type)==1 && search(type,"ELTU")!=[]);

  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);
  bbox  = [-size/2,+size/2];
  D     = direction ? fl_direction(direction=direction,default=[+Z,+X]) : I;
  M     = octant    ? fl_octant(octant=octant,bbox=bbox)                : I;

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

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) fl_color(material) do_add();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) cube(size=size, center=true);
      } else if ($verb==FL_FOOTPRINT) {
        fl_modifier($FL_FOOTPRINT)
          fl_color(material) do_footprint();
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=size);
  }
}

// engine for generating bent plates
// See also https://metalfabricationsvcs.com/products/bent-plate/
// default octant     : O
// default direction  : [+Z,+X]
module fl_bentPlate(
  verbs     = FL_ADD,
  preset,             // preset profiles
  type,               // "L" or "U"
  radius,             // fold internal radius (square if undef)
  size,               // dimensioni del profilato [w,h,d]. Uno scalare s indica [s,s,s]
  material,           // actually a color
  thick,              // sheet thickness
  direction,  // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant      // when undef native positioning is used
) {
  assert(size!=undef);
  assert(thick!=undef);

  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);
  bbox  = [-size/2,+size/2];
  D     = direction ? fl_direction(direction=direction,default=[+Z,+X]) : I;
  M     = octant    ? fl_octant(octant=octant,bbox=bbox)                : I;

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
          fl_sector(radius=R,angles=[-90,-180]);
        else
          fl_arc(radius=r,angles=[-90,-180],width=thick);
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

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_add();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_cube(size=size, octant=FL_O);
      } else if ($verb==FL_FOOTPRINT) {
        fl_modifier($FL_FOOTPRINT) do_add(footprint=true);
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=size);
  }
}

__test__();
