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
use <../foundation/mngm-engine.scad>
use <../foundation/util.scad>

FL_JACK_NS = "jack";

/*!
 * 'Barrel' jack plug.
 *
 * The preferred cutout direction on +X is circular allowing the carving for
 * jack plug insertion:
 *
 * ![preferred cutouts on +x](256x256/fig_jack_barrel_preferred_cutouts.png)
 *
 * On the other directions the cutout section is standard:
 *
 * ![default cutouts on -x,±y and ±z](256x256/fig_jack_barrel_default_cutouts.png)
 */
FL_JACK_BARREL = let(
  // following data definitions taken from NopSCADlib jack() module
  l = 12,
  w = 7,
  h = 6,
  ch = 2.5,
  // calculated bounding box corners
  bbox      = [[-l/2,-w/2,0],[+l/2+ch,+w/2,h]]
) fl_Object(bbox, engine="jack/barrel", others=[fl_cutout(value=[+X])]);

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
) fl_Object(bbox, name=name, engine="jack/mcxjphstem1", others=[
  fl_cutout(value=[-Y]),
  fl_connectors(value=[
    conn_Socket("antenna",+FL_X,-FL_Z,[0,0,axis.z],size=3.45,octant=-FL_X-FL_Y,direction=[-FL_Z,180])
  ]),
  ["axis of symmetry",  axis],
  ["external diameter", d_ext],
  ["head",              head],
  ["tail",              tail],
  ["jack length",       jack]
]);

FL_JACK_DICT = [
  FL_JACK_BARREL,
  FL_JACK_MCXJPHSTEM1,
];

/*!
 * Common jack engine adapter.
 *
 * Context variables:
 *
 * | Name             | Context   | Description                                           |
 * | ---------------- | --------- | ----------------------------------------------------- |
 * | $fl_thickness    | Parameter | Used during FL_CUTOUT (see also fl_parm_thickness())  |
 * | $fl_tolerance    | Parameter | Used during FL_CUTOUT (see fl_parm_tolerance())       |
 *
 */
module fl_jack(
  //! supported verbs: FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT
  verbs       = FL_ADD,
  type,
  //! translation applied to cutout
  cut_drift=0,
  //! FL_CUTOUT direction list. Defaults to 'preferred' cutout direction
  co_dirs,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction
) {
  assert(type);

  engine        = fl_engine(type);

  if (engine=="jack/barrel")
    fl_jack_barrelEngine(verbs,type,cut_drift,co_dirs,octant,direction);
  else if (engine=="jack/mcxjphstem1")
    fl_jack_mcxjphstem1Engine(verbs,type,cut_drift,co_dirs,octant,direction);
  else
    assert(false,str("Engine '",engine,"' unknown."));
}

/*!
 * Barrel jack engine.
 *
 * Context variables:
 *
 * | Name             | Context   | Description                                           |
 * | ---------------- | --------- | ----------------------------------------------------- |
 * | $fl_thickness    | Parameter | Used during FL_CUTOUT (see also fl_parm_thickness())  |
 * | $fl_tolerance    | Parameter | Used during FL_CUTOUT (see fl_parm_tolerance())       |
 */
module fl_jack_barrelEngine(
  //! supported verbs: FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT
  verbs       = FL_ADD,
  type,
  //! translation applied to cutout
  cut_drift=0,
  //! See fl_jack{}.
  co_dirs,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction
) {
  bbox    = fl_bb_corners(type);
  size    = fl_bb_size(type);

  fl_vmanage(verbs,type,octant,direction)
    if ($verb==FL_ADD)
      jack();
    else if ($verb==FL_BBOX)
      fl_bb_add(bbox);
    else if ($verb==FL_CUTOUT)
      assert($fl_thickness!=undef)
        fl_cutoutLoop(co_dirs, fl_cutout(type))
          fl_new_cutout(bbox,$co_current,
            drift         = function() cut_drift+($co_preferred ? -2.5 : 0),
            trim          = function() $co_preferred ? X(-size.x/2) : undef,
            $fl_tolerance = $fl_tolerance+2xNIL
          ) jack();
    else
      fl_error(["unimplemented verb",$this_verb]);

}

