/*
 * Generic holder for Snapmaster A250T/A350T enclosure
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../lib/ext/NopSCADlib/core.scad>
include <../../lib/ext/NopSCADlib/vitamins/screws.scad>

include <../../lib/OFL/foundation/core.scad>
include <../../lib/OFL/foundation/limits.scad>
include <../../lib/OFL/artifacts/t-nut.scad>
include <../../lib/OFL/vitamins/knurl_nuts.scad>

use <../../lib/OFL/foundation/2d-engine.scad>
use <../../lib/OFL/foundation/3d-engine.scad>
use <../../lib/OFL/foundation/hole.scad>

include <../../lib/ext/NopSCADlib/utils/core/core.scad>
use <../../lib/ext/NopSCADlib/utils/thread.scad>

$fl_print_tech   = "Selective Laser sintering"; // [Selective Laser sintering,Fused deposition modeling,Stereo lithography,Material jetting,Binder jetting,Direct metal Laser sintering]
$fn         = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// Default color for printable items (i.e. artifacts)
$fl_filament  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]
SHOW_LABELS     = false;
SHOW_SYMBOLS    = false;

/* [tnut] */

opening               = 6;
in_width              = 10.0; // [0:0.1:20]
length                = 30;
wall_thick            = 2.0;  // [0:0.1:1]
base_thick            = 1.0;  // [0:0.1:3]
cone_thick            = 2.0;  // [0:0.1:6]
nut_tolerance         = 0;    // [-1:0.1:1]
hole_tolerance        = 0;    // [-1:0.1:2]
countersink_tolerance = 0;    // [-1:0.1:1]

/* [BLOB mount] */

VIEW_MODE = "FULL"; // [FULL,ASSEMBLED,MOUNTED,PRINT ME!]

ARC_GAP     = 0;  // [-10:0.1:10]
ARC_SIZE    = 45;
// internal arc radius
ARC_R       = 5.73; // [5:0.01:10]
// show T-NUT
VIEW_TNUT   = true;
// show block
VIEW_BLOCK  = true;
// T slot structural framing nominal size
T_SLOT      = 24;
// side gap (glass thickness plus toppings)
SIDE_GAP    = 3.1;
// flange thickness
T           = 2;
// height of the tool holder
H           = 20;
tolerance   = 0.1;

/* [Hidden] */

module block() {
  fl_color()
  linear_extrude(base_sz.x) {

    // hull() {
    diag_sz = [w-tolerance,T];
    translate(X(T_SLOT))
      rotate(-45,Z)
        fl_square(size=diag_sz, corners=[0,2,0,0], quadrant=-X+Y);

    horiz_sz  = [SIDE_GAP+T+tolerance,T];
    translate(X(T_SLOT))
      fl_square(size=horiz_sz, corners=[2,0,0,0], quadrant=+X+Y);
    // }

    vert_sz   = [T,H];
    translate(X(T_SLOT+SIDE_GAP+tolerance))
      fl_square(size=vert_sz, corners=[0,0,0,2], quadrant=+X-Y);

    translate(X(T_SLOT+SIDE_GAP+tolerance-ARC_GAP))
      fl_arc(r=ARC_R+T, angles=[-90,-90-ARC_SIZE], thick=T, quadrant=-X+Y);
  }
}

w = T_SLOT*sqrt(2);
base_sz = [30,2,w];
nut_thick = wall_thick+base_thick+cone_thick;

// screw
screw       = M3_cap_screw;
scr_d       = 2*screw_radius(screw);
scr_head_d  = 2*screw_head_radius(screw);
scr_len     = base_sz.y*2+nut_thick;

washer  = screw_washer(screw);
wsh_d   = washer_diameter(washer);

// t-nut
nut_holes = let(d=scr_d) [
  fl_Hole([0,wall_thick,5],d,+Y,nut_thick,screw=screw),
  fl_Hole([0,wall_thick,5+20],d,+Y,nut_thick,screw=screw)
];
nut = fl_TNut(opening,[in_width,length],[wall_thick,base_thick,cone_thick],screw,true,nut_holes);

// brass insert
knut  = fl_knut_search(screw=screw,thick=nut_thick);

if (VIEW_BLOCK)
  difference() {
    block();
    // holes subtraction
    translate([10,10,0])
      fl_tnut([FL_DRILL],nut,direction=[Z,-45],dri_thick=10);
  }

if (VIEW_TNUT)
  translate([10,10,0])
    fl_tnut(
      [FL_ADD,FL_ASSEMBLY,FL_MOUNT],
      nut,direction=[Z,-45],dri_thick=10,
      $FL_ASSEMBLY=VIEW_TNUT&&(VIEW_MODE=="FULL"||VIEW_MODE=="ASSEMBLED")?"ON":"OFF",
      $FL_MOUNT=VIEW_TNUT&&(VIEW_MODE=="FULL"||VIEW_MODE=="MOUNTED")?"ON":"OFF",
      $FL_ADD=VIEW_TNUT?"ON":"OFF"
    );
