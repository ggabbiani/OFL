/*
 * PSU vitamin module implementation.
 *
 * Copyright © 2021 Giampiero Gabbiani.
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

include <psus.scad>
use     <screw.scad>
use     <../foundation/hole.scad>
use     <../foundation/util.scad>

include <../foundation/unsafe_defs.scad>

module ofl_psu(
  // MANDATORY verb or list of verbs
  verbs,                  
  // MANDATORY
  type,                   
  // holder thickness
  thick    = 0,           
  // screw versors (as surface normals) ["+X","+Y","-Z"]
  assembly = ["+X","+Y","-Z"], 
  // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,              
  // when undef native positioning is used
  octant                  
  ) {
  // $FL_TRACE=true;
  assert(verbs!=undef);
  assert(type!=undef);

  function terminal_size(type)     = let(
      term_ways   = fl_get(type,"terminal ways"),
      term_step   = fl_get(type,"terminal step"),
      term_esz    = fl_get(type,"terminal edge size")
    ) [
      term_step*term_ways+term_esz.x,
      term_esz.y,
      term_esz.z
    ];

  axes        = fl_list_has(verbs,FL_AXES);
  verbs       = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  pcb_color   = "#FCD67E";
  pcb_t       = fl_get(type,"pcb thickness");
  holes       = fl_holes(type);

  screw       = fl_screw(type);
  screw_r     = screw_radius(screw);
  screw_len   = screw_longer_than(thick+1);

  term_screw  = fl_get(type,"terminal screw");
  term_ways   = fl_get(type,"terminal ways");
  term_step   = fl_get(type,"terminal step");
  term_esz    = fl_get(type,"terminal edge size");
  term_size   = terminal_size(type);

  grid_d      = fl_get(type,"grid diameter");
  grid_t      = fl_get(type,"grid thickness");
  grid_faces  = fl_get(type,"grid surfaces");
  grid_shift  = grid_d + fl_get(type,"grid diagonal delta");

  bent_sheet  = fl_folding(faces=grid_faces);
  cbox        = fl_bb_corners(bent_sheet); // case box
  cbox_sz     = cbox[1]-cbox[0];
  bbox        = fl_bb_corners(type);
  bbox_sz     = bbox[1]-bbox[0];

  pcb_size    = [cbox_sz.x-2*grid_t,cbox_sz.y-grid_t,pcb_t];

  D           = direction ? fl_direction(proto=type,direction=direction)      : I;
  M           = octant    ? fl_octant(octant=octant,bbox=fl_bb_corners(type)) : I;

  fl_trace("grid shift",grid_shift);

  module terminal() {
    module flange() {
      r=0.5;
      s=[term_esz.z,term_esz.y,term_esz.x];
      // fl_color(grey20) 
      translate(-fl_Y(s.y/2))
      translate(fl_Z(s.y))
      rotate(90,FL_Y)
      translate([r,r])
      minkowski() { // dimensione risultante = [12,11]
        cube([s.x-r*2,s.y-r*2,s.z/2]);
        cylinder(r=r,h=s.z/2);
      }
    }
    translate(-fl_X(term_size.x/2)) {
      for(i=[0:term_ways-1]) translate(i*fl_X(term_step)) {
      // for(i=[0:0]) translate(i*fl_X(term_step)) {
        // base
        fl_color(grey(20)) 
        let(size=[term_step+term_esz.x, term_esz.y, 8])
        translate([size.x/2,0, 5-size.z/2])
        cube(size=size, center=true);
        // gruppo vite
        translate([(term_step+term_esz.x)/2,0,5]) 
          fl_color("silver") {
            translate(fl_Z(0.75)) {
              translate(fl_Z(1))
                screw(term_screw,8);
              cube(size=[5.9, 5.9, 1.5], center=true);
            }
            translate(fl_Z(0.25))
            cube(size=[5, 8, 0.5], center=true);
          }
        // flangia laterale
        fl_color(grey(20)) flange();
      }
      // flangia laterale di chiusura
      fl_color(grey(20)) 
      translate(fl_X((term_ways)*term_step))
      flange();
    }
  }

  module do_add() {
    difference() {
      // case box as a bent sheet metal
      fl_bend(type=bent_sheet,octant=+Y+Z)
        linear_extrude(fl_bb_size($sheet).z) 
          difference() {
            // 2d surface fitting the calculated $sheet size
            fl_bb_add(corners=fl_bb_corners($sheet),2d=true);
            // grid on face 4 (normal +Y) and part of face 1 (normal +Z)
            if (search($fid,[4,1])) 
              fl_grid_layout(origin=[0,grid_d],r_step=grid_shift,bbox=[$C,$M] + [[grid_shift,-grid_shift],-[5,9]],clip=false) 
                fl_circle(d=grid_d);
            // grid on face 0,1 (normal -X and +Z) 
            if (search($fid,[0,1])) 
              fl_grid_layout(origin=[2*grid_shift,1.5*grid_shift],r_step=grid_shift,bbox=[$A,$F] + [[1,5],-[5,3]],clip=false)
                fl_circle(d=grid_d);
          }
      // screw holes
      fl_holes(holes);
    }
    // pcb
    fl_color(pcb_color) 
      translate([0,0,5.5-pcb_t/2])
        fl_cube(size=pcb_size, octant=+Y);
    // terminal
    translate([-((cbox_sz.x-2)-term_size.x)/2,-term_size.y/2+5.5,term_size.z/2+5.0])
      rotate(90,FL_X) terminal();
  }

  module do_bbox() {
    translate([0,bbox_sz.y/2+fl_bb_corners(type)[0].y,bbox_sz.z/2])
      cube(bbox_sz,true);
  }

  module do_assembly()  {
    do_layout()
      translate(thick*$hole_n)
        fl_screw(type=screw,len=screw_len,direction=[$hole_n,0]);
  }

  module do_drill()  {
    fl_holes(holes);
  }

  module do_layout() {
    fl_lay_holes(holes,assembly)
      children();
  }

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_add();

      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) do_bbox();

      } else if ($verb==FL_ASSEMBLY) {
        fl_modifier($FL_ASSEMBLY) do_assembly();

      } else if ($verb==FL_LAYOUT) { 
        fl_modifier($FL_LAYOUT) do_layout() {
          children();
        }
      } else if ($verb==FL_DRILL) {
        fl_modifier($FL_DRILL)  do_drill();
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=1.2*cbox_sz);
  }
}
