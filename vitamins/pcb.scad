/*
 * PCB implementation file template for OpenSCAD Foundation Library.
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL).
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
include <../foundation/unsafe_defs.scad>
include <../foundation/defs.scad>
include <pcbs.scad>
include <pin_headers.scad>

use     <../foundation/2d.scad>
use     <rj45.scad>

module fl_pcb(
  verbs       = FL_ADD, // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  type,
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant,               // when undef native positioning is used
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  bbox    = fl_bb_corners(type);
  size    = fl_bb_size(type);
  D       = direction ? fl_direction(proto=type,direction=direction)  : I;
  M       = octant    ? fl_octant(octant=octant,bbox=bbox)            : I;
  holes   = fl_PCB_holes(type);
  screw   = fl_screw(type);
  screw_r = screw_radius(screw);
  comps   = fl_PCB_components(type);

  module do_add() {
    fl_color("green") difference() {
      translate(-Z(fl_thickness(type)))
        linear_extrude(size.z)
          fl_square(r=3,size=[size.x,size.y],quadrant=+Y);
      do_layout("holes")
        translate(+Z(NIL)) fl_cylinder(r=screw_r,h=size.z+2*NIL,octant=$octant);
    }
  }

  module do_layout(what) {
    assert(is_string(what),what);
    if (what=="holes")
      for(hole=holes) {
        fl_trace("hole",hole);
        $octant   = hole[0];
        position  = hole[1];
        translate(position)
          children();
      }
    else if (what=="components")
      for(c=comps) {
        $component = c;
        children();
      }
    else
      assert(false,"unknown command '",what,"'.");
  }
  
  module do_assembly() {
    do_layout("components") {
      let(
        engine    = $component[0],
        position  = $component[1],
        direction = $component[2],
        type      = $component[3]
      ) translate(position) 
          if (engine=="USB")
            fl_USB(type=type,direction=direction);
          else if (engine=="HDMI")
            fl_hdmi(type=type,direction=direction);
          else if (engine=="JACK")
            fl_jack(type=type,direction=direction);
          else if (engine=="ETHER")
            fl_rj45(direction=direction);
          else if (engine==FL_PHDR_NS)
            fl_pinHeader(nop=fl_nopSCADlib(type),direction=direction,geometry=[20,2]);
          else
            assert(false,str("Unknown engine ",engine));
    }
  }

  module do_drill() {}

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD)
          do_add();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_bb_add(bbox);
      } else if ($verb==FL_LAYOUT) {
        fl_modifier($FL_LAYOUT) do_layout("holes")
          children();
      } else if ($verb==FL_FOOTPRINT) {
        fl_modifier($FL_FOOTPRINT);
      } else if ($verb==FL_ASSEMBLY) {
        fl_modifier($FL_ASSEMBLY) do_assembly();
      } else if ($verb==FL_DRILL) {
        fl_modifier($FL_DRILL);
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=size+Z(5));
  }
}
