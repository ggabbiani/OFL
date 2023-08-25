/*
 * 2D foundation ellipse primitives tests.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../lib/OFL/foundation/core.scad>

use <../../lib/OFL/foundation/2d-engine.scad>

$fn         = 50;     // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]

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

/* [Ellipse] */

PARAMETRIC  = false;
POLAR       = false;
R           = false;
T           = false;
T_REAL      = false;

// horizontal semi axis
A             = 10.0; // [0.1:0.01:5]
// vertical semi axis
B             = 6.0;  // [0.1:0.01:5]
ARC_START   = -180; // [-720:720]
ARC_END     = +45;  // [-720:720]
ARC_STEP    = 1;    // [1:5]
// thickness
ARC_T         = 1;  // [0:10]

/* [Hidden] */

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

verbs=[
  if ($FL_ADD!="OFF")   FL_ADD,
  if ($FL_AXES!="OFF")  FL_AXES,
  if ($FL_BBOX!="OFF")  FL_BBOX,
];

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