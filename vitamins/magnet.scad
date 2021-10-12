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

include <../foundation/unsafe_defs.scad>
include <../foundation/defs.scad>

include <countersinks.scad>
include <magnets.scad>

use <../foundation/3d.scad>
use <../foundation/placement.scad>

include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/screws.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

/* [Supported verbs] */

// adds shapes to scene.
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
FPRINT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Magnet] */

SHOW      = "ALL"; // [ALL:All, M3_cs_magnet10x2:M3_cs_magnet10x2, M3_cs_magnet10x5:M3_cs_magnet10x5, M3_magnet10x5:M3_magnet10x5, M4_cs_magnet32x6:M4_cs_magnet32x6]
GROSS     = 0;

/* [Hidden] */

module __test__() {
  direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
  octant    = PLACE_NATIVE  ? undef : OCTANT;
  verbs=[
    if (ADD!="OFF")       FL_ADD,
    if (ASSEMBLY!="OFF")  FL_ASSEMBLY,
    if (AXES!="OFF")      FL_AXES,
    if (BBOX!="OFF")      FL_BBOX,
    if (DRILL!="OFF")     FL_DRILL,
    if (FPRINT!="OFF")    FL_FOOTPRINT,
    if (LAYOUT!="OFF")    FL_LAYOUT,
  ];

  // target object(s)
  object  = SHOW=="M3_cs_magnet10x2"  ? FL_MAG_M3_CS_10x2 
          : SHOW=="M3_magnet10x5"     ? FL_MAG_M3_10x5 
          : SHOW=="M3_cs_magnet10x5"  ? FL_MAG_M3_CS_10x5 
          : SHOW=="M4_cs_magnet32x6"  ? FL_MAG_M4_CS_32x6
          : undef;

  module do_test(magnet) {
    fl_trace("obj name:",fl_name(magnet));
    fl_trace("DIR_NATIVE",DIR_NATIVE);
    fl_trace("DIR_Z",DIR_Z);
    fl_trace("DIR_R",DIR_R);
    screw = fl_mag_screw(magnet);
    fl_magnet(verbs,magnet,gross=GROSS,octant=octant,direction=direction,
      $FL_ADD=ADD,$FL_ASSEMBLY=ASSEMBLY,$FL_AXES=AXES,$FL_BBOX=BBOX,$FL_DRILL=DRILL,$FL_FOOTPRINT=FPRINT,$FL_LAYOUT=LAYOUT)
      if (screw!=undef) fl_color("green") fl_cylinder(h=10,r=screw_radius(screw),octant=O);
  }

  if (object)
    do_test(object);
  else
    layout([for(magnet=FL_MAG_DICT) fl_mag_diameter(magnet)], 10)
      do_test(FL_MAG_DICT[$i]);
}

function fl_mag_diameter(type)    = fl_get(type,"diameter");
function fl_mag_radius(type)      = fl_mag_diameter(type) / 2;
function fl_mag_height(type)      = fl_get(type,"height");
function fl_mag_cs_h(type)        = fl_get(type,"counter sink height");
function fl_mag_color(type)       = fl_get(type,"color");
function fl_mag_screw(type)       = fl_get(type,"screw type");
function fl_mag_cs(type)          = fl_get(type,"counter sink type");

// function fl_bb_calculator(type)   = fl_get(type,"bbox calculator");

module fl_magnet(
  verbs   = FL_ADD, // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  type,             // magnet object
  gross   = 0,      // quantity to add to the footprint dimensions
  direction,        // desired direction [director,rotation], native direction when undef
  octant,           // when undef native positioning is used (+Z)
  axes    = false
) {
  assert(verbs!=undef);
  assert(type!=undef);

  cs            = fl_mag_cs(type);
  color         = fl_mag_color(type);
  d             = fl_mag_diameter(type);
  h             = fl_mag_height(type);
  screw         = fl_mag_screw(type);
  screw_len     = screw!=undef  ? screw_longer_than(h)   : undef;
  screw_d       = screw!=undef  ? 2*screw_radius(screw)  : undef;
  h_cs          = cs!=undef     ? fl_mag_cs_h(type)      : undef;
  cs_offset     = h_cs!=undef   ? h-h_cs : undef;
  screw_offset  = screw!=undef  ? h-(h_cs-screw_socket_af(screw)) : undef;
  bbox          = fl_bb_corners(type);
  size          = bbox[1]-bbox[0];
  name          = fl_name(type);
  D             = direction!=undef ? fl_direction(proto=type,direction=direction) : I;
  M             = octant!=undef ? fl_octant(octant=octant,bbox=bbox) : I;

  fl_trace("direction:",direction);
  fl_trace("D:",D);
  fl_trace("Bounding Box:",bbox);

  module M4_cs_magnet32x6() {
    // d=32;
    fl_trace("size",size);
    shell_r=size.z/2;
    cyl_h=size.z/2;
    shell_t=2;
    little=0.2;
    difference() {
      union() {
        translate([0,0,shell_r])
          rotate_extrude(convexity = 10)
            translate([d/2-shell_r, 0, 0])
              circle(r = shell_r);
        translate(+Z(cyl_h)) fl_cylinder(h=cyl_h,d=d);
        fl_cylinder(h=cyl_h,d=d-2*shell_r);
      }
      translate(+Z(cyl_h+NIL)) fl_cylinder(h=cyl_h,d=d-2*shell_t);  
    }

    translate(+Z(cyl_h)) fl_cylinder(h=cyl_h,d=d-2*shell_t-2*little);  
  }

  module do_add() {
    fl_trace("FL_ADD",$FL_ADD);
    fl_trace("name",name);
    fl_color(color) difference() {
      if (name=="M4_cs_magnet32x6") 
        M4_cs_magnet32x6();
      else 
        fl_cylinder(d=d, h=h, octant=+Z);
      if (cs!=undef)
        // translate(fl_Z(cs_offset+FL_NIL))
          translate(+Z(h+NIL)) fl_countersink(FL_ADD,type=cs);
      if (screw!=undef)
        translate(-fl_Z(FL_NIL))
          fl_cylinder(d=screw_d, h=h, octant=+Z);
    }
  }

  module do_layout() {
    if (screw!=undef)
      // translate(fl_Z(screw_offset+FL_NIL))
      translate(fl_Z(h+FL_NIL))
        children();
  }

  fl_trace("$fn",$fn);

  multmatrix(D) {
    multmatrix(M) fl_parse(fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES)) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_add();
      } else if ($verb==FL_BBOX) {
        fl_trace("$FL_BBOX",$FL_BBOX);
        fl_modifier($FL_BBOX) translate(-Z(NIL)) fl_cube(size=size+Z(2*NIL),octant=+Z);
      } else if ($verb==FL_LAYOUT) {
        fl_modifier($FL_LAYOUT) do_layout()
          children();
      } else if ($verb==FL_FOOTPRINT) {
        fl_modifier($FL_FOOTPRINT) fl_cylinder(d=d+gross, h=h+gross,octant=+Z);
      } else if ($verb==FL_ASSEMBLY) {
        fl_modifier($FL_ASSEMBLY) do_layout()
          screw(screw,25);
      } else if ($verb==FL_DRILL) {
        fl_modifier($FL_DRILL) do_layout()
          translate(+Z(NIL)) screw(screw,25);
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (fl_list_has(verbs,FL_AXES))
      fl_modifier($FL_AXES) fl_axes(size=size);
  }
}

__test__();

