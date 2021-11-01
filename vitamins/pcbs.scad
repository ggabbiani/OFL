/*
 * PCB definition file for OpenSCAD Foundation Library.
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
include <../vitamins/hdmis.scad>
include <../vitamins/jacks.scad>
include <../vitamins/usbs.scad>

include <NopSCADlib/lib.scad>
include <NopSCADlib/vitamins/screws.scad>

//*****************************************************************************
// PCB keys
function fl_PCB_holesKV(value)      = fl_kv("PCB/holes",value);
function fl_PCB_componentsKV(value) = fl_kv("PCB/components",value);

//*****************************************************************************
// PCB getters
function fl_PCB_holes(type)       = fl_get(type,fl_PCB_holesKV()); 
function fl_PCB_components(type)  = fl_get(type,fl_PCB_componentsKV()); 

FL_PCB_RPI4 = let(
  w = 56,
  l = 85,
  h = 16,
  bbox=[[-w/2,0,-1.4],[+w/2,l,0]]
) [
  fl_nameKV("RPI4-MODBP-8GB"),
  fl_bb_cornersKV(bbox),
  fl_sizeKV(bbox[1]-bbox[0]),
  fl_directorKV(+FL_Z),
  fl_rotorKV(+FL_X),
  fl_PCB_holesKV([ 
    // each row represents a hole with the following format:
    // [drill direction],[entrance point]
    [-FL_Z,  [24.5,3.5,0  ] ],
    [-FL_Z,  [24.5,61.5,0  ] ],
    [-FL_Z,  [-24.5,3.5,0 ] ],
    [-FL_Z,  [-24.5,61.5,0 ] ],
    ]),
  fl_screwKV(M3_cap_screw),
  fl_PCB_componentsKV([
    ["USB",   [24.5+1, 3.5+7.7,0],                  [+FL_X,0], FL_USB_TYPE_C],
    ["HDMI",  [24.5+1,3.5+7.7+14.8,0],              [+FL_X,0], FL_HDMI_TYPE_D],
    ["HDMI",  [24.5+1,3.5+7.7+14.8+13.5,0],         [+FL_X,0], FL_HDMI_TYPE_D],
    ["JACK",  [24.5-2.5,3.5+7.7+14.8+13.5+7+7.5,0], [+FL_X,0], FL_JACK],
    ["USB",   [w/2-9, 78,0],                        [+FL_Y,0], FL_USB_TYPE_Ax2],
    ["USB",   [w/2-27, 78,0],                       [+FL_Y,0], FL_USB_TYPE_Ax2],
    ["ETHER", [w/2-45.75, 76,0],                    [+FL_Y,0], undef],
  ]),
];

FL_PCB_DICT = [
  FL_PCB_RPI4,
];

use     <pcb.scad>
