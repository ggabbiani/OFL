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

/******************************************************************************
 * Hole driven PCB holders
 *****************************************************************************/

// constructor
function fl_pcb_HoleDrivenHolder(
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
  ["pcb/holder height", h],
];

module fl_pcb_holeDrivenHolder(
  verbs,
  // as returned from function fl_pcb_HoleDrivenHolder()
  type,
  // FL_DRILL thickness
  thick=0,
  // frame specs as a list [«z height»,«xy thickness»]
  frame,
  // desired direction [director,rotation], native direction when undef
  direction,
  // when undef native positioning is used
  octant,
) {
  // $FL_TRACE=true;
  assert(verbs!=undef);
  assert(type!=undef);
  assert(frame==undef||len(frame)==2,frame);

  screw   = fl_screw(type);
  scr_r   = screw_radius(screw);

  washer  = screw_washer(screw);
  wsh_t   = washer_thickness(washer);
  wsh_r   = washer_radius(washer);

  bbox    = fl_bb_corners(type);
  size    = bbox[1]-bbox[0];
  pcb     = fl_pcb(type);
  pcb_t   = fl_pcb_thick(pcb);
  pcb_bb  = fl_bb_corners(pcb);

  h       = fl_get(type,"pcb/holder height");
  radius  = wsh_r;

  holes = [for(hole=fl_holes(pcb)) let(p = hole[0],n = hole[1],d = hole[2]) [p,n,d]];

  D     = direction ? fl_direction(proto=type,direction=direction)  : FL_I;
  M     = octant    ? fl_octant(octant=octant,bbox=bbox)            : FL_I;

  module do_add() {
    difference() {
      union() {
        fl_lay_holes(holes)
          translate(-Z(pcb_t)) let(
              pos = holes[$hole_i][0],
              dx0 = abs(abs(pcb_bb[0].x)-abs(pos.x)),
              dy0 = abs(abs(pcb_bb[0].y)-abs(pos.y)),
              dx1 = abs(abs(pcb_bb[1].x)-abs(pos.x)),
              dy1 = abs(abs(pcb_bb[1].y)-abs(pos.y)),
              r   = min(wsh_r,dx0,dy0,dx1,dy1),
              t   = r-$hole_d / 2
            ) fl_cylinder(r=r,h=h,octant=-Z);
        if (frame)
          translate(bbox[0])
            linear_extrude(frame[0])
              fl_2d_frame(size=size,thick=frame[1],quadrant=+X+Y);
      }
      fl_pcb(FL_DRILL,pcb,thick=h+NIL);
    }
  }

  module do_drill() {
    fl_lay_holes(holes,thick=thick)
      translate(-$hole_n*(h+pcb_t))
        fl_cylinder(d=$hole_d,h=$hole_depth,octant=-Z);
  }

  module do_layout() {
    fl_lay_holes(holes,thick=thick)
      children();
  }

  fl_manage(verbs,M,D,(bbox[1]-bbox[0])) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) fl_color($FL_FILAMENT) do_add();

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) fl_pcb([FL_ADD,FL_ASSEMBLY],pcb,thick=h);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier) do_drill();

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout() children();

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier) fl_pcb(FL_MOUNT,pcb,thick=h);

    } else if ($verb==FL_PAYLOAD) {
      fl_modifier($modifier) fl_bb_add(pcb_bb);

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

/******************************************************************************
 * Size driven PCB holders
 *****************************************************************************/

// TODO: make a constructor
module fl_pcb_holdBySize(
  verbs,
  // OFL native PCB
  pcb,
  // height of holders along z axis excluding PCB thickness
  h,
  // FL_DRILL thickness
  thick=0,
  // frame specs as a list [«z height»,«xy thickness»]
  // NOTE: «xy thickness» is currently auto calculated (so ignored)
  frame,
  tolerance = 0.5,
  // desired direction [director,rotation], native direction when undef
  direction,
  // when undef native positioning is used
  octant,
) {
  assert(verbs!=undef);
  assert(pcb!=undef);
  assert(h!=undef);
  assert(frame==undef||len(frame)==2,frame);

  screw   = M3_cap_screw;
  scr_r   = screw_radius(screw);

  washer  = screw_washer(screw);
  wsh_t   = washer_thickness(washer);
  wsh_r   = washer_radius(washer);

  r       = scr_r;
  R       = wsh_r+1;

  pcb_t   = fl_pcb_thick(pcb);
  pcb_bb  = fl_bb_corners(pcb);

  bbox    = let(
      C0    = pcb_bb[0],
      C1    = pcb_bb[1],
      delta = (tolerance+sin(45)*r+R)*[1,1,0]
    ) [
    C0-delta-Z(h),
    C1+delta
  ];
  size    = bbox[1]-bbox[0];

  D       = direction ? fl_direction(direction=direction,default=[Z,X])  : FL_I;
  M       = octant    ? fl_octant(octant=octant,bbox=bbox)            : FL_I;

  holes  = let(
      C0  = pcb_bb[0],
      C1  = [pcb_bb[1].x,pcb_bb[1].y,pcb_bb[0].z],
      r   = scr_r,
      t   = tolerance,
      delta = (sin(45)*r+t)
    ) [
    // «3d point»,«plane normal»,«diameter»[,«depth»]
    [C0-delta*[1,1,0]+Z(pcb_t),+Z,2*r,h+pcb_t],
    [[-C0.x,C0.y,C0.z]-delta*[-1,1,0]+Z(pcb_t),+Z,2*r,h+pcb_t],
    [C1+delta*[1,1,0]+Z(pcb_t),+Z,2*r,h+pcb_t],
    [[-C1.x,C1.y,C1.z]+delta*[-1,1,0]+Z(pcb_t),+Z,2*r,h+pcb_t],
  ];

  module do_add() {
    difference(){
      union() {
        fl_lay_holes(holes)
          fl_cylinder(r=R,h=h+pcb_t,octant=-Z);
        if (frame)
          translate(bbox[0])
            linear_extrude(frame[0])
              fl_2d_frame(size=size,thick=R+r*sin(45),corners=R,quadrant=+X+Y);
      }
      fl_holes(holes,[+Z]);
      fl_bb_add([
        pcb_bb[0]-tolerance*[1,1,0]-Z(NIL),
        pcb_bb[1]+tolerance*[1,1,0]+Z(NIL)
      ]);
    }
  }

  module do_layout() {
    fl_lay_holes(holes,thick=thick)
      children();
  }

  module do_drill() {
    fl_lay_holes(holes)
      translate(-$hole_n*(h+pcb_t))
        fl_cylinder(r=r,h=thick,octant=-Z);
  }

  module do_mount() {
    fl_lay_holes(holes)
      // translate(Z(washer_thickness(washer)))
      fl_screw([FL_ADD,FL_ASSEMBLY],type=screw,washer="nylon",thick=h+pcb_t+thick);
  }

  fl_manage(verbs,M,D,(bbox[1]-bbox[0])) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) fl_color($FL_FILAMENT) do_add();

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) fl_pcb([FL_ADD,FL_ASSEMBLY],pcb,thick=h);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier) do_drill();

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout() children();

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier) do_mount();

    } else if ($verb==FL_PAYLOAD) {
      fl_modifier($modifier) fl_bb_add(pcb_bb);

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
