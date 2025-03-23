/*!
 * Ethernet.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

use     <../../ext/NopSCADlib/vitamins/pcb.scad>

include <../foundation/unsafe_defs.scad>

use <../foundation/2d-engine.scad>
use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>
use <../foundation/mngm-engine.scad>
use <../foundation/util.scad>

//! ethernet namespace
FL_ETHER_NS = "ether";

//*****************************************************************************
// Ethernet properties
// when invoked by «type» parameter act as getters
// when invoked by «value» parameter act as property constructors
function fl_ether_Zoffset(type,value) = fl_optProperty(type,"ether/Z offset for SM ethernet",value,0);

//! value of the internally inserted part of an RJ45 plug
FL_ETHER_PLUG_L   = 8.5;
//! part of a surface mount ethernet socket length is reserved for the external frame
FL_ETHER_FRAME_T  = 1.5;
//! a surface mount ethernet socket is partially embedded on PCB
FL_ETHER_Z_OFFSET = 5;

FL_ETHER_RJ45 = let(
  // overall dimensions
  l=21,w=16,h=13.5
) [
  fl_name(value="RJ45"),
  fl_bb_corners(value=[[-l/2,-w/2,0],[+l/2,+w/2,h]]),
  fl_cutout(value=[+X]),

  fl_engine(value=str(FL_ETHER_NS,"/NopSCADlib")),
];

FL_ETHER_RJ45_SM = let(
  // overall dimensions
  l=12.6,w=17.4,h=11.5
) [
  fl_name(value="RJ45 SLIM"),
  fl_bb_corners(value=[[-l+FL_ETHER_FRAME_T,-w/2,-FL_ETHER_Z_OFFSET],+[FL_ETHER_FRAME_T,w/2,h-FL_ETHER_Z_OFFSET]]),
  fl_cutout(value=[+X]),

  fl_dxf(value="vitamins/ether-slim.dxf"),
  fl_engine(value=str(FL_ETHER_NS,"/native")),
];

FL_ETHER_DICT = [
  FL_ETHER_RJ45,
  FL_ETHER_RJ45_SM
];

/*!
 * Ethernet engine.
 *
 * Context variables:
 *
 * | Name             | Context   | Description                                           |
 * | ---------------- | --------- | ----------------------------------------------------- |
 * | $fl_thickness    | Parameter | Used during FL_CUTOUT (see also fl_parm_thickness())  |
 * | $fl_tolerance    | Parameter | Used during FL_CUTOUT (see fl_parm_tolerance())       |
 */
module fl_ether(
  //! supported verbs: FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT
  verbs       = FL_ADD,
  type,
  //! translation applied to cutout (default 0)
  cut_drift=0,
  /*!
   * Cutout direction list in floating semi-axis list (see also fl_tt_isAxisList()).
   *
   * Example:
   *
   *     cut_dirs=[+X,+Z]
   *
   * in this case the ethernet plug will perform a cutout along +X and +Z.
   *
   */
  cut_dirs,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(type!=undef);

  plug_l      = FL_ETHER_PLUG_L;
  zoff        = FL_ETHER_Z_OFFSET;
  engine      = fl_engine(type);
  dxf         = engine==str(FL_ETHER_NS,"/native") ? fl_dxf(type) : undef;
  cut_dirs = cut_dirs ? cut_dirs : fl_cutout(type);

  module do_footprint() {
    if (engine==str(FL_ETHER_NS,"/NopSCADlib")) fl_bb_add($this_bbox);
    else
      translate(X(-$this_size.x+FL_ETHER_FRAME_T)-Z(zoff))
        fl_linear_extrude(direction=[X,90],length=$this_size.x) {
          fl_importDxf(dxf,"body");
          fl_importDxf(dxf,"front");
          // fl_importDxf(dxf,"shield");
        }
  }

  module do_cutout()
    fl_cutoutLoop(cut_dirs, fl_cutout($this))
      fl_new_cutout($this_bbox,$co_current,
        drift         = cut_drift,
        $fl_tolerance = $fl_tolerance+2xNIL
      ) do_footprint();

  module do_add() {
    translate(-Z(zoff)) {
      fl_color(fl_grey(30)) {
        fl_linear_extrude(direction=[X,90],length=FL_ETHER_FRAME_T)
          fl_importDxf(dxf,"front");
        translate(-X(plug_l))
          fl_linear_extrude(direction=[X,90],length=plug_l)
            difference() {
              fl_importDxf(dxf,"body");
              fl_importDxf(dxf,"plug");
            }
        translate(-X(plug_l)+Z($this_size.z-0.6))
          fl_cube($this_size=[$this_size.x-plug_l-FL_ETHER_FRAME_T, $this_size.y-2*(1.5+0.6),$this_size.z-0.6-zoff]
            ,octant=-X-Z
          );
        }
      fl_color("silver")
        translate(-X(plug_l))
          fl_linear_extrude(direction=[X,90],length=plug_l)
            fl_importDxf(dxf,"shield");
      }
  }

  fl_vmanage(verbs, type, octant=octant, direction=direction)
    if ($this_verb==FL_ADD)
      if (engine==str(FL_ETHER_NS,"/NopSCADlib"))
        rj45();
      else
        do_add();

    else if ($this_verb==FL_BBOX)
      fl_bb_add($this_bbox);

    else if ($this_verb==FL_CUTOUT)
      assert(!is_undef($fl_thickness))
      do_cutout();

    else if ($this_verb==FL_FOOTPRINT)
      do_footprint();

    else
      fl_error(["unimplemented verb",$this_verb]);
}
