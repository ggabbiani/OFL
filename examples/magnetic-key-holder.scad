/*
 * Template file for OpenSCAD Foundation Library.
 * Created on Fri Jul 16 2021.
 *
 * Copyright © 2021 Giampiero Gabbiani.
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

include <../foundation/unsafe_defs.scad>
include <../foundation/incs.scad>
include <../vitamins/incs.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Verbs] */
ADD       = true;
ASSEMBLY  = false;

/* [Direction] */

DIR_NATIVE  = true;
DIR_Z       = "Z";  // [X,-X,Y,-Y,Z,-Z]
DIR_R       = 0;    // [-270,-180,-90,0,90,180,270]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Magnetic Key Holder] */

NUM_MAGS      = 4;
GAP           = 10;
BASE_T        = 1;
FILLET_T      = 1;
HOLDER_T      = 1;
// fl_JNgauge=0.15
TOLERANCE     = 0.15; // [0:0.01:1]
FILLET_R      = 4;
FILLET_STEPS  = 20;

SCREW_ONLY    = false;

/* [Hidden] */

magnet  = FL_MAG_M4_CS_32x6;
d       = fl_mag_diameter(magnet);
h       = 5.1; // fl_mag_height(magnet);
base_sz = [d * NUM_MAGS + GAP * (NUM_MAGS),d+GAP,BASE_T];
mag_w   = d*NUM_MAGS+GAP*(NUM_MAGS-1);
cyl_d   = d + 2*FILLET_T;
cyl_gap = GAP - 2 * FILLET_T;
cyl_w   = cyl_d * NUM_MAGS + cyl_gap * (NUM_MAGS-1);
screw   = fl_mag_screw(magnet);
screw_l = base_sz.z+h+1.5;

if (ADD)
  fl_color(FILAMENT) difference() {
    union() {
      translate(-Z(h)) fl_cube(size=base_sz,octant=-Z);
      translate(-X(cyl_w/2)) layout([for(i=[1:NUM_MAGS]) cyl_d],cyl_gap) {
        fl_cylinder(d=cyl_d,h=h,octant=-Z);
        translate(-Z(h))
        fl_90DegFillet(r=FILLET_R,n=FILLET_STEPS,child_bbox=fl_bb_circle(cyl_d/2)) circle(d=cyl_d);
      }
    }
    translate(-X(mag_w/2))
      layout([for(i=[1:NUM_MAGS]) d],10)
        translate(-Z(h-FL_NIL))
          fl_magnet([FL_FOOTPRINT,FL_DRILL],type=magnet,gross=TOLERANCE);
  }

if (ASSEMBLY)
  translate(-X(mag_w/2))
    layout([for(i=[1:NUM_MAGS]) d],10) {
      if (!SCREW_ONLY) translate(-Z(h-FL_NIL)) fl_magnet(type=magnet);
      if (SCREW_ONLY) {if ($i==0) fl_color(FILAMENT) screw(screw,screw_l);}
      else screw(screw,screw_l);
    }
