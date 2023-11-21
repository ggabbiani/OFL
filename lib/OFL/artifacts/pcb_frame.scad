/*!
 * PCB frame library: a PCB frame is a size driven adapter for PCBs, providing
 * them the necessary holes to be ficed in a box.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../vitamins/pcbs.scad>

/*!
 * Constructor  for size-based pcb frame. It assumes the bare PCB bounding box
 * depth is from -«pcb thick» to 0.
 */
function fl_pcb_Frame(
  //! pcb object to be framed
  pcb,
  //! nominal screw ⌀
  d=2,
  /*!
   * List of Z-axis thickness for top and bottom faces or a common scalar value
   * for both.
   *
   * Positive value set thickness for the top face, negative for bottom while a
   * scalar can be used for both.
   *
   *     faces = [+3,-1]
   *
   * is interpreted as 3mm top, 1mm bottom
   *
   *     faces = [-1]
   *
   * is interpreted as 1mm bottom
   *
   *     faces = 2
   *
   * is interpreted as 2mm for top and bottom faces
   *
   */
  faces=1.2,
  //! distance between holes and external frame dimensions
  wall=1.5,
  /*!
   * overlap in the form [wide,thin]: wide overlap is along major pcb dimension,
   * thin overlap is along the minor pcb one
   */
  overlap=[1,0.5],
  /*!
   * inclusion is the size along major pcb dimension, laterally surrounding the pcb
   */
  inclusion=5,
  countersink=false,
  /*!
   * Frame layout method:
   *
   *     - "auto" (default) : auto detected based on PCB dimensions
   *     - "horizontal"     : holders are deployed horizontally from left to
   *                          right
   *     - "vertical"       : holders are deployed vertically from bottom to top
   */
  layout="auto"
) = let(
  horizontal  = layout=="auto" ? assert(pcb) let(sz=fl_bb_size(pcb)) sz.x>sz.y : layout=="horizontal",
  r           = d/2,
  pcb_bb      =
    assert(pcb)
    let(
      bb  = fl_bb_corners(pcb)
    ) horizontal ? bb : let(
      cog     = bb[0]+(bb[1]-bb[0])/2,
      R       = T(cog)*fl_R(+Z,90)*T(-cog),
      corners = fl_list_transform(bb,R)
    ) [
      [min(corners[0].x,corners[1].x),min(corners[0].y,corners[1].y),min(corners[0].z,corners[1].z)],
      [max(corners[0].x,corners[1].x),max(corners[0].y,corners[1].y),max(corners[0].z,corners[1].z)]
    ],

  // FROM HERE ONWARDS THE ALGORITHM BEHAVES AS IF THE LAYOUT WERE 'HORIZONTAL'
  pcb_cog = pcb_bb[0]+(pcb_bb[1]-pcb_bb[0])/2,  // PCB's center of gravity
  pcb_t   = fl_pcb_thick(pcb),
  pcb_sz  = pcb_bb[1]-pcb_bb[0],
  screw   = fl_screw_search(d=d,head_type=countersink?hs_cs_cap:hs_cap)[0],
  faces   = fl_parm_SignedPair(faces),
  depth   = abs(faces[0])+faces[1]+pcb_t,
  delta   = [+r,-(r+wall)],
  bbox    = fl_bb_calc([
    // bare holder bounding box
    [[pcb_bb[0].x-wall, pcb_bb[0].y-(d+2*wall),-(1+pcb_t)],[pcb_bb[1].x+wall,pcb_bb[1].y+(d+2*wall),+1]],
    // PCB bounding box
    pcb_bb
    ]),
  // four holes at the pcb corners + Δ
  holes   = [
      for(
        x=[pcb_bb[0].x+delta.x,pcb_bb[1].x-delta.x],
        y=[pcb_bb[0].y+delta.y,pcb_bb[1].y-delta.y]
      ) fl_Hole([x,y,faces[1]],d,depth=depth,screw=screw)
    ],
  w_over  = overlap[0],
  t_over  = overlap[1],
  /*
   * left bottom corner sector: we use the list transform function for
   * translating the 2d points returned from fl_sector() to the first hole.
   * NOTE: we drop first sector point (the center)
   */
  sec_lb  = fl_list_transform(
    // exclude first point (i.e. sector's center)
    fl_list_sub(fl_sector(r=r+wall, angles=[180,270]),1),
    // translation to holes[0]
    T(fl_hole_pos(holes[0])),
    FL_3D,FL_2D
  ),
  // left side internal points
  pts_l     = [
    [pcb_bb[0].x+inclusion, pcb_bb[0].y-(d+2*wall)],
    [pcb_bb[0].x+inclusion, pcb_bb[0].y+t_over],
    [pcb_bb[0].x+w_over,    pcb_bb[0].y+t_over],
    [pcb_bb[0].x+w_over,    pcb_bb[1].y-t_over],
    [pcb_bb[0].x+inclusion, pcb_bb[1].y-t_over],
    [pcb_bb[0].x+inclusion, pcb_bb[1].y+(d+2*wall)],
  ],
  // left top corner sector: see comment about left bottom corner sector
  sec_lt  = fl_list_transform(
    // sector center removal
    fl_list_sub(fl_sector(r=r+wall, angles=[90,180]),1),
    // translation to holes[1]
    T(fl_hole_pos(holes[1])),
    FL_3D,FL_2D
  ),
  left = concat(sec_lb,pts_l,sec_lt),
  // +180° rotation around axis PCB's center of gravity
  right = fl_list_transform(left,T(pcb_cog) * fl_R(+Z,180) * T(-pcb_cog),FL_3D,FL_2D),
  // if the layout is 'vertical' we need to rotate back -90° the results
  M_back        = horizontal ? I      : T(pcb_cog) * fl_R(+Z,-90) * T(-pcb_cog),
  result_bbox   = horizontal ? bbox   : fl_bb_polyhedron(fl_list_transform(bbox,M_back)),
  result_left   = horizontal ? left   : fl_list_transform(left,M_back,FL_3D,FL_2D),
  result_right  = horizontal ? right  : fl_list_transform(right,M_back,FL_3D,FL_2D),
  result_holes  = horizontal ? holes : [
      for(hole=holes)
        let(p=fl_transform(M_back,fl_hole_pos(hole)))
          fl_Hole([p.x,p.y,faces[1]],d,depth=depth,screw=screw)
    ]
) [
  fl_OFL(value=true),
  fl_pcb(value=pcb),
  fl_bb_corners(value=result_bbox),
  ["pcbf/wall",wall],
  ["pcbf/inclusion",inclusion],
  ["pcbf/overlap",overlap],
  ["pcbf/left side points",result_left],
  fl_screw(value=screw),
  fl_holes(value=result_holes),
  ["pcbf/right side points",result_right],
  ["pcbf/[bottom,top] face thickness",faces],
];

