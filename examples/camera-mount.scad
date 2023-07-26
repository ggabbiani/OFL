/*
 * D-Link DCS-932L camera mount
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/screws.scad>

include <../foundation/defs.scad>

use <../foundation/2d-engine.scad>
use <../foundation/3d-engine.scad>
use <../foundation/hole.scad>

$fn           = 50;           // [3:100]
// Debug statements are turned on
$fl_debug     = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER    = false;
// Default color for printable items (i.e. artifacts)
$fl_filament  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]

LABELS  = false;
SYMBOLS = false;


/* [Camera holder] */

T=1.5;

/* [Hidden] */

debug = fl_parm_Debug(labels=LABELS,symbols=SYMBOLS);

cam_d      = 80;
cam_screw  = M3_cap_screw;
cam_holes = [
  for(x=[-20,20])
    fl_Hole([x,0,T],screw_radius(cam_screw)*2,depth=T,screw=cam_screw),
  for(y=[-20,20])
    fl_Hole([0,y,T],screw_radius(cam_screw)*2,depth=T,screw=cam_screw)
];

difference() {
  linear_extrude(T) {
    fl_circle(d=cam_d);
    translate(-Y(cam_d/2))
      fl_square(size=[cam_d/2,cam_d]);
  }
  fl_holes(cam_holes);
}
fl_hole_debug(cam_holes,debug=debug);
