/*!
 * Box artifact engine.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../artifacts/spacer.scad>
include <../vitamins/countersinks.scad>
include <../vitamins/knurl_nuts.scad>
include <../vitamins/screw.scad>

use <../artifacts/profiles-engine.scad>
use <../foundation/fillet.scad>
use <../foundation/mngm-engine.scad>
use <../foundation/util.scad>

/*!
 * Engine for generating boxes.
 *
 * Context variables:
 *
 * | Name           | Context   | Description |
 * | -------------- | --------  | ----------- |
 * | $box_materials | Children  | list of used materials [«material_lower»,«material_upper»] |
 *
 * TODO: external function returning the resulting bounding box having the
 * payload as input (and vice versa?)
 */
module fl_box(
  //! supported verbs: FL_ADD, FL_AXES, FL_ASSEMBLY, FL_BBOX, FL_LAYOUT, FL_MOUNT, FL_PAYLOAD
  verbs           = FL_ADD,
  //! external dimensions
  xsize,
  //! internal dimensions
  isize,
  //! payload bounding box
  pload,
  //! sheet thickness
  thick,
  //! fold internal radius (square if undef)
  radius,
  //! "all","upper","lower"
  parts="all",
  tolerance       = 0.3,
  //! upper side color
  material_upper,
  //! lower side color
  material_lower,
  fillet          = true,
  /*!
   * payload octant for content positioning
   */
  lay_octant,
  /*!
   * Specifications for the fastenings of the upper part to the lower in
   * [«knurl nut thread type»,«screw nominal size»] format with:
   *
   *   - «knurl nut thread type»: either "linear" or "spiral".
   *   - «screw nominal size»   : countersink screw nominal size
   */
  fastenings=["linear",3],
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant
) {
  kn_type     = fastenings[0];
  scr_nominal = fastenings[1];
  knut        = fl_knut_shortest(fl_knut_find(thread=kn_type,nominal=scr_nominal));
  spacer      = fl_Spacer(knut=knut);
  // first countersink screw matching nominal ⌀
  screw       = let(inventory=fl_ScrewInventory(nominal=scr_nominal, head_type=hs_cs_cap, shorter_than=fl_thick(spacer))) assert(inventory) inventory[0];
  cs          = let(inventory=fl_cs_search(d=scr_nominal)) assert(inventory) inventory[0];

  T_real   = assert(thick) (thick + tolerance);
  // delta = «external bounding box» - «payload bounding box»
  delta  = [
    -[T_real,T_real,thick], // low corner delta
    +[T_real,T_real,T_real+fl_bb_size(spacer).x]  // high corner delta
  ];
  // delta2 = «external bounding box» - «internal bounding box»
  delta2  = [
    -[T_real,T_real,thick], // low corner delta
    +[T_real,T_real,T_real]  // high corner delta
  ];

  size    = let(delta_sz  = delta[1]-delta[0],delta2_sz=delta2[1]-delta2[0])
            xsize
          ? assert(is_undef(isize) && is_undef(pload)) xsize
          : isize ? assert(is_undef(pload)) isize + delta2_sz
          : pload[1]-pload[0]+delta_sz;

  sz_low  = size;
  sz_up   = [size.x,size.y-2*T_real,size.z-T_real];

  // «external bounding box» =  «payload bounding box» + delta
  bbox    = pload ? pload+delta : [-size/2,+size/2];
  // «payload bounding box» = «external bounding box» - delta
  pload   = pload ? pload :  bbox-delta;

  Mfront_knut = T([size.x/2,thick+tolerance-0*(size.y-thick-tolerance),sz_up.z+tolerance]);
  Mback_knut  = T([size.x/2,size.y-thick-tolerance,sz_up.z+tolerance]);

  module back_spacer(verbs=FL_ADD,direction=[+Y,0])
    fl_spacer(verbs,spacer,anchor=[-Y],fillet=fillet?T_real/2:undef,thick=[0,T_real],octant=+Y-Z,direction=direction,$fl_filament=undef)
      children();

  module front_spacer(verbs=FL_ADD)
    back_spacer(verbs, direction=[-Y,180])
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
            if (fillet) let(h=sz_low.x-2*T_real)
              translate(i*Y(size.y-2*thick))
                translate([T_real,thick,thick])
                  fl_fillet([FL_ADD],r=thick,h=h,direction=[+X,90+i*90]);
          }
          fl_cube(size=[size.x,size.y,thick],octant=O0);
        }
        multmatrix(Mback_knut)
          back_spacer([FL_DRILL,FL_LAYOUT],$FL_LAYOUT="ON")
            translate($spc_director*($spc_thick+NIL))
              fl_countersink(type=cs);
        multmatrix(Mfront_knut)
          front_spacer([FL_DRILL,FL_LAYOUT],$FL_LAYOUT="ON")
            translate($spc_director*($spc_thick+NIL))
              fl_countersink(type=cs);
      }
  }

  module upper() {
    translate([0,T_real,T_real])
      fl_bentPlate(FL_ADD,type="U",size=[sz_up.x,sz_up.z,sz_up.y],thick=thick,radius=radius,octant=+X-Y+Z,direction=[+Y,0]/* ,material=material_upper */);
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
          back_spacer(FL_MOUNT)
            fl_screw(FL_DRAW,screw,$fl_thickness=$spc_thickness,$FL_ADD=$FL_MOUNT,$FL_ASSEMBLY=$FL_MOUNT);
        multmatrix(Mfront_knut)
          front_spacer(FL_MOUNT)
            fl_screw(FL_DRAW,screw,$fl_thickness=$spc_thickness,$FL_ADD=$FL_MOUNT,$FL_ASSEMBLY=$FL_MOUNT);
      }
    }
  }

  module do_layout()
    context()
      if (lay_octant)
        let(half_sz = (pload[1]-pload[0])/2)
          translate(pload[0]+half_sz+[lay_octant.x*half_sz.x,lay_octant.y*half_sz.y,lay_octant.z*half_sz.z])
            children();
      else
        children();

  fl_vloop(verbs, bbox, octant, direction) {

    if ($verb==FL_ADD)
      fl_modifier($modifier) do_add();

    else if ($verb==FL_ASSEMBLY)
      fl_modifier($modifier)
        do_assembly();

    else if ($verb==FL_BBOX)
      fl_modifier($modifier) fl_bb_add(bbox);

    else if ($verb==FL_MOUNT)
      fl_modifier($modifier)
        do_mount();

    else if ($verb==FL_LAYOUT)
      fl_modifier($modifier)
        do_layout()
          children();

    else if ($verb==FL_PAYLOAD)
      fl_modifier($modifier)
        fl_bb_add(pload);

    else
      fl_error("unimplemented verb",$verb);
  }
}
