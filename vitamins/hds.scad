/*
 * Hard disk definition file.
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
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

HD_EVO860 = let(
  size  = [70,100,6.7],
  plug  = FL_SATA_POWERDATAPLUG,
  cid   = fl_sata_powerDataCID(),
  screw = M3_cs_cap_screw,
  screw_r = screw_radius(screw),

  Mpd   = let(
    w = size.x,
    l = fl_size(plug).x,
    d = 7
  ) fl_T(fl_X((l-w+2*d)/2)-fl_Z(FL_NIL)) * fl_Rx(90) * fl_octant(plug,octant=+FL_Y-FL_Z),

  conns   = fl_sata_conns(plug),
  pc      = fl_conn_clone(conns[0],M=Mpd),
  dc      = fl_conn_clone(conns[1],M=Mpd)
) [
  fl_name(value="Samsung V-NAND SSD 860 EVO"),
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
    [[  size.x/2-3.5, 13.5, 0   ], -Z, 3, 2.5+screw_r],
    [[  size.x/2-3.5, 90,   0   ], -Z, 3, 2.5+screw_r],
    [[ -size.x/2+3.5, 13.5, 0   ], -Z, 3, 2.5+screw_r],
    [[ -size.x/2+3.5, 90,   0   ], -Z, 3, 2.5+screw_r],
    [[  size.x/2,     13.5, 2.5 ], +X, 3, 3.5+screw_r],
    [[  size.x/2,     90,   2.5 ], +X, 3, 3.5+screw_r],
    [[ -size.x/2,     13.5, 2.5 ], -X, 3, 3.5+screw_r],
    [[ -size.x/2,     90,   2.5 ], -X, 3, 3.5+screw_r],
    ]),

  ["Mpd",        Mpd ],
];

FL_HD_DICT  = [ HD_EVO860 ];

//*****************************************************************************
// HD properties
// when invoked by «type» parameter act as getters
// when invoked by «value» parameter act as property constructors
function hd_screw_len(type,t)   = assert(t!=undef) screw_longer_than(fl_get(type,"hole depth")+t);

/*
 * Context passed to children (screws):
 *
 *  $director   - screw direction vector
 *  $direction  - [$director,0]
 *  $octant     - undef
 *  $thick      - thickness along current direction
 *  $length     - screw length
 */
module fl_hd(
  verbs,
  type,
  // thickness matrix for FL_DRILL, FL_CUTOUT in fixed form [[-X,+X],[-Y,+Y],[-Z,+Z]].
  thick,
  // FL_ASSEMBLY,FL_LAYOUT enabled directions passed as list of enabled normals (ex. ["+X","-z"])
  // A single string "s" is interpreted as ["s"] (ex. "-y" ⇒ ["-y"]) (See also module fl_holes())
  // lay_direction=["+x","-x","+z"],
  // faces for children FL_LAYOUT
  lay_direction=[-X,+X,-Z],
  // tolerance for FL_DRILL
  dri_tolerance   = fl_JNgauge,
  // rail lengths during FL_DRILL in fixed form [[-X,+X],[-Y,+Y],[-Z,+Z]].
  dri_rails=[[0,0],[0,0],[0,0]],
  // FL_ADD connectors
  add_connectors = false,
  // desired direction [vector,rotation], native direction when undef ([+X+Y+Z])
  direction,
  // when undef native positioning is used
  octant
  ) {
  assert(verbs!=undef);
  assert(type!=undef);
  assert(is_bool(add_connectors));

  screw       = fl_screw(type);
  screw_r     = screw_radius(screw);
  corner_r    = fl_get(type,"corner radius");
  size        = fl_size(type);
  conns       = fl_connectors(type);
  plug        = fl_sata_instance(type);
  Mpd         = fl_get(type,"Mpd");
  holes       = fl_holes(type);
  D           = direction ? fl_direction(type,direction=direction): I;
  M           = octant    ? fl_octant(type,octant=octant)         : I;

  module do_layout() {
    fl_lay_holes(holes,["+x","-x","-z"]) let(
        $director   = $hole_n,
        $direction  = [$director,0],
        $octant     = undef,
        $thick      = fl_3d_axisValue($director,thick),
        $length     = $thick+$hole_depth+dri_tolerance,
        delta       = (fl_3d_axisValue($director,thick)+dri_tolerance)
      ) translate(delta*$director) children();
  }

  module do_add() {
    difference() {
      fl_color("dimgray") difference() {
        linear_extrude(height=size.z) fl_square(size=size,corners=corner_r,quadrant=+Y);
        fl_holes(holes,["+x","-x","-z"])
          children();
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

    } else if ($verb==FL_ASSEMBLY) {
      // intentionally a no-op

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier) do_layout()
        fl_screw(type=screw,len=$length,direction=$direction);

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout()
        children();

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier) do_layout()
        fl_rail(fl_3d_axisValue($director,dri_rails))
          if ($children) children();
          else fl_screw(FL_FOOTPRINT,screw,len=$length,direction=$direction);

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
