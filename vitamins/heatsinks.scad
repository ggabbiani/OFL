/*
 * Heatsinks definition file.
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
include <../foundation/defs.scad>

include <NopSCADlib/lib.scad>
include <NopSCADlib/vitamins/screws.scad>

// namespace 
FL_HS_NS  = "hs";

FL_HS_PIMORONI = let(
  size  = [56,87,25.5]
) [
  fl_name(value="PIMORONI Heatsink Case"),
  fl_description(value="PIMORONI Aluminium Heatsink Case for Raspberry Pi 4"),
  fl_bb_corners(value=[
    [-size.x/2, 0,      0       ],  // negative corner
    [+size.x/2, size.y, size.z  ],  // positive corner
  ]),
  fl_screw(value=M2p5_cap_screw),
  fl_director(value=+FL_Z),fl_rotor(value=+FL_X),
  ["DXF model",         "pimoroni.dxf"],
  ["corner radius",      3],
  ["bottom part", [
    ["layer 0 base thickness",    2   ],
    ["layer 0 fluting thickness", 2.3 ],
    ["layer 0 holders thickness", 3   ],
  ]],
  ["top part", [
    ["layer 1 base thickness",    1.5   ],
    ["layer 1 fluting thickness", 8.6   ],
    ["layer 1 holders thickness", 5.5   ],
  ]],
  fl_vendor(value=[
      ["Amazon", "https://www.amazon.it/gp/product/B082Y21GX5/"],
    ]
  ),
];

FL_HS_DICT  = [FL_HS_PIMORONI];

use <heatsink.scad>
