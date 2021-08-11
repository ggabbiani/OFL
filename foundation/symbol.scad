/*
 * Created on Tue May 11 2021.
 *
 * Copyright © 2021 Giampiero Gabbiani.
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

include <defs.scad>
use <3d.scad>

$fn       = 50;           // [3:50]
$FL_TRACE    = false;
$FL_RENDER   = false;
$FL_DEBUG    = false;

AXES    = false;

/* [Symbol] */
SIZE_TYPE       = "default";  // [default,scalar,fl_vector]
SIZE_SCALAR     = 0.5;
SIZE_VECTOR     = [1.0,1.0,0.5];
SYMBOL          = "plug";  // [plug,socket]

/* [Hidden] */

module __test__() {
  size  = SIZE_TYPE=="default" ? undef : SIZE_TYPE=="scalar" ? SIZE_SCALAR : SIZE_VECTOR;

  if (SYMBOL=="plug")
    sym_plug(size=size,fl_axes=AXES);
  else
    sym_socket(size=size,fl_axes=AXES);
}

module sym_plug(verbs=FL_ADD,type=undef,size=0.5,debug=false,fl_axes=true) {
  sym_engine(verbs,type,size,"plug",debug,fl_axes);
}

module sym_socket(verbs=FL_ADD,type=undef,size=0.5,debug=false,fl_axes=true) {
  sym_engine(verbs,type,size,"socket",debug,fl_axes);
}

// provides the symbol required in its 'canonical' form:
// "plug": 'a piece that fits into a hole in order to close it'
//        Its canonical form implies an orientation of the piece coherent
//        with its insertion movement along +FL_Z axis. 
// "socket": 'a part of the body into which another part fits'
//        Its canonical form implies an orientation of the piece coherent
//        with its fitting movement along -FL_Z axis. 
module sym_engine(
  verbs   = FL_ADD  // really needed for an 'atomic' shape?
  ,type   = undef   // idem
  ,size   = 0.5     // default size give as a scalar
  ,symbol           // currently "plug" or "socket"
  ,debug  = false
  ,fl_axes   = true
  ) {
  // $FL_TRACE=true;
  assert(verbs!=undef);
  sz      = size==undef ? [0.5,0.5,0.5] : is_list(size) ? size : [size,size,size];
  d1      = sz.x * 2/3;
  d2      = 0;
  fl_overlap = sz.z / 5;
  h       = (sz.z + 2 * fl_overlap) / 3;
  delta   = h - fl_overlap;
  fl_trace("size",size);
  fl_trace("sz",sz);

  module do_add() {
    fl_color("blue") resize(sz) 
      translate(fl_Z(symbol=="socket"?-h:0))
      for(i=symbol=="plug"?[0:+2]:[-2:0])
        translate(fl_Z(i*delta))
          fl_cylinder(d1=d1,d2=d2,h=h);
    %fl_cube(octant=symbol=="plug"?-FL_Z:+FL_Z,size=[sz.x,sz.y,0.1]);
  }

  fl_parse(verbs) {
    if ($verb==FL_ADD) {
      do_add();
      if (fl_axes)
        sym_engine(FL_AXES,type,size,symbol,debug,fl_axes);
    } else if ($verb==FL_BBOX) {
    } else if ($verb==FL_ASSEMBLY) {
    } else if ($verb==FL_LAYOUT) { 
    } else if ($verb==FL_DRILL) {
    } else if ($verb==FL_AXES) {
      fl_axes(sz/* ,symbol=="socket" */);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

__test__();
