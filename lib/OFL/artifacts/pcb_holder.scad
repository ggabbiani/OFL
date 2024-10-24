/*!
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <spacer.scad>
include <../vitamins/pcbs.scad>

use <../foundation/bbox-engine.scad>
use <../foundation/mngm-engine.scad>

// TODO: shouldn't this be private?
function fl_pcbh_spacers(type,value) =  fl_property(type,"pcbh/list of spacers",value);

//**** Hole driven PCB holders ************************************************

/*!
 * Hole driven PCB holder constructor
 *
 * TODO: set PCB holder namespace as 'engine' property
 */
function fl_PCBHolder(
  //! PCB to be held
  pcb,
  /*!
   * Minimum spacer height.
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
  /*!
   * Knurl nut thread type: either 'undef', "linear" or "spiral".
   */
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
    ) fl_Spacer(h_min=h_min,d_min=fl_hole_d(hole)+wall,screw_size=nominal,knut=knut)
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
  // spc_height  = max([for(spacer=spacers) fl_spc_h(spacer)]),
  spc_height  = fl_spc_h(spacers[0]),
  this_bb = [[min(xs),min(ys),0],[max(xs),max(ys),spc_height+pcb_t]],
  // sums pcb holder bare bounding block with the pcb one translated of +Z(spc_height+pcb_t)
  bbox  = fl_bb_calc([this_bb,[for(point=pcb_bb) fl_transform(T(+Z(spc_height+pcb_t+NIL)), point)]])
) [
  fl_OFL(value=true),
  fl_pcb(value=pcb),
  fl_bb_corners(value=bbox),
  fl_pcbh_spacers(value=spacers),
  fl_spc_h(value=spc_height),
  // TODO: implement through [Module
  // Literals](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/WIP#Module_Literals_/_Module_References)
];

/*!
 * PCB holder engine.
 *
 * Children context:
 *
 *   - inherits fl_pcb{} context
 *   - inherits fl_spacer{} context
 *   - $pcbh_spacer   : current processed spacer
 *   - $pcbh_verb     : current triggering verb
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
   * is interpreted as thickness of 1mm along -Z and 0mm along +Z
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
  spcs        = fl_pcbh_spacers(this);
  thick       = fl_parm_SignedPair(thick);
  thickness   = abs(thick[0])+thick[1]+spc_height;
  holes       = fl_holes(pcb);

  module contextualLayout() {
    let(
      $pcbh_verb  = $verb
    ) fl_pcb(FL_LAYOUT,pcb)
        let(
          $pcbh_spacer= spcs[$hole_i],
          $pcbh_screw = $hole_screw
        ) children();
  }

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
        fl_doAxes(size,direction);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier)
        fl_bb_add(bbox);

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier)
        contextualLayout($FL_LAYOUT=$FL_DRILL)
          fl_spacer(FL_DRILL,$pcbh_spacer,thick=thick);

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier)
        contextualLayout()
          fl_spacer(FL_LAYOUT,$pcbh_spacer,thick=thick)
            children();

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier)
        contextualLayout($FL_LAYOUT=$FL_MOUNT)
            fl_spacer(FL_MOUNT,$pcbh_spacer,thick=thick)
              children();

    } else if ($verb==FL_PAYLOAD) {
      fl_modifier($modifier)
        multmatrix(pcb_M)
          fl_bb_add(pcb_bb);

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

