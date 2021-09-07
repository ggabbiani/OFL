/*
 * 2d primitives for OpenSCAD.
 *
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

include <shape_pie.scad> // dotSCAD

include <defs.scad>
use <placement.scad>

$fn         = 50;           // [3:100]
$FL_TRACE   = false;
$FL_RENDER  = false;
$FL_DEBUG   = false;

/* [Supported verbs] */

ADD   = true;
AXES  = false;
BBOX  = false;

/* [Placement] */

PLACE_NATIVE  = true;
QUADRANT      = [+1,+1];  // [-1:+1]

/* [2D primitives] */

PRIMITIVE     = "arc";  // ["arc", "circle",  "inscribed polygon", "sector"]
RADIUS        = 10;
// arc/sector specific
START_ANGLE   = 0;    // [-720:0.1:720]
END_ANGLE     = 60;   // [-720:0.1:720]
// arc thickness
ARC_T         = 1;
// Inscribed polygon edge number
IPOLY_N       = 3;  // [3:50]
// Show a circumscribed circle to inscribed polygon
IPOLY_CIRCLE  = false;

/* [Hidden] */

// echo($vpr=$vpr);
// echo($vpt=$vpt);
// echo($vpd=$vpd);
// echo($vpf=$vpf);

$vpr  = [0, 0, 0];
$vpt  = [0, 0, 0];
$vpd  = 140;
$vpf  = 22.5;

module __test__() {
  angles  = [START_ANGLE,END_ANGLE];
  verbs   = [
    if (ADD)  FL_ADD,
    if (AXES) FL_AXES
  ];
  quadrant  = PLACE_NATIVE ? undef : QUADRANT;

  module sector() {
    fl_sector(verbs,RADIUS,angles,quadrant=quadrant);
    if (BBOX)
      %fl_sector(FL_BBOX,RADIUS,angles,quadrant=quadrant);
  }

  module circle() {
    fl_circle(verbs,RADIUS,quadrant=quadrant);
    if (BBOX)
      %fl_circle(FL_BBOX,RADIUS,quadrant=quadrant);
  }

  module arc() {
    fl_arc(verbs,RADIUS,angles,ARC_T,quadrant=quadrant);
    if (BBOX)
      %fl_arc(FL_BBOX,RADIUS,angles,ARC_T,quadrant=quadrant);
  }

  module ipoly() {
    fl_ipoly(verbs,RADIUS,n=IPOLY_N,quadrant=quadrant);
    if (BBOX)
      %fl_ipoly(FL_BBOX,RADIUS,n=IPOLY_N,quadrant=quadrant);
    if (IPOLY_CIRCLE)
      fl_placeIf(!PLACE_NATIVE,quadrant=QUADRANT,bbox=fl_bb_ipoly(RADIUS,IPOLY_N)) #fl_circle(FL_ADD,RADIUS);
  }

  if      (PRIMITIVE == "arc"               ) arc();
  else if (PRIMITIVE == "circle"            ) circle();
  else if (PRIMITIVE == "inscribed polygon" ) ipoly();
  else if (PRIMITIVE == "sector"            ) sector();
}

//**** 2d bounding box calculations *******************************************

// return polygon bounding box
function fl_bb_polygon(points) = let(
  x = [for(p=points) p.x],
  y = [for(p=points) p.y]
) [[min(x),min(y)],[max(x),max(y)]];

function p(alpha) = [cos(alpha),sin(alpha)];

// return sector bounding box
function fl_bb_sector(
  radius
  ,angles
) = let(
  interval  = __normalize__(angles),
  inf       = interval[0],
  sup       = interval[1],
  start     = ceil(inf / 90),  // 0 <= start <= 3
  pts = [
    if ((sup-inf)<360) [0,0],
    if (inf%90!=0) let(alpha=inf)                           radius*p(alpha),
    for(i=[start:start+3]) let(alpha=i*90) if (alpha<=sup)  radius*p(alpha),
    if (sup%90!=0) let(alpha=sup)                           radius*p(alpha)
  ]
) fl_bb_polygon(pts);

// return the circle bounding box
function fl_bb_circle(radius)           = [[-radius,-radius],[+radius,+radius]];

// return the inscribed polygon bounding box
function fl_bb_ipoly(radius,n)          = fl_bb_polygon(fl_circle(radius,$fn=n));

// return arc bounding box
function fl_bb_arc(radius,angles,width) =
assert(is_num(radius),str("«radius» must be a number (",radius,")"))
assert(is_list(angles))
assert(is_num(width))
let(
  interval  = __normalize__(angles),
  inf       = interval[0],
  sup       = interval[1],
  start     = ceil(inf / 90),  // 0 <= start <= 3
  RADIUS    = radius+width,
  pts = [
    // internal sector
    if (inf%90!=0) let(alpha=inf)                           radius*p(alpha),
    for(i=[start:start+3]) let(alpha=i*90) if (alpha<=sup)  radius*p(alpha),
    if (sup%90!=0) let(alpha=sup)                           radius*p(alpha),
    // external sector
    if (inf%90!=0) let(alpha=inf)                           RADIUS*p(alpha),
    for(i=[start:start+3]) let(alpha=i*90) if (alpha<=sup)  RADIUS*p(alpha),
    if (sup%90!=0) let(alpha=sup)                           RADIUS*p(alpha)
  ]
) fl_bb_polygon(pts);

