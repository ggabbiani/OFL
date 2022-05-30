/*
 * Vitamins test template.
 *
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org)
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

include <../../foundation/grid.scad>
include <../../foundation/util.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, trace messages are turned on
$fl_traces   = false;

$FL_FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Supported verbs] */

// adds shapes to scene.
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [grid] */
MODE        = "sheet";  // [sheet,bent,both]
// folding thickness
T           = 0.5;  // [0.1:0.1:1]
// inter drill shape distance
DELTA       = 1.60;
// drill shape diameter
D           = 4.4;
// hole edge number for grid 1
EDGES_1 = 50; // [3:1:50]
// drill rotation about +Z on grid 1
ROT_1   = 0;  // [0:360]
// hole edge number for grid 2
EDGES_2 = 50; // [3:1:50]
// drill rotation about +Z on grid 2
ROT_2    = 0; // [0:360]

/* [Hidden] */

verbs=[
  if (ADD!="OFF")       FL_ADD,
  if (AXES!="OFF")      FL_AXES,
  if (BBOX!="OFF")      FL_BBOX,
];

// $FL_ADD=ADD;$FL_ASSEMBLY=ASSEMBLY;$FL_AXES=AXES;$FL_BBOX=BBOX;$FL_CUTOUT=CUTOUT;$FL_DRILL=DRILL;$FL_FOOTPRINT=FPRINT;$FL_LAYOUT=LAYOUT;$FL_PAYLOAD=PLOAD;

size = [51,62.5,28];

surfaces=[
  [-FL_X,[size.z, size.y, T]],
  [+FL_Z,[size.x, size.y, T]],
  [+FL_Y,[size.x, size.z, T]],
  [-FL_Y,[size.x, 9,      T]],
  [+FL_X,[size.z, size.y, T]],
  [-FL_Z,[size.x, size.y, T]],
];

shift = D + DELTA;
folding = fl_folding(faces=surfaces);

// for(oct=[-Z-X,+Z+X]) translate(10*[oct.x,0,0])
  // fl_bend(verbs,type=folding,flat=oct==-Z-X,octant=oct,

module test() {
  if (MODE=="both")
    for($octant=[-X+Y+Z,+X+Y+Z]) translate(40*[$octant.x,0,0])
      let($flat=$octant==+X+Y+Z) children();
  else
    let(
      $flat   = MODE=="sheet",
      $octant = MODE=="sheet" ? undef : +Y+Z
    ) children();
  }

test()
  fl_bend(verbs,type=folding,flat=$flat,octant=$octant,
          $FL_ADD=ADD,$FL_AXES=AXES,$FL_BBOX=BBOX)
    // bending algorithm requires a 3d shape
    linear_extrude(fl_bb_size($sheet).z)
      // grid algorithm operates on 2d surfaces
      difference() {
        // 2d surface fitting the calculated $sheet size
        fl_bb_add(corners=fl_bb_corners($sheet),2d=true);
        // grid on face 4 (normal +Y) and part of face 1 (normal +Z)
        if (search($fid,[4,1])) fl_grid_layout(
          origin  = [0,D],
          r_step  = shift,
          // bounding box C-M
          bbox    = [$C,$M] + [[shift,-shift],-[5,9]],
          clip    = false
        ) rotate(ROT_2,Z) fl_circle(d=D,$fn=EDGES_2);
        // grid on face 0,1 (normal -X and +Z)
        if (search($fid,[0,1])) fl_grid_layout(
          origin=[2*shift,1.5*shift],
          r_step  = shift,
          // bounding box A-F
          bbox    = [$A,$F] + [[1,5],-[5,3]],
          clip    = false
        ) rotate(ROT_1,Z) fl_circle(d=D,$fn=EDGES_1);
      }
