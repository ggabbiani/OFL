/*
 * PCB implementation file.
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

// use     <../foundation/2d.scad>
use     <../foundation/placement.scad>
use     <ether.scad>
use     <screw.scad>

module fl_pcb(
  verbs       = FL_ADD, // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  type,
  dr_thick=0,           // thickness during FL_DRILL
  co_thick=0,           // thickness during FL_CUTOUT
  co_tolerance=0,       // tolerance used during FL_CUTOUT
  co_label,             // when passed, the FL_CUTOUT verb will be triggered only on the labelled component
  thick=0,              // common override for dr_thick and co_thick
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant,               // when undef native positioning is used
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  pcb_t   = fl_PCB_thick(type);
  comps   = fl_PCB_components(type);
  bbox    = fl_bb_corners(type);
  size    = fl_bb_size(type);
  D       = direction ? fl_direction(proto=type,direction=direction)  : I;
  M       = octant    ? fl_octant(octant=octant,bbox=bbox)            : I;
  holes   = fl_PCB_holes(type);
  screw   = fl_screw(type);
  screw_r = screw_radius(screw);
  dr_thick  = thick!=undef ? thick : dr_thick;
  co_thick  = thick!=undef ? thick : co_thick;

  module do_add() {
    fl_color("green") difference() {
      translate(-Z(pcb_t))
        linear_extrude(pcb_t)
          fl_square(r=3,size=[size.x,size.y],quadrant=+Y);
      do_layout("holes")
        translate(-NIL*$director) 
          fl_cylinder(r=screw_r,h=size.z+2*NIL,octant=$director);
    }
  }

  module do_layout(class,label) {
    assert(is_string(class));
    assert(label==undef||is_string(label));
    fl_trace("class",class);
    fl_trace("label",label);
    fl_trace("children",$children);

    if (!label) { // layout by 'class'
      if (class=="holes")
        for(hole=holes) {
          fl_trace("hole",hole);
          $director = hole[0];
          position  = hole[1];
          translate(position)
            children();
        }
      else if (class=="components")
        for(c=comps) {
          $label      = c[0];
          $component  = c[1];
          children();
        }
      else
        assert(false,"unknown component class '",class,"'.");
    } else {  // layout by 'label'
      assert(class=="components",str("layout BY LABEL not implemented on class '",class,"'"));
      $component  = fl_get(comps,label);
      $label      = label;
      children();
    }
  }
  
  module do_assembly() {
    do_layout("components")
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
          else if (engine==FL_ETHER_NS)
            fl_ether(type=type,direction=direction);
          else if (engine==FL_PHDR_NS)
            fl_pinHeader(FL_ADD,type=type,direction=direction);
          else
            assert(false,str("Unknown engine ",engine));
    do_layout("holes")
      fl_screw([FL_ADD,FL_ASSEMBLY],type=screw,nut="default",thick=dr_thick+pcb_t,nwasher=true);
  }

  module do_drill() {
    do_layout("holes")
      translate(-$director*NIL)
      fl_screw([FL_DRILL],type=screw,washer="default",nut="default",thick=dr_thick+pcb_t,nwasher=true);
  }

  module do_cutout() {

    module trigger(component) {
      engine    = component[0];
      position  = component[1];
      direction = component[2];
      type      = component[3];
      translate(position) 
        if (engine=="USB")
          let(drift= $label=="POWER IN" ? -1.2 : -3)
            fl_USB(FL_CUTOUT,type=type,co_thick=co_thick,co_tolerance=co_tolerance,co_drift=drift,direction=direction);
        else if (engine=="HDMI")
          let(drift=-1.3)
            fl_hdmi(FL_CUTOUT,type=type,co_thick=co_thick,co_tolerance=co_tolerance,co_drift=drift,direction=direction);
        else if (engine=="JACK")
          let(drift=0)
            fl_jack(FL_CUTOUT,type=type,co_thick=co_thick-drift,co_tolerance=co_tolerance,co_drift=drift,direction=direction);
        else if (engine==FL_ETHER_NS)
          let(drift=-3.)
            fl_ether(FL_CUTOUT,type=type,co_thick=co_thick,co_tolerance=co_tolerance,co_drift=drift,direction=direction);
        else if (engine==FL_PHDR_NS)
          fl_pinHeader(FL_CUTOUT,type=type,co_thick=co_thick*4,co_tolerance=co_tolerance,direction=direction);
        else
          assert(false,str("Unknown engine ",engine));
    }

    do_layout("components",co_label)
      trigger($component);
  }

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_add();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_bb_add(bbox);
      } else if ($verb==FL_LAYOUT) {
        fl_modifier($FL_LAYOUT) do_layout("holes")
          children();
      } else if ($verb==FL_ASSEMBLY) {
        fl_modifier($FL_ASSEMBLY) do_assembly();
      } else if ($verb==FL_DRILL) {
        fl_modifier($FL_DRILL) do_drill();
      } else if ($verb==FL_CUTOUT) {
        fl_modifier($FL_CUTOUT) do_cutout();
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=size+Z(5));
  }
}
