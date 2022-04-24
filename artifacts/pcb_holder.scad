/*
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org)
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

include <spacer.scad>

/******************************************************************************
 * Hole driven PCB holders
 *****************************************************************************/

function fl_bb_holderByHoles(
    pcb,
    // spacers height
    h
  ) = let(
    pcb_bb  = fl_bb_corners(pcb),
    pcb_sz  = pcb_bb[1]-pcb_bb[0]
  ) [[pcb_bb[0].x,pcb_bb[0].y,0],[pcb_bb[1].x,pcb_bb[1].y,pcb_sz.z]+Z(h)];

/*
 * PCB holder by holes engine
 *
 * children() context:
 *
 * $holder_screw
 */
module fl_pcb_holderByHoles(
  verbs,
  pcb,
  // spacers height
  h,
  // FL_DRILL thickness
  thick=0,
  // knurl nut
  knut=false,
  frame,
  // FL_LAYOUT directions in floating semi-axis list
  lay_direction=[+Z,-Z],
  // desired direction [director,rotation], native direction when undef
  direction,
  // when undef native positioning is used
  octant,
) {
  assert(verbs!=undef);
  assert(pcb);
  assert(h);

  bbox    = fl_bb_holderByHoles(pcb,h);

  pcb_t   = fl_pcb_thick(pcb);
  pcb_bb  = fl_bb_corners(pcb);
  pcb_r   = fl_pcb_radius(pcb);
  pcb_sz  = pcb_bb[1]-pcb_bb[0];

  screw   = fl_screw(pcb);
  // scr_r   = screw_radius(screw);

  washer  = screw_washer(screw);
  wsh_t   = washer_thickness(washer);
  wsh_r   = washer_radius(washer);

  radius  = wsh_r;
  size    = bbox[1]-bbox[0];

  // NOTE: thickness along ±Z only
  thick   = is_num(thick) ? [[thick,thick],[thick,thick],[thick,thick]] : assert(fl_tt_isAxisVList(thick)) thick;

  // echo(holes=fl_holes(pcb));
  holes = [for(hole=fl_holes(pcb)) let(point = [hole[0].x,hole[0].y,0],normal = hole[1],d = hole[2],options=hole[4]) [
      point,normal,d,0,options]
    ];
  D     = direction ? fl_direction(direction=direction,default=[+Z,+X]) : I;
  M     = octant    ? fl_octant(octant=octant,bbox=bbox)                : I;
  Mpcb  = T(Z(h-pcb_bb[0].z));

  module context() {
    $hld_thick  = thick;
    $hld_h      = h;
    $hld_screw  = $hole_screw ? $hole_screw : screw;
    $hld_pcb    = pcb;
    // $hld_director = director;
    children();
  }

  function optimal_r(center,bb,screw) = let(
      dx0 = abs(abs(bb[0].x)-abs(center.x)),
      dy0 = abs(abs(bb[0].y)-abs(center.y)),
      dx1 = abs(abs(bb[1].x)-abs(center.x)),
      dy1 = abs(abs(bb[1].y)-abs(center.y)),
      w   = screw ? screw_washer(screw) : undef,
      v   = [if (w) washer_radius(w),dx0,dy0,dx1,dy1]
    ) min(v);

  module spacer(verbs,position,screw,dirs=lay_direction,Zt) {
    thick=Zt?[[0,0],[0,0],Zt]:thick+[[0,0],[0,0],[0,pcb_t]];
    r=optimal_r(position,pcb_bb,screw);
    // echo(thick=thick);
    fl_spacer(verbs,h=h,r=r,screw=screw,knut=knut,thick=thick,lay_direction=dirs)
      children();
  }

  module do_add() {
    fl_lay_holes(holes)
      context()
        spacer(FL_ADD,position=$hole_pos,screw=$hld_screw);

    if (frame) difference() {
      translate(bbox[0]) fl_color($FL_FILAMENT) linear_extrude(frame)
        fl_square(size=[pcb_sz.x,pcb_sz.y],corners=pcb_r,quadrant=+X+Y);
      translate(+Z(frame))
        fl_lay_holes(holes)
          context()
            translate(+Z(NIL))
              spacer(FL_DRILL,position=$hole_pos,screw=$hld_screw,dirs=[-Z],Zt=[frame+NIL2,0]);
    }
  }

  module do_drill() {
    fl_lay_holes(holes,thick=thick)
      context()
        spacer(FL_DRILL,$hole_pos,screw=$hld_screw);
  }

  module do_layout() {
    fl_lay_holes(holes,thick=thick,screw=screw)
      let(s=$hole_screw ? $hole_screw : screw)
        spacer(FL_LAYOUT,$hole_pos,s)
          translate($spc_director*$spc_thick)
            context()
              children();
  }

  module do_mount() {
    fl_lay_holes(holes,thick=thick)
      context()
        spacer(FL_MOUNT,$hole_pos,screw=$hld_screw);
  }

  module do_assembly() {
    // translate(Z(h-pcb_bb[0].z))
    multmatrix(Mpcb)
      fl_pcb(FL_DRAW,pcb,thick=h);
    fl_lay_holes(holes)
      context()
        spacer(FL_ASSEMBLY,position=$hole_pos,screw=$hld_screw);
  }

  fl_manage(verbs,M,D,(bbox[1]-bbox[0])) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_assembly();

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier) do_drill();

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout() children();

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier) do_mount();

    } else if ($verb==FL_PAYLOAD) {
      fl_modifier($modifier) multmatrix(Mpcb) fl_bb_add(pcb_bb);

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

/******************************************************************************
 * Size driven PCB holders
 *****************************************************************************/

function __R__(screw) = washer_radius(screw_washer(screw));

function fl_bb_holderBySize(
    pcb,
    // spacers height
    h,
    // used for the pcb joints
    tolerance = 0.5,
    // mounting screw
    screw = M3_cap_screw,
    // knurl nut
    knut=false
  ) =
  assert(pcb)
  assert(h)
  assert(is_bool(knut))
  let(
    pcb_bb  = fl_bb_corners(pcb),
    pcb_sz  = pcb_bb[1]-pcb_bb[0],
    pcb_t   = fl_pcb_thick(pcb),

    knut    = knut ? fl_knut_search(screw,h) : undef,
    r       = fl_spc_holeRadius(screw,knut),
    r_knut  = knut ? fl_knut_r(knut) : r,
    R       = __R__(screw),
    delta   = (__deltaXY__(h,tolerance,screw,knut!=undef)+R)*[1,1,0]
  )
  echo(delta=delta)
  [[pcb_bb[0].x,pcb_bb[0].y,0]-delta,[pcb_bb[1].x,pcb_bb[1].y,pcb_sz.z]+delta+Z(h-pcb_t)];

function __deltaXY__(
    // spacers height
    h,
    tolerance = 0.5,
    // mounting screw
    screw = M3_cap_screw,
    // knurl nut
    knut=false
  ) =
  assert(h)
  assert(is_bool(knut))
  let(
    knut    = knut ? fl_knut_search(screw,h) : undef,
    r       = fl_spc_holeRadius(screw,knut),
    r_knut  = knut ? fl_knut_r(knut) : r,
    R       = __R__(screw)
  ) (tolerance+sin(45)*r_knut+0*R);

/*
 * engine for pcb holder by size
 *
 * children() context:
 *
 * $holder_screw
 */
module fl_pcb_holderBySize(
  verbs,
  pcb,
  // spacers height
  h,
  // used for the pcb joints
  tolerance = 0.5,
  // MANDATORY mounting screw
  screw = M3_cap_screw,

  // knurl nut
  knut=false,
  // FL_DRILL thickness
  // FIXME: rename as dri_thick
  thick=0,
  // frame thickness. 0 means 'no frame'
  frame=0,
  // FL_LAYOUT directions in floating semi-axis list
  lay_direction=[+Z,-Z],
  // desired direction [director,rotation], native direction when undef
  direction,
  // when undef native positioning is used
  octant
) {
  assert(verbs);
  assert(pcb);
  assert(h!=undef);
  assert(screw);
  assert(is_num(frame));

  scr_r   = screw_radius(screw);
  scr_d   = 2*scr_r;
  washer  = screw_washer(screw);
  wsh_t   = washer_thickness(washer);
  wsh_r   = washer_radius(washer);
  knut    = knut ? fl_knut_search(screw,h) : undef;

  bbox    = fl_bb_holderBySize(pcb,h,tolerance,screw,knut!=undef);
  size    = bbox[1]-bbox[0];

  r       = fl_spc_holeRadius(screw,knut);
  r_knut  = knut ? fl_knut_r(knut) : r;
  R       = __R__(screw);

  echo(scr_d=scr_d,h=h,knut=knut);

  pcb_t   = fl_pcb_thick(pcb);
  pcb_bb  = fl_bb_corners(pcb);
  pcb_sz  = pcb_bb[1]-pcb_bb[0];

  D       = direction ? fl_direction(direction=direction,default=[Z,X]) : I;
  M       = octant    ? fl_octant(octant=octant,bbox=bbox)              : I;
  Mpcb    = T(Z(h-pcb_bb[0].z-pcb_t));

  holes  = let(
      normal    = +Z,
      diameter  = 2*r,
      depth     = h,
      low       = pcb_bb[0],
      high      = pcb_bb[1],
      delta     = __deltaXY__(h,tolerance,screw,knut!=undef),
      quad_I    = [high.x+delta,high.y+delta,0],
      quad_II   = [low.x-delta,quad_I.y,0],
      quad_III  = [quad_II.x,low.y-delta,0],
      quad_IV   = [quad_I.x,quad_III.y,0]
    ) [
    [quad_I,  normal,diameter,depth],
    [quad_II, normal,diameter,depth],
    [quad_III,normal,diameter,depth],
    [quad_IV, normal,diameter,depth],
  ];
  echo(holes=holes,bbox=bbox);

  module context() {
    $hld_thick  = thick;
    $hld_h      = h;
    $hld_screw  = screw;
    $hld_pcb    = pcb;
    // $hld_director = director;
    children();
  }

  module spacer(verbs,position,screw,dirs=lay_direction,Zt) {
    thick=Zt?[[0,0],[0,0],Zt]:thick;
    fl_spacer(verbs,h=h,r=R,screw=screw,knut=knut,thick=thick,lay_direction=dirs)
      children();
  }

  module do_add() {
    difference() {
      fl_lay_holes(holes)
        context()
          spacer(FL_ADD,position=$hole_pos,screw=$hld_screw);
      multmatrix(Mpcb)
        fl_bb_add([
          pcb_bb[0]-tolerance*[1,1,0]-Z(NIL),
          pcb_bb[1]+tolerance*[1,1,0]+Z(NIL)
        ]);
    }
    if (frame) difference() {
      translate(bbox[0]) fl_color($FL_FILAMENT) linear_extrude(frame)
        // fl_square(size=[pcb_sz.x,pcb_sz.y],corners=pcb_r,quadrant=+X+Y);
        fl_2d_frame(size=size,thick=R+r_knut*sin(45),corners=R,quadrant=+X+Y);
      translate(+Z(frame))
        fl_lay_holes(holes)
          context()
            translate(+Z(NIL))
              spacer(FL_DRILL,position=$hole_pos,screw=$hld_screw,dirs=[-Z],Zt=[frame+NIL2,0]);
    }
  }

  module do_layout() {
    fl_lay_holes(holes,thick=thick,screw=screw)
      let(s=screw)
        spacer(FL_LAYOUT,$hole_pos,s)
          translate($spc_director*$spc_thick)
            context()
              children();
  }

  module do_drill() {
    fl_lay_holes(holes)
      context()
        spacer(FL_DRILL,$hole_pos,screw=$hld_screw);
  }

  module do_mount() {
    fl_lay_holes(holes)
      context()
        spacer(FL_MOUNT,$hole_pos,screw=$hld_screw);
  }

  module do_assembly() {
    multmatrix(Mpcb)
      fl_pcb(FL_DRAW,pcb,thick=h);
    fl_lay_holes(holes)
      context()
        spacer(FL_ASSEMBLY,position=$hole_pos,screw=$hld_screw);
  }

  fl_manage(verbs,M,D,(bbox[1]-bbox[0])) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) fl_color($FL_FILAMENT) do_add();

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_assembly();

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier) do_drill();

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout() children();

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier) do_mount();

    } else if ($verb==FL_PAYLOAD) {
      fl_modifier($modifier) multmatrix(Mpcb) fl_bb_add(pcb_bb);

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
