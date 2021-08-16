/*
 * Created on Thu Jul 08 2021.
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

$fn         = 50;           // [3:100]
$FL_TRACE   = false;
$FL_RENDER  = false;
$FL_DEBUG   = false;

/* [Placement] */

PLACE_NATIVE  = true;
QUADRANT      = [+1,+1];  // [-1:+1]

/* [2D primitives] */
PRIMITIVE   = "arc";  // ["arc", "circle",  "inscribed polygon", "sector"]
RADIUS      = 10;
// arc/sector specific
START_ANGLE = 0;    // [0:360]
END_ANGLE   = 60;   // [0:360]
// arc thickness
T = 1;

/* [Polygon inscribed a circle] */
// Edge number
N       = 3;
// Adds a circumscribed circle
CIRCLE  = false;

/* [Hidden] */

// function fl_arc_bbox(
//   radius  // internal radius
//   ,angles // start and stop angles
//   ,width  // added to radius defines the external radius
// ) = 

module __test__() {
  angles  = [START_ANGLE,END_ANGLE];
  // bbox    = PRIMITIVE == "arc" ? fl_arc_bbox(RADIUS,angles,T)
  //         : PRIMITIVE == "circle" ? fl_circle_bbox(RADIUS)
  //         : PRIMITIVE == "inscribed polygon" ? fl_ipolygon_bbox(RADIUS,n=N)
  //         : PRIMITIVE == "sector" ? fl_sector_bbox(RADIUS,angles)
  //         : undef;
  // assert(bbox!=undef,str("Unknown '",PRIMITIVE,"' primitive"));

  if      (PRIMITIVE == "arc"               )   fl_arc(RADIUS,angles,T);
  else if (PRIMITIVE == "circle"            )   fl_circle(RADIUS);
  else if (PRIMITIVE == "inscribed polygon" ) { fl_ipolygon(RADIUS,n=N);if (CIRCLE) %fl_circle(RADIUS); }
  else if (PRIMITIVE == "sector"            )   fl_sector(RADIUS,angles,PLACE_NATIVE?undef:QUADRANT);
}

function old_fl_sector(
  radius
  ,angles   // start|end angles in whatever order
) = assert($fn>2)
let(
  delta     = 360 / $fn,
  sorted    = [min(angles),max(angles)],
  distance  = sorted[1]-sorted[0],
  o         = [if (distance < 360) [0, 0] ],          // origin NOT included when distance ≥ 360°
  range     = distance < 360 ? distance : 360-delta,  // range equal to distance minus last value when distance ≥ 360°
  canonic   = [sorted[0],sorted[0]+range],
  last      = [if (!fl_isMultiple(range,delta)) [radius * cos(canonic[1]), radius * sin(canonic[1])] ],
  what      = [for(a = [canonic[0] : delta : canonic[1]]) a],
  mid       = [for(a = what) [radius * cos(a), radius * sin(a)]],
  points    = concat(o,mid,last)
) 
  // echo($fn=$fn)
  // echo(delta=delta)
  // echo(angles=angles)
  // echo(sorted=sorted)
  // echo(range=range)
  // echo(canonic=canonic)
  // echo(o=o)  
  // echo(last=last)
  // echo(what=what)
  // echo(points=points)
  points;

function fl_sector(
  radius
  ,angles   // start|end angles in whatever order
) = assert($fn>2)
let(
  delta     = 360 / $fn,
  distance  = angles[1]-angles[0],
  o         = [if (abs(distance) < 360) [0, 0] ],          // origin NOT included when distance ≥ 360°
  range     = abs(distance) < 360 ? distance : 360-delta,  // range equal to distance minus last value when distance ≥ 360°
  canonic   = [angles[0],angles[0]+range],
  last      = [if (!fl_isMultiple(range,delta)) [radius * cos(canonic[1]), radius * sin(canonic[1])] ],
  what      = distance>0 ? [for(a = [canonic[0] : delta : canonic[1]]) a] : [for(a = [canonic[0] : -delta : canonic[1]]) a],
  mid       = [for(a = what) [radius * cos(a), radius * sin(a)]],
  points    = concat(o,mid,last)
) 
  // echo($fn=$fn)
  echo(delta=delta)
  // echo(angles=angles)
  // echo(sorted=sorted)
  echo(distance=distance)
  echo(range=range)
  // echo(canonic=canonic)
  // echo(o=o)  
  // echo(last=last)
  echo(what=what)
  echo(points=points)
  points;

function fl_circle(radius) = fl_sector(radius,[0,360]);

module fl_sector(radius, angles, quadrant) {
  function bbox() = let(
    sorted  = [min(angles),max(angles)],
    points  = [
      let(a=angles[0]) [cos(a),sin(a)],
      let(a=angles[1]) [cos(a),sin(a)],
      for(a=[0:90:270]) if (a>angles[0] && a<angles[1]) [cos(a),sin(a)]
    ],
    x = [for(p=points) p.x],
    y = [for(p=points) p.y]
  ) [[min(x)*radius,min(y)*radius],[max(x)*radius,max(y)*radius]];
  fl_trace("points",bbox());
  M = quadrant!=undef ? fl_quadrant(quadrant=quadrant,bbox=bbox()) : FL_I;
  multmatrix(M)
  polygon(fl_sector(radius,angles));
}

module fl_circle(radius) {
  polygon(fl_circle(radius));
}

module fl_arc(
  radius  // internal radius
  ,angles // start and stop angles
  ,width  // added to radius defines the external radius
  ) {
  difference() {
    fl_sector(radius + width, angles);
    fl_sector(radius, angles);
  }
} 

// Regular polygon inscribed a circonference
module fl_ipolygon(
  r   // circumscribed circle radius
  ,d  // circumscribed circle diameter
  ,n  // number of edges
) {
  assert(!(r!=undef && d!=undef));
  radius = r != undef ? r : d/2;
  fl_circle(r,$fn=n);
}

__test__();