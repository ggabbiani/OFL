/*
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

include <NopSCADlib/lib.scad>

module screw_and_nylon_washer(screw,len,filament) {
  washer    = screw_washer(screw);
  washer_t  = washer_thickness(washer);
  screw(screw,len+FL_NIL);
  fl_color("DarkSlateGray") translate(-fl_Z(washer_t)) washer(washer);
}

// contructor
function fl_pcb_Holder(
  // OFL PCB
  pcb,
  // screw used for PCB fixing
  screw,            
  // screw len fixes the holder height
  len,              
  tolerance=0.5, 
  // when >0 a base frame is added to supports
  frame_t=0,   
  // when true only two on the four available screws will be mounted
  half=true 
) =
assert(pcb!=undef)
let(
  hole_r      = screw_radius(screw),

  washer      = screw_washer(screw),
  washer_t    = washer_thickness(washer),
  washer_r    = washer_radius(washer),

  holder_h    = len-washer_t,
  holder_r    = hole_r,
  holder_R    = washer_r,
  
  // pcb 'as is'
  pcb_corners = fl_bb_corners(pcb),
  pcb_size    = fl_bb_size(pcb),
  
  // pcb with tolerance applied
  pcb_t_corners = let(c=pcb_corners,t=tolerance) c+[[-t,-t,0],[t,t,0]],
  pcb_t_size    = pcb_size+[2*tolerance,2*tolerance,0],
  
  // x and y distance between holes and 'toleranced' pcb
  delta   = hole_r/sqrt(2),
  holes   = let(c=pcb_t_corners,d=delta,z=c[0].z) 
      half==true 
    ? c+[[-d,-d,-c[0].z],[d,d,-c[1].z]] 
    : let(c4=[c[0],c[1],[c[1].x,c[0].y,0],[c[0].x,c[1].y,0]]) c4+[[-d,-d,-c[0].z],[d,d,-c[1].z],[d,-d,0],[-d,d,0]],
  t       = pcb_size.z,

  corners = let(R=holder_R,h=holder_h) holes+[[-R,-R,0],[R,R,h]]

) fl_bb_new(negative=corners[0],positive=corners[1]);

module pcb_holder(
  verbs,
  type,
  screw,                    // screw used for PCB fixing
  screw_len,
  filament  = "DodgerBlue", // filament color
  tolerance = 0.5,
  center    = false,
  frame     = false,        // when true a base frame is added to supports
  half      = true,         // when true only two on the four available screws will be mounted
  thick                     // mandatory when frame==true
  ) {
  // $FL_TRACE=true;
  assert(verbs!=undef);

  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  hole_r      = screw_radius(screw);

  washer      = screw_washer(screw);
  washer_t    = washer_thickness(washer);
  washer_r    = washer_radius(washer);

  holder_h    = screw_len-washer_t;
  holder_r    = hole_r;
  holder_R    = washer_r;
  
  // pcb 'as is'
  pcb_corners = fl_bb_corners(type);
  pcb_size    = fl_bb_size(type);
  
  // pcb with tolerance applied
  pcb_t_corners = let(c=pcb_corners,t=tolerance) c+[[-t,-t,0],[t,t,0]];
  pcb_t_size    = pcb_size+[2*tolerance,2*tolerance,0];
  
  delta   = hole_r/sqrt(2); // x and y distance between holes and 'toleranced' pcb
  fl_trace("Half",half);
  holes   = let(c=pcb_t_corners,d=delta,z=c[0].z) 
      half==true 
    ? c+[[-d,-d,-c[0].z],[d,d,-c[1].z]] 
    : let(c4=[c[0],c[1],[c[1].x,c[0].y,0],[c[0].x,c[1].y,0]]) c4+[[-d,-d,-c[0].z],[d,d,-c[1].z],[d,-d,0],[-d,d,0]];
  fl_trace("Holes",holes);
  t       = pcb_size.z;

  corners     = let(R=holder_R,h=holder_h) holes+[[-R,-R,0],[R,R,h]];
  bbox        = corners[1]-corners[0];

  M  = let(h=holes,fl_T=h[0],A=h[0],B=h[1],D=(A+(B-A)/2)) center ? [
    [1,0,0,-D.x],
    [0,1,0,-D.y],
    [0,0,1,-D.z],
  ] : [
    [1,0,0,-fl_T.x],
    [0,1,0,-fl_T.y],
    [0,0,1,-fl_T.z],
  ];
  fl_trace("M",M);

  assert(holder_R>delta+holder_r/sqrt(2));

  module pcb(tolerance=false) {
    size  = tolerance?pcb_t_size:pcb_size;
    c     = tolerance?pcb_t_corners:pcb_corners;
    translate([0,0,holder_h-size.z]+c[0]) cube(size=size+[0,0,FL_NIL]);
  }

  module do_add() {

    module frame() {
      fl_color(filament) translate(corners[0]-FL_Z*thick) difference() {
        cube(size=[bbox.x,bbox.y,thick]);
        translate([2*holder_R,2*holder_R,-FL_NIL]) cube(size=[bbox.x-4*holder_R,bbox.y-4*holder_R,thick+2*FL_NIL]);
      }
    }

    module holder() {
      r=holder_R;
      h=holder_h;
      fl_color(filament) difference() {
        translate(fl_Z(h/2)) cylinder(r=r, h=h, center=true);
        translate(fl_Z(screw_len)) screw(screw,screw_len);
      }
    }

    difference() {
      for(hole=holes) translate(fl_2(hole)) holder();
      pcb(tolerance=true);
    }
    if (frame)
      frame();
  }
  
  module do_bbox() {
    translate(corners[0]) %cube(size=bbox);
  }

  module do_assembly() {
    fl_color("green") pcb();
    fl_trace("Holes size",len(holes));
    for(i=[0:len(holes)-1])
      translate(fl_2(holes[i])) translate(fl_Z(screw_len)) children(i);
  }

  module do_layout()    {}
  module do_drill()     {}

  fl_parse(verbs) {
    if ($verb==FL_ADD) {
      multmatrix(M) do_add();
      if (axes)
        axes(bbox);
    } else if ($verb==FL_BBOX) {
      multmatrix(M) do_bbox();
    } else if ($verb==FL_ASSEMBLY) {
      multmatrix(M) do_assembly() {
        screw_and_nylon_washer(screw,screw_len,filament);
        screw_and_nylon_washer(screw,screw_len,filament);
        screw_and_nylon_washer(screw,screw_len,filament);
        screw_and_nylon_washer(screw,screw_len,filament);
      }
    } else if ($verb==FL_LAYOUT) { 
      multmatrix(M) do_layout() children();
    } else if ($verb==FL_DRILL) {
      multmatrix(M) color("orange") {
        do_drill();
      }
    } else if ($verb==FL_AXES) {
      fl_trace("bbox = ",bbox);
      fl_axes(bbox);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
