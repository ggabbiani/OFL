/*
 * Sheet bending test
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/foundation/grid.scad>
include <../../lib/OFL/foundation/util.scad>


$fn            = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER     = false;
// Default color for printable items (i.e. artifacts)
$fl_filament   = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]


/* [Debug] */

// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES        = -2;     // [-2:10]
DEBUG_ASSERTIONS  = false;
DEBUG_COMPONENTS  = ["none"];
DEBUG_COLOR       = false;
DEBUG_DIMENSIONS  = false;
DEBUG_LABELS      = false;
DEBUG_SYMBOLS     = false;


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

fl_status();

// end of automatically generated code

verbs=[
  if (ADD!="OFF")       FL_ADD,
  if (AXES!="OFF")      FL_AXES,
  if (BBOX!="OFF")      FL_BBOX,
];

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

