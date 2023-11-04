/*!
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <spacer.scad>

use <../foundation/bbox-engine.scad>
use <../foundation/mngm-engine.scad>

// TODO: shouldn't this be private?
function fl_pcbh_spacers(type,value) =  fl_property(type,"pcbh/list of spacers",value);

//**** Hole driven PCB holders ************************************************

/*!
 * Hole driven PCB holder constructor
 */
function fl_PCBHolderByHoles(
  //! PCB to be held
  pcb,
  /*!
   * this is the minimum height asked for spacers
   *
   * __NOTE__: the actual spacer height can be different depending on the knurl
   * nut constrains
   */
  h_min = 0,
  /*!
   * when using spacers without knurl nut, this is the wall thickness around the
   * spacers' holes
   */
  wall =1,
  knut_type
) = let(
  pcb_bb    = fl_bb_corners(pcb),
  pcb_t     = fl_pcb_thick(pcb),
  pcb_screw = fl_screw(pcb),
  holes     = fl_holes(pcb),
  spacers   = [for(hole=holes) let(
      screw   = let(screw = fl_hole_screw(hole)) screw ? screw : pcb_screw,
      nominal = screw ? fl_screw_nominal(screw) : 0,
      knut    = knut_type ? fl_knut_shortest(fl_knut_find(thread=knut_type,nominal=nominal)) : undef
    ) fl_Spacer(h_min=h_min,d_min=fl_hole_d(hole)+wall,knut=knut)
  ],
  xs = concat(
    [for(i=[0:len(spacers)-1]) let(
        spacer= spacers[i],
        hole = holes[i],
        spc_r = fl_spc_d(spacer)/2,
        center = fl_hole_pos(hole)
      ) center.x+spc_r],
    [for(i=[0:len(spacers)-1]) let(
        spacer= spacers[i],
        hole = holes[i],
        spc_r = fl_spc_d(spacer)/2,
        center = fl_hole_pos(hole)
      ) center.x-spc_r]
  ),
  ys = concat(
    [for(i=[0:len(spacers)-1]) let(
        spacer= spacers[i],
        hole = holes[i],
        spc_r = fl_spc_d(spacer)/2,
        center = fl_hole_pos(hole)
      ) center.y+spc_r],
    [for(i=[0:len(spacers)-1]) let(
        spacer= spacers[i],
        hole = holes[i],
        spc_r = fl_spc_d(spacer)/2,
        center = fl_hole_pos(hole)
      ) center.y-spc_r]
  ),
  zs = [for(spacer=spacers) fl_spc_h(spacer)],
  spc_height  = max(zs),
  this_bb = [[min(xs),min(ys),0],[max(xs),max(ys),spc_height+pcb_t]],
  // sums pcb holder bare bounding block with the pcb one translated of +Z(spc_height+pcb_t)
  bbox  = fl_bb_calc([this_bb,[for(point=pcb_bb) fl_transform(T(+Z(spc_height+pcb_t+NIL)), point)]])
) [
  fl_OFL(value=true),
  fl_pcb(value=pcb),
  fl_bb_corners(value=bbox),
  fl_pcbh_spacers(value=spacers),
  fl_spc_h(value=spc_height),
];

/*!
 * PCB holder engine.
 *
 * Children context:
 *
 *   - inherits fl_pcb{} context
 *   - inherits fl_spacer{} context
 *   - $pcbh_spacer : current processed spacer
 *   - $pcbh_verb   : current triggering verb
 */
module fl_pcbHolder(
  /*!
   * supported verbs: FL_ADD, FL_ASSEMBLY, FL_AXES, FL_BBOX, FL_LAYOUT,
   * FL_DRILL, FL_MOUNT
   */
  verbs,
  this,
  //! when >0 a fillet is added to anchors
  fillet=0,
  //! FL_ASSEMBLY modifier: when true also PCB will be shown during FL_ASSEMBLY
  asm_all=false,
  /*!
   * List of Z-axis thickness or a scalar value for FL_DRILL and FL_MOUNT
   * operations.
   *
   * A positive value represents thickness along +Z semi-axis.
   * A negative value represents thickness along -Z semi-axis.
   * A scalar value represents thickness for both Z semi-axes.
   *
   * Example 1:
   *
   *     thick = [+3,-1]
   *
   * is interpreted as thickness of 3mm along +Z and 1mm along -Z
   *
   * Example 2:
   *
   *     thick = [-1]
   *
   * is interpreted as thickness of 1mm along -Z
   *
   * Example:
   *
   *     thick = 2
   *
   * is interpreted as a thickness of 2mm along +Z and -Z axes
   *
   */
  thick,
  /*!
   * FL_DRILL and FL_LAYOUT directions in floating semi-axis list.
   *
   * __NOTE__: only Z semi-axes are used
   */
  lay_direction=[+Z,-Z],
  //! see constructor fl_parm_Debug()
  debug,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant,
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  bbox  = fl_bb_corners(this);
  size  = fl_bb_size(this);
  D     = direction ? fl_direction(direction)     : I;
  M     = octant    ? fl_octant(octant,bbox=bbox) : I;

  // resulting spacers' height
  spc_height  = fl_spc_h(this);
  pcb         = fl_pcb(this);
  pcb_t       = fl_pcb_thick(pcb);
  pcb_screw   = fl_screw(pcb);
  pcb_M       = T(+Z(spc_height+pcb_t));
  pcb_bb      = fl_bb_corners(pcb);
  holes       = fl_holes(pcb);
  spcs        = fl_pcbh_spacers(this);
  thick       = fl_parm_SignedPair(thick);
  thickness   = abs(thick[0])+thick[1]+spc_height;

  module contextualLayout()
    let($pcbh_verb  = $verb)
      fl_pcb(FL_LAYOUT,pcb)
        let($pcbh_spacer=spcs[$hole_i])
          children();

  module do_assembly() {
    contextualLayout($FL_LAYOUT=$FL_ASSEMBLY)
      fl_spacer(FL_ASSEMBLY,spacer=$pcbh_spacer,fillet=fillet,anchor=[-Z]);
    if (asm_all)
      multmatrix(pcb_M)
        fl_pcb(FL_DRAW,pcb);
  }

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier)
        contextualLayout($FL_LAYOUT=$FL_ADD)
          fl_spacer(spacer=$pcbh_spacer,fillet=fillet,anchor=[-Z]);

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier)
        do_assembly();

    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction,debug);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier)
        fl_bb_add(bbox);

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier)
        contextualLayout($FL_LAYOUT=$FL_DRILL)
          fl_spacer(FL_DRILL,$pcbh_spacer,thick=thick,lay_direction=lay_direction);

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier)
        contextualLayout()
          fl_spacer(FL_LAYOUT,$pcbh_spacer,thick=thick,lay_direction=lay_direction)
            children();

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier)
        contextualLayout($FL_LAYOUT=$FL_MOUNT)
            fl_spacer(FL_MOUNT,$pcbh_spacer,thick=thick)
              children();

    } else if ($verb==FL_PAYLOAD) {
      fl_modifier($modifier)
        multmatrix(pcb_M)
          fl_bb_add(pcb_bb);;

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
