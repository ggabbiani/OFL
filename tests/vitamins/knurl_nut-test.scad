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

include <../../vitamins/knurl_nuts.scad>

// TODO: implement a CI-TEST parameter set for all test

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

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Knurl nut] */

SHOW    = "All"; // [All, FL_KNUT_M2x4x3p5, FL_KNUT_M2x6x3p5,  FL_KNUT_M2x8x3p5,  FL_KNUT_M2x10x3p5, FL_KNUT_M3x4x5,   FL_KNUT_M3x6x5,    FL_KNUT_M3x8x5,    FL_KNUT_M3x10x5, FL_KNUT_M4x4x6,   FL_KNUT_M4x6x6,    FL_KNUT_M4x8x6,    FL_KNUT_M4x10x6,FL_KNUT_M5x6x7,   FL_KNUT_M5x8x7,    FL_KNUT_M5x10x7]

/* [Hidden] */

module __test__() {
  direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
  octant    = PLACE_NATIVE  ? undef : OCTANT;
  obj       = SHOW=="FL_KNUT_M2x4x3p5"  ? FL_KNUT_M2x4x3p5
            : SHOW=="FL_KNUT_M2x6x3p5"  ? FL_KNUT_M2x6x3p5
            : SHOW=="FL_KNUT_M2x8x3p5"  ? FL_KNUT_M2x8x3p5
            : SHOW=="FL_KNUT_M2x10x3p5" ? FL_KNUT_M2x10x3p5
            : SHOW=="FL_KNUT_M3x4x5"    ? FL_KNUT_M3x4x5
            : SHOW=="FL_KNUT_M3x6x5"    ? FL_KNUT_M3x6x5
            : SHOW=="FL_KNUT_M3x8x5"    ? FL_KNUT_M3x8x5
            : SHOW=="FL_KNUT_M3x10x5"   ? FL_KNUT_M3x10x5
            : SHOW=="FL_KNUT_M4x4x6"    ? FL_KNUT_M4x4x6
            : SHOW=="FL_KNUT_M4x6x6"    ? FL_KNUT_M4x6x6
            : SHOW=="FL_KNUT_M4x8x6"    ? FL_KNUT_M4x8x6
            : SHOW=="FL_KNUT_M4x10x6"   ? FL_KNUT_M4x10x6
            : SHOW=="FL_KNUT_M5x6x7"    ? FL_KNUT_M5x6x7
            : SHOW=="FL_KNUT_M5x8x7"    ? FL_KNUT_M5x8x7
            : SHOW=="FL_KNUT_M5x10x7"   ? FL_KNUT_M5x10x7
            : undef;
  verbs=[
    if (ADD!="OFF")       FL_ADD,
    if (ASSEMBLY!="OFF")  FL_ASSEMBLY,
    if (AXES!="OFF")      FL_AXES,
    if (BBOX!="OFF")      FL_BBOX,
    if (DRILL!="OFF")     FL_DRILL,
  ];
  fl_trace("verbs",verbs);

  module _knut_(verbs,obj) {
    knut(verbs,obj,octant=octant,direction=direction
        ,$FL_ADD=ADD,$FL_ASSEMBLY=ASSEMBLY,$FL_AXES=AXES,$FL_BBOX=BBOX,$FL_DRILL=DRILL);
  }

  if (obj)
    _knut_(verbs,obj);
  else
    for(i=[0:len(FL_KNUT_DICT)-1]) let(row=FL_KNUT_DICT[i],l=len(row)) translate(fl_Y(12*i)) {
      fl_trace("len(row)",len(row));
      fl_layout(axis=+FL_X,gap=3,types=row) {
        if (l>0) let(type=row[0]) _knut_(verbs,type);
        if (l>1) let(type=row[1]) _knut_(verbs,type);
        if (l>2) let(type=row[2]) _knut_(verbs,type);
        if (l>3) let(type=row[3]) _knut_(verbs,type);
      }
    }
}

__test__();