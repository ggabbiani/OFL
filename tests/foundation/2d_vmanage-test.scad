/*
 * 2d verb management (fl_2d_vmanage{}) and 2d direction (fl_2d_direction()) tests.
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
// NOTE: ONLY the 2d engine is loaded, 3d-engine.scad must NOT be added here.
use <../../lib/OFL/foundation/2d-engine.scad>
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
/******************************************************************************
 * REGRESSION: the 2d engine must not depend on the 3d one.
 *
 * Only 2d-engine.scad is loaded by this test: any 2d code calling a 3d
 * function (like fl_octant() or fl_direction() did in fl_2d_vmanage{})
 * produces an 'unknown function' WARNING, and any WARNING fails the test.
 */

/******************************************************************************
 * fl_2d_direction()
 */

// undef direction returns the default matrix
assert(fl_2d_direction(undef)==I,fl_2d_direction(undef));
assert(fl_2d_direction(undef,default="none")=="none");

// native direction (+X) is the identity
assert(fl_2d_direction([1,0])==I,fl_2d_direction([1,0]));

// native +X is rotated along «direction», +Y follows (counterclockwise).
// Matrices are built from the versor components: results are exact.
let(
  cases = [
  //  direction   +X image      +Y image
    [ [0,1],      [0,1],        [-1,0]      ],
    [ [-1,0],     [-1,0],       [0,-1]      ],
    [ [0,-1],     [0,-1],       [1,0]       ],
    [ [5,0],      [1,0],        [0,1]       ],  // not normalized
    [ [3,4],      [0.6,0.8],    [-0.8,0.6]  ],  // not normalized
  ]
) for(c=cases) let(
    M = fl_2d_direction(c[0]),
    x = M*[1,0,0,1],
    y = M*[0,1,0,1]
  ) echo(direction=c[0],x=x,y=y)
    assert([x.x,x.y]==c[1],str("direction=",c[0]," +X image=",x))
    assert([y.x,y.y]==c[2],str("direction=",c[0]," +Y image=",y))
    assert(x.z==0 && y.z==0,"2d direction must not leave the XY plane");

/******************************************************************************
 * fl_2d_vmanage{}
 */

object = fl_Object(bbox=[[0,0],[4,2]],name="2d test object");

// REGRESSION: «quadrant» and «direction» are accepted and passed to the
// children context together with the standard fl_generic_vmanage{} variables
fl_2d_vmanage([FL_ADD,FL_AXES,FL_BBOX],object,quadrant=[-1,-1],direction=[0,1])
  echo($this_verb=$this_verb,$this_quadrant=$this_quadrant,$this_direction=$this_direction)
  assert($this_verb==FL_ADD || $this_verb==FL_BBOX,$this_verb)
  assert($this==object,$this)
  assert($this_quadrant==[-1,-1],$this_quadrant)
  assert($this_direction==[0,1],$this_direction)
  assert($this_bbox==[[0,0],[4,2]],$this_bbox)
  assert($this_size==[4,2],$this_size);

// native positioning and direction
fl_2d_vmanage(FL_ADD,object)
  assert(is_undef($this_quadrant),$this_quadrant)
  assert(is_undef($this_direction),$this_direction);
