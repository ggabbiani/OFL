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

include <sata.scad>
include <screw.scad>

use <../foundation/hole-engine.scad>
use <../foundation/mngm-engine.scad>

include <../../ext/NopSCADlib/core.scad>
include <../../ext/NopSCADlib/vitamins/screws.scad>

FL_HD_NS  = "hd";

FL_HD_EVO860 = let(
  size    = [69.85,100,7],
  plug    = FL_SATA_POWERDATAPLUG,
  cid     = fl_sata_powerDataCID(),
  specs   = M3_cs_cap_screw,
  screw_r = screw_radius(specs),

  Mpd     = T(-X(4.8)-Z(NIL)) * fl_direction([-Y,0]) * fl_octant(+Y-Z,type=plug),

  conns   = fl_connectors(plug),
  pc      = fl_conn_clone(conns[0],M=Mpd),
  dc      = fl_conn_clone(conns[1],M=Mpd)
) fl_Object(
  name    = "Samsung V-NAND SSD 860 EVO",
  engine  = FL_HD_NS,
  bbox    = [
    [-size.x/2, 0,      0       ],  // negative corner
    [+size.x/2, +size.y,+size.z ],  // positive corner
  ],
  others  = [
    ["offset",            [0,-size.y/2,-size.z/2]],
    ["corner radius",     3],
    fl_screw_specs(value=specs),
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

    fl_cutout(value=[-Y]),
  ]
);

FL_HD_DICT  = [ FL_HD_EVO860 ];

/*!
 * Hard-drive engine.
 *
 * Context variables:
 *
 * | Name           | Context   | Description                           |
 * | ------------   | -------   | ------------------------------------- |
 * | $hd_thick      | Children  | scalar thickness along hole normal    |
 * | $hd_screw_len  | Children  | screw length along hole normal comprehensive of hole depth and tolerance |
 * | $hole_*        | Children  | see fl_hole_Context{}                 |
 * | $dbg_Symbols   | Execution | When true connector symbols are shown |
 * | $fl_thickness  | Parameter | thickness in fixed form [[-X,+X],[-Y,+Y],[-Z,+Z]]  |
 * | $fl_tolerance  | Parameter | Used during FL_CUTOUT and FL_DRILL    |
 */
module fl_hd(
  //! FL_ASSEMBLY, FL_AXES, FL_MOUNT, FL_LAYOUT, FL_DRILL, FL_BBOX, FL_FOOTPRINT, FL_CUTOUT
  verbs=FL_ADD,
  type,
  //! FL_LAYOUT directions in floating semi-axis list form
  lay_direction = [-X,+X,-Z],
  //! rail lengths during FL_DRILL in fixed form [[-X,+X],[-Y,+Y],[-Z,+Z]].
  dri_rails     = [[0,0],[0,0],[0,0]],
  //! FL_CUTOUT scalar drift
  cut_drift = 0,
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
  //! desired direction [vector,rotation], native direction when undef ([+X+Y+Z])
  direction
  ) {
  assert(verbs!=undef);
  assert(type!=undef);

  thick       =
    is_undef($fl_thickness) ? 0 :
    is_num($fl_thickness) ?
      [[$fl_thickness,$fl_thickness],[$fl_thickness,$fl_thickness],[$fl_thickness,$fl_thickness]] :
      assert(is_list($fl_thickness)) $fl_thickness;
  specs       = fl_screw_specs(type);
  screw_r     = screw_radius(specs);
  corner_r    = fl_get(type,"corner radius");
  size        = fl_size(type);
  conns       = fl_connectors(type);
  plug        = fl_sata_plug(type);
  Mpd         = fl_get(type,"Mpd");
  holes       = fl_holes(type);
  cut_dirs    = fl_cut_dirs(cut_dirs,type);

  module context() {
    $fl_thickness = $hole_n ? fl_3d_axisValue($hole_n,thick) : undef;
    $hd_screw_len = ($fl_thickness!=undef && $hole_depth!=undef) ? $fl_thickness+$hole_depth+$fl_tolerance : undef;
    children();
  }

  module do_layout() {
    fl_lay_holes(holes,lay_direction)
      context() translate(($fl_thickness+$fl_tolerance)*$hole_n)
        children();
  }

  module do_add() {
    difference() {
      fl_color("dimgray") difference() {
        linear_extrude(height=size.z)
          fl_square(size=size,corners=corner_r,quadrant=+Y);
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

  module do_footprint()
    translate(-Z($fl_tolerance))
      linear_extrude(height=size.z+2*$fl_tolerance)
        offset($fl_tolerance)
          fl_square(size=size,corners=corner_r,quadrant=+Y,$FL_ADD=$FL_FOOTPRINT);

  fl_vmanage(verbs,type,octant=octant,direction=direction)
    if ($this_verb==FL_ADD)
      do_add();

    else if ($this_verb==FL_ASSEMBLY)
      ; // intentionally a no-op

    else if ($this_verb==FL_BBOX)
      fl_bb_add($this_bbox,$FL_ADD=$FL_BBOX);

    else if ($this_verb==FL_CUTOUT) {
      fl_cutoutLoop(cut_dirs, fl_cutout($this))
        if ($co_preferred)
          multmatrix(Mpd) let(
            // the only cutout axis is -Y so we use just the related scalar
            $fl_thickness = fl_3d_axisValue(-Y, values=thick)
          ) fl_sata(FL_CUTOUT,plug,$dbg_Symbols=false,cut_drift=cut_drift);
        // else
        //   fl_new_cutout($this_bbox,$co_current,drift=drift,$fl_tolerance=$fl_tolerance+2xNIL)
        //     do_footprint($FL_FOOTPRINT=$FL_CUTOUT);

    } else if ($this_verb==FL_DRILL)
      assert(thick)
      do_layout()
        fl_rail(fl_3d_axisValue($hole_n,dri_rails)) let(
          screw = fl_Screw(specs, longer_than=$hd_screw_len)
        ) fl_screw(FL_DRILL,screw,direction=$hole_direction);

    else if ($this_verb==FL_FOOTPRINT)
      fl_bb_add($this_bbox, auto=true);

    else if ($this_verb==FL_LAYOUT)
      do_layout($FL_ADD=$FL_LAYOUT)
        children();

    else if ($this_verb==FL_MOUNT)
      do_layout($FL_ADD=$FL_MOUNT) let(
          screw = fl_Screw(specs, longer_than=$hd_screw_len)
        ) fl_screw(type=screw,direction=$hole_direction);

    else
      fl_error(["unimplemented verb",$this_verb]);
}
