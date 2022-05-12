/*
 * Box artifact.
 *
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org).
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

include <../artifacts/spacer.scad>
include <../foundation/fillet.scad>
include <../foundation/profile.scad>
include <../foundation/util.scad>
include <../vitamins/knurl_nuts.scad>
include <../vitamins/screw.scad>

// engine for generating boxes
module fl_box(
  verbs           = FL_ADD,
  // preset profiles (UNUSED)
  preset,
  // external dimensions
  xsize,
  // internal payload size
  isize,
  // internal bounding box
  pload,
  // sheet thickness
  thick,
  // fold internal radius (square if undef)
  radius,
  // "all","upper","lower"
  parts,
  tolerance       = 0.3,
  // upper side color
  material_upper,
  // lower side color
  material_lower,
  fillet          = true,
  // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  // when undef native positioning is used
  octant
) {
  assert(thick!=undef);

  Treal   = thick + tolerance;
  deltas  = [2*Treal,2*Treal,2*Treal];  // deltas = «external size» - «payload»
  size    = xsize  ? assert(is_undef(isize) && is_undef(pload)) xsize
          : isize ? assert(is_undef(pload)) isize + deltas
          : pload[1]-pload[0]+deltas;

  sz_low  = size;
  sz_up   = [size.x,size.y-2*Treal,size.z-Treal];
  bbox    = pload ? [pload[0]-deltas/2,pload[1]+deltas/2] : [-size/2,+size/2];
  knut    = FL_KNUT_M3x8x5;
  screw   = M3_cs_cap_screw;
  holder_sz = fl_bb_size(knut)+[3,3,-2*FL_NIL];
  // Mknut   = T([0,size.y/2-thick-tolerance,sz_up.z/2-(holder_sz.y+thick-tolerance)/2]);
  Mknut2  = T([size.x/2,size.y-thick-tolerance,Treal+sz_up.z-(holder_sz.y+thick-tolerance)/2]);
  // Mholder = Mknut * Rx(90);
  D       = direction ? fl_direction(direction=direction,default=[+Z,+X])  : I;
  M       = octant    ? fl_octant(octant=octant,bbox=bbox)            : I;

  module do_fillet(r) {
    delta = thick - r;
    for(i=[-1,1])
      translate([0,i*(delta + thick - size.y/2),-size.z/2 + delta + thick])
        fl_fillet(r=r,h=sz_low.x,octant=[1,1,0],direction=[FL_X,-45+i*135]);
  }

  module holder() {
    difference() {
      translate(fl_Z(FL_NIL)) fl_cube(FL_ADD,size=holder_sz,octant=+FL_Z);
      fl_knut(FL_DRILL,knut);
    }
  }

  module fillet(r) {
    delta = thick - r;
    for(i=[-1,1])
      translate([0,i*(delta + thick - size.y/2),-size.z/2 + delta + thick])
        fl_fillet(r=r,h=sz_low.x,octant=[1,1,0],direction=[FL_X,-45+i*135]);
  }

  module lower() {
    corners = let(r=radius?radius+thick:0)[r,r,0,0];
      difference() {
        union() {
          for(i=[0,+1]) {
            translate(i*Y(size.y-thick))
              rotate(90,X)
                translate(-Z(thick))
                  linear_extrude(thick)
                    fl_square(quadrant=+X+Y,size=[size.x,size.z],corners=corners);
            if (fillet)
              translate(i*Y(size.y-2*thick))
                translate([0,thick,thick])
                  fl_fillet([FL_ADD],r=thick,h=sz_low.x,direction=[+X,90+i*90]);
          }
          fl_cube(size=[size.x,size.y,thick]);
        }
        translate(+Y(NIL))
        multmatrix(Mknut2)
          fl_spacer([FL_LAYOUT],holder_sz.z,4,screw=screw,knut=true,thick=[[0,0],[0,0],[Treal,Treal]],octant=-Z,direction=[+Y,0],lay_direction=[+Z],$FL_FILAMENT=undef)
            translate($spc_thick*$spc_director)
              fl_screw(FL_FOOTPRINT,screw,10);
      }
  }

  module upper() {
    translate([0,Treal,Treal])
      difference() {
        fl_bentPlate(FL_ADD,type="U",size=[sz_up.x,sz_up.z,sz_up.y],thick=thick,radius=radius,octant=+X-Y+Z,direction=[+Y,0]/* ,material=material_upper */);
        if (fillet)
          for(i=[0,+1])
            translate(i*Y(size.y-2*Treal))
              fl_fillet([FL_ADD],r=Treal,h=sz_low.x,direction=[+X,90+i*90]);
      }
      multmatrix(Mknut2) {
        fl_cutout(holder_sz.z/2,cut=true)
          fl_spacer([FL_ADD],holder_sz.z,4,screw=screw,knut=true,thick=Treal,octant=-Z,direction=[+Y,0],$FL_FILAMENT=undef);
        fl_spacer([FL_ADD],holder_sz.z,4,screw=screw,knut=true,thick=Treal,octant=-Z,direction=[+Y,0],$FL_FILAMENT=undef);
      }
  }

  module do_assembly() {
    translate(bbox[0]) {
      if (parts=="all" || parts=="upper")
        multmatrix(Mknut2)
          fl_spacer([FL_ASSEMBLY],holder_sz.z,4,screw=screw,knut=true,thick=Treal,octant=-Z,direction=[+Y,0],$FL_FILAMENT=undef);
    }
  }

  /**
   * the followed approach is now to draw parts always in the first octant then move to bounding box
   */
  module do_add() {
    translate(bbox[0]) {
      if (parts=="all" || parts==("upper")) fl_color(material_upper) upper();
      if (parts=="all" || parts==("lower")) fl_color(material_lower) lower();
    }
  }

  module do_mount() {
    translate(bbox[0]) {
      if (parts=="all" || parts=="lower")
        multmatrix(Mknut2)
          fl_spacer([FL_MOUNT],holder_sz.z,4,screw=screw,knut=true,thick=Treal,lay_direction=+Z,octant=-Z,direction=[+Y,0],$FL_FILAMENT=undef)
            screw(screw,10);
    }
  }

  module do_pload() {
    fl_bb_add([bbox[0]+deltas/2,bbox[1]-deltas/2]);
  }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_assembly();

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier) do_mount();

    } else if ($verb==FL_PAYLOAD) {
      fl_modifier($modifier) do_pload();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
