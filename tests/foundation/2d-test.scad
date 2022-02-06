/*
 * 2D foundation primitives tests.
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

include <../../foundation/2d.scad>

$fn         = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
QUADRANT      = [+1,+1];  // [-1:+1]

/* [2D primitives] */

PRIMITIVE     = "circle arc";  // ["circle", "circle arc", "circle sector", "circle annulus", "ellipse", "elliptic arc", "elliptic sector", "elliptic annulus", "frame", "inscribed polygon", "square"]
RADIUS        = 10;
// ellipse horiz. semi axis
A             = 10;
// ellipse vert. semi axis
B             = 6;
// arc/sector specific
START_ANGLE   = 0;    // [-360:360]
END_ANGLE     = 60;   // [-360:360]
// arc thickness
ARC_T         = 1;  // [0:10]
// Inscribed polygon edge number
IPOLY_N       = 3;  // [3:50]
// Show a circumscribed circle to inscribed polygon
IPOLY_CIRCLE  = true;
SQUARE_SIZE   = [40,30];

/* [Hidden] */

// echo($vpr=$vpr);
// echo($vpt=$vpt);
// echo($vpd=$vpd);
// echo($vpf=$vpf);

$vpr  = [0, 0, 0];
$vpt  = [0, 0, 0];
$vpd  = 140;
$vpf  = 22.5;

angles  = [START_ANGLE,END_ANGLE];
verbs=[
  if ($FL_ADD!="OFF")   FL_ADD,
  if ($FL_AXES!="OFF")  FL_AXES,
  if ($FL_BBOX!="OFF")  FL_BBOX,
];
quadrant  = PLACE_NATIVE ? undef : QUADRANT;

module ipoly() {
  fl_ipoly(verbs,RADIUS,n=IPOLY_N,quadrant=quadrant);
  if (IPOLY_CIRCLE)
    fl_2d_placeIf(!PLACE_NATIVE,quadrant=QUADRANT,bbox=fl_bb_ipoly(r=RADIUS,n=IPOLY_N)) #fl_circle(FL_ADD,r=RADIUS);
}

if      (PRIMITIVE == "circle"            ) fl_circle(verbs,r=RADIUS,quadrant=quadrant);
else if (PRIMITIVE == "circle arc"        ) fl_arc(verbs,r=RADIUS,angles=angles,thick=ARC_T,quadrant=quadrant);
else if (PRIMITIVE == "circle sector"     ) fl_sector(verbs,r=RADIUS,angles=angles,quadrant=quadrant);
else if (PRIMITIVE == "circle annulus"    ) fl_annulus(verbs,r=RADIUS,thick=ARC_T,quadrant=quadrant);
else if (PRIMITIVE == "ellipse"           ) fl_ellipse(verbs,[A,B],quadrant=quadrant);
else if (PRIMITIVE == "elliptic arc"      ) fl_ellipticArc(verbs,[A,B],angles,ARC_T,quadrant=quadrant);
else if (PRIMITIVE == "elliptic sector"   ) fl_ellipticSector(verbs,[A,B],angles,quadrant=quadrant);
else if (PRIMITIVE == "elliptic annulus"  ) fl_ellipticAnnulus(verbs,[A,B],ARC_T,quadrant=quadrant);
else if (PRIMITIVE == "frame"             ) fl_2d_frame(verbs,size=SQUARE_SIZE,thick=ARC_T,quadrant=quadrant);
else if (PRIMITIVE == "inscribed polygon" ) ipoly();
else if (PRIMITIVE == "square"            ) fl_square(verbs,size=SQUARE_SIZE,quadrant=quadrant);
