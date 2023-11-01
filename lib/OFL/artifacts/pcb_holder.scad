/*!
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <spacer.scad>

use <../foundation/bbox-engine.scad>
use <../foundation/mngm-engine.scad>

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

/*!
 * PCB holder by holes engine
 *
 * children() context:
 *
 * - $holder_screw
 */
module fl_pcb_holderByHoles(
  verbs,
  pcb,
  //! spacers height
  h,
  //! FL_DRILL thickness
  thick=0,
  /*!
   * knurl nut, can assume one of these values:
   *
   * - false (no knurl nut)
   * - "linear"
   * - "spiral"
   */
  knut=false,
  frame,
  //! FL_LAYOUT directions in floating semi-axis list
  lay_direction=[+Z,-Z],
  //! desired direction [director,rotation], native direction when undef
  direction,
  //! when undef native positioning is used
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

  washer  = assert(screw,"PCB's screw is 'undef'") screw_washer(screw);
  wsh_t   = washer_thickness(washer);
  wsh_r   = washer_radius(washer);

  radius  = wsh_r;
  size    = bbox[1]-bbox[0];

  // NOTE: thickness along ±Z only passed in signed-pair format
  thick   = fl_parm_SignedPair(thick);
  echo(thick=thick);

  // echo(holes=fl_holes(pcb));
  holes = [
    for(hole=fl_holes(pcb)) let(
        p     = let(p=fl_hole_pos(hole)) [p.x,p.y,0],
        n     = fl_hole_n(hole),
        d     = fl_hole_d(hole),
        ldir  = fl_hole_ldir(hole),
        loct  = fl_hole_loct(hole),
        screw = fl_hole_screw(hole)
      ) fl_Hole(p,d,n,0,ldir,loct,screw)
  ];
  // echo(holes=holes);
  D     = direction ? fl_direction(direction) : I;
  M     = fl_octant(octant,bbox=bbox);
  Mpcb  = T(Z(h+pcb_t));

  module context() {
    $hld_thick  = thick;
    $hld_h      = h;
    $hld_screw  = $hole_screw ? $hole_screw : screw;
    $hld_pcb    = pcb;
    // $hld_director = director;
    children();
  }

  function optimal_r(center,bb,screw,knut) = let(
      dx0 = abs(abs(bb[0].x)-abs(center.x)),
      dy0 = abs(abs(bb[0].y)-abs(center.y)),
      dx1 = abs(abs(bb[1].x)-abs(center.x)),
      dy1 = abs(abs(bb[1].y)-abs(center.y)),
      w   = screw ? screw_washer(screw) : undef,
      kr  = knut ? let(
        specs = fl_switch(fl_screw_nominal(screw), FL_KNUT_NOMINAL_DRILL),
        w     = assert(specs,specs) specs[2]
      ) fl_knut_r(knut)+w : 0,
      v   = [if (w) washer_radius(w),dx0,dy0,dx1,dy1]
    ) max(min(v),kr);

  module spacer(verbs=FL_ADD,position,screw,dirs=lay_direction,Zt) {
    // echo(Zt=Zt);
    knut  = knut ?
      assert(knut=="linear" || knut=="FL_KNUT_TAG_SPIRAL",knut)
        let(
          kn = fl_knut_search(screw=screw,thread=knut,thick=h)
        ) assert(kn,str("No ",knut," knurl nut found for M",fl_screw_nominal(screw)," screw.")) echo(fl_name(kn)) kn
      : undef;
    thick = Zt ? Zt : thick+[0,pcb_t];
    r     = optimal_r(position,pcb_bb,screw,knut);
    // echo("pcb_holderByHoles::spacer{}:",thick=thick,knut=knut);
    echo(r=r)
    fl_spacer(verbs,h=h,r=r,screw=screw,knut=knut,thick=thick,lay_direction=dirs)
      children();
  }

  module do_add() {
    fl_lay_holes(holes)
      context()
        spacer(position=$hole_pos,screw=$hld_screw);

    // echo("pcb_holderByHoles::do_add():",frame=frame,holes=holes,frame=frame);
    if (frame)
      difference() {
        translate(bbox[0])
          fl_color()
            linear_extrude(frame)
              fl_square(size=[pcb_sz.x,pcb_sz.y],corners=pcb_r,quadrant=+X+Y);

        translate(+Z(frame))
          fl_lay_holes(holes)
            context()
              translate(+Z(NIL))
                spacer(FL_DRILL,position=$hole_pos,screw=$hld_screw,dirs=[-Z],Zt=[-frame-2xNIL],$FL_DRILL=$FL_ADD);
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

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_assembly();

    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size);

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
    //! spacers height
    h,
    //! used for the pcb joints
    tolerance = 0.5,
    //! mounting screw
    screw = M3_cap_screw,
    //! knurl nut
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
  // echo(delta=delta)
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

/*!
 * engine for pcb holder by size
 *
 * children() context:
 *
 * - $holder_screw
 */
module fl_pcb_holderBySize(
  verbs,
  pcb,
  //! spacers height
  h,
  //! used for the pcb joints
  tolerance = 0.5,
  //! MANDATORY mounting screw
  screw = M3_cap_screw,
  //! knurl nut
  knut=false,
  /*!
   * FL_DRILL thickness
   *
   * FIXME: rename as dri_thick
   */
  thick=0,
  //! frame thickness. 0 means 'no frame'
  frame=0,
  //! FL_LAYOUT directions in floating semi-axis list
  lay_direction=[+Z,-Z],
  //! desired direction [director,rotation], native direction when undef
  direction,
  //! when undef native positioning is used
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

  // echo(scr_d=scr_d,h=h,knut=knut);

  pcb_t   = fl_pcb_thick(pcb);
  pcb_bb  = fl_bb_corners(pcb);
  pcb_sz  = pcb_bb[1]-pcb_bb[0];

  D       = direction ? fl_direction(direction) : FL_I;
  M       = fl_octant(octant,bbox=bbox);
  Mpcb    = T(Z(h));

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
    fl_Hole(quad_I,   diameter, normal, depth),
    fl_Hole(quad_II,  diameter, normal, depth),
    fl_Hole(quad_III, diameter, normal, depth),
    fl_Hole(quad_IV,  diameter, normal, depth),
  ];
  // echo(holes=holes,bbox=bbox);

  module context() {
    $hld_thick  = thick;
    $hld_h      = h;
    $hld_screw  = screw;
    $hld_pcb    = pcb;
    // $hld_director = director;
    children();
  }

  module spacer(verbs=FL_ADD,position,screw,dirs=lay_direction,Zt) {
    thick = Zt ? Zt : thick;
    fl_spacer(verbs,h=h,r=R,screw=screw,knut=knut,thick=thick,lay_direction=dirs)
      children();
  }

  module do_add() {
    echo("pcb_holderBySize::do_add(): ",frame=frame);
    // spacers
    difference() {
      fl_lay_holes(holes)
        context()
          spacer(position=$hole_pos,screw=$hld_screw);
      multmatrix(Mpcb)
        fl_bb_add([
          [pcb_bb[0].x,pcb_bb[0].y,-pcb_t]-tolerance*[1,1,1]-Z(NIL),
          [pcb_bb[1].x,pcb_bb[1].y,0]+tolerance*[1,1,0]+Z(NIL)
        ]);
    }
    // frame
    if (frame) difference() {
      translate(bbox[0]) fl_color() linear_extrude(frame)
        // fl_square(size=[pcb_sz.x,pcb_sz.y],corners=pcb_r,quadrant=+X+Y);
        fl_2d_frame(size=size,thick=R+r_knut*sin(45),corners=R,quadrant=+X+Y);
      translate(+Z(frame))
        fl_lay_holes(holes)
          context()
            translate(+Z(NIL))
              spacer(FL_DRILL,position=$hole_pos,screw=$hld_screw,dirs=[-Z],Zt=[-frame-2xNIL,0],$FL_DRILL=$FL_ADD);
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

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) fl_color() do_add();

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_assembly();

    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size);

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
