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
  verbs   = [FL_ADD,FL_AXES],
  type    = undef,// really needed?
  size    = 0.5,  // default size given as a scalar
  symbol          // currently "plug" or "socket"
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
    %fl_cube(octant=symbol=="plug"?-FL_Z:+FL_Z,size=[sz.x,sz.y,0.1]);
  }

  fl_manage(verbs,size=size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

module fl_sym_hole(
  // supported verbs: FL_ADD, FL_ASSEMBLY, FL_AXES, FL_BBOX, FL_CUTOUT, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT, FL_MOUNT, FL_PAYLOAD
  verbs       = FL_ADD, 
  // hole specs
  hole,
  // desired direction [director,rotation], hole normal when undef
  direction,            
  // when undef hole center positioning is used
  octant                
) {
  assert(hole);
  
  center    = hole[0];
  normal    = hole[1];
  diameter  = hole[2];
  radius    = diameter/2;
  depth     = hole[3];

  Dhole = fl_align(from=+Z,to=normal);
  rotor = fl_transform(Dhole,+X);
  Mhole = T(center);

  bbox  = [
    fl_transform(Mhole,[-radius,-radius,-depth]),
    fl_transform(Mhole,[+radius,+radius,0])
  ];
  size  = bbox[1]-bbox[0];

  D     = (direction ? fl_direction(direction=direction,default=[normal,rotor]) : I)
        * Dhole;
  M     = (octant ? fl_octant(octant=octant,bbox=bbox) : I)
        * Mhole;

  module do_add() {
    fl_color("black") 
      fl_cylinder(r=radius,h=depth,octant=-Z);
    fl_color("yellow")
      fl_vector(depth*Z);
  }

  module do_assembly() {

  }

  module do_bbox() {

  }

  module do_cutout() {

  }

  module do_drill() {

  }

  module do_fprint() {

  }

  module do_layout() {
    children();
  }

  module do_mount() {

  }

  module do_pload() {

  }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_assembly();

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox,$FL_ADD=$FL_BBOX);

    } else if ($verb==FL_CUTOUT) {
      fl_modifier($modifier) do_cutout();

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier) do_drill();

    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) do_fprint();

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout()
        children();

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier) do_mount();

    } else if ($verb==FL_PAYLOAD) {
      fl_modifier($modifier) do_pload();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
