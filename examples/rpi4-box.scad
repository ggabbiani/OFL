/*
 * Example representing a box built around a Raspberry Pi4 with TV uHat
 *
 * Copyright © 2022 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'Raspberry Pi4' (RPI4) project.
 *
 * RPI4 is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * RPI4 is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with RPI4.  If not, see <http://www.gnu.org/licenses/>.
 */

// include <OFL/artifacts/pcb_holder.scad>
include <../artifacts/box.scad>
include <../artifacts/spacer.scad>
include <../vitamins/heatsinks.scad>
include <../vitamins/hds.scad>
include <../artifacts/caddy.scad>
// include <OFL/vitamins/pcbs.scad>

$fn           = 50;           // [3:100]
// Debug statements are turned on
$fl_debug     = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER    = false;
// Default color for printable items (i.e. artifacts)
$fl_filament  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]

/* [meta verbs] */

// adds shapes to scene.
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
CUTOUT    = "OFF";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
FOOTPRINT = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// mount shape through predefined screws
MOUNT     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a box representing the payload of the shape
PAYLOAD   = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Box] */

FILAMENT_UPPER  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
FILAMENT_LOWER  = "SteelBlue";  // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// box thickness
T=2.5;
// inner radius for rounded angles (square if undef)
RADIUS      = 1.1;
TOLERANCE   = 0.2;
FILLET      = true;
UPPER_PART  = true;
LOWER_PART  = true;


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
verbs=[
  if (ADD!="OFF")       FL_ADD,
  if (ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if (AXES!="OFF")      FL_AXES,
  if (BBOX!="OFF")      FL_BBOX,
  if (CUTOUT!="OFF")    FL_CUTOUT,
  if (DRILL!="OFF")     FL_DRILL,
  if (FOOTPRINT!="OFF") FL_FOOTPRINT,
  if (LAYOUT!="OFF")    FL_LAYOUT,
  if (MOUNT!="OFF")     FL_MOUNT,
  if (PAYLOAD!="OFF")   FL_PAYLOAD,
];

rpi         = FL_PCB_RPI4;
pimoroni    = FL_HS_PIMORONI;

pim_octant  = octant;
pim_bottom  = fl_get(FL_HS_PIMORONI,"bottom part");
pim_fthick  = fl_get(pim_bottom,"layer 0 fluting thickness");
pim_bbox    = fl_bb_pimoroni(pimoroni,bottom=false);
// pim_size    = pim_bbox[1]-pim_bbox[0];

spacer_h    = 1.7+T+TOLERANCE;

radius  = RADIUS!=0 ? RADIUS : undef;
parts = (LOWER_PART && UPPER_PART) ? "all"
      : LOWER_PART ? "lower"
      : UPPER_PART ? "upper"
      : "none";

// heatsink rendering plus layout of mounted spacers
fl_pimoroni([FL_ADD,FL_LAYOUT,FL_BBOX],pimoroni,bottom=false,octant=pim_octant,$FL_ADD=ASSEMBLY,$FL_LAYOUT=ADD,$FL_BBOX=BBOX)
  fl_spacer([FL_ADD,FL_LAYOUT],h=spacer_h,r=$hs_radius,screw=$hs_screw,knut=true,thick=T,lay_direction=[$hs_normal],octant=$hs_normal,$FL_ADD=LOWER_PART?ADD:"OFF",$FL_LAYOUT=MOUNT)
    fl_screw([FL_ADD,FL_ASSEMBLY],$spc_screw,thick=$spc_h+$spc_thick,washer="no",direction=[$spc_director,0],$FL_ADD=MOUNT,$FL_ASSEMBLY=MOUNT);
// heatsink layout of assembled parts
fl_pimoroni(FL_LAYOUT,pimoroni,bottom=false,octant=pim_octant,lay_what="assembly",$FL_LAYOUT=ASSEMBLY) {
  fl_pcb(FL_DRAW,rpi);
  // connect [female GPIO pin header, connector 0] to [rpi, connector 0]
  fl_connect([FL_PHDR_GPIOHDR_F,0],[rpi,0]) {
    // connection child rendering
    fl_pinHeader(FL_ADD,$con_child,color=grey(30));

    // connect [long female GPIO pin header, connector 0] to [female GPIO pin header, connector 1]
    fl_connect([FL_PHDR_GPIOHDR_FL,0],[$con_child,1]) {
      // connection child rendering
      fl_pinHeader(FL_ADD,$con_child,color=grey(60));

      // connect [tv hat, connector 0] to [long female GPIO pin header, connector 1]
      fl_connect([FL_PCB_RPI_uHAT,0],[$con_child,1])
        // connection child rendering
        fl_pcb(FL_DRAW,$con_child);
    }
  }
}

m0      = fl_pimoroni(FL_LAYOUT,pimoroni,bottom=false,octant=pim_octant,lay_what="assembly",$FL_LAYOUT=ASSEMBLY);
m1      = m0*fl_connect([FL_PHDR_GPIOHDR_F,0],[rpi,0]);
trans1  = fl_bb_transform(m1,fl_bb_corners(FL_PHDR_GPIOHDR_F));
m2      = m1*fl_connect([FL_PHDR_GPIOHDR_FL,0],[FL_PHDR_GPIOHDR_F,1]);
trans2 = fl_bb_transform(m2,fl_bb_corners(FL_PHDR_GPIOHDR_FL));
m3      = m2*fl_connect([FL_PCB_RPI_uHAT,0],[FL_PHDR_GPIOHDR_FL,1]);
trans3  = fl_bb_transform(m3,fl_bb_corners(FL_PCB_RPI_uHAT));
bb      = fl_bb_calc([pim_bbox,trans1,trans2,trans3]);

difference() {
  // box rendering
  fl_box([FL_ADD,FL_ASSEMBLY,FL_MOUNT],pload=bb,thick=T,radius=radius,parts=parts,material_upper=FILAMENT_UPPER,material_lower=FILAMENT_LOWER,tolerance=TOLERANCE,fillet=FILLET,$FL_ADD=ADD,$FL_ASSEMBLY=ASSEMBLY,$FL_MOUNT=MOUNT);

  // spacers drill
  fl_pimoroni(FL_LAYOUT,pimoroni,bottom=false,octant=pim_octant)
    fl_spacer(FL_LAYOUT,h=spacer_h,r=$hs_radius,screw=$hs_screw,knut=true,thick=T,lay_direction=[-Z],octant=$hs_normal)
      fl_cylinder(h=2*spacer_h,r=$spc_holeR,octant=O);

  fl_pimoroni(FL_LAYOUT,pimoroni,bottom=false,octant=pim_octant,lay_what="assembly",$FL_LAYOUT="ON") {
    // rpi cutout for +X and +Y components
    fl_pcb(FL_CUTOUT,rpi,thick=20,cut_direction=[+X,+Y],cut_tolerance=0.5);
    // window for the uSD card socket
    for(z=[0:3])
      translate(-z*Z(1.3))
        fl_pcb(FL_CUTOUT,rpi,thick=20,cut_label="uSD",cut_tolerance=0.5);
    fl_connect([FL_PHDR_GPIOHDR_F,0],[rpi,0])
      fl_connect([FL_PHDR_GPIOHDR_FL,0],[$con_child,1])
        fl_connect([FL_PCB_RPI_uHAT,0],[$con_child,1])
          // TV hat cutout
          fl_pcb([FL_ADD,FL_CUTOUT],$con_child,thick=20,cut_direction=[-X],cut_tolerance=3.5,$FL_ADD="ON");
  }

  translate(+X(0.5+TOLERANCE))
    difference() {
      fl_pimoroni(FL_LAYOUT,pimoroni,bottom=false,octant=pim_octant,lay_what="assembly",$FL_LAYOUT="ON")
        hull()
          fl_pcb(FL_CUTOUT,rpi,thick=10,cut_direction=[+X],cut_tolerance=2);
      fl_box(FL_PAYLOAD,pload=bb,thick=T,radius=radius,parts=parts,material_upper=FILAMENT_UPPER,material_lower=FILAMENT_LOWER,tolerance=TOLERANCE,fillet=FILLET,$FL_PAYLOAD="ON");
    }
}

