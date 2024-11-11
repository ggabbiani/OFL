/*
 * Example representing a box built around a Raspberry Pi4 with TV uHat
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../lib/OFL/artifacts/caddy.scad>
include <../lib/OFL/artifacts/pcb_holder.scad>
include <../lib/OFL/artifacts/spacer.scad>
include <../lib/OFL/vitamins/hds.scad>
include <../lib/OFL/vitamins/heatsinks.scad>
include <../lib/OFL/vitamins/pcbs.scad>

use <../lib/OFL/foundation/bbox-engine.scad>
use <../lib/OFL/artifacts/box.scad>

$fn           = 50;           // [3:100]
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

/* [Fixings] */

// Knurl nut thread type
FAST_TYPE  = "linear"; // [linear,spiral]
// Knurl nut screw nominal ⌀
FAST_NOMINAL = 3;  // [2,3,4,5,6,8]

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

// sbc_direction = SBC=="rpi4" ? undef : [+Z,180];
// sbc_octant    = SBC=="rpi4" ? undef : +Z;

holder  = fl_PCBHolder(sbc,knut_type=FAST_TYPE);
payload = fl_bb_corners(holder);

module sbcBox(mode)
  let(
    verbs = mode=="add"?[FL_ADD,FL_LAYOUT,if (VIEW_MODE!="PRINT ME!") FL_ASSEMBLY]:FL_LAYOUT
  ) /* echo(mode=mode) */ fl_box(verbs,pload=payload,
    thick=T,
    radius=radius,
    parts=parts,
    material_upper=FILAMENT_UPPER,
    material_lower=FILAMENT_LOWER,
    tolerance=BOX_TOLERANCE,
    fillet=FILLET,
    fastenings=[FAST_TYPE,FAST_NOMINAL],
    // lay_octant=-Z,
    octant=+Z
    // $FL_ADD="DEBUG"
  ) if (mode=="add") // echo("***ADD***")
        let(
          verbs = LOWER_PART?FL_ADD:[],
          thick   = [-(T+NIL),fl_pcb_thick(sbc)],
          fillet  = FILLET?0.5:undef
        ) fl_pcbHolder(
          verbs,
          holder,
          thick=thick,
          fillet=fillet,
          $fl_filament=FILAMENT_LOWER
        );
    else if (mode=="assembly") // echo("***ASSEMBLY***")
      let(
        verbs = LOWER_PART?FL_ASSEMBLY:[],
        thick   = [-(T+NIL),fl_pcb_thick(sbc)],
        fillet  = FILLET?0.5:undef
      ) fl_pcbHolder(
        verbs,
        holder,
        thick=thick,
        fillet=fillet,
        asm_all=VIEW_MODE=="FULL"
      );
    else // echo("***CUTOUT***")
      translate(+Z(fl_spc_h(fl_pcbh_spacers(holder)[0])+fl_pcb_thick(sbc)))
        fl_pcb(
          FL_CUTOUT,
          sbc,
          thick=3*T,
          $fl_tolerance=CUT_TOLERANCE,
          cut_direction=[if (SBC=="rpi4") +X,-Y,+Y]
        );

difference() {
  sbcBox("add");
  sbcBox("cut out");
}
if (VIEW_MODE!="PRINT ME!")
  sbcBox("assembly");
