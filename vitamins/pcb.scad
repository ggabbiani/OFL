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
use     <../foundation/hole.scad>
use     <../foundation/placement.scad>
include <../foundation/type_trait.scad>

use     <ether.scad>
include <pin_headers.scad>
use     <screw.scad>

include <pcbs.scad>

// Convert offsets from the edge to coordinates relative to the centre
// This allows negative ordinates to represent offsets from the far edge
function pcb_coord(size, p) = [
    (p.x >= 0 ? p.x : size.x + p.x) - size.x / 2,
    (p.y >= 0 ? p.y : size.y + p.y) - size.y / 2
  ];

module fl_grid_plating(grid,size,pcb_color,holes) {
  t               = size.z;
  plating         = 0.1;
  fr4             = pcb_color != "sienna";
  plating_colour  = is_undef(grid[4]) ? ((pcb_color == "green" || pcb_color == "#2140BE") ? silver : pcb_color == "sienna" ? copper : gold) : grid[4];
  color(plating_colour)
    translate(-Z(plating))
      linear_extrude(fr4 ? t + 2 * plating : plating) {
        fl_grid_layout(grid,size)
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

/**
 * Return the grid size in [cols,rows] format
 */
function fl_grid_geometry(grid,size) = let(
    cols  = is_undef(grid[2]) ? round((size.x - 2 * grid.x) / inch(0.1))  : grid[2] - 1,
    rows  = is_undef(grid[3]) ? round((size.y - 2 * grid.y) / inch(0.1))  : grid[3] - 1
  ) [cols,rows];

/**
 * Iterates over grid members calling children with the following context:
 * $position  ⇒ current [column,row] position 
 * $point     ⇒ current [x,y,z] 3d position
 */
// TODO: unify this grid implementation with fl_2d_grid()
module fl_grid_iterate(
  // grid specs as from NopSCADlib: [«origin x»,«origin y»,«optional columns»,«optional rows»,«optional plating color»]
  grid,
  // 2d pcb size
  size
) {
  // conversion inches ⇒ millimeters
  function inch(inches) = inches*25.4;
  // Transforms [columns,rows,z] grid position into 3d [x,y,z] position
  function grid2xyz(position) = let(
    column  = position.x,
    row     = position.y,
    z       = is_undef(position.z) ? 0 : position.z
  ) [
      -size.x / 2 + grid.x + 2.54 * column,
      -size.y / 2 + grid.y + 2.54 * row, 
      +size.z + z
    ];

  geometry  = fl_grid_geometry(grid,size);
  cols      = geometry.x;
  rows      = geometry.y;
  for(x = [0 : cols], y = [0 : rows])
    let(
      $position = [x,y],
      $point    = grid2xyz($position)
    ) children();
  // $position = [0,0];
  // $point    = grid2xyz($position);
  // children();
}

/**
 * Layout children over 3d positions, same context as fl_grid_iterate() module.
 */
// TODO: better management needed for the grid origin. 
// For now it follows NopSCADlib conventions, implying the grid placed in the first quadrant.
// This implies positive coords for all the grid points. Useful for implementing
// the convention abouot negative coordinates for hole offsets from the pcb edges.
// But this is incoherent with OFL hole conventions, actually using all the 3d space
// and so accepting also negatives as valid hole coordinates.
module fl_grid_layout(
  // grid specs as from NopSCADlib: [«origin x,y»,«optional columns»,«optional rows»]
  grid,
  // 2d pcb size
  size
) {
  fl_grid_iterate(grid,size)
    translate($point)
      children();
}

module fl_pcb(
  verbs=FL_ADD,   // FL_ADD, FL_ASSEMBLY, FL_AXES, FL_BBOX, FL_CUTOUT, FL_DRILL, FL_LAYOUT
  type,
  cut_tolerance=0,// FL_CUTOUT tolerance 
  cut_label,      // FL_CUTOUT component filter by label
  cut_direction,  // FL_CUTOUT component filter by direction (+X,+Y or +Z)
  // FL_DRILL and FL_CUTOUT thickness in fixed form [[-X,+X],[-Y,+Y],[-Z,+Z]] or scalar shortcut
  thick=0,
  // FL_ASSEMBLY,FL_LAYOUT enabled directions passed as list of strings
  lay_direction="+z",
  direction,      // desired direction [director,rotation], native direction when undef
  octant          // when undef native positioning is used
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(!(cut_direction!=undef && cut_label!=undef),"cutout filtering cannot be done by label and direction at the same time");

  fl_trace("thick",thick);

  axes      = fl_list_has(verbs,FL_AXES);
  verbs     = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  pcb_t     = fl_pcb_thick(type);
  comps     = fl_pcb_components(type);
  bbox      = fl_bb_corners(type);
  size      = fl_bb_size(type);
  D         = direction ? fl_direction(proto=type,direction=direction)  : I;
  M         = octant    ? fl_octant(octant=octant,bbox=bbox)            : I;
  holes     = fl_holes(type);
  screw     = fl_screw(type);
  screw_r   = screw_radius(screw);
  thick     = is_num(thick) ? [[thick,thick],[thick,thick],[thick,thick]] 
            : assert(fl_tt_isThickList(thick)) thick;
  dr_thick  = thick.z[0]; // thickness along -Z
  cut_thick = thick;
  material  = fl_material(type,default="green");
  radius    = fl_pcb_radius(type);
  grid      = fl_has(type,"pcb/grid",function(value) true) ? fl_pcb_grid(type) : undef;

  fl_trace("type",type);
  fl_trace("holes",fl_holes(type));
  fl_trace("bbox",bbox);
  fl_trace("grid",grid);

  // TODO: better clarify the kind of native positioning, right now it places pcb on first quadrant
  // then translate according the bounding box. This doesn't match the behaviour followed
  // for holes, that are instead already placed din the final full 3d space
  module do_add() {
    fl_color(material) difference() {
      translate(Z(bbox[0].z)) linear_extrude(pcb_t)
        difference() {
          translate(bbox[0]) 
            fl_square(corners=radius,size=[size.x,size.y],quadrant=+X+Y);
          if (grid)
            fl_grid_layout(grid,size)
              circle(d=1);
        }
      fl_holes(holes,"+Z");
    }
    if (grid)
      fl_grid_plating(grid=grid,size=size,pcb_color=material,holes=holes);
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
    fl_lay_holes(holes,lay_direction) 
      fl_screw([FL_ADD,FL_ASSEMBLY],type=screw,nut="default",thick=dr_thick+pcb_t,nwasher=true);
  }

  module do_drill() {
    fl_lay_holes(holes,"+z")
      fl_cylinder(d=$diameter,h=dr_thick+pcb_t,octant=-$normal);
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
      } else
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=size*1.2);
  }
}
