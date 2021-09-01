/*
 * 2d.scad  : 2d primitives for OpenSCAD.
 * Created  : on Thu Jul 08 2021
 * Copyright: © 2021 Giampiero Gabbiani
 * Email    : giampiero@gabbiani.org
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
include <shape_pie.scad>

$fn         = 50;           // [3:100]
$FL_TRACE   = false;
$FL_RENDER  = false;
$FL_DEBUG   = false;

/* [Verbs] */
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
// Adds a circumscribed circle to inscribed polygon
IPOLY_CIRCLE  = false;

/* [Hidden] */

// $vpr=[0, 0, 0];
// $vpt=[0.00465057, -0.00132873, 0];
// $vpd=5.292;
// $vpf=22.5;

module __test__() {
  angles  = [START_ANGLE,END_ANGLE];
  verbs   = [
    if (ADD)  FL_ADD,
    if (AXES) FL_AXES
  ];

  module sector() {
    fl_sector(verbs,RADIUS,angles,PLACE_NATIVE ? undef : QUADRANT);
    if (BBOX)
      #fl_sector(FL_BBOX,RADIUS,angles,PLACE_NATIVE ? undef : QUADRANT);
  }

  module circle() {
    fl_circle(verbs,RADIUS,PLACE_NATIVE ? undef : QUADRANT);
    if (BBOX)
      #fl_circle(FL_BBOX,RADIUS,PLACE_NATIVE ? undef : QUADRANT);
  }

  module arc() {
    fl_arc(verbs,RADIUS,angles,ARC_T,PLACE_NATIVE ? undef : QUADRANT);
    if (BBOX)
      #fl_arc(FL_BBOX,RADIUS,angles,ARC_T,PLACE_NATIVE ? undef : QUADRANT);
  }

  module ipolygon() {
    fl_ipolygon(verbs,RADIUS,n=IPOLY_N,quadrant=PLACE_NATIVE ? undef : QUADRANT);
    if (BBOX)
      #fl_ipolygon(FL_BBOX,RADIUS,n=IPOLY_N,quadrant=PLACE_NATIVE ? undef : QUADRANT);
    fl_placeIf(!PLACE_NATIVE,quadrant=QUADRANT,bbox=fl_bb_polygon(fl_circle(RADIUS,$fn=IPOLY_N)))
      if (IPOLY_CIRCLE) %fl_circle(FL_ADD,RADIUS);
  }

  if      (PRIMITIVE == "arc"               ) arc();
  else if (PRIMITIVE == "circle"            ) circle();
  else if (PRIMITIVE == "inscribed polygon" ) ipolygon();
  else if (PRIMITIVE == "sector"            ) sector();
}

// return the polygon bounding box
function fl_bb_polygon(points) = let(
  x = [for(p=points) p.x],
  y = [for(p=points) p.y]
) [[min(x),min(y)],[max(x),max(y)]];

function fl_sector(
  radius
  ,angles   // start|end angles in whatever order
) = assert($fn>2) let(
  sorted    = [min(angles),max(angles)],
  distance  = sorted[1] - sorted[0],
  turn      = abs(distance) >= 360,
  a         = turn ? [0,360] : [sorted[0],sorted[0]+distance%360]
) shape_pie(radius,a);

module fl_sector(verbs=FL_ADD,radius, angles, quadrant, axes=false) {
  points  = fl_sector(radius,angles);
  bbox    = fl_bb_polygon(points);
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

function fl_circle(radius) = fl_sector(radius,[0,360]);

module fl_circle(verbs,radius,quadrant,axes=false) {
  bbox  = [[-radius,-radius],[+radius,+radius]];
  size  = bbox[1] - bbox[0];
  M     = quadrant!=undef ? fl_quadrant(quadrant=quadrant,bbox=bbox) : FL_I;
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

module fl_arc(
  verbs   = FL_ADD
  ,radius // internal radius
  ,angles // start and stop angles
  ,width  // added to radius defines the external radius
  ,quadrant
  ,axes=false
  ) {
  
  bbox  = fl_bb_sector(radius+width,angles);
  size  = bbox[1] - bbox[0];
  M     = quadrant!=undef ? fl_quadrant(quadrant=quadrant,bbox=bbox) : FL_I;

  fl_parse(verbs) {
    if ($verb==FL_ADD) {
      multmatrix(M)
        difference() {
          fl_sector(verbs=verbs, radius=radius + width,angles=angles);
          fl_sector(verbs=verbs, radius=radius, angles=angles);
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

// Regular polygon inscribed a circonference
module fl_ipolygon(
  verbs   = FL_ADD
  ,r  // circumscribed circle radius
  ,d  // circumscribed circle diameter
  ,n  // number of edges
  ,quadrant
  ,axes=false
) {
  assert(!(r!=undef && d!=undef));
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