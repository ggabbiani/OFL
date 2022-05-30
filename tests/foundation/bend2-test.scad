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
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
$FL_ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
$FL_CUTOUT    = "OFF";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
$FL_FOOTPRINT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a box representing the payload of the shape
$FL_PAYLOAD     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

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
// when true folding is NOT bent
FLAT        = false;
BREAK   = 0.5;  // [0:0.1:10]
/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
verbs=[
  if ($FL_ADD!="OFF")       FL_ADD,
  if ($FL_ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if ($FL_AXES!="OFF")      FL_AXES,
  if ($FL_BBOX!="OFF")      FL_BBOX,
  if ($FL_CUTOUT!="OFF")    FL_CUTOUT,
  if ($FL_DRILL!="OFF")     FL_DRILL,
  if ($FL_FOOTPRINT!="OFF")    FL_FOOTPRINT,
  if ($FL_LAYOUT!="OFF")    FL_LAYOUT,
  if ($FL_PAYLOAD!="OFF")     FL_PAYLOAD,
];

size=[51,78,28];
surfaces=[
  [-X,[size.z,size.y,T]],
  [+Z,[size.x,size.y,T]],
  [+Y,[size.x,size.z,T]],
  [-Y,[size.x,size.z/3,T]],
  [+X,[size.z,size.y,T]],
  [-Z,[size.x,size.y,T]],
];

shift = D + DELTA;
folding = fl_folding(faces=surfaces);

fl_bend(verbs,type=folding,flat=FLAT,octant=octant,direction=direction)
  // bending algorithm requires a 3d shape
  linear_extrude(fl_bb_size($sheet).z)
    difference() {
      fl_bb_add(corners=fl_bb_corners($sheet),2d=true);
      let(thick=BREAK+T) {
        let(size=$size[3]) translate($H-Y(thick)) fl_square(size=[size.y,thick,size.z],quadrant=+X+Y);
        let(size=$size[4]) translate($F-X(thick)) fl_square(size=[thick,size.y,size.z],quadrant=+X+Y);
        let(size=$size[5]) translate($P-X(thick)) fl_square(size=[thick,size.y,size.z],quadrant=+X+Y);
        let(size=$size[1]) translate($E-X(thick)) fl_square(size=[thick,size.y,size.z],quadrant=+X+Y);
        let(size=$size[3]) translate($I-X(thick)) fl_square(size=[thick,size.y,size.z],quadrant=+X+Y);
      }
    }
