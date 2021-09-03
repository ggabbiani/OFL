/*
 * Magnets implementation.
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

include <magnets.scad>

include <../foundation/defs.scad>
include <countersinks.scad>

include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/screws.scad>

$fn         = 50;           // [3:50]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = true;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Verbs] */
ADD       = true;
ASSEMBLY  = false;
AXES      = false;
BBOX      = false;
CUTOUT    = false;
DRILL     = false;
FPRINT    = false;
LAYOUT    = false;
PLOAD     = false;

/* [Magnet] */

SHOW      = "ALL"; // [ALL:All, M3_cs_magnet10x2:M3_cs_magnet10x2, M3_cs_magnet10x5:M3_cs_magnet10x5, M3_magnet10x5:M3_magnet10x5, M4_cs_magnet32x6:M4_cs_magnet32x6]
CENTER    = false;
SW_SINGLE = (SHOW!="ALL");
DIRECTION = true;
GROSS     = 0;

/* [Hidden] */

module __test__() {

  // target object(s)
  objs =  (SHOW=="M3_cs_magnet10x2" 
          ? FL_MAG_M3_CS_10x2 
          : (SHOW=="M3_magnet10x5" 
            ? FL_MAG_M3_10x5 
            : (SHOW=="M3_cs_magnet10x5" 
              ? FL_MAG_M3_CS_10x5 
              : (SHOW=="M4_cs_magnet32x6" 
                ? FL_MAG_M4_CS_32x6 : FL_MAG_DICT
                )
              )
            )
          );
  verbs = [
    if (ADD)      FL_ADD,
    if (ASSEMBLY) FL_ASSEMBLY,
    if (FPRINT)   FL_FOOTPRINT,
    if (DRILL)    FL_DRILL,
  ];

  module do_test(magnet) {
    fl_trace("obj name:",fl_name(magnet));
    fl_magnet(verbs,magnet,center=CENTER,direction=DIRECTION,gross=GROSS);
  }

  if (SW_SINGLE)
    do_test(objs);
  else
    layout([for(p = objs) fl_mag_diameter(p)], 10)
      do_test(objs[$i]);

}

function fl_mag_name(type)        = fl_get(type,"name");
function fl_mag_description(type) = fl_get(type,"description");
function fl_mag_diameter(type)    = fl_get(type,"diameter");
function fl_mag_radius(type)      = fl_mag_diameter(type) / 2;
function fl_mag_height(type)      = fl_get(type,"height");
function fl_mag_cs_h(type)        = fl_get(type,"counter sink height");
function fl_mag_color(type)       = fl_get(type,"color");
function fl_mag_screw(type)       = fl_get(type,"screw type");
function fl_mag_cs(type)          = fl_get(type,"counter sink type");

function fl_mag_direction(type)   = fl_mag_height(type) * fl_get(type,"direction")[0];
function fl_mag_origin(type,center=true) = fl_get(type,"direction")[1] + [0,0,(center ? fl_mag_height(type)/2 : fl_mag_height(type))];

// gross: quantity to add to the footprint dimensions
module fl_magnet(verbs=FL_ADD,type,center=true,gross=0,direction=false) {
  assert(verbs!=undef);
  fl_trace("direction",direction);

  cs            = fl_mag_cs(type);
  color         = fl_mag_color(type);
  d             = fl_mag_diameter(type);
  h             = fl_mag_height(type);
  screw         = fl_mag_screw(type);
  screw_len     = screw!=undef  ? screw_longer_than(h)   : undef;
  screw_d       = screw!=undef  ? 2*screw_radius(screw)  : undef;
  h_cs          = cs!=undef     ? fl_mag_cs_h(type)      : undef;
  cs_offset     = h_cs!=undef   ? (center ? h/2-h_cs/2 : h-h_cs) : undef;
  screw_offset  = screw!=undef  ? (center ? h/2 : h)-(h_cs-screw_socket_af(screw)) : undef;

  module do_add() {
    fl_color(color)
    difference() {
      cylinder(d=d, h=h, center=center);
      if (cs!=undef)
        translate(fl_Z(cs_offset+FL_NIL))
          fl_countersink(FL_ADD,type=cs,trunk=h_cs,center=center);
      if (screw!=undef)
        translate(-fl_Z(FL_NIL))
          cylinder(d=screw_d, h=h, center=center);
    }
    if (direction)
      color("red")
        translate(fl_mag_origin(type,center))
          fl_vector(fl_mag_direction(type));
  }

  module do_layout() {
    if (screw!=undef)
      translate(fl_Z(screw_offset+FL_NIL))
        children();
  }

  module do_assembly() {
    do_layout()
      screw(screw,25);
  }

  module do_footprint() {
    cylinder(d=d+gross, h=h+gross, center=center);
    if (direction)
      fl_color("red")
        translate(fl_mag_origin(type,center))
          fl_vector(fl_mag_direction(type));
  }

  module do_bbox() {}
  module do_drill() {}

  fl_parse(verbs) {
    if ($verb==FL_ADD) {
      do_add();
    } else if ($verb==FL_LAYOUT) {
      do_layout()
        children();
    } else if ($verb==FL_FOOTPRINT) {
      do_footprint();
    } else if ($verb==FL_ASSEMBLY) {
      do_assembly();
    } else if ($verb==FL_DRILL) {
      color("orange")
        fl_magnet(FL_LAYOUT,type,center,gross,direction)
          screw(screw,25);
    } else if ($verb==FL_BBOX) {
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

__test__();