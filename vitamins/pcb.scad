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
use     <../foundation/grid.scad>
use     <../foundation/hole.scad>
use     <../foundation/placement.scad>
include <../foundation/type_trait.scad>

use     <ether.scad>
include <pin_headers.scad>
use     <screw.scad>

include <pcbs.scad>

module fl_pcb(
  // FL_ADD, FL_ASSEMBLY, FL_AXES, FL_BBOX, FL_CUTOUT, FL_DRILL, FL_LAYOUT, FL_PAYLOAD
  verbs=FL_ADD,
  type,
  // FL_CUTOUT tolerance
  cut_tolerance=0,
  // FL_CUTOUT component filter by label
  cut_label,
  // FL_CUTOUT component filter by direction (+X,+Y or +Z)
  cut_direction,
  // FL_DRILL and FL_CUTOUT thickness in fixed form [[-X,+X],[-Y,+Y],[-Z,+Z]] or scalar shortcut
  thick=0,
  // FL_ASSEMBLY,FL_LAYOUT enabled directions passed as list of strings
  lay_direction="+z",
  // desired direction [director,rotation], native direction when undef
  direction,
  // when undef native positioning is used
  octant
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(!(cut_direction!=undef && cut_label!=undef),"cutout filtering cannot be done by label and direction at the same time");

  fl_trace("thick",thick);

  axes      = fl_list_has(verbs,FL_AXES);
  verbs     = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  pcb_t     = fl_pcb_thick(type);
  comps     = fl_pcb_components(type);
  size      = fl_bb_size(type);
  bbox      = fl_bb_corners(type);
  holes     = fl_holes(type);
  screw     = fl_screw(type);
  screw_r   = screw_radius(screw);
  thick     = is_num(thick) ? [[thick,thick],[thick,thick],[thick,thick]]
            : assert(fl_tt_isThickList(thick)) thick;
  dr_thick  = thick.z[0]; // thickness along -Z
  cut_thick = thick;
  material  = fl_material(type,default="green");
  radius    = fl_pcb_radius(type);
  grid      = fl_has(type,fl_pcb_grid()[0]) ? fl_pcb_grid(type) : undef;
  pload     = fl_has(type,fl_payload()[0])
            ? fl_payload(type)
            : let(
                h = max([for(i=comps) let(c=i[1][3],bb=fl_bb_corners(c)) bb[1].z-bb[0].z])
              ) [bbox[0]+Z(pcb_t),[bbox[1].x,bbox[1].y,bbox[0].z+pcb_t+h]];

  D         = direction ? fl_direction(proto=type,direction=direction)  : I;
  M         = octant    ? fl_octant(octant=octant,bbox=bbox)            : I;

  fl_trace(fl_pcb_components()[0],comps);
  fl_trace("type",type);
  fl_trace("holes",holes);
  fl_trace("bbox",bbox);
  fl_trace("grid",grid);

  function fl_pcb_NopHoles(nop) = let(
    pcb_t     = pcb_thickness(nop),
    hole_d    = pcb_hole_d(nop),
    nop_holes = pcb_holes(nop),
    holes     = [
      for(h=nop_holes) [
        let(p=pcb_coord(nop, h)) [p.x,p.y,pcb_t],  // 3d point
        +Z,                           // plane normal
        hole_d,                       // hole diameter
        pcb_t                         // hole depth
      ]
    ]
  ) holes;

  module grid_plating() {
  /**
  * Return the grid size in [cols,rows] format
  */
  function fl_grid_geometry(grid,size) = let(
      cols  = is_undef(grid[2]) ? round((size.x - 2 * grid.x) / inch(0.1))  : grid[2] - 1,
      rows  = is_undef(grid[3]) ? round((size.y - 2 * grid.y) / inch(0.1))  : grid[3] - 1
    ) [cols,rows];

    t               = size.z;
    plating         = 0.1;
    fr4             = material != "sienna";
    plating_colour  = is_undef(grid[4]) ? ((material == "green" || material == "#2140BE") ? silver : material == "sienna" ? copper : gold) : grid[4];
    color(plating_colour)
      translate(-Z(plating))
        linear_extrude(fr4 ? t + 2 * plating : plating) {
          fl_grid_layout(
            step    = inch(0.1),
            bbox    = bbox+[grid,-grid],
            clip    = false
          )
            fl_annulus(d=1-NIL2,thick=0.5);

          // oval lands at the ends
          if (fr4 && len(grid) < 3) {
            screw_x = holes[0][0].x;
            y0      = grid.y;
            rows    = fl_grid_geometry(grid,size).y;
            for(end = [-1, 1], y = [1 : rows - 1])
              translate([end * screw_x, y0 + y * inch(0.1) - size.y / 2])
                hull()
                  for(x = [-1, 1])
                    translate([x * 1.6 / 2, 0])
                      circle(d = 2);
          }
        }
  }

  // TODO: better clarify the kind of native positioning, right now it places pcb on first quadrant
  // then translate according the bounding box. This doesn't match the behaviour followed
  // for holes, that are instead already placed din the final full 3d space
  module do_add() {
    fl_color(material) difference() {
      translate(Z(bbox[0].z)) linear_extrude(pcb_t)
        difference() {
          translate(bbox[0])
            fl_square(corners=radius,size=[size.x,size.y],quadrant=+X+Y);
          if (grid) {
            fl_trace("PCB  size:",size);
            fl_grid_layout(
              step    = inch(0.1),
              bbox    = bbox+[grid,-grid],
              clip    = false
              // $FL_TRACE=true
            )
              fl_circle(d=1);
          }
        }
      if (holes)
        fl_holes(holes,"+Z");
    }
    if (grid)
      grid_plating();
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
        if (class=="components")
          for(c=comps) {  // «c» = ["label",component]
            $component  = c[1];
            $label      = c[0];
            position    = $component[1];
            translate(position) children();
          }
        else if (class=="holes")
          fl_lay_holes(holes,lay_direction)
            children();
        else
          assert(false,str("unknown component class '",class,"'."));
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
    if (holes)
      fl_lay_holes(holes,lay_direction)
        fl_screw([FL_ADD,FL_ASSEMBLY],type=screw,nut="default",thick=dr_thick+pcb_t,nwasher=true);
  }

  module do_drill() {
    fl_lay_holes(holes,"+z")
      fl_cylinder(d=$hole_d,h=dr_thick+pcb_t,octant=-$hole_n);
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
        let(drift=drift(component)) fl_USB(FL_CUTOUT,type=type,cut_thick=cut_thick,cut_tolerance=cut_tolerance,cut_drift=drift,direction=direction);
      else if (engine=="HDMI")
        let(drift=drift(component)) fl_hdmi(FL_CUTOUT,type=type,cut_thick=cut_thick,cut_tolerance=cut_tolerance,cut_drift=drift,direction=direction);
      else if (engine=="JACK")
        let(drift=0)
          fl_jack(FL_CUTOUT,type=type,cut_thick=cut_thick,cut_tolerance=cut_tolerance,cut_drift=drift,direction=direction);
      else if (engine==FL_ETHER_NS)
        let(drift=drift(component))
          fl_ether(FL_CUTOUT,type=type,cut_thick=cut_thick,cut_tolerance=cut_tolerance,cut_drift=drift,direction=direction);
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

  module do_payload() {
    if (pload)
      fl_bb_add(pload);
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

      } else if ($verb==FL_PAYLOAD) {
        fl_modifier($FL_PAYLOAD) do_payload();

      } else
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=size*1.2);
  }
}

