/*
 * Definition file template for OpenSCAD Foundation Library.
 *
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
use     <../dxf.scad>
include <../foundation/unsafe_defs.scad>
include <../foundation/tube.scad>

MCXJPHSTEM1 = let(
  name  = "50Ω MCX MINI JACK PCB straight edge mount",
  w   = 6.7,
  l   = 9.3,
  h   = 5,
  sz  = [w,l,h],
  bbox  = [[-w/2,0,-h/2+0.4],[+w/2,l,+h/2+0.4]],
  dxf   = "vitamins/MCXJPHSTEM1.dxf"
) [
  fl_native(value=true),
  fl_name(value=name),
  fl_bb_corners(value=bbox),
  fl_director(value=-Y),fl_rotor(value=+X),
  fl_dxf(value=dxf),
];

module MCXJPHSTEM1(
  // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD, 
  type,
  // thickness for FL_CUTOUT, FL_DRILL
  cut_thick,            
  // tolerance used during FL_CUTOUT
  cut_tolerance=0,      
  // translation applied to cutout
  cut_drift=0,          
  // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,            
  // when undef native positioning is used
  octant,               
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  dxf   = fl_dxf(type);
  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  axis  = [0,0,0.4];
  head  = 6.25;
  Mshape  = T(+Y(size.y)) * Rx(90);
  D     = direction ? fl_direction(proto=type,direction=direction)  : I;
  M     = octant    ? fl_octant(octant=octant,bbox=bbox)            : I;

  module do_add() {
    multmatrix(Mshape) {
      fl_color("gold") {
        difference() {
          fprint();
          translate([0,0.4,-NIL])
            fl_cylinder(d=3.45,h=size.y+NIL);
          translate([0,2.9,-NIL])
            fl_cube(size=[size.x,size.z,size.y+NIL2],octant=+Y+Z);
          translate([0,0,-NIL])
            fl_cube(size=[size.x,size.z,size.y-head+NIL2],octant=-Y+Z);
          translate([0,0.4,-NIL])
            fl_cube(size=[size.x,size.z,size.y-head+NIL2],octant=+Y+Z);
        }
        translate(+Y(axis.z))
          fl_tube(d=0.96+NIL2,thick=0.1,h=size.y-2);
        translate([0,axis.z,size.y-head])
          fl_tube(d=3.45+NIL2,thick=(3.45-1.88)/2,h=1);
      }
      fl_color("white") translate([0,axis.z,size.y-head])
        fl_tube(d=1.88+NIL2,thick=(1.88-0.96)/2,h=1);
    }
  }

  module do_assembly() {
    // intentionally empty
  }

  module do_cutout() {
    assert(cut_thick);
    translate(-Y(cut_drift))
      multmatrix(Mshape) 
        translate([0,axis.z,size.y])
          fl_cylinder(d=3.45+cut_tolerance*2,h=cut_thick);
  }

  module do_drill() {
    assert(cut_thick);
    multmatrix(Mshape) 
      translate([0,axis.z,size.y])
        fl_cylinder(d=3.45,h=cut_thick);
  }

  module fprint() {
    difference() {
      translate(+Y(0.4))
        fl_cylinder(d=6.7,h=size.y-NIL);
      translate(-Z(NIL))
        fl_cube(size=[size.x,size.z,size.y+NIL2],octant=-Y+Z);
    }
    fl_cube(size=[4.8,2.1,size.y-NIL],octant=-Y+Z);
  }

  module do_footprint() {
    multmatrix(Mshape) 
      fprint();
  }

  // module do_layout() {

  // }

  // module do_mount() {

  // }

  // module do_pload() {

  // }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_assembly();

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_CUTOUT) {
      fl_modifier($modifier) do_cutout();

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier) do_drill();

    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) do_footprint();

    // } else if ($verb==FL_LAYOUT) {
    //   fl_modifier($modifier) do_layout()
    //     children();

    // } else if ($verb==FL_MOUNT) {
    //   fl_modifier($modifier) do_mount()
    //     children();

    // } else if ($verb==FL_PAYLOAD) {
    //   fl_modifier($modifier) do_pload()
    //     children();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
