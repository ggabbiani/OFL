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

$fn         = 50;           // [3:50]
$FL_TRACE   = false;
$FL_RENDER  = false;
$FL_DEBUG   = false;

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

ANGLES=[START_ANGLE,END_ANGLE];

if      (PRIMITIVE == "arc"               )   fl_arc(RADIUS,ANGLES,T);
else if (PRIMITIVE == "circle"            )   fl_circle(RADIUS);
else if (PRIMITIVE == "inscribed polygon" ) { fl_ipolygon(RADIUS,n=N);if (CIRCLE) %fl_circle(RADIUS); }
else if (PRIMITIVE == "sector"            )   fl_sector(RADIUS,ANGLES);

function fl_sector(
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

function fl_circle(radius) = fl_sector(radius,[0,360]);

module fl_sector(radius, angles) {
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
