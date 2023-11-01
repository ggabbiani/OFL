/*
 * pcb_holder test
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/artifacts/pcb_holder.scad>
include <../../lib/OFL/vitamins/pcbs.scad>


$fn            = 50;           // [3:100]
// When true, debug statements are turned on
$fl_debug      = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER     = false;
// Default color for printable items (i.e. artifacts)
$fl_filament   = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES     = -2;     // [-2:10]
SHOW_LABELS     = false;
SHOW_SYMBOLS    = false;


/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
$FL_ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// mount shape through predefined screws
$FL_MOUNT     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a box representing the payload of the shape
$FL_PAYLOAD   = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


/* [3D Placement] */

X_PLACE = "undef";  // [undef,-1,0,+1]
Y_PLACE = "undef";  // [undef,-1,0,+1]
Z_PLACE = "undef";  // [undef,-1,0,+1]


/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [-360:360]


/* [PCB Holder]*/
ENGINE  = "by holes"; // [by holes, by size]
H   = 4;  // [0.1:0.1:10]
// frame thickness on Z axis
FRAME_T  = 0; // [0:0.1:5]
TOLERANCE = 0.5;  // [0:0.1:1]
// thickness along +Z semi axis
T_zp = 0;  // [0:0.1:10]
// thickness along -Z semi axis
T_zn = 0;  // [-10:0.1:0]
// knurl nut
KNUT  = "none";  // [none,linear,spiral]
// FL_LAYOUT directions in floating semi-axis list
LAYOUT_DIRS  = ["±z"];

PCB         = "Perfboard 80 x 20mm";  //  ["HiLetgo SX1308 DC-DC Step up power module", "ORICO 4 Ports USB 3.0 Hub 5 Gbps with external power supply port", "Perfboard 70 x 50mm", "Perfboard 60 x 40mm", "Perfboard 70 x 30mm", "Perfboard 80 x 20mm", "RPI4-MODBP-8GB", "Raspberry PI uHAT", "KHADAS-SBC-VIM1"]


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// end of automatically generated code

thick = [if (T_zn) T_zn,if (T_zp) T_zp];

verbs=fl_verbList([
    FL_ADD,
    FL_ASSEMBLY,
    FL_AXES,
    FL_BBOX,
    FL_DRILL,
    FL_LAYOUT,
    FL_MOUNT,
    FL_PAYLOAD,
  ]
);
pcb   = let(all=FL_PCB_DICT) fl_switch(PCB,fl_list_pack(fl_dict_names(all),all));
dirs  = fl_3d_AxisList(LAYOUT_DIRS);
knut  = KNUT=="none" ? false : KNUT;

// screw   = SCREW=="M2" ? M2_cap_screw : M3_cap_screw;

// frame = FRAME_H && FRAME_T ? [FRAME_H,FRAME_T] : undef;
// holder  = ENGINE=="by holes" ? fl_pcb_HolderByHoles(pcb,H) : fl_pcb_HolderBySize(pcb,H,TOLERANCE);

// fl_pcb_holder(verbs,holder,direction=direction,octant=octant,frame=frame,thick=T,knut=KNUT)
//   fl_screw(type=$hole_screw,thick=H+fl_pcb_thick(pcb)+T);

if (ENGINE=="by holes") {
  if (fl_screw(pcb))
    fl_pcb_holderByHoles(verbs,pcb,H,knut=knut,frame=FRAME_T,thick=thick,lay_direction=dirs,direction=direction,octant=octant) {
      echo($hld_thick=$hld_thick);
      fl_screw(FL_DRAW,type=$hld_screw,thick=$hld_h+fl_pcb_thick($hld_pcb)-$hld_thick[0]+$hld_thick[1],washer="nylon",nut="default",nwasher="nylon",direction=[$spc_director,0]);
    }
  else {
    echo("**NO SCREW ON PCB** either change PCB or choose another engine please");
  }
} else
  fl_pcb_holderBySize(verbs,pcb,H,knut=knut,frame=FRAME_T,thick=thick,lay_direction=dirs,tolerance=TOLERANCE,direction=direction,octant=octant)
    fl_screw(FL_DRAW,type=$hld_screw,thick=$hld_h+$hld_thick[0]+$hld_thick[1],washer="nylon",nut="default",nwasher="nylon",direction=[$spc_director,0]);
