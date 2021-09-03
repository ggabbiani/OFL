/*
 * Magnets definitions.
 * 
 * Created  : on Mon Aug 30 2021.
 * Copyright: © 2021 Giampiero Gabbiani.
 * Email    : giampiero@gabbiani.org
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

include <countersinks.scad>

include <NopSCADlib/lib.scad>
include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/screws.scad>

FL_MAG_M3_CS_10x2  = [
  ["name",                "M3_cs_magnet10x2"],
  ["description",         "M3 10x2mm countersink magnet"],
  ["direction",           [[0,0,1],[0,0,0]]], // direction AND origin
  ["diameter",            10],
  ["height",              2.0],
  ["counter sink height",  2],
  ["color",               grey(80)],
  ["screw type",          M3_cs_cap_screw],
  ["counter sink type",   FL_CS_M3],
];

FL_MAG_M3_10x5 = [
  ["name",                "M3_magnet10x5"],
  ["description",         "M3 10x5mm magnet"],
  ["direction",           [[0,0,1],[0,0,0]]],
  ["diameter",            10],
  ["height",               5],
  ["counter sink height",  0],
  ["color",               grey(80)],
  ["screw type",          undef],
  ["counter sink type",   undef],
];

FL_MAG_M3_CS_10x5 = [
  ["name",                "M3_cs_magnet10x5"],
  ["description",         "M3 10x5mm countersink magnet"],
  ["direction",           [[0,0,1],[0,0,0]]],
  ["diameter",            10],
  ["height",              5.0],
  ["counter sink height",  3],
  ["color",               grey(80)],
  ["screw type",          M3_cs_cap_screw,],
  ["counter sink type",   FL_CS_M3],
];

FL_MAG_M4_CS_32x6  = [
  ["name",                "M4_cs_magnet32x6"],
  ["description",         "M4 32x6mm countersink magnet"],
  ["direction",           [[0,0,1],[0,0,0]]],
  ["diameter",            32],  // real: 31.89 31.89 31.92 31.88 31.88 31.81 31.88 31.88  ⇒ average: 31.88mm ±0.04mm
  ["height",              6.0], // real:  5.21  5.17  5.17  5.18  5.14  5.13  5.23  5.10  ⇒ average:  5.17mm ±0.07mm
  ["counter sink height",  3],
  ["color",               grey(80)],
  ["screw type",          M4_cs_cap_screw,],
  ["counter sink type",   FL_CS_M4],
  ["vendor",              [
      ["Amazon", "https://www.amazon.it/gp/product/B07RQL2ZSS/ref=crt_ewc_title_dp_1?ie=UTF8&psc=1&smid=A3USG5B4TCNFER"]
    ]
  ]
];

FL_MAG_DICT = [
  FL_MAG_M3_CS_10x2
  ,FL_MAG_M3_10x5
  ,FL_MAG_M3_CS_10x5
  ,FL_MAG_M4_CS_32x6
];

use <magnet.scad>
