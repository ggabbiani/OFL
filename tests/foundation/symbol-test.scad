/*
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

include <../../foundation/hole.scad>
include <../../foundation/label.scad>
include <../../foundation/symbol.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, trace messages are turned on
$fl_traces   = false;

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
  fl_hole_Context([O,HOLE_N,HOLE_D,HOLE_DEPTH]) fl_sym_hole(verbs);
else
  fl_symbol(verbs=verbs,size=size,symbol=SYMBOL)
    fl_label(FL_ADD,"Ciao!",size=$sym_size.y,thick=0.1,direction=$sym_ldir);

