/*
 * Label holder for a desk chest of drawers available on Amazon [Portaoggetti da Scrivania](https://www.amazon.it/gp/product/B07BSX9T2L).
 *
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org)
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
 * along with OFL.  If not, see <http://www.gnu.org/licenses/>.
 */

include <../foundation/3d.scad>

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
