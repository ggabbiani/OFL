/*
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
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
use     <2d.scad>
use     <3d.scad>
use     <layout.scad>
use     <placement.scad>

$fn         = 50;           // [3:100]
$fs         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

/* [Supported verbs] */

// adds shapes to scene.
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Torus] */

// Torus radius
R = 5;                // [0:+100]
// Ellipse horiz. semi axis
A = 2;                // [0:+10]
// Ellipse vert. semi axis
B = 1;                // [0:+10]

/* [Hidden] */

module __test__() {
  direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
  octant    = PLACE_NATIVE  ? undef : OCTANT;
  verbs=[
    if (ADD!="OFF")       FL_ADD,
    if (AXES!="OFF")      FL_AXES,
    if (BBOX!="OFF")      FL_BBOX,
  ];

  fl_torus(verbs,r=R,a=A,b=B,$fn=$fn,octant=octant,direction=direction,
    $FL_ADD=ADD,$FL_AXES=AXES,$FL_BBOX=BBOX);
}

module fl_torus(
  verbs       = FL_ADD, // supported verbs: FL_ADD, FL_AXES, FL_BBOX
  r           = 1,
  a,
  b,
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant                // when undef native positioning is used
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(r>=a,str("r=",r,",a=",a));
  
  // echo(n=($fn>0?($fn>=3?$fn:3):ceil(max(min(360/$fa,r*2*PI/$fs),5))),a_based=360/$fa,s_based=r*2*PI/$fs);

  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  ellipse = [a,b];
  bbox    = let(edge=a+r) [[-edge,-edge,-b],[+edge,+edge,+b]];
  size    = bbox[1]-bbox[0];
  D       = direction ? fl_direction(direction=direction,default=[+Z,+X]) : I;
  M       = octant    ? fl_octant(octant=octant,bbox=bbox)                : I;

  fn      = $fn;

  fl_trace("D",D);
  fl_trace("M",M);

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) rotate_extrude($fn=$fn) translate(X(r-a)) fl_ellipse(e=ellipse,quadrant=+X,$fn=fn);
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_bb_add(bbox);
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=size);
  }
}

__test__();
