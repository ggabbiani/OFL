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
  verbs=FL_ADD,   // FL_ADD, FL_ASSEMBLY, FL_AXES, FL_BBOX, FL_CUTOUT, FL_DRILL, FL_LAYOUT
  type,
  cut_tolerance=0,// FL_CUTOUT tolerance 
  cut_label,      // FL_CUTOUT component filter by label
  cut_direction,  // FL_CUTOUT component filter by direction (+X,+Y or +Z)
  thick,          // FL_DRILL and FL_CUTOUT thickness in fixed form [[-X,+X],[-Y,+Y],[-Z,+Z]]. 
  direction,      // desired direction [director,rotation], native direction when undef
  octant          // when undef native positioning is used
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(!(cut_direction!=undef && cut_label!=undef),"cutout filtering cannot be done by label and direction at the same time");

  fl_trace("thick",thick);

  axes      = fl_list_has(verbs,FL_AXES);
  verbs     = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  pcb_t     = fl_PCB_thick(type);
  comps     = fl_PCB_components(type);
  bbox      = fl_bb_corners(type);
  size      = fl_bb_size(type);
  D         = direction ? fl_direction(proto=type,direction=direction)  : I;
  M         = octant    ? fl_octant(octant=octant,bbox=bbox)            : I;
  holes     = fl_PCB_holes(type);
  screw     = fl_screw(type);
  screw_r   = screw_radius(screw);
  thick     = is_num(thick) ? [[thick,thick],[thick,thick],[thick,thick]] 
            : assert(len(thick)==3 && len(thick.x)==2 && len(thick.y)==2 && len(thick.z)==2,thick) thick;
  dr_thick  = thick.z[0]; // thickness along -Z
  cut_thick  = thick;

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

  module do_layout(class,label,directions) {
    assert(is_string(class));
    assert(label==undef||is_string(label));
    assert(directions==undef||is_list(directions));
    fl_trace("class",class);
    fl_trace("directions",directions);
    fl_trace("label",label);
    fl_trace("children",$children);

    if (label) {
      assert(class=="components",str("Cannot layout BY LABEL on class '",class,"'"));
      $component  = fl_get(comps,label);
      $label      = label;
      position    = $component[1];
      translate(position) children();
    } else if (directions) {
      assert(class=="components",str("Cannot layout BY DIRECTION on class '",class,"'"));
      for(c=comps) {  // «c» = ["label",component]
        component = c[1];
        direction = component[2][0];
        // triggers a component if its direction matches the direction list
        if (search([direction],directions)!=[[]]) {
          $component  = c[1];
          $label      = c[0];
          $direction  = direction;  // component direction
          position    = $component[1];
          translate(position) children();
        }
      }
    } else {  // by class
      if (class=="holes")
        for(hole=holes) {
          $director = hole[0];
          position  = hole[1];
          translate(position) children();
        }
      else if (class=="components")
        for(c=comps) {  // «c» = ["label",component]
          $component  = c[1];
          $label      = c[0];
          position    = $component[1];
          translate(position) children();
        }
      else
        assert(false,"unknown component class '",class,"'.");
    }
  }
  
  module do_assembly() {
    do_layout("components")
      let(
        engine    = $component[0],
        direction = $component[2],
        type      = $component[3]
      ) if (engine=="USB")
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

      function drift(component) = let(
        position  = component[1],
        direction = component[2],
        type      = component[3],
        sz        = fl_size(type),
        director  = direction[0]
      ) -(sz.x/2-((director==X||director==-X ? size/2 : size)-position) * director);

      engine    = component[0];
      position  = component[1];
      direction = component[2];
      type      = component[3];
      director  = direction[0];
      cut_thick  = director==+X ? cut_thick.x[1] : director==-X ? cut_thick.x[0]
                : director==+Y ? cut_thick.y[1] : director==-Y ? cut_thick.y[0]
                : director==+Z ? cut_thick.z[1] : cut_thick.z[0];
      if (engine=="USB")
        let(drift=drift(component)) fl_USB(FL_CUTOUT,type=type,cut_thick=cut_thick,cut_tolerance=cut_tolerance,co_drift=drift,direction=direction);
      else if (engine=="HDMI")
        let(drift=drift(component)) fl_hdmi(FL_CUTOUT,type=type,cut_thick=cut_thick,cut_tolerance=cut_tolerance,co_drift=drift,direction=direction);
      else if (engine=="JACK")
        let(drift=0)
          fl_jack(FL_CUTOUT,type=type,cut_thick=cut_thick,cut_tolerance=cut_tolerance,co_drift=drift,direction=direction);
      else if (engine==FL_ETHER_NS)
        let(drift=drift(component)) 
          fl_ether(FL_CUTOUT,type=type,cut_thick=cut_thick,cut_tolerance=cut_tolerance,co_drift=drift,direction=direction);
      else if (engine==FL_PHDR_NS) let(
          thick = size.z-pcb_t+cut_thick
        ) fl_pinHeader(FL_CUTOUT,type=type,cut_thick=thick,cut_tolerance=cut_tolerance,direction=direction);
      else
        assert(false,str("Unknown engine ",engine));
    }

    if (cut_label) 
      do_layout("components",cut_label) trigger($component);
    else
      do_layout("components",undef,cut_direction) trigger($component);
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
      fl_modifier($FL_AXES) fl_axes(size=size*1.2);
  }
}
