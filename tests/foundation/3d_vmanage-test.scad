/*
 * 3d verb management (fl_vmanage{}) tests and 2d/3d direction coherence.
 *
 * NOTE: this file is generated automatically from 'template-nogui.scad', any
 * change will be lost.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

// **** TEST_INCLUDES *********************************************************
include <../../lib/OFL/foundation/unsafe_defs.scad>
use <../../lib/OFL/foundation/3d-engine.scad>
use <../../lib/OFL/foundation/type-engine.scad>
// **** TAB_Debug *************************************************************
/* [Debug] */

// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES        = -2;     // [-2:10]
DEBUG_ASSERTIONS  = false;
DEBUG_COMPONENTS  = ["none"];
DEBUG_COLOR       = false;
DEBUG_DIMENSIONS  = false;
DEBUG_LABELS      = false;
DEBUG_SYMBOLS     = false;
// **** TEST_PROLOGUE *********************************************************
$dbg_Assert     = DEBUG_ASSERTIONS;
$dbg_Dimensions = DEBUG_DIMENSIONS;
$dbg_Color      = DEBUG_COLOR;
$dbg_Components = DEBUG_COMPONENTS[0]=="none" ? undef : DEBUG_COMPONENTS;
$dbg_Labels     = DEBUG_LABELS;
$dbg_Symbols    = DEBUG_SYMBOLS;

fl_status();
// end of automatically generated code
// true when the 4x4 matrices «a» and «b» are equal within «eps»
function near(a,b,eps=1e-9) = max([for(i=[0:3]) for(j=[0:3]) abs(a[i][j]-b[i][j])])<eps;

/******************************************************************************
 * 2d/3d direction coherence.
 *
 * The 2d direction is a specialization of the 3d one: fl_2d_direction(d)
 * must be equal to fl_direction([+Z,atan2(d.y,d.x)]). The 3d matrix is built
 * with trigonometric functions, so the comparison uses a tolerance.
 */
let(
  directions = [
    [1,0],[0,1],[-1,0],[0,-1],
    [1,1],[-1,1],[-1,-1],[1,-1],
    [3,4],[-2,1],[0.1,-7]
  ]
) for(d=directions) let(
    m2d = fl_2d_direction(d),
    m3d = fl_direction([FL_Z,atan2(d.y,d.x)])
  ) echo(d=d,m2d=m2d,m3d=m3d)
    assert(near(m2d,m3d),str("2d/3d direction mismatch for d=",d,": ",m2d," vs ",m3d));

/******************************************************************************
 * fl_vmanage{}
 */

object = fl_Object(bbox=[[0,0,0],[4,2,1]],name="3d test object");

// REGRESSION: $this_octant is set in the children context
fl_vmanage([FL_ADD,FL_AXES,FL_BBOX],object,octant=[-1,-1,-1],direction=[FL_X,30])
  echo($this_verb=$this_verb,$this_octant=$this_octant,$this_direction=$this_direction)
  assert($this_verb==FL_ADD || $this_verb==FL_BBOX,$this_verb)
  assert($this==object,$this)
  assert($this_octant==[-1,-1,-1],$this_octant)
  assert($this_direction==[FL_X,30],$this_direction)
  assert($this_bbox==[[0,0,0],[4,2,1]],$this_bbox)
  assert($this_size==[4,2,1],$this_size);

// native positioning and direction
fl_vmanage(FL_ADD,object)
  assert(is_undef($this_octant),$this_octant)
  assert(is_undef($this_direction),$this_direction);
