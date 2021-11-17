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
// magnet keys
function fl_mag_dKV(value)        = fl_kv("mag/diameter",value);
function fl_mag_csHKV(value)      = fl_kv("mag/counter sink height",value);
function fl_mag_csKV(value)       = fl_kv("mag/counter sink type",value);
function fl_mag_engine_KV(value)  = fl_kv("mag/__internal engine type__",value);

//*****************************************************************************
// magnet getters
function fl_mag_d(type)       = fl_get(type,fl_mag_dKV()); 
function fl_mag_cs_h(type)    = fl_get(type,fl_mag_csHKV());
function fl_mag_cs(type)      = fl_get(type,fl_mag_csKV());
function fl_mag_engine(type)  = fl_get(type,fl_mag_engine_KV());

//*****************************************************************************
// magnet DEPRECATED getters
function fl_mag_diameter(type)  = fl_deprecated("fl_mag_diameter(type)",fl_mag_d(type),"fl_mag_d(type)");
function fl_mag_radius(type)    = fl_deprecated("fl_mag_radius(type)",fl_mag_d(type) / 2,"fl_mag_d(type) / 2");
function fl_mag_height(type)    = fl_deprecated("fl_mag_height(type)",fl_thickness(type),"fl_thickness(type)");
function fl_mag_screw(type)     = fl_deprecated("fl_mag_screw(type)",fl_screw(type),"fl_screw(type)");

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
    fl_nameKV(name),
    fl_descriptionKV(description),
    fl_mag_engine_KV(engine),
    fl_directorKV(+FL_Z), fl_rotorKV(+FL_X),
    if (engine=="cyl") fl_mag_dKV(d),
    fl_sizeKV(bbox[1]-bbox[0]),
    [fl_mag_csKV(),cs],
    if (cs!=undef) fl_mag_csHKV(csh),
    fl_material_KV(grey(80)),
    [fl_screwKV(),screw],
    fl_bb_cornersKV(bbox),
    fl_vendorKV(vendors),
  ];

FL_MAG_M3_CS_10x2 = fl_Magnet(
  name        = "M3_cs_magnet10x2",
  description = "M3 10x2mm countersink magnet",
  d           = 10, thick = 2,
  cs          = FL_CS_M3, csh = 2,
  screw       = M3_cs_cap_screw,
  vendors     = [
      ["Amazon", "https://www.amazon.it/gp/product/B007UOXRY0/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1"],
    ]
);

FL_MAG_M3_10x5  = fl_Magnet(
  name        = "M3_magnet10x5",
  description = "M3 10x5mm magnet",
  d           = 10, thick = 5,
  vendors     = [
      ["Amazon", "https://www.amazon.it/gp/product/B017W7J0TA/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1"],
    ]
);

FL_MAG_M3_CS_10x5 = fl_Magnet(
  name        = "M3_cs_magnet10x5",
  description = "M3 10x5mm countersink magnet",
  d           = 10, thick = 5,
  cs          = FL_CS_M3, csh = 3,
  screw       = M3_cs_cap_screw,
  vendors     = [
      ["Amazon", "https://www.amazon.it/gp/product/B001TOJESK/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1"],
    ]
);

FL_MAG_M4_CS_32x6  = fl_Magnet(
  name        = "M4_cs_magnet32x6",
  description = "M4 32x6mm countersink magnet",
  d           = 32, // actual: 31.89 31.89 31.92 31.88 31.88 31.81 31.88 31.88  ⇒ average: 31.88mm ±0.04mm
  thick       = 6,
  cs          = FL_CS_M3, csh = 2,
  screw       = M3_cs_cap_screw,
  vendors     = [
      ["Amazon", "https://www.amazon.it/gp/product/B07RQL2ZSS/ref=crt_ewc_title_dp_1?ie=UTF8&psc=1&smid=A3USG5B4TCNFER"],
    ]
);

FL_MAG_RECT_10x5x1  = fl_Magnet(
  name        = "RECT_10x5x1",
  description = "10x5x1mm rectangular magnet",
  size        = [10,5,1],
  vendors     = [
      ["Amazon", "https://www.amazon.it/gp/product/B07RQL2ZSS/ref=crt_ewc_title_dp_1?ie=UTF8&psc=1&smid=A3USG5B4TCNFER"],
    ]
);

FL_MAG_RECT_10x5x2  = fl_Magnet(
  name        = "RECT_10x5x2",
  description = "10x5x2mm rectangular magnet",
  size        = [10,5,2],
  vendors     = [
      ["Amazon", "https://www.amazon.it/gp/product/B07RQL2ZSS/ref=crt_ewc_title_dp_1?ie=UTF8&psc=1&smid=A3USG5B4TCNFER"],
    ]
);

FL_MAG_DICT = [
  FL_MAG_M3_CS_10x2,
  FL_MAG_M3_10x5,
  FL_MAG_M3_CS_10x5,
  FL_MAG_M4_CS_32x6,
  FL_MAG_RECT_10x5x1,
  FL_MAG_RECT_10x5x2,
];

use <magnet.scad>
