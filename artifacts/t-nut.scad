/*!
 * T-slot nut engine for OpenSCAD Foundation Library.
 *
 * T-slot nuts are used with
 * (T-slot structural framing)[https://en.wikipedia.org/wiki/T-slot_structural_framing]
 * to build a variety of industrial structures and machines.
 *
 * T-slot nut are not to be confused with (T-nuts)[https://en.wikipedia.org/wiki/T-nut].
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <../foundation/unsafe_defs.scad>
include <../vitamins/screw.scad>
include <../vitamins/countersinks.scad>

use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>
use <../foundation/hole.scad>
use <../foundation/mngm.scad>

// namespace
__FL_ART_NS  = "tsnut";

// TODO: build preset types
__FL_ART_DICT = [
];

/*!
 * Constructor returning a T-slot nut.
 *
 *                        screw M
 *                      ⭰─────────⇥
 *            ________________________________
 *          ╱           ░░░░░░░░░░░░           ╲       ⤒         ⤒
 *        ╱             ░░░░░░░░░░░░             ╲    cone
 *      ╱               ░░░░░░░░░░░░               ╲   ⤓         h
 *     │                ░░░░░░░░░░░░                │  ⤒         e
 *     │                ░░░░░░░░░░░░                │ base       i
 *     │_________       ░░░░░░░░░░░░       _________│  ⤓         g
 *               │      ░░░░░░░░░░░░      │            ⤒         t
 *               │      ░░░░░░░░░░░░      │           wall       h
 *               │      ░░░░░░░░░░░░      │            ⤓         ⤓
 *               └────────────────────────┘
 *                        opening
 *               ⭰───────────────────────⇥
 *
 *                         width
 *     ⭰──────────────────────────────────────────⇥
 *
 */
function fl_TNut(
  //! the opening of the T-slot
  opening,
  /*!
   * 2d size in the form [with,length], the height being calculated from «thickness».
   * The resulting bounding box is: `[width, ∑ thickness, length]`
   */
  size,
  /*!
   * section heights passed as `[wall,base,cone]` thicknesses
   */
  thickness,
  //! an optional screw determining a hole
  screw,
  //! eventual knurl nut
  knut=false,
  //! list of user defined holes usually positioned on the 'opening' side
  holes
) = let(
  // r = screw_radius(screw),
  wall  = thickness[0],
  base  = thickness[1],
  cone  = thickness[2],
  size  = [size.x, fl_accum(thickness), size.y],
  bbox  = [[-size.x/2,-base-cone,0],[+size.x/2,+wall,size.z]],
  hole_d  = screw ? 2*screw_radius(screw) : undef,
  points  = [
    [bbox[1].x-cone,bbox[0].y],
    [bbox[1].x,bbox[0].y+cone],
    [bbox[1].x,bbox[0].y+cone+base],
    [opening/2,bbox[0].y+cone+base],
    [opening/2,bbox[1].y],

    [-opening/2,bbox[1].y],
    [-opening/2,bbox[0].y+cone+base],
    [bbox[0].x,bbox[0].y+cone+base],
    [bbox[0].x,bbox[0].y+cone],
    [bbox[0].x+cone,bbox[0].y],
  ]
) [
  ["opening", opening],
  ["[wall, base, cone] thickness", thickness],
  fl_bb_corners(value=bbox),
  ["section points", points],
  if (screw) fl_screw(value=screw),
  if (screw) holes ? ["holes",holes] : ["holes",[fl_Hole([0,bbox[1].y,size.z/2],hole_d,+Y,size.y,screw=screw)]],
  if (knut) ["knut",fl_knut_search(screw,size.y)],
];

module fl_tnut(
  //! supported verbs: `FL_ADD, FL_AXES, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT`
  verbs       = FL_ADD,
  type,
  /*!
   * tolerances added to [nut, hole, countersink] dimensions
   *
   * tolerance=x means [x,x,x]
   */
  tolerance=0,
  countersink=false,
  //! see constructor fl_parm_Debug()
  debug,
  //! desired direction [director,rotation], native direction when undef ([+Z,0])
  direction,
  //! when undef native positioning is used
  octant,
) {
  assert(is_list(verbs)||is_string(verbs),verbs);


  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  D     = direction ? fl_direction(direction) : FL_I;
  M     = fl_octant(octant,bbox=bbox);

  thickness = fl_property(type, "[wall, base, cone] thickness");
  wall  = thickness[0];
  base  = thickness[1];
  cone  = thickness[2];
  points  = fl_property(type,"section points");
  screw = fl_optional(type,fl_screw()[0]);
  d     = screw ? 2*screw_radius(screw) : undef;
  tolerance = is_undef(tolerance) ? [0,0,0] : is_num(tolerance) ? [tolerance,tolerance,tolerance] : tolerance;
  nut_t = tolerance[0];
  hole_t  = tolerance[1];
  cs_t  = tolerance[2];
  holes  = fl_optional(type,"holes");
  knut  = fl_optional(type,"knut");
  ext_r = knut ? fl_knut_r(knut)+hole_t : undef;

  echo(d=d,tolerance=tolerance,bbox=bbox,size=size,points=points);
  echo(knut=knut,ext_r=ext_r);

  // module context() {
  //   fl_hole_Context(hole)
  //     children();
  // }

  module do_add() {
    fl_color()
      difference() {
        // add section extrusion
        linear_extrude(size.z)
          offset(r=-nut_t)
            polygon(points);
        // subtract holes and countersink
        if (screw) {
          fl_holes(holes,tolerance=hole_t);
          if (countersink)
            do_layout()
              translate(-Y(size.y+NIL))
                fl_countersink(type=FL_CS_M3,tolerance=cs_t,direction=[-$hole_n,0],octant=-Z);
        }
        // subtract the cylinder guide for insert
        if (knut)
          let(h=size.y-fl_knut_thick(knut))
          if (h>0)
            do_layout()
              translate(-0*Y(h+NIL))
                translate(-Y(size.y+NIL))
                fl_cylinder(h=h+NIL2,r=ext_r,direction=[-$hole_n,0],octant=-Z);
      }
  }

  module do_assembly() {
    if (knut)
      do_layout()
        translate(Y(NIL))
          fl_knut(type=knut,direction=[-$hole_n,0],octant=+Z,$FL_ADD=$FL_ASSEMBLY);
  }
  module do_layout() {
    if (holes)
      fl_lay_holes(holes)
        children();
  }

  // TODO: implement do_drill() module
  module do_drill() {
  }

  module do_symbols(
    debug,
    // connectors,
    holes
  ) {
    if (debug) {
      // if (connectors)
      //   fl_conn_debug(connectors,debug=debug);
      if (holes)
        fl_hole_debug(holes,debug=debug);
    }
  }

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      do_symbols(debug,holes);
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_assembly() children();

    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction,debug);

    } else if ($verb==FL_BBOX) {
      echo($modifier=$modifier);
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier);

    // TODO: implement FL_FOOTPRINT verb
    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier);

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout()
        children();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
