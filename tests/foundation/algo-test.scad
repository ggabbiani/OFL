/*
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../lib/OFL/foundation/core.scad>
use <../../lib/OFL/foundation/algo-engine.scad>

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
