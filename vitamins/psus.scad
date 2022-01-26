/*
 * PSU vitamin definitions.
 *
 * Copyright © 2021 Giampiero Gabbiani.
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

// include <../foundation/incs.scad>

include <NopSCADlib/lib.scad>

// ***** PSU MeanWell RS-25-5 25W 5V 5A ***************************************

PSU_MeanWell_RS_25_5 = let(
    size  = [51,78,28],
    pcb_t = 1.6,
    // sheet metal thickness
    t     = 1,
    // TODO: terminal must become a stand-alone vitamin
    term_ways = 5,
    term_step = 7.62,
    term_esz  = [1.62,11,12]
  ) [
    ["name",                "PSU MeanWell RS-25-5 25W 5V 5A"],
    fl_bb_corners(value=[
      [-size.x/2, -term_esz.y,  0     ],  // negative corner
      [+size.x/2,  size.y,      size.z],  // positive corner
    ]),
    fl_screw(value=M3_cs_cap_screw),
    ["pcb thickness",       pcb_t],

    ["terminal screw",      M3_pan_screw  ],
    ["terminal ways",       term_ways     ],
    ["terminal step",       term_step     ],
    ["terminal edge size",  term_esz      ],

    ["grid diameter",       4.4],
    ["grid diagonal delta", 1.6],
    ["grid thickness",      t],
    ["grid surfaces",       [
      [-FL_X,[size.z, size.y, t]],
      [+FL_Z,[size.x, size.y, t]],
      [+FL_Y,[size.x, size.z, t]],
      [-FL_Y,[size.x, 9,      t]],
      [+FL_X,[size.z, size.y, t]],
      [-FL_Z,[size.x, size.y, t]],
    ]],
    fl_holes(value=[
      [[25.5,8.75,14                ],+FL_X, 3, pcb_t],
      [[25.5,75,14                  ],+FL_X, 3, pcb_t],
      [[0,12,0                      ],-FL_Z, 3, pcb_t],
      [[0,67,0                      ],-FL_Z, 3, pcb_t],
      [[-size.x/2+6.2,  size.y, 10  ],+FL_Y, 3, pcb_t],
    ]),
    fl_vendor(value=
      [
        ["Amazon",  "https://www.amazon.it/gp/product/B00MWQDAMU/"],
      ]
    ),
    fl_director(value=-FL_Y),fl_rotor(value=-FL_X),
  ];

PSU_MeanWell_RS_15_5 = let(
    size      = [51,62.5,28],
    pcb_t     = 1.6,
    // sheet metal thickness
    t         = 1,
    // TODO: terminal must become a stand-alone vitamin
    term_ways = 5,
    term_step = 7.62,
    term_esz  = [1.62,11,12]
  ) [
    ["name",                "PSU MeanWell RS-15-5 15W 5V 3A"],
    fl_bb_corners(value=[
      [-size.x/2, -term_esz.y,  0     ],  // negative corner
      [+size.x/2, size.y,       size.z],  // positive corner
    ]),
    fl_screw(value=M3_cs_cap_screw),
    ["pcb thickness",       pcb_t],

    ["terminal screw",      M3_pan_screw  ],
    ["terminal ways",       term_ways     ],
    ["terminal step",       term_step     ],
    ["terminal edge size",  term_esz      ],

    ["grid diameter",       4.4],
    ["grid diagonal delta", 1.6],
    ["grid thickness",      t],
    ["grid surfaces",       [
      [-FL_X,[size.z, size.y, t]],
      [+FL_Z,[size.x, size.y, t]],
      [+FL_Y,[size.x, size.z, t]],
      [-FL_Y,[size.x, 9,      t]],
      [+FL_X,[size.z, size.y, t]],
      [-FL_Z,[size.x, size.y, t]],
    ]],
    fl_holes(value=[
      [[size.x/2,     11.9,   15.1  ],+FL_X, 3, pcb_t],
      [[size.x/2,     size.x, 15.1  ],+FL_X, 3, pcb_t],
      [[0,            8.75,   0     ],-FL_Z, 3, pcb_t],
      [[0,            47.85,  0     ],-FL_Z, 3, pcb_t],
      [[-size.x/2+6.2,  size.y, 10  ],+FL_Y, 3, pcb_t],
    ]),
    fl_vendor(value=
      [
        ["Amazon",  "https://www.amazon.it/gp/product/B00MWQD43U/"],
      ]
    ),
    fl_director(value=-FL_Y),fl_rotor(value=-FL_X),
  ];

FL_PSU_DICT = [
  PSU_MeanWell_RS_25_5,
  PSU_MeanWell_RS_15_5,
];

use <psu.scad>
