/*
 * Single pole, double throw switch.
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

FL_SODAL_SPDT = let(
  ,len    = 40
  ,d      = 19
  ,head_d = 22
  ,head_h = +2
) [
  fl_name(value="B077HJT92M"),
  fl_description(value="SODIAL(R) SPDT Button Switch 220V"),
  fl_bb_corners(value=[
    [-head_d/2, -head_d/2,  -len+head_h ],  // negative corner
    [+head_d/2, +head_d/2,   head_h     ],  // positive corner
  ]),
  ["nominal diameter",      d],
  ["length",                len],
  ["head diameter",         head_d],
  ["head height",           head_h],
  fl_director(value=+FL_Z),
  fl_rotor(value=+FL_X),
  fl_vendor(value=
    [
      ["Amazon", "https://www.amazon.it/gp/product/B077HJT92M/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1"],
    ]
  ),
];

FL_SPDT_DICT = [ FL_SODAL_SPDT ];

use <spdt.scad>