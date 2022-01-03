/*
 * Vitamins test template.
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
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
include <../../foundation/unsafe_defs.scad>
include <../../foundation/incs.scad>
include <../../vitamins/incs.scad>

include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/pcbs.scad>

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

/* [Supported verbs] */

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
FPRINT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a box representing the payload of the shape
PLOAD     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Wrapper] */

NOP_MODEL = "PERF74x51"; // [PERF74x51, PERF70x51, PERF70x50, PERF60x40, PERF70x30, PERF80x20, RAMPSEndstop, MT3608, PI_IO, ExtruderPCB, ZC_A0591, RPI0, EnviroPlus, ArduinoUno3, ArduinoLeonardo, WD2002SJ, RPI3, RPI4, BTT_SKR_MINI_E3_V2_0, BTT_SKR_E3_TURBO, BTT_SKR_V1_4_TURBO, DuetE, Duex5]
ORIGINAL  = true;

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
  if (FPRINT!="OFF")    FL_FOOTPRINT,
  if (LAYOUT!="OFF")    FL_LAYOUT,
  if (PLOAD!="OFF")     FL_PAYLOAD,
];
nop = NOP_MODEL=="RAMPSEndstop" ? RAMPSEndstop
    : NOP_MODEL=="MT3608" ? MT3608
    : NOP_MODEL=="PI_IO"  ? PI_IO
    : NOP_MODEL=="ExtruderPCB"  ? ExtruderPCB
    : NOP_MODEL=="ZC_A0591" ? ZC_A0591
    : NOP_MODEL=="RPI0" ? RPI0
    : NOP_MODEL=="EnviroPlus" ? EnviroPlus
    : NOP_MODEL=="ArduinoUno3"  ? ArduinoUno3
    : NOP_MODEL=="ArduinoLeonardo"  ? ArduinoLeonardo
    : NOP_MODEL=="WD2002SJ" ? WD2002SJ
    : NOP_MODEL=="RPI3" ? RPI3
    : NOP_MODEL=="RPI4" ? RPI4
    : NOP_MODEL=="BTT_SKR_MINI_E3_V2_0" ? BTT_SKR_MINI_E3_V2_0
    : NOP_MODEL=="BTT_SKR_E3_TURBO" ? BTT_SKR_E3_TURBO
    : NOP_MODEL=="BTT_SKR_V1_4_TURBO" ? BTT_SKR_V1_4_TURBO
    : NOP_MODEL=="DuetE"  ? DuetE
    : NOP_MODEL=="Duex5"  ? Duex5
    : NOP_MODEL=="PERF74x51"  ? PERF74x51
    : NOP_MODEL=="PERF70x50"  ? PERF70x50
    : NOP_MODEL=="PERF60x40"  ? PERF60x40
    : NOP_MODEL=="PERF70x30"  ? PERF70x30
    : PERF80x20;

//                                   l      w      t    r     h     l  c        b     h
//                                   e      i      h    a     o     a  o        o     o
//                                   n      d      i    d     l     n  l        m     l
//                                   g      t      c    i     e     d  o              e
//                                   t      h      k    u              u              s
//                                   h             n    s     d     d  r
//                                                 e
//                                                 s
//                                                 s
//
// Ethernet = ["Ethernet", "Duet Ethernet piggy back",
//                                      33.8,  37.5,  1.6, 0,    2.54, 0, "#1D39AB",  false, [[27.1, -6.3], [7.5, -2.7], [21.3, -31.1]],
//                                                                     [[10.7,  -13.1, 180, "rj45"],
//                                                                      [7.75, -36.2,   0, "-2p54header", 6, 1],
//                                                                      [7.75, -26.04,  0, "-2p54header", 6, 1],
//                                                                      [27.1, -6.3,    0, "-standoff", 5, 4.5, 12.5, 2.54],
//                                                                      [7.5, -2.70,    0, "-standoff", 5, 4.5, 12.5, 2.54],
//                                                                      [21.3, -31.1,   0, "-standoff", 5, 4.5, 12.5, 2.54],
//                                                                     ],
//                                                                     []];
//                                   l      w      t    r     h     l  c        b     h
//                                   e      i      h    a     o     a  o        o     o
//                                   n      d      i    d     l     n  l        m     l
//                                   g      t      c    i     e     d  o              e
//                                   t      h      k    u              u              s
//                                   h             n    s     d     d  r
//                                                 e
//                                                 s
//                                                 s
// PERF80x20 = ["PERF80x20", "Perfboard 80 x 20mm", 
//                                  80,   20,     1.6, 0,   2.3,    0, "green", true, [[2,2],[-2,2],[2,-2],[-2,-2]],
//   ?  ?   g
//   ?  ?   r
//   ?  ?   i
//   ?  ?   d
//
//          o
//          r
//          i
//          g
//          i
//          n
//          
//  [], [], [5.87, 3.49]];
// PERF70x50 = ["PERF70x50", "Perfboard 70 x 50mm", 70, 50, 1.6, 0, 2.3, 0, "green", true, [[2,2],[-2,2],[2,-2],[-2,-2]], [], [], [5.87, 3.49]];
// PERF70x30 = ["PERF70x30", "Perfboard 70 x 30mm", 70, 30, 1.6, 0, 2.3, 0, "green", true, [[2,2],[-2,2],[2,-2],[-2,-2]], [], [], [5.87, 3.49]];
// PERF60x40 = ["PERF60x40", "Perfboard 60 x 40mm", 60, 40, 1.6, 0, 2.3, 0, "green", true, [[2,2],[-2,2],[2,-2],[-2,-2]], [], [], [5.87, 3.49]];
// PERF70x51 = ["PERF70x51", "Perfboard 70 x 51mm", 70, 51, 1.0, 0, 3.0, 0, "sienna", true, [[3.0, 5.25], [-3.0, 5.25], [3.0, -5.25], [-3.0, -5.25]], [], [], [5.79, 3.91]];
// PERF74x51 = ["PERF74x51", "Perfboard 74 x 51mm", 74, 51, 1.0, 0, 3.0, 0, "sienna", true, [[3.0, 3.5], [-3.0, 3.5], [3.0, -3.5], [-3.0, -3.5]], [], [], [9.5, 4.5]];

