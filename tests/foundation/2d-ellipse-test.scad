/*
 * 2D foundation ellipse primitives tests
 *
 * NOTE: this file is generated automatically from 'template-2d.scad', any
 * change will be lost.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
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
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER     = false;
// Default color for printable items (i.e. artifacts)
$fl_filament   = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

// **** TAB_Debug *************************************************************

/* [Debug] */

// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES        = -2;     // [-2:10]
DEBUG_ASSERTIONS  = false;
DEBUG_COMPONENTS  = ["none"];
DEBUG_COLOR       = false;
DEBUG_DIMENSIONS  = false;
DEBUG_LABELS      = false;
DEBUG_SYMBOLS     = false;

// **** TAB_Verbs *************************************************************

// **** TAB_Placement *********************************************************

// **** TAB_TEST **************************************************************

/* [Ellipse] */

PARAMETRIC  = false;
POLAR       = false;
R           = false;
T           = false;
T_REAL      = false;

// horizontal semi axis
A             = 10.0; // [0.1:0.01:10]
// vertical semi axis
B             = 6.0;  // [0.1:0.01:10]
ARC_START   = -180; // [-720:720]
ARC_END     = +45;  // [-720:720]
ARC_STEP    = 1;    // [1:5]
// thickness
ARC_T         = 1;  // [0:10]

/* [Hidden] */
// **** TEST_PROLOGUE *********************************************************

fl_status();

// **** end of automatically generated code ***********************************

// echo($vpr=$vpr);
// echo($vpt=$vpt);
// echo($vpd=$vpd);
// echo($vpf=$vpf);

// $vpr  = [0, 0, 0];
// $vpt  = [0, 0, 0];
// $vpd  = 140;
// $vpf  = 22.5;

angles  = ARC_START<ARC_END ? [ARC_START,ARC_END] : [ARC_END,ARC_START];
e       = [A,B];

module polar() {
  for(theta=[angles[0]:ARC_STEP:angles[1]])
    let(p = fl_ellipseXY(e,angle=theta))
      translate(p)
        circle(.05);
}

module parametric() {
  for(t=[angles[0]:ARC_STEP:angles[1]])
    let(p = fl_ellipseXY(e,t=t))
      translate(p)
        square(0.1,true);
}

module r() {
  for(theta=[angles[0]:ARC_STEP:angles[1]])
    let(y = fl_ellipseR(e,theta))
    // echo("r(θ)=",[radians(theta),y])
      translate([radians(theta),y])
        fl_ipoly(verbs,0.05,n=3);
}

module t_real() {
  for(theta=[angles[0]:ARC_STEP:angles[1]])
    let(y = fl_ellipseT(e,theta))
    // echo("t(θ)=",[radians(theta),y])
      translate([radians(theta),y/100])
        fl_ipoly(verbs,0.05,n=6);
}

module t() {
  for(theta=[angles[0]:ARC_STEP:angles[1]])
    let(
      a = e[0],
      b = e[1],
      y = asin(fl_ellipseR(e,theta)*sin(theta)/b)
    )
    // echo("t(θ)=",[radians(theta),y])
      translate([radians(theta),y/100])
        fl_ipoly(verbs,0.05,n=6);
}

function radians(degrees) = PI / 180 * degrees;

// fl_ellipticSector(verbs,[A,B],angles,quadrant=quadrant);
// test for ellipseXY in polar or parametric mode
if (POLAR)
  color("red")
    polar();
if (PARAMETRIC)
  color("blue")
    parametric();
if (R)
  color("yellow")
    r();
if (T)
  color("blue")
    t();
if (T_REAL)
  color("green")
    t_real();

singularity=-90;
echo(str("ramp(",singularity,")=",__ramp__(singularity)));
echo(str("step(",singularity,")=",__step__(-90)));
echo(str("t(",singularity,")=",asin(fl_ellipseR(e,-90)*sin(-90)/B)));
echo(str("t_real(",singularity-1,")=",fl_ellipseT(e,singularity-1)));
echo(str("t_real(",singularity,")=",fl_ellipseT(e,singularity)));
echo(str("t_real(",singularity+1,")=",fl_ellipseT(e,singularity+1)));

v=fl_ellipseXY(e=[0.9, 0.63],angle=-90);
echo(v=v);

