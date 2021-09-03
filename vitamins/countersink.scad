/*
 * Countersink implementation.
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

use <NopSCADlib/utils/layout.scad>

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
PLOAD     = false;

/* [Countersink] */

CENTER  = true;
TRUNK   = 1;

/* [Hidden] */

module __test__() {
  diams = [for(cs = FL_CS_DICT) fl_cs_head_d(cs)];
  layout(diams)
    fl_countersink(FL_ADD,FL_CS_DICT[$i],center=CENTER);
  translate(fl_Y(max(diams)+2))
    layout([for(cs = FL_CS_DICT) fl_cs_head_d(cs)])
      fl_countersink(FL_ADD,FL_CS_DICT[$i],trunk=TRUNK,center=CENTER);
}

function fl_cs_h(type)         = fl_get(type, "height");
function fl_cs_nominal_d(type) = fl_get(type, "nominal diameter");
function fl_cs_head_d(type)    = fl_get(type, "head diameter");
function fl_cs_d(type,h)       = let (
  head_d      = fl_cs_head_d(type)
  ,nominal_d  = fl_cs_nominal_d(type)
  )
  h == undef ? head_d : h / fl_cs_h(type) * (head_d - nominal_d) + nominal_d;

module fl_countersink(verb,type,center=true,trunk,debug=false,axes=false) {
  assert(verb!=undef);

  h   = (trunk == undef ? fl_cs_h(type) : trunk);
  d1  = fl_cs_nominal_d(type);
  d2  = fl_cs_d(type,h);

  fl_trace("trunk",trunk);
  fl_trace("h==cs_h(type)?",h==fl_cs_h(type));

  if (verb==FL_ADD) {
    cylinder(d1=d1, d2=d2, h=h, center=center);
  } else {
    assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
  }
}

__test__();