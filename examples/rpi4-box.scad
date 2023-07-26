/*
 * Example representing a box built around a Raspberry Pi4 with TV uHat
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

// include <OFL/artifacts/pcb_holder.scad>
include <../artifacts/caddy.scad>
include <../artifacts/spacer.scad>
include <../vitamins/hds.scad>
include <../vitamins/heatsinks.scad>
include <../vitamins/pcbs.scad>

use <../foundation/bbox-engine.scad>
use <../artifacts/box.scad>

$fn           = 50;           // [3:100]
// Debug statements are turned on
$fl_debug     = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER    = false;
// Default color for printable items (i.e. artifacts)
$fl_filament  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]

/* [Box] */

VIEW_MODE = "FULL"; // [FULL,PARTIAL,PRINT ME!]
SBC       = "rpi4"; // [rpi4, khadas]

FILAMENT_UPPER  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
FILAMENT_LOWER  = "SteelBlue";  // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// box thickness
T=1.5;
// extra height for fixing screws
EXTRA_H     = 7.0;
// inner radius for rounded angles (square if undef)
RADIUS        = 1.1;
BOX_TOLERANCE = 0.2;
// tolerance for the cutting
CUT_TOLERANCE = 0.6;
FILLET        = true;
UPPER_PART    = true;
LOWER_PART    = true;
SPACER_T      = 2;    // [1:0.1:2]


/* [Hidden] */

fl_status();

sbc         = SBC=="rpi4" ? FL_PCB_RPI4 : FL_PCB_VIM1;
// spacer_h    = 1.7+T+BOX_TOLERANCE;
spacer_h    = -fl_bb_corners(sbc)[0].z-fl_pcb_thick(sbc)+BOX_TOLERANCE;

radius  = RADIUS!=0 ? RADIUS : undef;
parts = (LOWER_PART && UPPER_PART) ? "all"
      : LOWER_PART ? "lower"
      : UPPER_PART ? "upper"
      : "none";

sbc_direction = SBC=="rpi4" ? undef : [+Z,180];
sbc_octant    = SBC=="rpi4" ? undef : +Z;

/*
 * The box is built using the sbc bounding box passed as payload.
 * Since Khadas is rotated of 180° around Z axis and translated on +Z
 * semi-space, its bounding box must be transformed consequently.
 *
 * Finally the resulting bounding box is always enhanced on the Z axis for
 * hosting the box fixing screws
 */
box_payload = let(
  bb  = SBC=="rpi4"
      ? fl_bb_corners(sbc)
      : fl_bb_transform(Rz(180)*fl_octant(sbc_octant,sbc),fl_bb_corners(sbc)+[[-T,0,0],[T,1,0]])
) [bb[0],bb[1]+Z(EXTRA_H)];

// box rendering
difference() {
  // adding part
  fl_box(
    [FL_ADD,FL_LAYOUT],
    pload=box_payload,thick=T,radius=radius,parts=parts,material_upper=FILAMENT_UPPER,material_lower=FILAMENT_LOWER,tolerance=BOX_TOLERANCE,fillet=FILLET,
    // lay_octant=O,
    octant=+Z,
    // $FL_ADD="DEBUG"
  ) translate(X(T)) fl_pcb(
    [FL_LAYOUT],
    sbc,
    octant=sbc_octant,
    direction=sbc_direction
  ) translate(-Z($pcb_thick))
      fl_spacer(
        [FL_ADD],
        spacer_h,
        d=$hole_d+SPACER_T*2,
        screw=$hole_screw,
        knut=true,
        thick=T,
        lay_direction=[$hole_n],
        octant=-$hole_n,
        $fl_filament=$box_materials[0],
        $FL_ADD=LOWER_PART?"ON":"OFF"
      );
  // cut out
  fl_box(
    [FL_LAYOUT],
    pload=box_payload,thick=T,radius=radius,parts=parts,material_upper=FILAMENT_UPPER,material_lower=FILAMENT_LOWER,tolerance=BOX_TOLERANCE,fillet=FILLET,
    // lay_octant=O,
    octant=+Z
  ) translate(X(T)) fl_pcb(
      [FL_CUTOUT],
      sbc,
      thick=3*T,
      cut_tolerance=CUT_TOLERANCE,
      cut_direction=[-X,-Y,+Y],
      octant=sbc_octant,
      direction=sbc_direction
    );
}

// assembly
fl_box(
  [FL_ASSEMBLY,FL_LAYOUT,FL_MOUNT],
  pload=box_payload,thick=T,radius=radius,parts=parts,material_upper=FILAMENT_UPPER,material_lower=FILAMENT_LOWER,tolerance=BOX_TOLERANCE,fillet=FILLET,
  // lay_octant=O,
  octant=+Z,
  $FL_ADD="ON",
  $FL_ASSEMBLY=(VIEW_MODE=="FULL"||VIEW_MODE=="PARTIAL")?"ON":"OFF",
  $FL_MOUNT=(VIEW_MODE=="FULL")?"ON":"OFF"
) translate(X(T)) fl_pcb(
    [FL_ADD,FL_ASSEMBLY,FL_LAYOUT],
    sbc,
    octant=sbc_octant,
    direction=sbc_direction,
    $FL_ADD=(VIEW_MODE=="FULL")?"ON":"OFF",
    $FL_ASSEMBLY=(VIEW_MODE=="FULL")?"ON":"OFF"
  ) translate(-Z($pcb_thick))
      fl_spacer(
        [FL_ASSEMBLY],
        spacer_h,
        d=$hole_d+SPACER_T*2,
        screw=$hole_screw,
        knut=true,
        thick=T,
        lay_direction=[$hole_n],
        octant=-$hole_n,
        $FL_ASSEMBLY=(LOWER_PART&&(VIEW_MODE=="FULL"||VIEW_MODE=="PARTIAL"))?"ON":"OFF"
      );
    // translate($spc_director*$spc_thick)
    //   fl_screw(FL_DRAW,$spc_screw,thick=$spc_h+$spc_thick,washer="nylon",direction=[$spc_director,0]);

