/*
 * Front and left handles for the Snapmaker A250T/A350T enclosure.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../lib/OFL/foundation/3d-engine.scad>
include <../../lib/OFL/foundation/2d-engine.scad>
include <../../lib/OFL/foundation/fillet.scad>
include <../../lib/OFL/foundation/limits.scad>
include <../../lib/OFL/vitamins/magnets.scad>
include <../../lib/OFL/vitamins/screw.scad>
include <../../lib/OFL/vitamins/knurl_nuts.scad>

// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
$fn=100;
// the height NOT counting top surface
h=30;
// printing technology
$fl_print_tech  = "Fused deposition modeling";  // [Selective Laser sintering,Fused deposition modeling,Stereo lithography,Material jetting,Binder jetting,Direct metal Laser sintering]
// Default color for printable items (i.e. artifacts)
$fl_filament  = "DodgerBlue";                   // [DodgerBlue,Blue,OrangeRed,SteelBlue,DarkSlateGray]
// magnet screw overloading
SCREW     = "default";                          // [default, M2_cs_cap_screw, M3_cs_cap_screw]
// the deeper .. the stronger!
MAGNET    = "FL_MAG_M3_CS_D10x2";               // [FL_MAG_M3_CS_D10x2,FL_MAG_M3_CS_D10x5]
VIEW_MODE = "FULL";                             // [FULL,PARTIAL,PRINT ME!]
PART      = "Front";                            // [Front, Right]

/* [Hidden] */

clearance = fl_techLimit(FL_LIMIT_CLEARANCE)/2;

magnet      = MAGNET=="FL_MAG_M3_CS_D10x2" ? FL_MAG_M3_CS_D10x2 : FL_MAG_M3_CS_D10x5;
screw       = fl_switch(SCREW,[["M2_cs_cap_screw",M2_cs_cap_screw],["M3_cs_cap_screw",M3_cs_cap_screw]],fl_screw(magnet));
mag_sz      = fl_bb_size(magnet);
T           = 2+clearance;
// shortest linear threaded nut matching screw
knut        = fl_knut_search(screw,thread="linear",best=FL_KNUT_SHORTEST);
knut_thick  = fl_knut_thick(knut);
tube_thick  = 1.6; // from brass insert producer data it should be at least 1.6mm
tube_d      = mag_sz.x+(tube_thick+clearance)*2;
emi_d       = tube_d;
tube_h      = max(mag_sz.z+knut_thick-(T+emi_d/2)+1,0);

// ellipse geometry
e         = [15,18];
e_angles  = PART=="Front" ? [0,90] : [0,-90];
// magnet translation
M_magnet  = PART=="Front" ? [0,e.y/2,h-12] : [0,e.y/2,h-17];
// fillet radius
fill_r    = 3;
// pin radius should be actual radius (3mm) minus clearance, we round it up to 2.5mm
pin_r     = 2.5/2;
pin_h     = 3;

difference() {
  fl_color() {
    linear_extrude(height = h+T) {
      // elliptic arc
      fl_ellipticArc(e=e, angles = e_angles, thick =T, quadrant=+X+Y);
      translate(fl_ellipseXY(e=e-T/2*[1,0],angle=0)+(PART=="Right" ? [0,e.y] : [0,0]))
        fl_circle(r = T/2);
      // linear surface
      translate(Y(PART=="Front" ? 0 : T))
        fl_square(size = [T,e.y-T], quadrant=+X+Y);
      // *fl_circle(r = T/2,quadrant=+X);

    }

    // top surface
    translate(+Z(h)) {
      linear_extrude(height = T)
        fl_square(size = [fill_r*2,e.y], corners = [0,fill_r,fill_r,0],quadrant=-X+Y);
      // pins
      for(y=[e.y-fill_r,fill_r])
        translate([-fill_r,y])
          fl_cylinder(r=pin_r,h=pin_h,octant=-Z);
    }

    translate(M_magnet) {
      translate(X(T))
        fl_color() {
          if (tube_h)
            fl_tube(d=tube_d,h=tube_h,thick=tube_thick,direction=[+X,0]);
          // emi-sphere for brass insert
          translate(X(tube_h))
            intersection() {
              fl_sphere(d=emi_d);
              fl_cube(size = [emi_d/2,emi_d,emi_d],octant=+X);
            }
        }
    }

    // fillet(s)
    fl_fillet(r=fill_r,h=h,direction=[Z,90]);
    translate(Y(e.y))
      fl_fillet(r=fill_r,h=h,direction=[Z,180]);
  }

  translate(M_magnet)
    fl_magnet([FL_FOOTPRINT,FL_LAYOUT],type=magnet,$fl_tolerance=clearance,$fl_thickness=emi_d/2,octant=-Z,direction=[-X,90])
      translate(-Z(mag_sz.z+clearance-NIL))
        fl_knut(FL_DRILL,type=knut,dri_thick=T+emi_d/2+tube_h-mag_sz.z-clearance-fl_knut_thick(knut)+NIL,$FL_DRILL="ON");
}


translate(M_magnet)
  fl_magnet(
    [FL_ADD,FL_MOUNT,FL_LAYOUT],
    type=magnet,octant=-Z,direction=[-X,90],
    $FL_ADD       = VIEW_MODE=="FULL"?"ON":"OFF",
    $FL_ASSEMBLY  = VIEW_MODE=="FULL"?"ON":"OFF",
    $FL_LAYOUT    = VIEW_MODE!="PRINT ME!"?"ON":"OFF"
  ) translate(-Z(mag_sz.z+clearance))
    fl_knut(type=knut,$FL_ADD=VIEW_MODE!="PRINT ME!"?"ON":"OFF");