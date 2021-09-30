/*
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org).
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

include <unsafe_defs.scad>
use     <3d.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

BBOX        = false;

/* [Layout] */

GAP           = 5;
AXIS          = "+X"; // [+X, -X, +Y, -Y, +Z, -Z]

/* [Hidden] */

module __test__() {
  psu= [
    ["name", "PSU MeanWell RS-25-5 25W 5V 5A"],
    fl_bb_cornersKV([
        [-51/2, -11,   0],  // negative corner
        [+51/2,  78,  28],  // positive corner
      ]),
  ];

  hd = [
    ["name",  "Samsung V-NAND SSD 860 EVO"],
    fl_bb_cornersKV([
      [-69/2,-(13+3),0],  // negative corner
      [69/2,100,6.7],     // positive corner
    ]),
  ];

  rpi = [
    ["name",                "RPI4-MODBP-8GB"],
    fl_bb_cornersKV([
      [-56/2-2.5,  -3, -1.5],     // negative corner
      [+56/2,     85,  -1.5+16],  // positive corner
    ]),
  ];

  types   = [rpi,hd,hd,psu];
  bcs     = [for(t=types) fl_bb_corners(t)];
  axis    = AXIS=="+X" ? +X : AXIS=="-X" ? -X : AXIS=="+Y" ? +Y : AXIS=="-Y" ? -Y : AXIS=="+Z" ? +Z : -Z;

  module arrow() {
    first   = types[0];
    size    = lay_bb_size(axis,GAP,types);
    sum     = axis*[1,1,1]>0;
    corner  = fl_bb_corners(first);
    pivot   = sum ? corner[0] : corner[1];

    translate(fl_3d_vectorialProjection(pivot,axis))
      fl_vector(abs(size*axis)*axis);
  }

  fl_color("red") arrow();

  fl_layout(axis,GAP,types) { 
    let(type=rpi, bc=fl_bb_corners(type)) fl_bb_add(bc);
    let(type=hd,  bc=fl_bb_corners(type)) fl_bb_add(bc);
    let(type=hd,  bc=fl_bb_corners(type)) fl_bb_add(bc);
    let(type=psu, bc=fl_bb_corners(type)) fl_bb_add(bc);
  }
  bc = lay_bb_corners(axis,GAP,types);
  fl_trace("bc",bc);
  if (BBOX) 
    %fl_bb_add(bc);
}

/**
 * ... an unveiled mistery ...
 */
function lay_align_many(axis,types) = let(
  dummy = echo(fl_trace("****DEPRECATED***")) true
)
[
  for(t=types) let(c=fl_bb_corners(t)) [[c[0].x,0,c[0].z],[c[1].x,c[1].y-c[0].y,c[1].z]]
];

/**
 * creates a group with the resulting bounding box corners of a layout
 */
function lay_group(axis,gap,types) = [fl_bb_cornersKV(lay_bb_corners(axis,gap,types))];

/**
 * add a bounding box shape
 */
module fl_bb_add(
  corners // bounding box corners
) {
  translate(corners[0]) fl_cube(size=corners[1]-corners[0],octant=+X+Y+Z);
}

/*
 * Projection of «vector» onto a cartesian «axis»
 */
function fl_3d_vectorialProjection(
  vector, // 3D vector
  axis    // cartesian axis ([-1,0,0]==[1,0,0]==X)
) = 
assert(len(vector)==3,str("vector=",vector))
assert(fl_3d_abs(axis)==+X||fl_3d_abs(axis)==+Y||fl_3d_abs(axis)==+Z)
let(
  axis=fl_3d_abs(axis)
) (vector*axis)*axis;

/*
 * Projection of «vector» onto a cartesian «plane»
 */
function fl_3d_planarProjection(
  vector, // 3D vector
  plane   // cartesian plane by vector with ([-1,+1,0]==[1,1,0]==XY)
) = assert(
    fl_3d_abs(plane)==+X+Y||fl_3d_abs(plane)==+X+Z
  ||fl_3d_abs(plane)==+Y+X||fl_3d_abs(plane)==+Y+Z
  ||fl_3d_abs(plane)==+Z+X||fl_3d_abs(plane)==+Z+Y
) let(
  plane = fl_3d_abs(plane),
  x = fl_3d_vectorialProjection(vector,X) * plane * X, 
  y = fl_3d_vectorialProjection(vector,Y) * plane * Y, 
  z = fl_3d_vectorialProjection(vector,Z) * plane * Z 
) x+y+z;

/*
 * Transforms a vector inside the +X+Y+Z octant
 */
function fl_3d_abs(a) = [abs(a.x),abs(a.y),abs(a.z)];

/**
 * Builds a minor vector
 */
function fl_3d_min(a,b) = [min(a.x,b.x),min(a.y,b.y),min(a.z,b.z)];
/**
 * Builds a max vector
 */
function fl_3d_max(a,b) = [max(a.x,b.x),max(a.y,b.y),max(a.z,b.z)];
/*
 * Cartesian plane from axis
 */
