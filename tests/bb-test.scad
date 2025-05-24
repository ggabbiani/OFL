/*
 * Bounding block arithmetic test
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

include <../lib/OFL/foundation/core.scad>

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

empty = [

];

single = [
[[0,0],[1,1]],
];

l1 = [
[[0,0,0],[0,1,1]],
[[0,0,0],[1,1,1]],
[[0,0,0],[2,1,1]],
];

l2 = [
[[0,0,0],[0,1,1]],
[[1,0,0],[1,1,1]],
[[2,0,0],[2,1,1]],
];

function fl_bb_sum(bboxes,__r__) = let(
    len = len(bboxes)
  )
  echo("*********",len=len)
  echo(bboxes=bboxes)
  echo(__r__=__r__)
  len>0
  ? let(
    curr = bboxes[0],
    min  = let(c=curr[0],r=__r__[0]) __r__!=undef ? [min(c.x,r.x),min(c.y,r.y),min(c.z,r.z)] : c,
    max  = let(c=curr[1],r=__r__[1]) __r__!=undef ? [max(c.x,r.x),max(c.y,r.y),max(c.z,r.z)] : c,
    rest = len==1 ? [] : [for(i=[1:len(bboxes)-1]) bboxes[i]]
  )
    echo(min=min)
    echo(max=max)
    fl_bb_sum(rest,[min,max])
  : echo("****FINE****") __r__;

assert(fl_bb_sum(empty)==undef);
assert(fl_bb_sum(single)==single[0]);
assert(fl_bb_sum(l1)==l1[2]);
echo(fl_bb_sum(l2));
