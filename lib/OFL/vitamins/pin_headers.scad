/*!
 * NopSCADlib pin header wrapper definitions.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <../foundation/unsafe_defs.scad>

include <../foundation/connect.scad>
include <../foundation/label.scad>
use <../foundation/mngm-engine.scad>
use <../foundation/util.scad>

include <../../ext/NopSCADlib/lib.scad>
include <../../ext/NopSCADlib/vitamins/pin_headers.scad>

//! namespace for pin headers engine
FL_PHDR_NS  = "phdr";

//*****************************************************************************
// Pin header properties
// when invoked by «type» parameter act as getters
// when invoked by «value» parameter act as property constructors
function fl_phdr_geometry(type,value)  = fl_property(type,"phdr/size in [cols,rows]",value);

//*****************************************************************************
// helpers

function fl_phdr_cid(nop,geometry)  = str("PIN HEADER pitch ",hdr_pitch(nop)," ",geometry.x,"x",geometry.y);

//! return the nop bounding box from its geometry
function fl_bb_nopPinHeader(
  //! NopSCADlib pin header
  nop,
  //! pin header size in [cols,rows]
  geometry,
  //! can be "female" or "male"
  engine
) = engine=="male"
  ? let(
    w = hdr_pitch(nop)*geometry.x,
    d = hdr_pitch(nop)*geometry.y,
    h = hdr_pin_length(nop),
    b = hdr_pin_below(nop)
  ) [[-w/2,-d/2,-b],[+w/2,+d/2,h-b]]
  : let(
    w = hdr_pitch(nop)*geometry.x+0.5,
    d = hdr_pitch(nop)*geometry.y-0.08,
    h = hdr_pin_length(nop),
    b = hdr_pin_below(nop)
  ) [[-w/2,-d/2,-b],[+w/2,+d/2,h-b]];

//! return the nop size from its geometry
function fl_phdr_nopSize(
  //! NopSCADlib pin header
  nop,
  //! pin header size in [cols,rows]
  geometry,
  //! "female" or "male"
  engine
) = let(bbox = fl_bb_nopPinHeader(nop,geometry,engine)) bbox[1]-bbox[0];

//*****************************************************************************
//! PinHeader constructor
function fl_PinHeader(
  name,
  //! optional description string
  description,
  //! NopSCADlib base type
  nop,
  //! pin header size in [cols,rows]
  geometry  = [1,1],
  //! smt
  smt=false,
  //! "female" or "male"
  engine,
  //! pass-through (in that case pin numbers are inverted)
  through=false,
  //! vendor list
  vendors   = []
) = assert(is_string(engine))
let(
  bbox      = fl_bb_nopPinHeader(nop,geometry,engine),
  pitch     = hdr_pitch(nop),
  pin_1_hi  = [-(geometry.x-1)*pitch/2,-(geometry.y-1)*pitch/2,engine=="male" ? pitch : hdr_socket_depth(nop)],
  pin_1_lo  = [pin_1_hi.x,pin_1_hi.y,0],
  pin_2_lo  = [pin_1_hi.x,-pin_1_hi.y,0],
  pin_2_hi  = [pin_1_hi.x,-pin_1_hi.y,pin_1_hi.z],
  cid       = fl_phdr_cid(nop,geometry)
) [
    assert(is_string(name)) fl_name(value=name),
    assert(nop!=undef)      fl_nopSCADlib(value=nop),
    if (description) assert(is_string(description)) fl_description(value=description),
    fl_engine(value=engine),
    fl_phdr_geometry(value=geometry),
    fl_bb_corners(value=bbox),
    fl_connectors(value=[
      engine=="male"||through ? conn_Plug(cid,+X,+Y, pin_1_hi,size=pitch,octant=engine=="male"?-X:+X) :  conn_Socket(cid,+X,-Y,pin_2_hi,size=pitch,octant=+X),
      through ? conn_Socket(cid,+X,+Y,pin_1_lo,size=pitch,octant=+X,direction=[-Z,180]) : conn_Plug(cid,+X,-Y,pin_2_lo,size=pitch,octant=-X),
      if (through) conn_Socket(cid,+X,-Y,pin_2_hi,size=pitch,octant=+X,direction=[-Z,180]),
      if (through) conn_Plug(cid,+X,-Y,pin_2_lo,size=pitch,octant=+X),
    ]),
    ["phdr/smt", smt],
    ["phdr/pass-through", through],
    if (vendors!=[]) fl_vendor(value=vendors),
    fl_cutout(value=[+Z]),
  ];

/*!
 * Pin headers engine.
 */