function fl_3d_orthoPlane(
  axis  // cartesian axis ([-1,0,0]==[1,0,0]==X)
) = assert(
  fl_3d_abs(axis)==+X||fl_3d_abs(axis)==+Y||fl_3d_abs(axis)==+Z
) [axis.x?0:1,axis.y?0:1,axis.z?0:1];

/**
 * calculates the overall bounding box size of a layout
 */
function lay_bb_size(axis,gap,types) = let(c = lay_bb_corners(axis,gap,types)) c[1]-c[0];

/**
 * returns the bounding box corners of a layout
 */
function lay_bb_corners(
  axis, // cartesian axis ([-1,0,0]==[1,0,0]==X)
  gap,  // gap to be inserted between bounding boxes along axis
  types // list of types
) = let(
  bbcs = [for(t=types) fl_bb_corners(t)]
) fl_bb_accum(axis,gap,bbcs);

/**
 * Accumulates a list of bounding boxes along a direction.
 *
 * L'algoritmo è ricorsivo, ad ogni chiamata un bounding box viene estratto dalla lista e
 * scomposto nelle componente assiale e planare. Se è l'ultimo viene restituito come risultato.
 * Se rimangono ancora bounding box da calcolare, viene fatta una nuova chiamata e il suo
 * risultato, scomposto nella componente assiale e planare, usato per produrre un nuovo 
 * bounding box nel seguente modo:
 * - per la componente planare, si calcolano i nuovi corner negativo e positivo con le 
 *   dimensioni minime tra quello corrente ed il risultato della chiamata ricorsiva;
 * - per la componente assiale in caso di asse positivo
 *   - il corner negativo è uguale al corner corrente;
 *   - il corner positivo è pari al corner positivo corrente PIÙ il gap e la dimensione
 *     assiale del risultato;
 * - in caso di asse negativo:
 *   - il corner negativo è pari a quello corrente MENO il gap e la dimensione assiale del
 *     risultato
 *   - il corner positivo è uguale al corner corrente.
 */
function fl_bb_accum(
  axis, // cartesian axis ([-1,0,0]==[1,0,0]==X)
  gap,  // gap to be inserted between bounding boxes along axis
  bbcs  // bounding box corners
) =
assert(fl_3d_abs(axis)==+X||fl_3d_abs(axis)==+Y||fl_3d_abs(axis)==+Z)
assert(len(bbcs))
let(
  len = len(bbcs),
  plane   = fl_3d_orthoPlane(axis),
  sum = axis*[1,1,1]>0,

  curr_result = bbcs[0],
  curr_plane  = [fl_3d_planarProjection(curr_result[0],plane),fl_3d_planarProjection(curr_result[1],plane)],
  curr_axis   = [fl_3d_vectorialProjection(curr_result[0],axis),fl_3d_vectorialProjection(curr_result[1],axis)],

  rest      = len(bbcs)>1 ? [for(i=[1:len(bbcs)-1]) bbcs[i]] : [],
  rest_result  = sum 
  ? len(rest) ? fl_bb_accum(axis,gap,rest) + [O,gap*axis]: [O,O]
  : len(rest) ? fl_bb_accum(axis,gap,rest) - [O,gap*axis]: [O,O],
  rest_plane  = [fl_3d_planarProjection(rest_result[0],plane),fl_3d_planarProjection(rest_result[1],plane)],
  rest_axis = [fl_3d_vectorialProjection(rest_result[0],axis),fl_3d_vectorialProjection(rest_result[1],axis)],

  result_plane  = [fl_3d_min(curr_plane[0],rest_plane[0]),fl_3d_max(curr_plane[1],rest_plane[1])],
  result_axis_size  = rest_axis[1]-rest_axis[0],
  result_axis = sum
  ? [curr_axis[0],curr_axis[1]+result_axis_size]
  : [curr_axis[0]-result_axis_size,curr_axis[1]]
) result_plane + result_axis;

/**
 * layout of types along a direction
 */
module fl_layout(
  axis,   // layout direction
  gap,    // gap inserted along «axis»
  types,  // list of types to be arranged
  _i_=0   // internally used: DO NOT TOUCH
) {  
  fl_trace("$children",$children);
  len = len(types);
  sum = axis*[1,1,1]>0;
  fac = sum ? 1 : -1;
  bcs = [for(t=types) 
    let(cs=fl_bb_corners(t)) 
    [fl_3d_vectorialProjection(cs[0],axis),fl_3d_vectorialProjection(cs[1],axis)]];
  size = [for(c=bcs) c[1]-c[0]];

  fl_trace("bcs",bcs);
  fl_trace("size",size);
  for(i=[0:len-1]) {
    fl_trace("i",i);
    offset = sum
    ? i>0 ? bcs[0][1] -bcs[i][0] : O
    : i>0 ? bcs[0][0] -bcs[i][1] : O;
    sz = i>1 ? fl_accum([for(j=[1:i-1]) size[j]]) : O;
    fl_trace("sz",sz);
    fl_trace("delta",i*gap*axis);
    fl_trace("offset",offset);
    translate(offset+fac*sz+i*gap*axis)
      children(i);
  }
}

__test__();
