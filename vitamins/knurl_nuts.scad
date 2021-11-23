/*
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
include <NopSCADlib/lib.scad>;

//*****************************************************************************
// key values
function fl_knut_screwKV(value)           = fl_kv("knut/screw",value);
function fl_knut_lengthKV(value)          = fl_kv("knut/Z axis length",value);
function fl_knut_toothHeightKV(value)     = fl_kv("knut/tooth height",value);
function fl_knut_teethNumberKV(value)     = fl_kv("knut/teeth number",value);
function fl_knut_externalRadiusKV(value)  = fl_kv("knut/external radius",value);
function fl_knut_ringsKV(value)           = fl_kv("knut/rings array [[height1,position1],[height2,position2,..]]",value);

/**
 * contructor
 */
function fl_Knut(screw,length,diameter,tooth,rings) = let(
  rlen  = len(rings),
  delta = length/(rlen-1)
) 
assert(screw!=undef,"screw is undef")
assert(is_num(length),str("length=",length))
assert(is_num(diameter),str("diameter=",diameter))
assert(is_num(tooth),str("tooth=",tooth))
[
  fl_knut_screwKV(screw),
  fl_knut_lengthKV(length),
  fl_knut_externalRadiusKV(diameter/2),
  fl_knut_toothHeightKV(tooth),
  fl_knut_teethNumberKV(100),
  fl_knut_ringsKV(
    [for(i=[0:len(rings)-1]) [rings[i],(i<(rlen-1)/2?rings[i]/2:(i==(rlen-1)/2?0:-rings[i]/2))+i*delta-rings[i]/2]] 
  ),
  fl_bb_corners(value=[
    [-diameter/2, -diameter/2,  0],       // negative corner
    [+diameter/2, +diameter/2,  length],  // positive corner
  ]),
  fl_director(value=FL_Z),
  fl_rotor(value=FL_X),
];

FL_KNUT_M2x4x3p5   = fl_Knut(M2_cap_screw,4,3.5,0.6, [1.15,  1.15      ]);
FL_KNUT_M2x6x3p5   = fl_Knut(M2_cap_screw,6,3.5,0.6, [1.5,   1.5       ]);
FL_KNUT_M2x8x3p5   = fl_Knut(M2_cap_screw,8,3.5,0.5, [1.3,   1.4,  1.3 ]);
FL_KNUT_M2x10x3p5  = fl_Knut(M2_cap_screw,10,3.5,0.5,[1.9,   2.0,  1.9 ]);

FL_KNUT_M3x4x5     = fl_Knut(M3_cap_screw,4,5,0.5,   [1.2,   1.2       ]);
FL_KNUT_M3x6x5     = fl_Knut(M3_cap_screw,6,5,0.5,   [1.5,   1.5       ]);
FL_KNUT_M3x8x5     = fl_Knut(M3_cap_screw,8,5,0.5,   [1.9,   1.9       ]);
FL_KNUT_M3x10x5    = fl_Knut(M3_cap_screw,10,5,0.5,  [1.6,   1.5,   1.6]);

FL_KNUT_M4x4x6     = fl_Knut(M4_cap_screw,4,6,0.5,   [1.3,   1.3       ]);
FL_KNUT_M4x6x6     = fl_Knut(M4_cap_screw,6,6,0.5,   [1.7,   1.7       ]);
FL_KNUT_M4x8x6     = fl_Knut(M4_cap_screw,8,6,0.5,   [2.3,   2.3       ]);
FL_KNUT_M4x10x6    = fl_Knut(M4_cap_screw,10,6,0.5,  [1.9,   1.7,   1.9]);

FL_KNUT_M5x6x7     = fl_Knut(M5_cap_screw,6,7.0,0.5, [1.9,   1.9       ]);
FL_KNUT_M5x8x7     = fl_Knut(M5_cap_screw,8,7.0,0.5, [2.4,   2.4       ]);
FL_KNUT_M5x10x7    = fl_Knut(M5_cap_screw,10,7.0,0.8,[1.7,   1.5,  1.7 ]);

FL_KNUT_DICT = [
  [FL_KNUT_M2x4x3p5, FL_KNUT_M2x6x3p5,  FL_KNUT_M2x8x3p5,  FL_KNUT_M2x10x3p5],
  [FL_KNUT_M3x4x5,   FL_KNUT_M3x6x5,    FL_KNUT_M3x8x5,    FL_KNUT_M3x10x5  ],
  [FL_KNUT_M4x4x6,   FL_KNUT_M4x6x6,    FL_KNUT_M4x8x6,    FL_KNUT_M4x10x6  ],
  [FL_KNUT_M5x6x7,   FL_KNUT_M5x8x7,    FL_KNUT_M5x10x7                     ],
];

FL_KNUT_DICT_1 = [
  FL_KNUT_M2x4x3p5, FL_KNUT_M2x6x3p5,  FL_KNUT_M2x8x3p5,  FL_KNUT_M2x10x3p5,
  FL_KNUT_M3x4x5,   FL_KNUT_M3x6x5,    FL_KNUT_M3x8x5,    FL_KNUT_M3x10x5  ,
  FL_KNUT_M4x4x6,   FL_KNUT_M4x6x6,    FL_KNUT_M4x8x6,    FL_KNUT_M4x10x6  ,
  FL_KNUT_M5x6x7,   FL_KNUT_M5x8x7,    FL_KNUT_M5x10x7                     ,
];

use <knurl_nut.scad>