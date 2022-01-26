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

include <satas.scad>

include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/screws.scad>

FL_HD_NS  = "hd";

HD_EVO860 = let(
  size  = [70,100,6.7],
  plug  = FL_SATA_POWERDATAPLUG,
  cid   = fl_sata_powerDataCID(),

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
  fl_screw(value=M3_cs_cap_screw),
  ["hole depth",        4],
  ["screw block upper", [30.86,  90,   2.5]],
  ["screw block lower", [30.86,  13.5, 2.5]],
  fl_sata_instance(value=plug),
  fl_connectors(value=[pc,dc]),

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

  // TODO: make it public somehow
  function fl_axisThick(axis,thick) =
      axis==-X ? thick.x[0]
    : axis==+X ? thick.x[1]
    : axis==-Y ? thick.y[0]
    : axis==+Y ? thick.x[1]
    : axis==-Z ? thick.z[0]
    : thick.z[1];

  function railLen(axis) =
      axis==-X ? dri_rails.x[0]
    : axis==+X ? dri_rails.x[1]
    : axis==-Y ? dri_rails.y[0]
    : axis==+Y ? dri_rails.x[1]
    : axis==-Z ? dri_rails.z[0]
    : dri_rails.z[1];

  axes        = fl_list_has(verbs,FL_AXES);
  verbs       = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);
  screw       = fl_screw(type);
  screw_r     = screw_radius(screw);
  screw_hole  = fl_get(type,"hole depth");
  corner_r    = fl_get(type,"corner radius");
  size        = fl_size(type);
  conns       = fl_connectors(type);
  plug        = fl_sata_instance(type);
  Mpd         = fl_get(type,"Mpd");
  block_lower = fl_get(type,"screw block lower");
  block_upper = fl_get(type,"screw block upper");
  D           = direction ? fl_direction(type,direction=direction): I;
  M           = octant    ? fl_octant(type,octant=octant)         : I;

  module do_layout(faces) {
    assert(faces!=undef);
    // horizontal layout
    h_indexes = [
      if (fl_isSet(-X,faces)) -1,
      if (fl_isSet(+X,faces)) +1,
    ];
    for(i=h_indexes) {
      $director   = i*X;
      $direction  = [$director,0];
      $octant     = undef;
      $thick      = fl_axisThick($director,thick);
      $length     = $thick+screw_hole+dri_tolerance;
      delta       = fl_width(type)/2+fl_axisThick($director,thick)+dri_tolerance;
      // lower block
      translate([i*delta,block_lower.y,block_lower.z])
        children();
      // upper block
      translate([i*delta,block_upper.y,block_upper.z])
        children();
    }
    // vertical layout
    if (fl_isSet(-Z,faces))
      for(i=[-1,+1]) {
        $director   = -Z;
        $direction  = [$director,0];
        $octant     = undef;
        $thick      = fl_axisThick($director,thick);
        $length     = $thick+screw_hole+dri_tolerance;
        delta       = -(fl_axisThick($director,thick)+dri_tolerance);
        translate([i*block_lower.x,block_lower.y,delta])
          children();
        translate([i*block_upper.x,block_upper.y,delta])
          children();
      }
  }

  module do_add() {
    difference() {
      fl_color("dimgray") difference() {
        linear_extrude(height=size.z) fl_square(size=size,corners=corner_r,quadrant=+Y);
        do_layout([-X,+X,-Z]) let(
          l = fl_axisThick($director,thick)+screw_hole
        ) fl_screw(FL_FOOTPRINT,screw,len=l,octant=$octant,direction=[$director,0]);
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

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_add();

      } else if ($verb==FL_ASSEMBLY) {
        fl_modifier($FL_ASSEMBLY) do_layout(lay_direction)
          fl_screw(type=screw,len=$length,direction=$direction);

      } else if ($verb==FL_LAYOUT) {
        fl_modifier($FL_LAYOUT) do_layout(lay_direction)
          children();

      } else if ($verb==FL_DRILL) {
        fl_modifier($FL_DRILL) do_layout(lay_direction)
          fl_rail(railLen($direction[0]))
            if ($children) children();
            else fl_screw(FL_FOOTPRINT,screw,len=$length,direction=$direction);

      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) do_bbox();

      } else if ($verb==FL_FOOTPRINT) {
        fl_modifier($FL_FOOTPRINT) do_bbox();

      } else if ($verb==FL_CUTOUT) {
        // FL_CUTOUT is intentionally a no-op

      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_axes(size*1.2);
  }
}
