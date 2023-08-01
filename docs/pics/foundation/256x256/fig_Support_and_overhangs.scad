/*!
 * "Support and overhangs" figure
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <OFL/library.scad>

$vpr = [90, 0, 0];
$vpt = [6.99216, -1.5, 8.13173];
$vpf = 22.5;
$vpd = 55.1063;

T=1.5;
l=10;
size=[10,10];
alpha           = 90-fl_techLimit(FL_LIMIT_OVERHANGS);
// alpha=20;
delta = size.x/4;
$fl_technology  = FL_TECH_FDM;
$fn=100;
fl_color("DodgerBlue")
translate(fl_Y(T))
fl_linear_extrude([-Y,0],T) {
    difference() {
    fl_square(size=size,quadrant=+X+Y);
    translate(X(delta))
        fl_ellipticSector(e=1.5*size, angles = [0,90-alpha], quadrant = +X+Y);
    }
}

beta=alpha/2;
e=sqrt(2)*(size+[T,T]);

translate(X(delta-FL_NIL)) {
fl_color("red")
    fl_linear_extrude([-Y,0],T) {
    translate(fl_ellipseXY(e-[T,T]/2,angle=90-beta))
        rotate(-beta,FL_Z)
        polygon([[0,-T],[T,0],[0,+T]]);
    fl_ellipticArc(e=e,angles=[90,90-alpha],thick=T,$fn=100);
    }
}
#translate(X(delta-FL_NIL))
fl_linear_extrude([-Y,0],T)
    fl_ellipticSector(e=e-T*[1,1],angles=[90,90-alpha]);
echo(
$vpr=$vpr,
$vpt=$vpt,
$vpf=$vpf,
$vpd=$vpd
);
