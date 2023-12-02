/*
 * 2D foundation primitives tests.
 *
 * NOTE: this file is generated automatically from 'template-2d.scad', any
 * change will be lost.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

// **** TEST_INCLUDES *********************************************************

include <../../lib/OFL/foundation/core.scad>
use <../../lib/OFL/foundation/2d-engine.scad>

// **** TAB_PARAMETERS ********************************************************

$fn            = 50;           // [3:100]
// When true, debug statements are turned on
$fl_debug      = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER     = false;
// Default color for printable items (i.e. artifacts)
$fl_filament   = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES     = -2;     // [-2:10]
SHOW_LABELS     = false;
SHOW_SYMBOLS    = false;

// **** TAB_Verbs *************************************************************

/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

// **** TAB_Placement *********************************************************

/* [2D Placement] */

X_PLACE = "undef";  // [undef,-1,0,+1]
Y_PLACE = "undef";  // [undef,-1,0,+1]

// **** TAB_TEST **************************************************************

/* [2D primitives] */

PRIMITIVE     = "circle arc";  // [circle, circle arc, circle sector, circle annulus, ellipse, elliptic arc, elliptic sector, elliptic annulus, frame, inscribed polygon, square]
RADIUS        = 10;
// ellipse horiz. semi axis
A             = 10;
// ellipse vert. semi axis
B             = 6;
// arc/sector specific
START_ANGLE   = 0;    // [-720:720]
END_ANGLE     = 60;   // [-720:720]
// arc thickness
ARC_T         = 1;  // [0:10]
// Inscribed polygon edge number
IPOLY_N       = 3;  // [3:50]
// Show a circumscribed circle to inscribed polygon
IPOLY_CIRCLE  = true;
SQUARE_SIZE   = [40,30];

/* [Hidden] */
// **** TEST_PROLOGUE *********************************************************

quadrant    = fl_parm_Quadrant(X_PLACE,Y_PLACE);
debug       = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// **** end of automatically generated code ***********************************

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

module ipoly() {
  fl_ipoly(verbs,RADIUS,n=IPOLY_N,quadrant=quadrant);
  if (IPOLY_CIRCLE)
    fl_2d_placeIf(quadrant!=[undef,undef],quadrant=quadrant,bbox=fl_bb_ipoly(r=RADIUS,n=IPOLY_N)) #fl_circle(FL_ADD,r=RADIUS);
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

