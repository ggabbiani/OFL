/*
 * Hard disk definition file.
 *
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
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

include <../foundation/hole.scad>
include <sata.scad>
include <screw.scad>

include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/screws.scad>

FL_HD_NS  = "hd";

FL_HD_EVO860 = let(
  size  = [70,100,6.7],
  plug  = FL_SATA_POWERDATAPLUG,
  cid   = fl_sata_powerDataCID(),
  screw = M3_cs_cap_screw,
  screw_r = screw_radius(screw),

  Mpd   = let(
    w = size.x,
    l = fl_size(plug).x,
    d = 7
  ) fl_T(fl_X((l-w+2*d)/2)-fl_Z(FL_NIL)) * fl_Rx(90) * fl_octant(+Y-Z,type=plug),

  conns   = fl_sata_conns(plug),
  pc      = fl_conn_clone(conns[0],M=Mpd),
  dc      = fl_conn_clone(conns[1],M=Mpd)
) [
  fl_name(value="Samsung V-NAND SSD 860 EVO"),
  fl_engine(value=FL_HD_NS),
  fl_bb_corners(value=[
    [-size.x/2, 0,      0       ],  // negative corner
    [+size.x/2, +size.y,+size.z ],  // positive corner
  ]),
  fl_director(value=+FL_Z),fl_rotor(value=+FL_X),
  ["offset",            [0,-size.y/2,-size.z/2]],
  ["corner radius",     3],
  fl_screw(value=screw),
  fl_sata_instance(value=plug),
  fl_connectors(value=[pc,dc]),

  // each row represents a hole with the following format:
  // [[point],[normal], diameter, thickness]
  fl_holes(value=[
    fl_Hole([  size.x/2-3.5, 13.5, 0   ], 3, -Z, 2.5+screw_r),
    fl_Hole([  size.x/2-3.5, 90,   0   ], 3, -Z, 2.5+screw_r),
    fl_Hole([ -size.x/2+3.5, 13.5, 0   ], 3, -Z, 2.5+screw_r),
    fl_Hole([ -size.x/2+3.5, 90,   0   ], 3, -Z, 2.5+screw_r),
    fl_Hole([  size.x/2,     13.5, 2.5 ], 3, +X, 3.5+screw_r),
    fl_Hole([  size.x/2,     90,   2.5 ], 3, +X, 3.5+screw_r),
    fl_Hole([ -size.x/2,     13.5, 2.5 ], 3, -X, 3.5+screw_r),
    fl_Hole([ -size.x/2,     90,   2.5 ], 3, -X, 3.5+screw_r),
    ]),

  ["Mpd",        Mpd ],
];

FL_HD_DICT  = [ FL_HD_EVO860 ];

/*
 * Children context during FL_LAYOUT (in addition to holes' context):
 *
 *  $hd_thick     - scalar thickness along hole normal
 *  $hd_screw_len - screw length along hole normal comprehensive of hole depth and tolerance
 *
 */
module fl_hd(
  verbs,
  type,
  // thickness matrix for FL_DRILL, FL_CUTOUT in fixed form [[-X,+X],[-Y,+Y],[-Z,+Z]].
  // scalar «t» means [[t,t],[t,t],[t,t]]
  thick,
  // FL_LAYOUT directions in floating semi-axis list form
  lay_direction   = [-X,+X,-Z],
  // tolerance for FL_DRILL
  dri_tolerance   = fl_JNgauge,
  // rail lengths during FL_DRILL in fixed form [[-X,+X],[-Y,+Y],[-Z,+Z]].
  dri_rails=[[0,0],[0,0],[0,0]],
  // FL_ADD connectors
  add_connectors  = false,
  // desired direction [vector,rotation], native direction when undef ([+X+Y+Z])
  direction,
  // when undef native positioning is used
  octant
  ) {
  assert(verbs!=undef);
  assert(type!=undef);
  assert(is_bool(add_connectors));

  thick       = is_num(thick) ? [[thick,thick],[thick,thick],[thick,thick]] : thick;
  screw       = fl_screw(type);
  screw_r     = screw_radius(screw);
  corner_r    = fl_get(type,"corner radius");
  size        = fl_size(type);
  conns       = fl_connectors(type);
  plug        = fl_sata_instance(type);
  Mpd         = fl_get(type,"Mpd");
  holes       = fl_holes(type);
  D           = direction ? fl_direction(type,direction=direction): I;
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
      multmatrix(Mpd) fl_sata_powerDataPlug(FL_FOOTPRINT,plug);
    }
    multmatrix(Mpd) fl_sata_powerDataPlug(type=plug);

    if (add_connectors)
      for(c=conns) fl_conn_add(c,2);
  }

  module do_bbox() {
    translate([0,size.y/2,size.z/2])
      cube(size,true);
  }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_ASSEMBLY) {  // intentionally a no-op

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier) do_layout()
        fl_screw(type=screw,len=$hd_screw_len,direction=$hole_direction);

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout()
        children();

    } else if ($verb==FL_DRILL) {
      assert(thick)
      fl_modifier($modifier) do_layout()
        fl_rail(fl_3d_axisValue($hole_n,dri_rails))
          fl_screw(FL_FOOTPRINT,screw,len=$hd_screw_len,direction=$hole_direction);

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
