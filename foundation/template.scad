/*
 * Template file for OpenSCAD Foundation Library.
 * Created on Fri Jul 16 2021.
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
include <defs.scad>

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

/* [Direction] */

DIR_NATIVE  = true;
DIR_Z       = "Z";  // [X,-X,Y,-Y,Z,-Z]
DIR_R       = 0;    // [-270,-180,-90,0,90,180,270]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Hidden] */

module __test__() {
}

module stub(verbs,type,debug=false,axes=false) {
  assert(verbs!=undef);

  module do_add() {}
  module do_bbox() {}
  module do_assembly() {}
  module do_layout() {}
  module do_drill() {}

  fl_parse(verbs) {
    if ($verb==FL_ADD) {
      do_add();
      if (axes)
        fl_axes();
    } else if ($verb==FL_BBOX) {
      do_bbox();
    } else if ($verb==FL_ASSEMBLY) {
      do_assembly();
    } else if ($verb==FL_LAYOUT) { 
      do_layout() children();
    } else if ($verb==FL_DRILL) {
      color("orange") {
        do_drill();
      }
    } else if ($verb==FL_AXES) {
      fl_axes();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

__test__();
