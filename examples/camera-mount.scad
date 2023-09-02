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

include <../lib/OFL/foundation/core.scad>
include <../lib/OFL/foundation/limits.scad>
include <../lib/OFL/artifacts/t-nut.scad>
include <../lib/OFL/vitamins/knurl_nuts.scad>

use <../lib/OFL/foundation/2d-engine.scad>
use <../lib/OFL/foundation/3d-engine.scad>
use <../lib/OFL/foundation/hole.scad>

include <NopSCADlib/utils/core/core.scad>
use <NopSCADlib/utils/thread.scad>

$fl_print_tech   = "Selective Laser sintering"; // [Selective Laser sintering,Fused deposition modeling,Stereo lithography,Material jetting,Binder jetting,Direct metal Laser sintering]
$fn         = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// Default color for printable items (i.e. artifacts)
$fl_filament  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]
// Debug statements are turned on
$fl_debug   = false;
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

/* [Camera mount] */

VIEW_MODE = "FULL"; // [FULL,ASSEMBLED,MOUNTED,PRINT ME!]

DIRECTION       = [0,1,-0.4];  // [-1:0.1:+1]

// show T-NUT
T_NUT                 = true;
// show arm
ARM                   = true;

/* [Hidden] */

base_sz = [30,2,20];
nut_thick = wall_thick+base_thick+cone_thick;

// screw
screw = M3_cap_screw;
scr_d = 2*screw_radius(screw);
scr_head_d  = 2*screw_head_radius(screw);
scr_len=base_sz.y*2+nut_thick;

washer  = screw_washer(screw);
wsh_d   = washer_diameter(washer);

// t-nut
nut_holes = let(d=scr_d+1) [
  fl_Hole([0,wall_thick,5],d,+Y,nut_thick,screw=screw),
  fl_Hole([0,wall_thick,5+20],d,+Y,nut_thick,screw=screw)
];
nut = fl_TNut(opening,[in_width,length],[wall_thick,base_thick,cone_thick],screw,true,nut_holes);

// brass insert
knut= fl_knut_search(screw,nut_thick);

// thread
thr_pitch = 2;
thr_starts = 4;
thr_profile = thread_profile(thr_pitch / 2, thr_pitch * 0.366, 30);
thr_len = 6.9;
thr_d = 15.8;

module arm() {
  m     = fl_direction([DIRECTION,0]);
  stop  = 6.5;
  multmatrix(m) {
    translate(+Z(5))
      // cylinder part
      fl_cylinder(FL_ADD, h = 40, r = 5);

    translate(+Z(45)-Y((thr_d-5)/8)) multmatrix(invert(m)) fl_direct([+Y,0]) {
      // thread part
      male_metric_thread(thr_d, thr_pitch, thr_len);
      translate(+Z(thr_len/2))
        // stopper part
        fl_cylinder(h=stop,d=6.20);
    }
  }
}

difference() {
  union() {
    translate(-Y(base_sz.y))
      fl_tnut([FL_ADD,FL_ASSEMBLY],nut,direction=[X,0],octant=-Y,$FL_ASSEMBLY=T_NUT&&(VIEW_MODE=="FULL"||VIEW_MODE=="ASSEMBLED")?"ON":"OFF",$FL_ADD=T_NUT?"ON":"OFF");

    if (ARM) fl_color("DodgerBlue") {
      hull() {
        fl_cube(size=base_sz,octant=+Y);
        fl_direct([DIRECTION,0])
          translate(+Z(base_sz.y))
            fl_cylinder(h=5,r=5);
      }
      arm();
    }

  }

  // holes subtraction
  translate(-Y(FL_NIL))
    fl_tnut(FL_LAYOUT,nut,direction=[X,0],octant=-Y) {
      // screw holes
      fl_cylinder(h=30,d=scr_d+0.4,direction=[+Y,0],octant=+Z);
      // screw head holes
      translate(+Y(base_sz.y))
        fl_cylinder(h=30,d=wsh_d+0.2,direction=[+Y,0],octant=+Z);
    }

}

if (VIEW_MODE=="MOUNTED"||VIEW_MODE=="FULL")
  translate(-Y(base_sz.y))
    fl_tnut([FL_LAYOUT],nut,direction=[X,0],octant=-Y)
      translate(Y(2*base_sz.y))
        fl_screw([FL_ADD,FL_ASSEMBLY],type=screw,len=scr_len,washer="nylon",direction=[+Y,0]);