/**
 * Calculates a cubic bounding block from a bounding blocks list or 3d point set
 */
function fl_bb_calc(
    // list of bounding blocks to be included in the new one
    bbs,
    // list of 3d points to be included in the new bounding block
    pts
  ) =
  assert(fl_XOR(bbs!=undef,pts!=undef))
  assert(bbs==undef || is_list(bbs),bbs)
  assert(pts==undef || is_list(pts),pts)
  bbs!=undef
  ? let(
    xs  = [for(bb=bbs) bb[0].x],
    ys  = [for(bb=bbs) bb[0].y],
    zs  = [for(bb=bbs) bb[0].z],
    XS  = [for(bb=bbs) bb[1].x],
    YS  = [for(bb=bbs) bb[1].y],
    ZS  = [for(bb=bbs) bb[1].z]
  ) [[min(xs),min(ys),min(zs)],[max(XS),max(YS),max(ZS)]]
  : let(
    xs  = [for(p=pts) p.x],
    ys  = [for(p=pts) p.y],
    zs  = [for(p=pts) p.z]
  ) [[min(xs),min(ys),min(zs)],[max(xs),max(ys),max(zs)]];

/**
 * PCB adapter for NopSCADlib.
 *
 * While full attributes rendering is supported via NopSCADlib APIs, only basic
 * support is provided to OFL verbs, sometimes even with different behaviour:
 *
 * FL_ADD       - being impossible to render NopSCADlib pcbs without components,
 *                this verb always renders components too;
 * FL_ASSEMBLY  - only screws are added during assembly, since
 *                components are always rendered during FL_ADD;
 * FL_AXES      - no changes;
 * FL_BBOX      - while OFL native PCBs includes also components sizing in
 *                bounding box calculations, the adapter bounding box is
 *                'reduced' to pcb only. The only way to mimic OFL native
 *                behaviour is to explicity add the payload capacity through
 *                the «payload» parameter.
 * FL_CUTOUT    - always applied to all the components, it's not possible to
 *                reduce component triggering by label nor direction.
 *                No cutout tolerance is provided either;
 * FL_DRILL     - no changes
 * FL_LAYOUT    - no changes
 * FL_PAYLOAD   - unsupported by native OFL PCBs
 *
 * Others:
 *
 * Placement    - working with the FL_BBOX limitations
 * Orientation  - no changes
 */
