/*!
 * NopSCADlib Jack definitions wrapper.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../foundation/3d-engine.scad>
include <../foundation/connect.scad>
include <../foundation/label.scad>

use <../foundation/3d-engine.scad>
use <../foundation/mngm.scad>
use <../foundation/util.scad>

FL_JACK_NS = "jack";

FL_JACK_BARREL = let(
  // following data definitions taken from NopSCADlib jack() module
  l = 12,
  w = 7,
  h = 6,
  ch = 2.5,
  // calculated bounding box corners
  bbox      = [[-l/2,-w/2,0],[+l/2+ch,+w/2,h]]
) [
  fl_bb_corners(value=bbox),
  // fl_director(value=+FL_X),fl_rotor(value=+FL_Y),
  fl_cutout(value = [+FL_X]),
  fl_engine(value="fl_jack_barrelEngine"),
];

FL_JACK_MCXJPHSTEM1 = let(
  name  = "50Ω MCX EDGE MOUNT JACK PCB CONNECTOR",
  w     = 6.7,
  l     = 9.3,
  h     = 5,
  sz    = [w,l,h],
  axis  = [0,0,0.4],
  bbox  = [[-w/2,0,-h/2+axis.z],[+w/2,l,+h/2+axis.z]],
  d_ext = 6.7,
  head  = 6.25,
  tail  = sz.y - head,
  jack  = sz.y-2
) [
  fl_name(value=name),
  fl_bb_corners(value=bbox),
  // fl_director(value=-FL_Y),fl_rotor(value=+X),
  fl_cutout(value = [-FL_Y]),
  fl_engine(value="fl_jack_mcxjphstem1Engine"),
  fl_connectors(value=[
    conn_Socket("antenna",+FL_X,-FL_Z,[0,0,axis.z],size=3.45,octant=-FL_X-FL_Y,direction=[-FL_Z,180])
  ]),
  ["axis of symmetry",  axis],
  ["external diameter", d_ext],
  ["head",              head],
  ["tail",              tail],
  ["jack length",       jack]
];

FL_JACK_DICT = [
  FL_JACK_BARREL,
  FL_JACK_MCXJPHSTEM1,
];

/*!
 * Jack engine.
 */
module fl_jack(
  //! supported verbs: FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT
  verbs       = FL_ADD,
  type,
  //! thickness for FL_CUTOUT
  cut_thick,
  //! tolerance used during FL_CUTOUT
  cut_tolerance=0,
  //! translation applied to cutout
  cut_drift=0,
  //! see constructor fl_parm_Debug()
  debug,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant,
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(type!=undef);
  engine  = fl_engine(type);
  if (engine=="fl_jack_barrelEngine")
    fl_jack_barrelEngine(verbs,type,cut_thick,cut_tolerance,cut_drift,debug,direction,octant);
  else if (engine=="fl_jack_mcxjphstem1Engine")
    fl_jack_mcxjphstem1Engine(verbs,type,cut_thick,cut_tolerance,cut_drift,debug,direction,octant);
  else
    assert(false,str("Engine '",engine,"' unknown."));
}

/*!
 * Barrel jack engine.
 */
module fl_jack_barrelEngine(
  //! supported verbs: FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT
  verbs       = FL_ADD,
  type,
  //! thickness for FL_CUTOUT
  cut_thick,
  //! tolerance used during FL_CUTOUT
  cut_tolerance=0,
  //! translation applied to cutout
  cut_drift=0,
  //! see constructor fl_parm_Debug()
  debug,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant,
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(type!=undef);

  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  D     = direction ? fl_direction(direction) : FL_I;
  M     = fl_octant(octant,bbox=bbox);

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier)
        jack();
    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction,debug);
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);
    } else if ($verb==FL_CUTOUT) {
      assert(cut_thick!=undef);
      fl_modifier($modifier)
        translate(+fl_X(bbox[1].x-2.5+cut_drift))
          fl_cutout(len=cut_thick,z=X,x=-FL_Z,delta=cut_tolerance,trim=fl_X(-size.x/2),cut=true)
            jack();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

// FIXME: issue when directing, likely to be related to the 'D' matrix when director is not +Z
/*!
 * Engine for RF MCX edge mount jack pcb connector
 * specs taken from https://www.rfconnector.com/mcx/edge-mount-jack-pcb-connector
 */
module fl_jack_mcxjphstem1Engine(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  type,
  //! thickness for FL_CUTOUT
  cut_thick,
  //! tolerance used during FL_CUTOUT
  cut_tolerance=0,
  //! translation applied to cutout
  cut_drift=0,
  //! see constructor fl_parm_Debug()
  debug,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant,
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  bbox    = fl_bb_corners(type);
  size    = fl_bb_size(type);
  d_ext   = fl_get(type,"external diameter");
  axis    = fl_get(type, "axis of symmetry");
  head    = fl_get(type,"head");
  tail    = fl_get(type,"tail");
  jack    = fl_get(type,"jack length");
  Mshape  = T(+fl_Y(size.y)) * Rx(90);
  conns   = fl_connectors(type);
  D       = direction ? fl_direction(direction) : FL_I;
  M       = fl_octant(octant,bbox=bbox);

  module do_add() {
    multmatrix(Mshape) {
      fl_color("gold") {
        difference() {
          fprint();
          translate([0,axis.z,-FL_NIL])
            fl_cylinder(d=3.45,h=size.y+FL_NIL);
          translate([0,0,-FL_NIL])
            fl_cube(size=[size.x,size.z,size.y-head+FL_NIL2],octant=-FL_Y+FL_Z);
          translate([0,axis.z,-FL_NIL])
            fl_cube(size=[size.x,size.z,size.y-head+FL_NIL2],octant=+FL_Y+FL_Z);
        }
        // female jack
        let(l=jack)
        translate([0,axis.z,0])
          fl_tube(d=0.95+FL_NIL2,thick=0.1,h=l);
        // closing bottom
        translate([0,axis.z,size.y-head+FL_NIL])
          fl_tube(d=3.45+FL_NIL2,thick=(3.45-1.88)/2,h=1);
      }
      fl_color("white") translate([0,axis.z,size.y-head+FL_NIL])
        fl_tube(d=1.88+FL_NIL2,thick=(1.88-0.95)/2,h=1);
    }
  }

  module do_cutout() {
    assert(cut_thick);
    translate(-fl_Y(cut_drift))
      multmatrix(Mshape)
        translate([0,axis.z,size.y])
          fl_cylinder(d=3.45+cut_tolerance*2,h=cut_thick);
  }

  module fprint() {
    difference() {
      translate(+fl_Y(axis.z))
        fl_cylinder(d=d_ext,h=size.y-FL_NIL);
      // lower cut
      fl_cube(size=[size.x,size.z,size.y+0*FL_NIL],octant=-FL_Y+FL_Z);
      // upper cut
      translate([0,size.z/2+axis.z,0])
        fl_cube(size=[size.x,size.z,size.y+FL_NIL2],octant=+FL_Y+FL_Z);
    }
    fl_cube(size=[4.8,size.z/2-axis.z,size.y-FL_NIL],octant=-FL_Y+FL_Z);
  }

  module do_footprint() {
    multmatrix(Mshape)
      fprint();
  }

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction,debug);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_CUTOUT) {
      fl_modifier($modifier) do_cutout();

    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) do_footprint();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
