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

include <../foundation/defs.scad>
include <countersinks.scad>

include <NopSCADlib/lib.scad>
include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/screws.scad>

// namespace for pin headers engine
// TODO: extend namespace definition to other modules
FL_MAG_NS  = "mag";

//*****************************************************************************
// magnet properties
// when invoked by «type» parameter act as getters
// when invoked by «value» parameter act as property constructors
function fl_mag_d(type,value)       = fl_property(type,"mag/diameter",value);
function fl_mag_csH(type,value)     = fl_property(type,"mag/counter sink height",value);
function fl_mag_cs(type,value)      = fl_property(type,"mag/counter sink type",value);
function fl_mag_engine(type,value)  = fl_property(type,"mag/__internal engine type__",value);

//*****************************************************************************
// constructor
function fl_Magnet(name,description,d,thick,size,cs,csh,screw,vendors) = 
  assert(thick!=undef || size!=undef)
  let(
    engine  = d!=undef ? "cyl" : "quad",
    bbox    = engine=="cyl" 
              ? assert(size==undef) assert(thick!=undef) fl_bb_cylinder(d=d,h=thick) 
              : assert(size!=undef) [[-size.x/2,-size.y/2,0],[size.x/2,size.y/2,size.z]]
  ) [
    fl_name(value=name),
    fl_description(value=description),
    fl_mag_engine(value=engine),
    fl_director(value=+FL_Z), fl_rotor(value=+FL_X),
    if (engine=="cyl") fl_mag_d(value=d),
    fl_mag_cs(value=cs),
    if (cs!=undef) fl_mag_csH(value=csh),
    fl_material(value=grey(80)),
    fl_screw(value=screw),
    fl_bb_corners(value=bbox),
    fl_vendor(value=vendors),
  ];

FL_MAG_M3_CS_D10x2 = fl_Magnet(
  name        = "mag_M3_cs_d10x2",
  description = "M3 countersink magnet d10x2mm 1.2kg",
  d           = 10, thick = 2,
  cs          = FL_CS_M3, csh = 2,
  screw       = M3_cs_cap_screw,
  vendors     = [
      ["Amazon", "https://www.amazon.it/gp/product/B007UOXRY0/"],
    ]
);

FL_MAG_D10x5  = fl_Magnet(
  name        = "mag_d10x5",
  description = "magnet d10x5mm",
  d           = 10, thick = 5,
  vendors     = [
      ["Amazon", "https://www.amazon.it/gp/product/B017W7J0TA/"],
    ]
);

FL_MAG_M3_CS_D10x5 = fl_Magnet(
  name        = "mag_M3_cs_d10x5",
  description = "M3 countersink magnet d10x5mm 2.0kg",
  d           = 10, thick = 5,
  cs          = FL_CS_M3, csh = 3,
  screw       = M3_cs_cap_screw,
  vendors     = [
      ["Amazon", "https://www.amazon.it/gp/product/B001TOJESK/"],
    ]
);

FL_MAG_M4_CS_D32x6  = fl_Magnet(
  name        = "mag_M4_cs_d32x6",
  description = "M4 countersink magnet d32x6mm 29.0kg",
  d           = 32, // actual: 31.89 31.89 31.92 31.88 31.88 31.81 31.88 31.88  ⇒ average: 31.88mm ±0.04mm
  thick       = 6,
  cs          = FL_CS_M3, csh = 2,
  screw       = M3_cs_cap_screw,
  vendors     = [
      ["Amazon", "https://www.amazon.it/gp/product/B07RQL2ZSS/"],
    ]
);

FL_MAG_RECT_10x5x1  = fl_Magnet(
  name        = "mag_rect_10x5x1",
  description = "rectangular magnet 10x5x1mm",
  size        = [10,5,1],
  vendors     = [
      ["Amazon", "https://www.amazon.it/gp/product/B06XQNG59T/"],
    ]
);

FL_MAG_RECT_10x5x2  = fl_Magnet(
  name        = "mag_rect_10x5x2",
  description = "rectangular magnet 10x5x2mm",
  size        = [10,5,2],
  vendors     = [
      ["Amazon", "https://www.amazon.it/gp/product/B075PBJ31D/"],
    ]
);

FL_MAG_DICT = [
  FL_MAG_M3_CS_D10x2,
  FL_MAG_D10x5,
  FL_MAG_M3_CS_D10x5,
  FL_MAG_M4_CS_D32x6,
  FL_MAG_RECT_10x5x1,
  FL_MAG_RECT_10x5x2,
];

use <magnet.scad>
