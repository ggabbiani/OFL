/*
 * pcb_holder test
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
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
SHOW_DIMENSIONS = false;


/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
$FL_ASSEMBLY  = "ON";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
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



/* [Constructor]*/
H_MIN = 4;  // [0.1:0.1:10]
// knurl nut
KNUT  = "none";  // [none,linear,spiral]
PCB   = "Perfboard 80 x 20mm";  //  ["ORICO 4 Ports USB 3.0 Hub 5 Gbps with external power supply port", "Perfboard 70 x 50mm", "Perfboard 60 x 40mm", "Perfboard 70 x 30mm", "Perfboard 80 x 20mm", "RPI4-MODBP-8GB", "Raspberry PI uHAT", "KHADAS-SBC-VIM1"]

/* [Engine] */
// no fillet if zero
FILLET  = .5;  // [0:0.1:5]
// when true also PCB will be shown during FL_ASSEMBLY
ASSEMBLY_ALL  = true;
// thickness on +Z axis
THICK_POSITIVE = 1.6;      // [0:0.1:10]
// thickness on -Z axis
THICK_NEGATIVE = 2.5;      // [0:0.1:10]
// FL_LAYOUT directions
LAYOUT_DIRS  = "±z";  // [±z, -z, +z]


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS,dimensions=SHOW_DIMENSIONS);

fl_status();

// end of automatically generated code

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
thickness = let(t= [
  if (THICK_NEGATIVE) -THICK_NEGATIVE,
  if (THICK_POSITIVE) +THICK_POSITIVE
]) t ? t : undef;

pcb     = fl_pcb_select(PCB);
pcb_scr = fl_screw(pcb);
dirs    = fl_3d_AxisList([LAYOUT_DIRS]);
thread  = KNUT!="none" ? KNUT : undef;
pcbh    = fl_PCBHolder(pcb,h_min=H_MIN,knut_type=thread);

fl_pcbHolder(verbs,pcbh,thick=thickness,lay_direction=dirs,fillet=FILLET,asm_all=ASSEMBLY_ALL,direction=direction,octant=octant)
  if ($pcbh_verb==FL_LAYOUT) echo($spc_thick=$spc_thick) {
    if ($spc_thick)
      translate($spc_director*($spc_thick))
        let(l=1.5*fl_spc_d($pcbh_spacer))
          fl_cube(size=[l,l,$spc_thick],octant=-$spc_director,$FL_ADD=$FL_LAYOUT);
  } else if ($pcbh_verb==FL_MOUNT)
    let(
      htyp    = screw_head_type($pcbh_screw),
      washer  = (htyp==hs_cs||htyp==hs_cs_cap) ? "no" : "nylon"
    ) fl_screw(FL_DRAW,$pcbh_screw,thick=$spc_thickness,washer=washer,$FL_ADD=$FL_MOUNT,$FL_ASSEMBLY=$FL_MOUNT);
  else echo($pcbh_verb=$pcbh_verb);
