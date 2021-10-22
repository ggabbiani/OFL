/*
 * Countersink test.
 *
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

include <../../foundation/unsafe_defs.scad>
include <../../foundation/incs.scad>
include <../../vitamins/incs.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

$FL_FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Supported verbs] */

// adds shapes to scene.
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Countersink] */

SHOW    = "ALL"; // [ALL, FL_CS_M3, FL_CS_M4, FL_CS_M5, FL_CS_M6, FL_CS_M8, FL_CS_M10, FL_CS_M12, FL_CS_M16, FL_CS_M20]
GAP     = 5;

/* [Hidden] */

module __test__() {
  direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
  octant    = PLACE_NATIVE  ? undef : OCTANT;
  verbs=[
    if (ADD!="OFF")   FL_ADD,
    if (AXES!="OFF")  FL_AXES,
    if (BBOX!="OFF")  FL_BBOX,
  ];
  obj = SHOW=="FL_CS_M3"  ? FL_CS_M3
      : SHOW=="FL_CS_M4"  ? FL_CS_M4
      : SHOW=="FL_CS_M5"  ? FL_CS_M5
      : SHOW=="FL_CS_M6"  ? FL_CS_M6
      : SHOW=="FL_CS_M8"  ? FL_CS_M8
      : SHOW=="FL_CS_M10" ? FL_CS_M10
      : SHOW=="FL_CS_M12" ? FL_CS_M12
      : SHOW=="FL_CS_M16" ? FL_CS_M16
      : SHOW=="FL_CS_M20" ? FL_CS_M20
      : undef;

  if (obj)
    fl_countersink(verbs,obj,octant=octant,direction=direction,
                    $FL_ADD=ADD,$FL_AXES=AXES,$FL_BBOX=BBOX);
  else
    fl_layout(X,GAP,FL_CS_DICT)
      fl_countersink(verbs,FL_CS_DICT[$i],octant=octant,direction=direction,
                    $FL_ADD=ADD,$FL_AXES=AXES,$FL_BBOX=BBOX);
}

module fl_countersink(
  verbs,
  type,
  direction,        // desired direction [director,rotation], native direction when undef
  octant            // when undef native positioning is used (+Z)
) {
  assert(verbs!=undef);
  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  d     = fl_cs_d(type);
  h     = fl_cs_h(type);
  D     = direction!=undef ? fl_direction(proto=type,direction=direction) : I;
  M     = octant!=undef ? fl_octant(octant=octant,bbox=bbox) : I;

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD)
        fl_modifier($FL_ADD) 
          fl_cylinder(d1=0,d2=d,h=h,octant=-Z);
      else if ($verb==FL_BBOX)
        fl_modifier($FL_BBOX) translate(Z(NIL)) fl_bb_add(bbox);
      else
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=1.2*size);
  }
}

__test__();