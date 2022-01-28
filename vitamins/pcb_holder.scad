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

include <../foundation/hole.scad>
include <../foundation/tube.scad>

include <../vitamins/pcbs.scad>

module screw_and_nylon_washer(screw,len,filament) {
  washer    = screw_washer(screw);
  washer_t  = washer_thickness(washer);
  screw(screw,len+FL_NIL);
  fl_color("DarkSlateGray") translate(-fl_Z(washer_t)) washer(washer);
}

function fl_pcb(type,value)      = fl_property(type,"pcb in OFL format",value);

// contructor
function fl_pcb_Holder(
  // OFL PCB
  pcb,
  // holder height
  h,
  // TODO: ignored in case of pcb with holes
  // tolerance=0.5
) =
assert(pcb)
assert(h)
let(
  screw   = fl_screw(pcb),

  washer  = screw_washer(screw),
  wsh_t   = washer_thickness(washer),
  wsh_r   = washer_radius(washer),

  pcb_bb      = fl_bb_corners(pcb),
  pcb_t = fl_pcb_thick(pcb),
  bbox    = [pcb_bb[0]-Z(h),pcb_bb[1]]
  // bbox    = [pcb_bb[0]-Z(h),[pcb_bb[1].x,pcb_bb[1].y,pcb_bb[0].z]]
) [
  fl_name(value=str("Holder for ",fl_name(pcb))),
  fl_screw(value=screw),
  // TODO: fl_tolerance(value=tolerance),
  fl_bb_corners(value=bbox),
  fl_director(value=+FL_Z),fl_rotor(value=+FL_X),
  fl_pcb(value=pcb),
  ["holder/height", h],
];

module pcb_holder(
  verbs,
  // as returned from function fl_pcb_Holder()
  type,
  // when >0 a frame is added
  frame = 0,
  // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  // when undef native positioning is used
  octant,
) {
  // $FL_TRACE=true;
  assert(verbs!=undef);
  assert(type!=undef);
  assert(frame>=0);

  screw       = fl_screw(type);
  scr_r       = screw_radius(screw);

  washer      = screw_washer(screw);
  wsh_t    = washer_thickness(washer);
  wsh_r    = washer_radius(washer);

  bbox    = fl_bb_corners(type);
  size    = bbox[1]-bbox[0];
  pcb     = fl_pcb(type);
  pcb_t   = fl_pcb_thick(pcb);
  pcb_bb  = fl_bb_corners(pcb);

  h    = fl_get(type,"holder/height");
  radius     = wsh_r;
  // thick = wsh_r - scr_r;

  holes = fl_holes(pcb);

  D     = direction ? fl_direction(proto=type,direction=direction)  : FL_I;
  M     = octant    ? fl_octant(octant=octant,bbox=bbox)            : FL_I;

  module do_add() {

    module frame() {
      translate(bbox[0]-Z*size.z) difference() {
        cube(size=[bbox.x,bbox.y,thick]);
        translate([2*holder_R,2*holder_R,-FL_NIL]) cube(size=[bbox.x-4*holder_R,bbox.y-4*holder_R,thick+2*FL_NIL]);
      }
    }

    fl_lay_holes(holes)
      translate(-Z(pcb_t)) let(
          pos = holes[$hole_i][0],
          dx0 = abs(abs(pcb_bb[0].x)-abs(pos.x)),
          dy0 = abs(abs(pcb_bb[0].y)-abs(pos.y)),
          dx1 = abs(abs(pcb_bb[1].x)-abs(pos.x)),
          dy1 = abs(abs(pcb_bb[1].y)-abs(pos.y)),
          r   = min(wsh_r,dx0,dy0,dx1,dy1),
          t   = r-$hole_d / 2
        ) fl_tube(r=r,h=h,thick=t,octant=-Z);

    if (frame)
      frame();
  }

  module do_bbox() {
    fl_bb_add(bbox);
  }

  module do_assembly() {
    fl_pcb([FL_ADD,FL_ASSEMBLY],pcb,thick=h);
    // fl_color("green") pcb();
    // fl_trace("Holes size",len(holes));
    // for(i=[0:len(holes)-1])
    //   translate(fl_2(holes[i])) translate(Z(screw_len)) children();
  }

  module do_layout()    {}
  module do_drill()     {}

  fl_manage(verbs,M,D,(bbox[1]-bbox[0])) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_assembly()
        screw_and_nylon_washer(screw,screw_len,filament);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) do_bbox();

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout() children();

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier) do_drill();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