module fl_pcb_adapter(
  // FL_ADD, FL_ASSEMBLY, FL_AXES, FL_BBOX, FL_CUTOUT, FL_DRILL, FL_LAYOUT, FL_PAYLOAD
  verbs=FL_ADD,
  type,
  // FL_DRILL thickness in fixed form [[-X,+X],[-Y,+Y],[-Z,+Z]] or scalar shortcut
  thick=0,
  // pay-load bounding box, is added to the overall bounding box calculation
  payload,
  // desired direction [director,rotation], native direction when undef
  direction,
  // when undef native positioning is used
  octant
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  fl_trace("thick",thick);

  axes      = fl_list_has(verbs,FL_AXES);
  verbs     = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  pcb_t     = pcb_thickness(type);
  comps     = pcb_components(type);
  size      = pcb_size(type);
  bbox      = let(bare=[[-size.x/2,-size.y/2,0],[+size.x/2,+size.y/2,+size.z]]) payload ? fl_bb_calc(bbs=[bare,payload]) : bare;
  holes     = fl_pcb_NopHoles(type);
  screw     = pcb_screw(type);
  screw_r   = screw ? screw_radius(screw) : 0;
  thick     = is_num(thick) ? [[thick,thick],[thick,thick],[thick,thick]]
            : assert(fl_tt_isThickList(thick)) thick;
  dr_thick  = thick.z[0]; // thickness along -Z
  material  = fl_material(type,default="green");
  radius    = pcb_radius(type);
  grid      = pcb_grid(type);

  D         = direction ? fl_direction(proto=type,direction=direction,default=[+Z,+X])  : I;
  M         = octant    ? fl_octant(octant=octant,bbox=bbox) : I;

  fl_trace("screw",screw);
  fl_trace("components",comps);
  fl_trace("type",type);
  fl_trace("holes",holes);
  fl_trace("bbox",bbox);
  fl_trace("grid",grid);

  module do_add() {
    pcb(type) children();
  }

  module do_layout() {
    if (holes)
      fl_lay_holes(holes,"+z")
        children();
  }

  module do_assembly() {
    if (holes)
      fl_lay_holes(holes,"+z")
        fl_screw([FL_ADD,FL_ASSEMBLY],type=screw,nut="default",thick=dr_thick+pcb_t,nwasher=true);
  }

  module do_drill() {
    if (holes)
      fl_lay_holes(holes,"+z")
        fl_cylinder(d=$hole_d,h=dr_thick+pcb_t,octant=-$hole_n);
  }

  module do_cutout() {
    pcb_cutouts(type);
  }

  module do_payload() {
    if (payload)
      fl_bb_add(payload);
  }

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_add();

      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_bb_add(bbox);

      } else if ($verb==FL_LAYOUT) {
        fl_modifier($FL_LAYOUT) do_layout()
          children();

      } else if ($verb==FL_ASSEMBLY) {
        fl_modifier($FL_ASSEMBLY) do_assembly();

      } else if ($verb==FL_DRILL) {
        fl_modifier($FL_DRILL) do_drill();

      } else if ($verb==FL_CUTOUT) {
        fl_modifier($FL_CUTOUT) do_cutout();

      } else if ($verb==FL_PAYLOAD) {
        fl_modifier($FL_PAYLOAD) do_payload();

      } else
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=size*1.2);
  }
}
