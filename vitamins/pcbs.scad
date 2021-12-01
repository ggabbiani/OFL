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
FL_PCB_NS  = "PCB";

//*****************************************************************************
// PCB properties
// when invoked by «type» parameter act as getters
// when invoked by «value» parameter act as property constructors
function fl_PCB_holes(type,value)      = fl_property(type,"PCB/holes",value);
function fl_PCB_components(type,value) = fl_property(type,"PCB/components",value);
function fl_PCB_thick(type,value)      = fl_property(type,"PCB/thickness",value);

FL_PCB_RPI4 = let(
  w     = 56,
  l     = 85,
  h     = 16,
  pcb_t = 1.5,
  bbox  = [[-w/2,0,-pcb_t],[+w/2,l,0+h]]
) [
  fl_name(value="RPI4-MODBP-8GB"),
  fl_bb_corners(value=bbox),
  fl_director(value=+FL_Z),fl_rotor(value=+FL_X),
  fl_PCB_thick(value=pcb_t),
  fl_PCB_holes(value=[ 
    // each row represents a hole with the following format:
    // [drill direction],[position]
    [-FL_Z, [ 24.5, 3.5,  0 ]],
    [-FL_Z, [ 24.5, 61.5, 0 ]],
    [-FL_Z, [-24.5, 3.5,  0 ]],
    [-FL_Z, [-24.5, 61.5, 0 ]],
    ]),
  fl_screw(value=M3_cap_screw),
  fl_PCB_components(value=[
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

FL_PCB_DICT = [
  FL_PCB_RPI4,
];

use     <pcb.scad>