module fl_pinHeader(
  //! supported verbs: FL_ADD, FL_AXES, FL_BBOX, FL_CUTOUT, FL_DRILL
  verbs       = FL_ADD,
  type,
  color,
  //! thickness for FL_CUTOUT
  cut_thick,
  //! tolerance used during FL_CUTOUT
  cut_tolerance=0,
  //! Cutout direction list in floating semi-axis list (see also fl_tt_isAxisList()).
  cut_dirs,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef
  direction
) {
  assert(type);
  assert(is_list(verbs)||is_string(verbs),verbs);

  nop       = fl_nopSCADlib(type);
  geometry  = fl_phdr_geometry(type);
  cols      = geometry.x;
  rows      = geometry.y;
  conns     = fl_connectors(type);
  pitch_sz  = hdr_pitch(nop);
  engine    = fl_engine(type);
  smt       = fl_property(type,"phdr/smt");
  cut_dirs  = is_undef(cut_dirs) ? fl_cutout(type) : cut_dirs;

  module do_add() {
    if (engine=="male")
      pin_header(nop, cols, rows,colour=color, smt=smt);
    else
      pin_socket(nop, cols, rows,colour=color, smt=smt);
  }

  module do_drill() {
    pin_sz  = let(w=hdr_pin_width(nop),l=hdr_pin_below(nop)) [w,w,cut_thick];
    for(x=[0:geometry.x-1],y=[0:geometry.y-1])
      translate([pitch_sz * (x - (geometry.x - 1) / 2), pitch_sz * (y - (geometry.y - 1) / 2)])
        fl_cube(size=pin_sz,octant=-Z);
  }

  fl_vmanage(verbs, type, octant=octant, direction=direction)
    if ($verb==FL_ADD)
      do_add();

    else if ($verb==FL_BBOX)
      fl_bb_add($this_bbox);

    else if ($verb==FL_CUTOUT)
      fl_cutoutLoop(cut_dirs, fl_cutout(type),$fl_thickness=cut_thick,$fl_tolerance=cut_tolerance) {
        if ($co_preferred)
          fl_new_cutout($this_bbox,$co_current)
            do_add();
      }

    else if ($verb==FL_DRILL)
      assert(cut_thick!=undef)
      do_drill();

    else
      fl_error(["unimplemented verb",$this_verb]);
}

FL_PHDR_GPIOHDR          = fl_PinHeader(
  name        = "FL_PHDR_GPIOHDR",
  description = "GPIO pin header",
  nop         = 2p54header,
  geometry    = [20,2],
  engine      = "male"
);
FL_PHDR_GPIOHDR_F       = fl_PinHeader(
  name        = "FL_PHDR_GPIOHDR_F",
  description = "GPIO female pin header",
  nop         = 2p54header,
  geometry    = [20,2],
  engine      = "female"
);
FL_PHDR_GPIOHDR_FL  = let(
  // Longer pins for stacking
  //                      p     p     b    p      p          b     s    b                 b    p      r   r
  //                      i     i     e    i      i          a     o    o                 o    i      a   a
  //                      t     n     l    n      n          s     c    x                 x    n
  //                      c           o                      e     k                                  b   h
  //                      h     l     w    w      c                     s                 t    y
  //                                                         c     h    z                             o
  //                                                                                                  f
  nop  = ["2p54long",   2.54, 19.6,  11,  0.66, gold,   grey(20), 8.6, [0,   0,    8.7], 2.4, 0,     0,   0  ]
) fl_PinHeader(
  name        = "FL_PHDR_GPIOHDR_FL",
  description = "GPIO female long pin header",
  nop         = nop,
  geometry    = [20,2],
  engine      = "female",
  vendors     = [
    ["amazon.it","https://www.amazon.it/gp/product/B08G8M9WX7"]
  ]
);

FL_PHDR_GPIOHDR_F_SMT_LOW  = let(
  // smt low profile pins
  //                      p     p     b    p      p          b     s    b                 b    p      r   r
  //                      i     i     e    i      i          a     o    o                 o    i      a   a
  //                      t     n     l    n      n          s     c    x                 x    n
  //                      c           o                      e     k                                  b   h
  //                      h     l     w    w      c                     s                 t    y
  //                                                         c     h    z                             o
  //                                                                                                  f
  nop = ["2p54smtlow",   2.54,  4,     0, 0.66, gold,   grey(20),   4, [0,   0,    8.7], 2.4, 0,     0,    0  ]
) fl_PinHeader(
  name        = "FL_PHDR_GPIOHDR_F_SMT_LOW",
  description = "GPIO female low pin pass-through header",
  nop         = nop,
  geometry    = [20,2],
  smt         = true,
  engine      = "female",
  through     = true
);

FL_PHDR_DICT = [
  FL_PHDR_GPIOHDR,
  FL_PHDR_GPIOHDR_F,
  FL_PHDR_GPIOHDR_FL,
  FL_PHDR_GPIOHDR_F_SMT_LOW,
];
