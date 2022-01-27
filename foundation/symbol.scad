/*
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
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

include <3d.scad>

module fl_sym_plug(verbs=[FL_ADD,FL_AXES],type=undef,size=0.5) {
  fl_symbol(verbs,type,size,"plug");
}

module fl_sym_socket(verbs=[FL_ADD,FL_AXES],type=undef,size=0.5) {
  fl_symbol(verbs,type,size,"socket");
}

// provides the symbol required in its 'canonical' form:
// "plug": 'a piece that fits into a hole in order to close it'
//        Its canonical form implies an orientation of the piece coherent
//        with its insertion movement along +Z axis.
// "socket": 'a part of the body into which another part fits'
//        Its canonical form implies an orientation of the piece coherent
//        with its fitting movement along -Z axis.
module fl_symbol(
  verbs   = [FL_ADD,FL_AXES],
  type    = undef,// really needed?
  size    = 0.5,  // default size given as a scalar
  symbol          // currently "plug" or "socket"
  ) {
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
    fl_trace("d1",d1);
    fl_trace("d2",d2);
    fl_color("blue") resize(sz)
      translate(fl_Z(symbol=="socket"?-h:0))
      for(i=symbol=="plug"?[0:+2]:[-2:0])
        translate(fl_Z(i*delta))
          fl_cylinder(d1=d1,d2=d2,h=h);
    %fl_cube(octant=symbol=="plug"?-FL_Z:+FL_Z,size=[sz.x,sz.y,0.1]);
  }

  fl_manage(verbs) {
    if ($verb==FL_ADD) {
      fl_modifier($FL_ADD) do_add();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
    fl_modifier($FL_AXES) fl_axes(size=sz);
  }
}