//**** sector *****************************************************************

// reduces an angular interval in the form [inf,sup] with:
// sup ≥ inf
// distance = sup - inf
//    0° ≤ distance ≤ +360°
//    0° ≤   inf    < +360°
//    0° ≤   sup    < +720°
function __normalize__(angles) = 
assert(is_list(angles),str("angles=",angles))
let(
  sorted    = [min(angles),max(angles)],
  d         = sorted[1] - sorted[0],          // d ≥ 0°
  distance  = d>360 ? 360 : d,                // 0° ≤ distance ≤ +360°
  inf       = (sorted[0] % 360 + 360) % 360   // 0° ≤   inf    < +360°
)
assert(d>=0)
assert(distance>=0 && distance<=360)
assert(inf>=0 && inf<360)
[inf,inf+distance];

function fl_sector(
  radius
  ,angles   // start|end angles in whatever order
) = 
assert($fn>2) 
assert(is_num(radius),str("radius=",radius))
assert(is_list(angles),str("angles=",angles))
shape_pie(radius,__normalize__(angles));

module fl_sector(verbs=FL_ADD,radius, angles, quadrant, axes=false) {
  assert(is_num(radius),str("radius=",radius));
  assert(is_list(angles),str("angles=",angles));
  points  = fl_sector(radius,angles);
  bbox    = fl_bb_sector(radius,angles);
  size    = bbox[1] - bbox[0];
  M       = quadrant!=undef ? fl_quadrant(quadrant=quadrant,bbox=bbox) : FL_I;
  fl_trace("radius",radius);
  fl_trace("points",points);
  fl_trace("bbox",bbox);
  fl_trace("size",size);
  fl_trace("axes",axes);

  fl_parse(verbs) {
    if ($verb==FL_ADD) {
      multmatrix(M) polygon(points);
      if (axes)
        fl_axes(size=size);
    } else if ($verb==FL_BBOX) {
      multmatrix(M) translate(bbox[0]) square(size=size, center=false);
    } else if ($verb==FL_AXES) {
      fl_axes(size=size);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

//**** circle *****************************************************************

function fl_circle(radius) = fl_sector(radius,[0,360]);

module fl_circle(verbs,radius,quadrant,axes=false) {
  bbox  = fl_bb_circle(radius);
  size  = bbox[1] - bbox[0];
  M     = quadrant!=undef ? fl_quadrant(quadrant=quadrant,bbox=bbox) : FL_I;
  fl_trace("quadrant",quadrant);
  fl_trace("M",M);
  fl_trace("bbox",bbox);
  fl_trace("axes",axes);

  fl_parse(verbs) {
    if ($verb==FL_ADD) {
      multmatrix(M) polygon(fl_circle(radius));
      if (axes)
        fl_axes(size=size);
    } else if ($verb==FL_BBOX) {
      multmatrix(M) translate(bbox[0]) square(size=size, center=false);
    } else if ($verb==FL_AXES) {
      fl_axes(size=size);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

//**** arc ********************************************************************

module fl_arc(
  verbs   = FL_ADD
  ,radius // internal radius
  ,angles // start and stop angles
  ,width  // added to radius defines the external radius
  ,quadrant
  ,axes=false
  ) {
  assert(is_list(verbs)||is_string(verbs));
  assert(is_num(radius));
  assert(is_list(angles));
  assert(is_num(width));

  bbox  = fl_bb_arc(radius,angles,width);
  size  = bbox[1] - bbox[0];
  M     = quadrant!=undef ? fl_quadrant(quadrant=quadrant,bbox=bbox) : FL_I;

  fl_parse(verbs) {
    if ($verb==FL_ADD) {
      multmatrix(M)
        difference() {
          fl_sector(verbs=$verb, radius=radius + width,angles=angles);
          fl_sector(verbs=$verb, radius=radius, angles=angles);
        }
      if (axes)
        fl_axes(size=size);
    } else if ($verb==FL_BBOX) {
      multmatrix(M) translate(bbox[0]) square(size=size, center=false);
    } else if ($verb==FL_AXES) {
      fl_axes(size=size);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
} 

//**** inscribed polygon ******************************************************

// Regular polygon inscribed a circonference
module fl_ipoly(
  verbs   = FL_ADD
  ,r  // circumscribed circle radius
  ,d  // circumscribed circle diameter
  ,n  // number of edges
  ,quadrant
  ,axes=false
) {
  assert(fl_XOR(r!=undef,d!=undef));
  radius  = r!=undef ? r : d/2;
  points  = fl_circle(radius,$fn=n);

  bbox    = fl_bb_polygon(points);
  size    = bbox[1] - bbox[0];
  M       = quadrant!=undef ? fl_quadrant(quadrant=quadrant,bbox=bbox) : FL_I;
  fl_trace("bbox",bbox);
  fl_trace("axes",axes);

  fl_parse(verbs) {
    if ($verb==FL_ADD) {
      multmatrix(M) polygon(points);
      if (axes)
        fl_axes(size=size);
    } else if ($verb==FL_BBOX) {
      multmatrix(M) translate(bbox[0]) square(size=size, center=false);
    } else if ($verb==FL_AXES) {
      fl_axes(size=size);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

__test__();