/*
 * Countersink definitions, data taken from:
 * https://www.sailornautica.it/viti-metallo-inox-aisi-316-e-304/927-vite-testa-svasata-piana-esagono-incassato-m3-uni-5933-acciaio-inox-aisi-316.html
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

include <../foundation/defs.scad>
include <NopSCADlib/lib.scad>
include <NopSCADlib/vitamins/screws.scad>

//*****************************************************************************
// key values
function fl_cs_diameterKV(value)  = fl_kv("cs/diameter",value);
function fl_cs_angleKV(value)     = fl_kv("cs/angle",value);

//*****************************************************************************
// getters
function fl_cs_d(type)      = fl_get(type, fl_cs_diameterKV());
function fl_cs_angle(type)  = fl_get(type, fl_cs_angleKV());
function fl_cs_h(type)      = let(
  r     = fl_cs_d(type)/2,
  alpha = fl_cs_angle(type)/2
) r / tan(alpha);
//*****************************************************************************
// constructor
function fl_Countersink(
  name,
  description,
  d,
  angle
) = let(
  r = d/2,
  alpha = angle /2,
  h = r / tan(alpha)
) [
  fl_nameKV(name),
  fl_descriptionKV(description),
  fl_cs_diameterKV(d),
  fl_cs_angleKV(angle),
  fl_bb_cornersKV([[-r,-r,-h],[r,r,0]]),
  fl_directorKV(+FL_Z),
  fl_rotorKV(+FL_X),
];

FL_CS_M3  = fl_Countersink("FL_CS_M3","M3 countersink",6+3/5,angle=90);
FL_CS_M4  = fl_Countersink("FL_CS_M4","M4 countersink",8+4/5,angle=90);
FL_CS_M5  = fl_Countersink("FL_CS_M5","M5 countersink",10+5/5,angle=90);
FL_CS_M6  = fl_Countersink("FL_CS_M6","M6 countersink",12+6/5,angle=90);
FL_CS_M8  = fl_Countersink("FL_CS_M8","M8 countersink",16+8/5,angle=90);
FL_CS_M10 = fl_Countersink("FL_CS_M10","M10 countersink",20+10/5,angle=90);
FL_CS_M12 = fl_Countersink("FL_CS_M12","M12 countersink",24+12/5,angle=90);
FL_CS_M16 = fl_Countersink("FL_CS_M16","M16 countersink",30+16/5,angle=90);
FL_CS_M20 = fl_Countersink("FL_CS_M20","M20 countersink",36+20/5,angle=90);

FL_CS_DICT = [
  FL_CS_M3
  ,FL_CS_M4
  ,FL_CS_M5
  ,FL_CS_M6
  ,FL_CS_M8
  ,FL_CS_M10
  ,FL_CS_M12
  ,FL_CS_M16
  ,FL_CS_M20
];

use <countersink.scad>
