/*!
 * Ethernet.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

use     <NopSCADlib/vitamins/pcb.scad>

include <../foundation/unsafe_defs.scad>

use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>
use <../foundation/mngm.scad>

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
  // fl_director(value=+FL_X),fl_rotor(value=-FL_Z),
  fl_cutout(value=[+FL_X]),

  fl_engine(value=str(FL_ETHER_NS,"/NopSCADlib")),
];

FL_ETHER_RJ45_SM = let(
  // overall dimensions
  l=12.6,w=17.4,h=11.5
) [
  fl_name(value="RJ45 SLIM"),
  fl_bb_corners(value=[[-l+FL_ETHER_FRAME_T,-w/2,-FL_ETHER_Z_OFFSET],+[FL_ETHER_FRAME_T,w/2,h-FL_ETHER_Z_OFFSET]]),
  // fl_director(value=+FL_X),fl_rotor(value=-FL_Z),
  fl_cutout(value=[+FL_X]),

  fl_dxf(value="vitamins/ether-slim.dxf"),
  fl_engine(value=str(FL_ETHER_NS,"/native")),
];

FL_ETHER_DICT = [
  FL_ETHER_RJ45,
  FL_ETHER_RJ45_SM
];

module fl_ether(
  //! supported verbs: FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT
  verbs       = FL_ADD,
  type,
  //! thickness for FL_CUTOUT
  cut_thick,
  //! tolerance used during FL_CUTOUT
  cut_tolerance=0,
  //! translation applied to cutout (default 0)
  cut_drift=0,
  //! see constructor fl_parm_Debug()
  debug,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant,
  // see constructor fl_parm_Debug()
  debug
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(type!=undef);

  size        = fl_size(type);
  plug_l      = FL_ETHER_PLUG_L;
  zoff        = FL_ETHER_Z_OFFSET;
  bbox        = fl_bb_corners(type);
  engine      = fl_engine(type);
  dxf         = engine==str(FL_ETHER_NS,"/native") ? fl_dxf(type) : undef;
  D           = direction ? fl_direction(direction) : FL_I;
  M           = fl_octant(octant,type=type);

  fl_trace("cutout drift",cut_drift);
  fl_trace("DXF file",dxf);

  module do_footprint() {
    translate(X(-size.x+FL_ETHER_FRAME_T)-Z(zoff))
      fl_linear_extrude(direction=[X,90],length=size.x) {
        fl_importDxf(dxf,"body");
        fl_importDxf(dxf,"front");
        fl_importDxf(dxf,"shield");
      }
  }

  module do_cutout() {
    translate(-Z(zoff)+X(0*cut_drift))
      fl_linear_extrude(direction=[X,90],length=cut_thick)
        offset(r=cut_tolerance) {
          fl_importDxf(dxf,"body");
          fl_importDxf(dxf,"front");
        }
  }

  module nop_cutout() {
    translate([cut_thick,0,size.z/2])
      rotate(-90,Y)
        linear_extrude(cut_thick)
          offset(r=cut_tolerance)
            fl_square(FL_ADD,size=[size.z,size.y]);
  }

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
        translate(-X(plug_l)+Z(size.z-0.6))
          fl_cube(size=[size.x-plug_l-FL_ETHER_FRAME_T, size.y-2*(1.5+0.6),size.z-0.6-zoff]
            ,octant=-X-Z
          );
        }
      fl_color("silver")
        translate(-X(plug_l))
          fl_linear_extrude(direction=[X,90],length=plug_l)
            fl_importDxf(dxf,"shield");
      }
  }

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier)
        if (engine==str(FL_ETHER_NS,"/NopSCADlib")) rj45();
        else do_add();

    } else if ($verb==FL_AXES) {
      fl_modifier($modifier) fl_doAxes(size,direction,debug);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_CUTOUT) {
      assert(cut_thick!=undef);
      fl_modifier($modifier)
        translate(+X(bbox[1].x+cut_drift))
          if (engine==str(FL_ETHER_NS,"/NopSCADlib")) nop_cutout();
          else do_cutout();

    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier)
        if (engine==str(FL_ETHER_NS,"/NopSCADlib")) fl_bb_add(bbox);
        else do_footprint();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
