/*
 * Empty file description
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
 * along with RPI4.  If not, see <http: //www.gnu.org/licenses/>.
 */

// include <OFL/artifacts/pcb_holder.scad>
include <../artifacts/spacer.scad>
include <../vitamins/heatsinks.scad>
include <../vitamins/hds.scad>
include <../artifacts/caddy.scad>
// include <OFL/vitamins/pcbs.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

$FL_FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

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

/* [Stub] */
// distance between Pimoroni and TV uHAT
PIM_TV_DIST = 10;
// box thickness
T=2.5;

/* [Hard Disks] */

// HD caddy tolerance (fl_JNgauge=0.15mm)
HD_TOLERANCE=0.15;
// HD caddy fillet radius
HD_FILLET_R = 1;
// Z delta to add between HDs
HD_GAP    = 1;

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

// fl_pcb_holderByHoles(verbs,FL_PCB_RPI4,h=spacer_h,knut=true,thick=T,direction=direction,octant=octant) ;

pim_bottom  = fl_get(FL_HS_PIMORONI,"bottom part");
pim_fthick  = fl_get(pim_bottom,"layer 0 fluting thickness");
pim_bbox    = fl_bb_corners(FL_HS_PIMORONI);
pim_size    = pim_bbox[1]-pim_bbox[0];

spacer_h    = T+pim_fthick;

tv_size     = let(corner=fl_bb_corners(FL_PCB_RPI_uHAT)) corner[1]-corner[0];
tv_spc_h    = T;

pimoroni([FL_ADD,FL_LAYOUT,FL_ASSEMBLY,FL_BBOX],FL_HS_PIMORONI,octant=-Y+Z,$FL_LAYOUT=ADD,$FL_ASSEMBLY=ASSEMBLY,$FL_ADD=ASSEMBLY,$FL_BBOX=BBOX)
  fl_spacer([FL_ADD,FL_LAYOUT],h=spacer_h,r=$hs_radius,screw=$hs_screw,knut=true,thick=T,lay_direction=[$hs_normal],octant=$hs_normal,$FL_ADD=ADD,$FL_LAYOUT=MOUNT)
    fl_screw([FL_ADD,FL_ASSEMBLY],$spc_screw,thick=$spc_h+$spc_thick,washer="nylon",direction=[$spc_director,0],$FL_ADD=MOUNT,$FL_ASSEMBLY=MOUNT);

// translate([-(pim_size.x/2+PIM_TV_DIST),0,0])
//     fl_pcb([FL_ADD,FL_ASSEMBLY,FL_BBOX,FL_LAYOUT],FL_PCB_RPI_uHAT,direction=[+Y,0],octant=+X-Y+Z,$FL_ADD=ASSEMBLY,$FL_ASSEMBLY=ASSEMBLY,$FL_BBOX=BBOX,$FL_LAYOUT=ADD)
//       translate(-Z($hole_depth))
//         fl_spacer([FL_ADD,FL_LAYOUT],h=tv_spc_h,r=$pcb_radius,screw=$hole_screw,knut=false,thick=T,lay_direction=[-$hole_n],octant=-$hole_n,$FL_ADD=ADD,$FL_LAYOUT=MOUNT)
//           fl_screw([FL_ADD,FL_ASSEMBLY],$spc_screw,thick=$spc_h+$spc_thick,washer="nylon",direction=[$spc_director,0],$FL_ADD=MOUNT,$FL_ASSEMBLY=MOUNT);

translate([-(pim_size.x/2+PIM_TV_DIST),0,0])
fl_pcb([FL_ADD,FL_ASSEMBLY,FL_AXES,FL_BBOX,FL_LAYOUT],FL_PCB_MH4PU_P,octant=+X+Y+Z,direction=[+Z,180],$FL_ADD=ASSEMBLY,$FL_ASSEMBLY=ASSEMBLY,$FL_AXES=AXES,$FL_BBOX=BBOX,$FL_LAYOUT=ADD);

// hd_axis   = +Z;
// hd_list   = [FL_HD_EVO860,FL_HD_EVO860];
// lay_bbox  = lay_bb_corners(hd_axis,HD_GAP,hd_list);
// hds       = fl_bb_new(negative=lay_bbox[0],positive=lay_bbox[1]);
// fl_caddy([FL_ADD,FL_ASSEMBLY,FL_MOUNT],hds,thick=T,faces=[+X,-X],$FL_ADD=ADD,$FL_ASSEMBLY=ASSEMBLY)
//   fl_layout(FL_LAYOUT,hd_axis,HD_GAP,hd_list)
//     echo($cad_verbs=$cad_verbs) 
//     fl_hd($cad_verbs,$item,thick=T+HD_TOLERANCE,$FL_ADD=ASSEMBLY,$FL_MOUNT=MOUNT);