/**
 * returns nop grid size in [cols,rows]
 */
function nop_grid_size(nop) = let(
    o     =  pcb_grid(type),
    cols  = is_undef(grid[2]) ? round((pcb_length(type) - 2 * o.x) / inch(0.1)) : grid[2] - 1,
    rows  = is_undef(grid[3]) ? round((pcb_width(type) - 2 * o.y) / inch(0.1))  : grid[3] - 1
  ) [cols,rows];

function nop_grid2holes(type) = let(
  grid_sz = nop_grid_size(type),
  cols    = grid_sz.x,
  rows    = grid_sz.y,
  holes   = [for(x=[0:cols],y=[0:rows]) pcb_grid_pos(type)]
) holes;

/**
 * tarnsforms nop hole list into OFL hole list
 */
function nop_holes(nop) = let(
    pcb_t     = pcb_thickness(nop),
    hole_d    = pcb_hole_d(nop),
    nop_holes = pcb_holes(nop),
    holes     = [
      for(h=nop_holes) [
        let(p=pcb_coord(nop, h)) [p.x,p.y,pcb_t],  // 3d point
        +Z,                           // plane normal
        hole_d,                       // hole diameter
        pcb_t                         // hole depth
      ]
    ]
  ) holes;

/**
 * wrapper constructor from NopSCADlib pcb objects.
 * Returns a valid OFL PCB.
 */
function fl_pcb_Wrapper(nop) = let(
    w         = max(pcb_width(nop),pcb_length(nop)),
    l         = min(pcb_width(nop),pcb_length(nop)),
    h         = 0,
    pcb_t     = pcb_thickness(nop),
    bbox      = [[-w/2,-l/2,0],[+w/2,+l/2,pcb_t+h]]
  )
  [
    // fl_nopSCADlib(value=nop),
    fl_bb_corners(value=bbox),
    fl_director(value=+FL_Z),fl_rotor(value=+FL_X),
    fl_pcb_thick(value=pcb_t),
    fl_pcb_components(value=[]),
    fl_screw(value=M3_cap_screw),
    fl_material(value=pcb_colour(nop)),
    fl_pcb_radius(value=pcb_radius(nop)),
    fl_holes(value=nop_holes(nop)),
    fl_pcb_grid(value=pcb_grid(nop)),
  ];

if (ORIGINAL)
  pcb(nop);
else {
  pcb = fl_pcb_Wrapper(nop);
  fl_pcb(verbs,type=pcb,direction=direction,octant=octant,
      $FL_TRACE=true,
      $FL_ADD=ADD,$FL_ASSEMBLY=ASSEMBLY,$FL_AXES=AXES,$FL_BBOX=BBOX,$FL_CUTOUT=CUTOUT,$FL_DRILL=DRILL,$FL_FOOTPRINT=FPRINT,$FL_LAYOUT=LAYOUT,$FL_PAYLOAD=PLOAD
      );
}
// $FL_ADD=ADD;$FL_ASSEMBLY=ASSEMBLY;$FL_AXES=AXES;$FL_BBOX=BBOX;$FL_CUTOUT=CUTOUT;$FL_DRILL=DRILL;$FL_FOOTPRINT=FPRINT;$FL_LAYOUT=LAYOUT;$FL_PAYLOAD=PLOAD;
