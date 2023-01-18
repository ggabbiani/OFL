/*
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../foundation/hole.scad>
include <../../foundation/label.scad>
include <../../foundation/symbol.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$fl_debug   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]

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
SYMBOL          = "plug";  // [plug,socket,hole]

/* [Hidden] */

verbs=[
  if ($FL_ADD!="OFF")   FL_ADD,
  if ($FL_AXES!="OFF")  FL_AXES,
  if ($FL_LAYOUT!="OFF")  FL_LAYOUT,
];

size  = SIZE_TYPE=="default" ? undef : SIZE_TYPE=="scalar" ? SIZE_SCALAR : SIZE_VECTOR;

if (SYMBOL=="hole")
  fl_hole_Context(fl_Hole(O,HOLE_D,HOLE_N,HOLE_DEPTH))
    fl_sym_hole(FL_ADD);
else
  fl_symbol(verbs=verbs,size=size,symbol=SYMBOL)
    fl_label(FL_ADD,"Ciao!",size=$sym_size.y,thick=0.1,direction=$sym_ldir);

