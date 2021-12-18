/*
 * Vitamins test template.
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

/* [grid] */

// folding thickness
T           = 0.5;
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

size = [51,78,28];

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

for(oct=[-Z-X,+Z+X]) translate(10*oct)
  fl_bend(verbs,type=folding,flat=oct==-Z-X,octant=oct)
    // bending algorithm requires a 3d shape
    linear_extrude(fl_bb_size($sheet).z) 
    // grid on face 4 (normal +Y) the bounding box used is the C-M region
    // reduced by (shift,2.5) on the lower corner and (5,10) on the upper one
    fl_2d_grid([$C,$M] + [[shift,-2.5],-[5,10]],shift=shift,d=D,edges=EDGES_2,rotation=ROT_2)
    // grid on face 0,1 (normal -X and +Z) the bounding box used is the A-F region
    // reduced by (4.2,2.2) on the lower corner and (5,3.2) on the upper one
    fl_2d_grid([$A + [4.2,2.2],$F - [5,3.2]],shift=shift,d=D,edges=EDGES_1,rotation=ROT_1)
      // grid algorithm operates on 2d surfaces
      // we add a 2d surface fitting the exact number of sized surfaces
      // passed to the bend constructor through «faces»
      fl_bb_add(corners=fl_bb_corners($sheet),2d=true);

// for(oct=[+Z+X]) translate(10*oct)
// fl_place(folding, octant=oct)
// fl_bb_add(fl_bb_corners(folding));