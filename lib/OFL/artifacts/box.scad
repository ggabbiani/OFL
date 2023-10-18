/*!
 * Box artifact engine.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../artifacts/spacer.scad>
include <../vitamins/knurl_nuts.scad>
include <../vitamins/screw.scad>

use <../foundation/fillet.scad>
use <../foundation/mngm-engine.scad>
use <../foundation/profile.scad>
use <../foundation/util.scad>

/*!
 * engine for generating boxes.
 *
 * __children context__:
 *
 * - $box_materials - list of used materials [«material_lower», «material_upper»]
 */
module fl_box(
  //! supported verbs: FL_ADD, FL_AXES, FL_ASSEMBLY, FL_BBOX, FL_LAYOUT, FL_MOUNT, FL_PAYLOAD
  verbs           = FL_ADD,
  //! preset profiles (UNUSED)
  preset,
  //! external dimensions
  xsize,
  //! internal payload size
  isize,
  //! internal bounding box
  pload,
  //! sheet thickness
  thick,
  //! fold internal radius (square if undef)
  radius,
  //! "all","upper","lower"
  parts,
  tolerance       = 0.3,
  //! upper side color
  material_upper,
  //! lower side color
  material_lower,
  fillet          = true,
  lay_octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant
) {
  assert(thick!=undef);

  Treal   = thick + tolerance;
  deltas  = [2*Treal,2*Treal,2*Treal];  // deltas = «external size» - «payload»
  size    = xsize ? assert(is_undef(isize) && is_undef(pload)) xsize
          : isize ? assert(is_undef(pload)) isize + deltas
          : pload[1]-pload[0]+deltas;

  sz_low  = size;
  sz_up   = [size.x,size.y-2*Treal,size.z-Treal];
  bbox    = pload ? [pload[0]-deltas/2,pload[1]+deltas/2] : [-size/2,+size/2];
  knut    = FL_KNUT_LINEAR_M3x8;
  screw   = M3_cs_cap_screw;
  holder_sz = fl_bb_size(knut)+[3,3,-2*FL_NIL];
  // Mknut   = T([0,size.y/2-thick-tolerance,sz_up.z/2-(holder_sz.y+thick-tolerance)/2]);
  Mfront_knut = T([size.x/2,thick+tolerance-0*(size.y-thick-tolerance),sz_up.z+tolerance]);
  Mback_knut      = T([size.x/2,size.y-thick-tolerance,sz_up.z+tolerance]);
  // Mholder = Mknut * Rx(90);
  D       = direction ? fl_direction(direction)  : I;
  M       = fl_octant(octant,bbox=bbox);

  module back_spacer(verbs=FL_ADD)
    fl_spacer(verbs,holder_sz.z,4,screw=screw,knut=true,anchor=[-Y],fillet=fillet?Treal/2:undef,thick=Treal,lay_direction=+Z,octant=+Y-Z,direction=[+Y,0],$fl_filament=undef)
      children();

  module front_spacer(verbs=FL_ADD)
    fl_spacer(verbs,holder_sz.z,4,screw=screw,knut=true,anchor=[-Y],fillet=fillet?Treal/2:undef,thick=Treal,lay_direction=+Z,octant=+Y-Z,direction=[-Y,180],$fl_filament=undef)
      children();

  module context() {
    $box_materials  = [material_lower,material_upper];
    children();
  }

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
          fl_cube(size=[size.x,size.y,thick],octant=O0);
        }
        multmatrix(Mback_knut)
          back_spacer(FL_DRILL);
        multmatrix(Mfront_knut)
          front_spacer(FL_DRILL);
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
      multmatrix(Mback_knut)
        back_spacer();
      multmatrix(Mfront_knut) {
        front_spacer();
      }
  }

  module do_assembly() {
    translate(bbox[0]) {
      if (parts=="all" || parts=="upper") {
        multmatrix(Mback_knut)
          back_spacer(FL_ASSEMBLY);
        multmatrix(Mfront_knut)
          front_spacer(FL_ASSEMBLY);
      }
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
      if (parts=="all" || parts=="lower") {
        multmatrix(Mback_knut)
          back_spacer(FL_MOUNT);
        multmatrix(Mfront_knut)
          front_spacer(FL_MOUNT);
      }
    }
  }

  module do_pload() {
    fl_bb_add([bbox[0]+deltas/2,bbox[1]-deltas/2]);
  }

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction);

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_assembly();

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier) do_mount();

    } else if ($verb==FL_LAYOUT) {
      pload = [bbox[0]+deltas/2,bbox[1]-deltas/2];
      psize = pload[1]-pload[0];
      po    = (pload[1]+pload[0])/2;
      fl_modifier($modifier) context()
        if (lay_octant) {
          translate([lay_octant.x*psize.x/2,lay_octant.y*psize.y/2,lay_octant.z*psize.z/2])
            children();
        } else {
          children();
        }

    } else if ($verb==FL_PAYLOAD) {
      fl_modifier($modifier) do_pload();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
