/*
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
 * along with OFL.  If not, see <http: //www.gnu.org/licenses/>.
 */

include <../../foundation/algo.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$fl_debug   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]

// Draw planes
FL_PLANES  = true;

/* [Placement] */

OCTANT        = [0,0,0];  // [-1:+1]

/* [Algo] */

DEPLOYMENT  = [10,0,0];
ALIGN       = [0,0,0];  // [-1:+1]

/* [Hidden] */

data    = [
  ["zero",    [1,11,111]],
  ["first",   [2,22,1]],
  ["second",  [3,33,1]],
];
pattern = [0,1,1,2];

fl_trace("result",fl_algo_pattern(10,pattern,data));
fl_algo_pattern(10,pattern,data,deployment=DEPLOYMENT,octant=OCTANT,align=ALIGN);

if (FL_PLANES)
  fl_planes(size=200);