// FIXME: issue when directing, likely to be related to the 'D' matrix when director is not +Z
/*!
 * Engine for RF MCX edge mount jack pcb connector
 * specs taken from https://www.rfconnector.com/mcx/edge-mount-jack-pcb-connector
 *
 * Context variables:
 *
 * | Name             | Context   | Description                                           |
 * | ---------------- | --------- | ----------------------------------------------------- |
 * | $fl_thickness    | Parameter | Used during FL_CUTOUT (see also fl_parm_thickness())  |
 * | $fl_tolerance    | Parameter | Used during FL_CUTOUT (see fl_parm_tolerance())       |
 */
module fl_jack_mcxjphstem1Engine(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  type,
  //! translation applied to cutout
  cut_drift=0,
  //! See fl_jack{}.
  co_dirs,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction
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
  preferred_co  = fl_cutout(type);
  co_dirs       = co_dirs ? co_dirs : preferred_co;

  module do_add() {
    multmatrix(Mshape) {
      fl_color("gold") {
        difference() {
          fprint();
          translate([0,axis.z,-NIL])
            fl_cylinder(d=3.45,h=size.y+NIL);
          translate([0,0,-NIL])
            fl_cube(size=[size.x,size.z,size.y-head+2xNIL],octant=-FL_Y+FL_Z);
          translate([0,axis.z,-NIL])
            fl_cube(size=[size.x,size.z,size.y-head+2xNIL],octant=+FL_Y+FL_Z);
        }
        // female jack
        let(l=jack)
        translate([0,axis.z,0])
          fl_tube(d=0.95+2xNIL,thick=0.1,h=l);
        // closing bottom
        translate([0,axis.z,size.y-head+NIL])
          fl_tube(d=3.45+2xNIL,thick=(3.45-1.88)/2,h=1);
      }
      fl_color("white") translate([0,axis.z,size.y-head+NIL])
        fl_tube(d=1.88+2xNIL,thick=(1.88-0.95)/2,h=1);
    }
  }

  module do_cutout()
    fl_cutoutLoop(co_dirs, fl_cutout(type))
      fl_new_cutout(bbox,$co_current,drift=cut_drift, $fl_tolerance=$fl_tolerance+2xNIL)
        if ($co_preferred)
          multmatrix(Mshape)
            translate([0,axis.z,size.y])
              fl_cylinder(d=3.45+$fl_tolerance*2,h=$fl_thickness);
        else
          do_add($FL_ADD=$FL_CUTOUT);

  module fprint() {
    difference() {
      translate(+fl_Y(axis.z))
        fl_cylinder(d=d_ext,h=size.y-NIL);
      // lower cut
      fl_cube(size=[size.x,size.z,size.y+0*NIL],octant=-FL_Y+FL_Z);
      // upper cut
      translate([0,size.z/2+axis.z,0])
        fl_cube(size=[size.x,size.z,size.y+2xNIL],octant=+FL_Y+FL_Z);
    }
    fl_cube(size=[4.8,size.z/2-axis.z,size.y-NIL],octant=-FL_Y+FL_Z);
  }

  module do_footprint() {
    multmatrix(Mshape)
      fprint();
  }

  fl_vmanage(verbs,type,octant,direction) {
    if ($verb==FL_ADD) {
      do_add();

    } else if ($verb==FL_BBOX) {
      fl_bb_add(bbox);

    } else if ($verb==FL_CUTOUT) {
      do_cutout();

    } else if ($verb==FL_FOOTPRINT) {
      do_footprint();

    } else {
      fl_error(["unimplemented verb",$this_verb]);
    }
  }
}
