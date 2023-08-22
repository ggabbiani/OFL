/*
 * Label holder for a desk chest of drawers available on Amazon [Portaoggetti da Scrivania](https://www.amazon.it/gp/product/B07BSX9T2L).
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../lib/OFL/foundation/unsafe_defs.scad>

use <../lib/OFL/foundation/2d-engine.scad>
use <../lib/OFL/foundation/3d-engine.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$fl_debug   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// Default color for printable items (i.e. artifacts)
$fl_filament  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]

T       = 1.2;
FRAME_HIDE  = false;
FRAME   = 1;
ISIZE   = [40,13];
OSIZE   = ISIZE+FRAME*[2,2];
CORNERS = 2;

Dpin    = 2.5;
Hpin    = 5;

if (!FRAME_HIDE)
  translate(Z(T))
    linear_extrude(T)
      fl_2d_frame(size=OSIZE,corners=CORNERS,thick=FRAME);
linear_extrude(T)
  fl_square(size=OSIZE,corners=CORNERS);


for(i=[-(32+Dpin)/2,+(32+Dpin)/2])
  translate(X(i))
    rotate(Z(90))
      fl_cylinder(h=Hpin,d=Dpin,octant=-Z,$fn=6);