/*
 * PCB frame engine.
 *
 * This engine acts mostly as a proxy forwarding verbs to its embedded PCB.
 *
 */
module fl_pcb_frame(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  this,
  tolerance=0.2,
  /*!
   * PCB frame part visibility: defines which frame parts are shown.
   *
   * The full form is [«left|bottom part»,«right|top part»], where each list
   * item is a boolean managing the visibility of the corresponding part.
   *
   * Setting this parameter as a single boolean extends its value to both the parts.
   */
  parts=true,
  //! see homonymous parameter for fl_pcb{}
  thick=0,
  //! see homonymous parameter for fl_pcb{}
  lay_direction=[+Z],
  //! see homonymous parameter for fl_pcb{}
  cut_tolerance=0,
  //! see homonymous parameter for fl_pcb{}
  cut_label,
  //! see homonymous parameter for fl_pcb{}
  cut_direction,
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
  D     = direction ? fl_direction(direction) : I;
  M     = octant    ? fl_octant(octant,bbox=bbox) : I;

  screw       = fl_screw(this);
  d           = fl_screw_nominal(screw);
  r           = d/2;
  pcb         = fl_pcb(this);
  pcb_bb      = fl_bb_corners(pcb);
  pcb_t       = fl_pcb_thick(pcb);
  pcb_bare_sz = let(sz=pcb_bb[1]-pcb_bb[0]) [sz.x,sz.y,pcb_t];
  faces       = fl_property(this,"pcbf/[bottom,top] face thickness");
  depth       = abs(faces[0])+faces[1]+pcb_t;
  thick       = is_num(thick) ? [[thick,thick],[thick,thick],[thick,thick]]
              : assert(!fl_debug() || fl_tt_isAxisVList(thick)) thick;
  dr_thick    = depth+thick.z[0]; // thickness along -Z
  holes       = fl_holes(this);
  wall        = fl_property(this,"pcbf/wall");
  inclusion   = fl_property(this,"pcbf/inclusion");
  overlap     = fl_property(this,"pcbf/overlap");
  w_over      = overlap[0];
  t_over      = overlap[1];
  left        = (is_bool(parts) ? parts : parts[0]) ? fl_property(this,"pcbf/left side points") : undef;
  right       = (is_bool(parts) ? parts : parts[1]) ? fl_property(this,"pcbf/right side points") : undef;

  module do_symbols(debug,holes) {
    if (debug) {
      if (holes)
        fl_hole_debug(holes,debug=debug);
    }
  }

  module do_add() {
    fl_color()
      difference() {
        translate(-Z(abs(faces[0])+pcb_t))
          linear_extrude(depth) {
            if (left)
              polygon(left);
            if (right)
              polygon(right);
          }
        // remove PCB footprint
        translate(+Z(tolerance/2))
          resize(pcb_bare_sz+tolerance*[1,1,1])
            fl_pcb(FL_FOOTPRINT,pcb,$FL_FOOTPRINT="ON");
        // remove holes
        translate(-Z(0))
          fl_screw_holes(holes,[+Z], countersunk=true, tolerance=tolerance, $FL_DRILL="ON");
      }
  }

  module do_assembly() {
    fl_pcb(FL_DRAW,type=pcb);
  }

  module do_cutout() {
    fl_pcb(FL_CUTOUT,pcb,cut_tolerance=cut_tolerance,cut_label=cut_label,cut_direction=cut_direction,thick=thick,debug=debug, direction=direction, octant=octant);
  }

  module do_drill() {
    translate(-Z(depth))
    fl_screw_holes(holes,thick=thick,enable=lay_direction);
  }

  module do_footprint() {
    translate(-Z(pcb_t-faces[0]))
      linear_extrude(depth)
        fl_square(size=[size.x,size.y],corners=[for(hole=holes) fl_hole_d(hole)],$FL_ADD=$FL_FOOTPRINT);
  }

  module do_layout() {
    fl_lay_holes(holes,lay_direction)
      children();
  }

  module do_mount() {
    fl_lay_holes(holes,lay_direction)
      fl_screw([FL_ADD,FL_ASSEMBLY],type=$hole_screw,thick=dr_thick);
  }

  module do_pload() {

  }

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      do_symbols(debug,holes=holes);
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_assembly();

    } else if ($verb==FL_AXES) {
      fl_modifier($modifier)
        fl_doAxes(size,direction,debug);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox,$FL_ADD=$FL_BBOX);

    } else if ($verb==FL_CUTOUT) {
      fl_modifier($modifier) do_cutout();

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier) do_drill();

    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) do_footprint();

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout()
        children();

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier) do_mount()
        children();

    } else if ($verb==FL_PAYLOAD) {
      fl_modifier($modifier)
        fl_pcb($verb,pcb,debug=debug);

    } else if ($verb==FL_SYMBOLS) {
      fl_modifier($modifier) fl_doSymbols()
        children();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
