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

include <torus.scad>

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
  verbs   = FL_ADD,
  // really needed?
  type    = undef,
  // default size given as a scalar
  size    = 0.5,
  // currently "plug" or "socket"
  symbol
  ) {
  assert(verbs!=undef);

  sz      = size==undef ? [0.5,0.5,0.5] : is_list(size) ? size : [size,size,size];
  d1      = sz.x * 2/3;
  d2      = 0;
  overlap = sz.z / 5;
  h       = (sz.z + 2 * overlap) / 3;
  delta   = h - overlap;
  fl_trace("verbs",verbs);
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
    %fl_cube(octant=symbol=="plug"?-Z:+Z,size=[sz.x,sz.y,0.1]);
    let(sz=2*sz) {
      fl_color("red") translate(-X(sz.x/2)) fl_vector(X(sz.x),ratio=30);
      fl_color("green") translate(-Y(sz.y/2)) fl_vector(Y(sz.y),ratio=30);
    }
  }

  fl_manage(verbs,size=size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
/**
 * this symbol uses as input a complete node context.
 * The symbol is oriented according to the hole normal.
 */
module fl_sym_hole(
  // supported verbs: FL_ADD
  verbs = FL_ADD
) {
  radius  = $hole_d/2;
  D       = fl_align(from=+Z,to=$hole_n);
  rotor   = fl_transform(D,+X);
  bbox    = [
    [-radius,-radius,-$hole_depth],
    [+radius,+radius,0]
  ];
  size    = bbox[1]-bbox[0];
  fl_trace("verbs",verbs);

  module do_add() {
    let(l=$hole_d*3/2,r=radius/20) {
      fl_color("red")
        translate(-X(l/2))
          fl_cylinder(r=r,h=l,direction=[+X,0]);
      fl_color("green")
        translate(-Y(l/2))
          fl_cylinder(r=r,h=l,direction=[+Y,0]);
      fl_color("black")
        for(z=[0,-$hole_depth])
          translate(Z(z))
            fl_torus(r=r,R=$hole_d/2);
    }
    if ($hole_depth)
      %fl_cylinder(d=$hole_d,h=$hole_depth,octant=-Z);
    fl_color("blue")
      fl_vector($hole_depth*Z);
  }

  fl_manage(verbs,direction=D,size=size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
