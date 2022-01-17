/*
 * PCB definition file.
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
include <../foundation/defs.scad>
include <../vitamins/ethers.scad>
include <../vitamins/hdmis.scad>
include <../vitamins/jacks.scad>
include <../vitamins/usbs.scad>
include <pin_headers.scad>

include <NopSCADlib/lib.scad>
include <NopSCADlib/vitamins/screws.scad>
include <NopSCADlib/vitamins/pin_headers.scad>

// namespace for PCB engine
FL_PCB_NS  = "pcb";

/**
 * PCB constructor from NopSCADlib.
 *
 * Only basic PCB attributes are imported from NopSCADlib types:
 *
 *  - sizing
 *  - material
 *  - holes
 *  - screw
 *  - grid
 * 
 * NO COMPONENT IS CURRENTLY IMPORTED.
 */
function fl_pcb_import(nop,payload) = let(
    w         = max(pcb_width(nop),pcb_length(nop)),
    l         = min(pcb_width(nop),pcb_length(nop)),
    h         = 0,
    pcb_t     = pcb_thickness(nop),
    bbox      = [[-w/2,-l/2,0],[+w/2,+l/2,pcb_t+h]]
  )
  [
    fl_bb_corners(value=bbox),
    fl_director(value=+FL_Z),fl_rotor(value=+FL_X),
    fl_pcb_thick(value=pcb_t),
    fl_pcb_components(value=[]),
    fl_screw(value=pcb_screw(nop)),
    fl_material(value=pcb_colour(nop)),
    fl_pcb_radius(value=pcb_radius(nop)),
    fl_holes(value=fl_pcb_NopHoles(nop)),
    fl_pcb_grid(value=pcb_grid(nop)),
    fl_payload(value=payload),
  ];

/**
 * Helper for conversion from NopSCADlib hole format to OFL.
 */
function fl_pcb_NopHoles(nop) = let(
  pcb_t     = pcb_thickness(nop),
  hole_d    = pcb_hole_d(nop),
  nop_holes = pcb_holes(nop),
  holes     = [
    for(h=nop_holes) [
      let(p=pcb_coord(nop, h)) [p.x,p.y,pcb_t],  // 3d point
      +FL_Z,  // plane normal
      hole_d, // hole diameter
      pcb_t   // hole depth
    ]
  ]
) holes;

//*****************************************************************************
// PCB properties
// when invoked by «type» parameter act as getters
// when invoked by «value» parameter act as property constructors
function fl_pcb_components(type,value)  = fl_property(type,"pcb/components",value);
function fl_pcb_radius(type,value)      = fl_property(type,"pcb/corners radius",value);
function fl_pcb_thick(type,value)       = fl_property(type,"pcb/thickness",value);
function fl_pcb_grid(type,value)        = fl_property(type,"pcb/grid",value);

FL_PCB_RPI4 = let(
  w       = 56,
  l       = 85,
  h       = 16,
  pcb_t   = 1.5,
  hole_d  = 2.7,
  bbox    = [[-w/2,0,-pcb_t],[+w/2,l,0+h]],
  payload = [bbox[0]+fl_Z(pcb_t),bbox[1]]
) [
  fl_native(value=true),
  fl_name(value="RPI4-MODBP-8GB"),
  fl_bb_corners(value=bbox),
  fl_director(value=+FL_Z),fl_rotor(value=+FL_X),
  fl_pcb_thick(value=pcb_t),
  fl_pcb_radius(value=3),
  fl_payload(value=payload),
  fl_holes(value=[ 
    // each row represents a hole with the following format:
    // [[point],[normal], diameter, thickness]
    [[ 24.5, 3.5,  0 ], +FL_Z, hole_d, pcb_t],
    [[ 24.5, 61.5, 0 ], +FL_Z, hole_d, pcb_t],
    [[-24.5, 3.5,  0 ], +FL_Z, hole_d, pcb_t],
    [[-24.5, 61.5, 0 ], +FL_Z, hole_d, pcb_t],
    ]),
  fl_screw(value=M3_cap_screw),
  fl_pcb_components(value=[
    // each row represent one component with the following format:
    // ["label", ["engine", [position], [[director],rotation] type]]
    ["POWER IN",  ["USB",       [25.5,      11.2, 0], [+FL_X,0  ], FL_USB_TYPE_C  ]],
    ["HDMI0",     ["HDMI",      [25,        26,   0], [+FL_X,0  ], FL_HDMI_TYPE_D ]],
    ["HDMI1",     ["HDMI",      [25,        39.5, 0], [+FL_X,0  ], FL_HDMI_TYPE_D ]],
    ["A/V",       ["JACK",      [22,        54,   0], [+FL_X,0  ], FL_JACK        ]],
    ["USB2",      ["USB",       [w/2-9,     79.5, 0], [+FL_Y,0  ], FL_USB_TYPE_Ax2]],
    ["USB3",      ["USB",       [w/2-27,    79.5, 0], [+FL_Y,0  ], FL_USB_TYPE_Ax2]],
    ["ETHERNET",  [FL_ETHER_NS, [w/2-45.75, 77.5, 0], [+FL_Y,0  ], FL_ETHER_RJ45  ]],
    ["GPIO",      [FL_PHDR_NS,  [-w/2+3.5,  32.5, 0], [+FL_Z,90 ], FL_PHDR_RPIGPIO]],
  ]),
];

FL_PCB_PERF70x50  = fl_pcb_import(PERF70x50);
FL_PCB_PERF60x40  = fl_pcb_import(PERF60x40);
FL_PCB_PERF70x30  = fl_pcb_import(PERF70x30);
FL_PCB_PERF80x20  = fl_pcb_import(PERF80x20);

FL_PCB_DICT = [
  FL_PCB_RPI4,
  FL_PCB_PERF70x50,
  FL_PCB_PERF60x40,
  FL_PCB_PERF70x30,
  FL_PCB_PERF80x20,
];

use     <pcb.scad>
