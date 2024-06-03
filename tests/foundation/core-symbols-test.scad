/*
 * Cores symbol test
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


include <../../lib/OFL/foundation/unsafe_defs.scad>

use <../../lib/OFL/foundation/3d-engine.scad>
use <../../lib/OFL/foundation/hole.scad>
use <../../lib/OFL/foundation/label.scad>


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
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]





/* [Test hole] */

// diameter
HOLE_D  = 1;
// normal
HOLE_N  = [0,0,1];
// depth
HOLE_DEPTH  = 2.5;

/* [Symbol] */

SIZE_TYPE       = "default";  // [default,scalar,fl_vector]
SIZE_SCALAR     = 0.5;
SIZE_VECTOR     = [1.0,1.0,0.5];
SYMBOL          = "direction";  // [direction,hole,plug,point,socket]

/* [Direction Symbol] */

DIRECTION       = [0,0,1];
ROTATION        = 0;      // [-360:360]


/* [Hidden] */

fl_status();
verbs=[
  if ($FL_ADD!="OFF")     FL_ADD,
  if ($FL_AXES!="OFF")    FL_AXES,
  if ($FL_LAYOUT!="OFF")  FL_LAYOUT,
];
size  = SIZE_TYPE=="default" ? undef : SIZE_TYPE=="scalar" ? SIZE_SCALAR : SIZE_VECTOR;

// end of automatically generated code

if (SYMBOL=="hole")
  fl_hole_Context(fl_Hole(O,HOLE_D,HOLE_N,HOLE_DEPTH))
    fl_sym_hole(FL_ADD);
else if (SYMBOL=="direction")
  fl_sym_direction(FL_ADD,direction=[DIRECTION,ROTATION],size=size);
else if (SYMBOL=="point")
  fl_sym_point(FL_ADD,size=SIZE_SCALAR);
else
  fl_symbol(verbs=verbs,size=size,symbol=SYMBOL)
    fl_label(FL_ADD,"Ciao!",size=$sym_size.y,thick=0.1,direction=$sym_ldir);

