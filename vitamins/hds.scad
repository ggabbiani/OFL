/*
 * Hard disk definition file.
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
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

include <satas.scad>

// include <OFL/foundation/defs.scad>
include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/screws.scad>

FL_HD_NS  = "hd";

HD_EVO860 = let(
  size  = [70,100,6.7],
  plug  = FL_SATA_POWERDATAPLUG,
  cid   = fl_sata_powerDataCID(),

  Mpd   = let(
    w = size.x,
    l = fl_size(plug).x,
    d = 7
  ) fl_T(fl_X((l-w+2*d)/2)-fl_Z(FL_NIL)) * fl_Rx(90) * fl_octant(plug,octant=+FL_Y-FL_Z),
  
  conns   = fl_sata_conns(plug),
  pc      = fl_conn_clone(conns[0],M=Mpd),
  dc      = fl_conn_clone(conns[1],M=Mpd)
) [
  fl_name(value="Samsung V-NAND SSD 860 EVO"),
  fl_bb_corners(value=[
    [-size.x/2, 0,      0       ],  // negative corner
    [+size.x/2, +size.y,+size.z ],  // positive corner
  ]),
  fl_director(value=+FL_Z),fl_rotor(value=+FL_X),
  fl_size(value=size),
  ["offset",            [0,-size.y/2,-size.z/2]],
  ["corner radius",     3],
  fl_screw(value=M3_cs_cap_screw),
  ["hole depth",        4],
  ["screw block upper", [30.86,  90,   2.5]],
  ["screw block lower", [30.86,  13.5, 2.5]],
  fl_sata_instance(value=plug),
  fl_connectors(value=[pc,dc]),

  ["Mpd",        Mpd ],
];

FL_HD_DICT  = [ HD_EVO860 ];

use <hd.scad>