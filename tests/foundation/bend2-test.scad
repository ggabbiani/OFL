/*
 * Another sheet bending test
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/foundation/unsafe_defs.scad>

use <../../lib/OFL/foundation/2d-engine.scad>
use <../../lib/OFL/foundation/3d-engine.scad>
use <../../lib/OFL/foundation/bbox-engine.scad>
use <../../lib/OFL/foundation/util.scad>


$fn            = 50;           // [3:100]
// When true, debug statements are turned on
$fl_debug      = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER     = false;
// Default color for printable items (i.e. artifacts)
$fl_filament   = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES     = -2;     // [-2:10]
SHOW_LABELS     = false;
SHOW_SYMBOLS    = false;


/* [Supported verbs] */

// adds shapes to scene.
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


/* [3D Placement] */

X_PLACE = "undef";  // [undef,-1,0,+1]
Y_PLACE = "undef";  // [undef,-1,0,+1]
Z_PLACE = "undef";  // [undef,-1,0,+1]


/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [-360:360]


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
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// end of automatically generated code

verbs=[
  if (ADD!="OFF")       FL_ADD,
  if (AXES!="OFF")      FL_AXES,
  if (BBOX!="OFF")      FL_BBOX,
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

fl_bend(verbs,type=folding,flat=FLAT,octant=octant,direction=direction,$FL_ADD=ADD,$FL_AXES=AXES,$FL_BBOX=BBOX)
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
