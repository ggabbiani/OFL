/*!
 * Hard disk definition file. Specs taken from [2.5 inch Hard Drive - Geekworm
 * Wiki](https://wiki.geekworm.com/2.5_inch_Hard_Drive)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../foundation/hole.scad>
use <../foundation/mngm-engine.scad>
include <sata.scad>
include <screw.scad>

include <../../ext/NopSCADlib/core.scad>
include <../../ext/NopSCADlib/vitamins/screws.scad>

FL_HD_NS  = "hd";

FL_HD_EVO860 = let(
  size    = [69.85,100,7],
  plug    = FL_SATA_POWERDATAPLUG,
  cid     = fl_sata_powerDataCID(),
  screw   = M3_cs_cap_screw,
  screw_r = screw_radius(screw),

  Mpd     = T(-X(4.8)-Z(NIL)) * fl_direction([-Y,0]) * fl_octant(+Y-Z,type=plug),

  conns   = fl_connectors(plug),
  pc      = fl_conn_clone(conns[0],M=Mpd),
  dc      = fl_conn_clone(conns[1],M=Mpd)
) [
  fl_name(value="Samsung V-NAND SSD 860 EVO"),
  fl_engine(value=FL_HD_NS),
  fl_bb_corners(value=[
    [-size.x/2, 0,      0       ],  // negative corner
    [+size.x/2, +size.y,+size.z ],  // positive corner
  ]),
  ["offset",            [0,-size.y/2,-size.z/2]],
  ["corner radius",     3],
  fl_screw(value=screw),
  fl_sata_plug(value=plug),
  fl_connectors(value=[pc,dc]),

  // each row represents a hole with the following format:
  // [[point],[normal], diameter, thickness]
  fl_holes(value=[
    fl_Hole([  size.x/2-3.5, 14,  0 ], 3, -Z, 3+screw_r),
    fl_Hole([  size.x/2-3.5, 90.6,0 ], 3, -Z, 3+screw_r),
    fl_Hole([ -size.x/2+3.5, 14,  0 ], 3, -Z, 3+screw_r),
    fl_Hole([ -size.x/2+3.5, 90.6,0 ], 3, -Z, 3+screw_r),
    fl_Hole([  size.x/2,     14,  3 ], 3, +X, 3.5+screw_r),
    fl_Hole([  size.x/2,     90.6,3 ], 3, +X, 3.5+screw_r),
    fl_Hole([ -size.x/2,     14,  3 ], 3, -X, 3.5+screw_r),
    fl_Hole([ -size.x/2,     90.6,3 ], 3, -X, 3.5+screw_r),
    ]),

  ["Mpd",        Mpd ],
];

FL_HD_DICT  = [ FL_HD_EVO860 ];

/*!
 * Hard-drive engine.
 *
 * Used context:
 *
 * | Name           | Context   | Description                           |
 * | ------------   | -------   | ------------------------------------- |
 * | $hd_thick      | Children  | scalar thickness along hole normal    |
 * | $hd_screw_len  | Children  | screw length along hole normal comprehensive of hole depth and tolerance |
 * | $hole_*        | Children  | see fl_hole_Context{}                 |
 * | $dbg_Symbols   | Debug     | When true connector symbols are shown |
 */
module fl_hd(
  verbs,
  type,
  /*!
   * thickness matrix for FL_DRILL, FL_CUTOUT in fixed form [[-X,+X],[-Y,+Y],[-Z,+Z]].
   *
   * scalar «t» means `[[t,t],[t,t],[t,t]]`
   */
  thick,
  //! FL_LAYOUT directions in floating semi-axis list form
  lay_direction   = [-X,+X,-Z],
  //! tolerance for FL_DRILL
  dri_tolerance   = fl_JNgauge,
  //! rail lengths during FL_DRILL in fixed form [[-X,+X],[-Y,+Y],[-Z,+Z]].
  dri_rails=[[0,0],[0,0],[0,0]],
  //! desired direction [vector,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant
  ) {
  assert(verbs!=undef);
  assert(type!=undef);

  thick       = is_num(thick) ? [[thick,thick],[thick,thick],[thick,thick]] : thick;
  screw       = fl_screw(type);
  screw_r     = screw_radius(screw);
  corner_r    = fl_get(type,"corner radius");
  size        = fl_size(type);
  conns       = fl_connectors(type);
  plug        = fl_sata_plug(type);
  Mpd         = fl_get(type,"Mpd");
  holes       = fl_holes(type);
  D           = direction ? fl_direction(direction): I;
  M           = fl_octant(octant,type=type);

  module context() {
    $hd_thick     = $hole_n ? fl_3d_axisValue($hole_n,thick) : undef;
    $hd_screw_len = ($hd_thick!=undef && $hole_depth!=undef) ? $hd_thick+$hole_depth+dri_tolerance : undef;
    children();
  }

  module do_layout() {
    fl_lay_holes(holes,lay_direction)
      context() translate(($hd_thick+dri_tolerance)*$hole_n)
        children();
  }

  module do_add() {
    difference() {
      fl_color("dimgray") difference() {
        linear_extrude(height=size.z) fl_square(size=size,corners=corner_r,quadrant=+Y);
        fl_holes(holes,[-X,+X,-Z]);
      }
      multmatrix(Mpd)
        fl_sata(FL_FOOTPRINT,plug,$FL_FOOTPRINT=$FL_ADD);
    }
    multmatrix(Mpd)
      fl_sata(type=plug,$dbg_Symbols=false);

    if (fl_dbg_symbols())
      for(c=conns)
        fl_conn_add(c,2);
  }

  module do_bbox() {
    translate([0,size.y/2,size.z/2])
      cube(size,true);
  }

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_ASSEMBLY) {
      // intentionally a no-op

    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction);

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier) do_layout($FL_ADD=$FL_MOUNT)
        fl_screw(type=screw,len=$hd_screw_len,direction=$hole_direction);

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout($FL_ADD=$FL_LAYOUT)
        children();

    } else if ($verb==FL_DRILL) {
      assert(thick)
      fl_modifier($modifier) do_layout()
        fl_rail(fl_3d_axisValue($hole_n,dri_rails))
          fl_screw(FL_FOOTPRINT,screw,len=$hd_screw_len,direction=$hole_direction,$FL_FOOTPRINT=$FL_DRILL);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) do_bbox();

    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) do_bbox();

    } else if ($verb==FL_CUTOUT) {
      // intentionally a no-op

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
