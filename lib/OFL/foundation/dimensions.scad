/*!
 * Dimension line library.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../foundation/unsafe_defs.scad>

use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>

//! prefix used for namespacing
FL_DIM_NS  = "dim";

// Dimension lines public properties

//! helper dimension line label
function fl_dim_label(type,value)  = fl_property(type,str(FL_DIM_NS,"/label"),value);
//! helper dimension line value
function fl_dim_value(type,value)  = fl_property(type,str(FL_DIM_NS,"/value"),value);

/*!
 * Constructor for single dimension lines.
 */
function fl_Dimension(
  //! mandatory value
  value,
  //! mandatory label string
  label,
)  = [
  fl_native(value=true),
  assert(!is_undef(label)) fl_dim_label(value=label),
  assert(!is_undef(value)) fl_dim_value(value=value),
];

/*!
 * Constructor for a strip of dimension lines indexed by their labels. Each
 * element can be later retrieved by using the standard fl_property() getter on
 * the strip itself, like in the following code:
 *
 *     strip = fl_DimensionPack([
 *               fl_Dimension(20,"Height"),
 *               fl_Dimension(10,"Width")],
 *               ...
 *             );
 *     ...
 *     fl_dimension(fl_property(strip,"Height"),...);
 *     fl_dimension(fl_property(strip,"Width"),...);
 */
function fl_DimensionPack(dimension_list) = [
  for(dim=dimension_list) [fl_dim_label(dim),dim]
];

/*!
 * Children context:
 *
 * | name        | description                                              |
 * | ----------  | -------------------------------------------------------- |
 * | $dim_align  | current alignment                                        |
 * | $dim_distr  | distribution direction, equal to the «distr» parameter   |
 * | $dim_gap    | gap between stacked dimension lines                      |
 * | $dim_label  | current dimension line label                             |
 * | $dim_level  | current dimension line stacking level (always positive)  |
 * | $dim_mode   | current mode                                             |
 * | $dim_object | bounded object                                           |
 * | $dim_spread | distribution direction in 2D space (always X or Y axis)  |
 * | $dim_value  | current value                                            |
 * | $dim_view   | dimension line bounded view                              |
 * | $dim_width  | current line width                                       |
 */
module fl_dimension(
  //! supported verbs: FL_ADD
  verbs       = FL_ADD,
  //! dimension geometry object as returned by fl_Dimension()
  geometry,
  /*!
   * Position of the measure line with respect to its distribute direction:
   *
   * | value                  | description                                   |
   * | ---------------------  | --------------------------------------------- |
   * | "centered"             | default value                                 |
   * | "positive"             | aligned in the positive half of the view plane|
   * | "negative"             | aligned in the negative half of the view plane|
   * | «scalar signed value»  | position of the start of the measurement line on the normal to its distribution direction |
   */
  align,
  /*!
   * Distribution direction of stacked dimension lines:
   *
   * | value  | description         |
   * | -----  | ------------------- |
   * | "h+"   | horizontal positive |
   * | "h-"   | horizontal negative |
   * | "v+"   | vertical positive   |
   * | "v-"   | vertical negative   |
   */
  distr,
  //! fixed gap between stacked dimension lines
  gap,
  //! dimension line thickness
  line_width,
  //! The object to which the dimension line is attached.
  object,
  /*!
   * Name of the projection plane view:
   *
   * | value    | projection plane  |
   * | -----    | ------------------|
   * | "right"  | XZ                |
   * | "top"    | XY                |
   * | "bottom" | YX                |
   * | "left"   | ZY                |
   * | "front"  | XZ                |
   * | "back"   | ZX                |
   */
  view,
  /*!
   * Dimension line mode:
   *
   * | value    | projection plane                                                  |
   * | -----    | ----------------------------------------------------------------- |
   * | "silent" | no text is shown                                                  |
   * | "label"  | dimension label is shown                                          |
   * | "value"  | dimension value is shown                                          |
   * | "full"   | dimension will show a full text in the format label=value         |
   * |  undef   | value is inherited from $dim_mode if any, set to "full" otherwise |
   */
  mode
) {
  assert(view=="right"||view=="top"||view=="bottom"||view=="left"||view=="front"||view=="back",view);
  assert(align=="centered"||align=="positive"||align=="+"||align=="negative"||align=="-"||is_num(align),align);

  $dim_level = is_undef($dim_level) ? 1 : $dim_level+1;

  value      = assert(is_list(geometry),str("geometry=",geometry)) fl_dim_value(geometry);
  label      = fl_dim_label(geometry);

  // eventual attribute inheritance from context variables
  align       = align ? align : is_undef($dim_align) ? "centered" : $dim_align;
  view        = view ? view : $dim_view;
  mode        = mode ? mode : is_undef($dim_mode) ? "full" : $dim_mode;
  distr       = distr ? distr : $dim_distr;
  object      = object  ? object  : $dim_object;
  line_width  = line_width ? line_width : $dim_width;
  gap         = gap ? gap : is_undef($dim_gap) ? 1 : $dim_gap;

  xy_spread   = fl_switch(distr,[["h+",+X],["h-",-X],["v+",+Y],["v-",-Y],],is_undef($dim_spread)?undef:fl_versor($dim_spread));
  xy_sgn      = fl_3d_sign(xy_spread);

  // plane.x and plane.y represent the X and Y axis in the specific 2d
  // projection view
  plane         =
    view=="right"   ? [+Y,+Z] :
    view=="top"     ? [+X,+Y] :
    view=="bottom"  ? [+X,-Y] :
    view=="left"    ? [-Y,+Z] :
    view=="front"   ? [+X,+Z] :
    /* "back" */      [-X,+Z] ;

  // translation on the 'measure line'
  Txy = let (
    // measure lines on "top" are parallel to this vector
    m_line = fl_3d_abs(cross(Z,xy_spread)),
    t = align=="centered"             ? 0 :
        align=="positive"||align=="+" ? +value/2 :
        align=="negative"||align=="-" ? -value/2 :
        assert(is_num(align)) value/2 + align
  ) T(t*m_line);
  // transformation matrix from "top" to the desired projection view
  P = fl_planeAlign(a=[X,Y],b=plane);
  // overall transformation matrix
  V = P*Txy;

  arrow_body_w  = line_width ? line_width : value/8;
  arrow_text_w  = arrow_body_w*3;
  arrow_head_w  = arrow_body_w*8/3;
  thick         = arrow_body_w;
  bbox          = top_bbox(fl_bb_corners(object));
  dims          = bbox[1]-bbox[0];
  // TODO: make a global getter for font usage
  // font          = "Symbola";

  // bounding box calculation in the "top" view
  function top_bbox(
    // embedded object bounding box
    embed
  ) = let(
    // gap(s) to add along the distribution vector
    gaps    = $dim_level*gap,
    length  = let(
      spread = fl_transform(P,xy_spread),
      sgn    = fl_3d_sign(spread)
    ) sgn*embed[_step_(sgn)][_index_(spread)]+gaps,
    dims    = xy_spread.y ? [value,length,thick] : [length,value,thick] ,
    // translation along distribution vector
    low = let(
      t = xy_sgn<0 ? -dims[_index_(xy_spread)] : 0
    ) xy_spread.y ? [-dims.x/2, t, -dims.z/2] : [t, -dims.y/2, -dims.z/2]
  ) [low,low+dims];

  function _index_(axis) = axis.x ? 0 : axis.y ? 1 : 2;
  function _step_(value) = value<0 ? 0 : 1;

  module context() let(
    $dim_align  = align,
    $dim_distr  = distr,
    $dim_gap    = gap,
    $dim_label  = label,
    $dim_object = object,
    $dim_mode   = mode,
    $dim_spread = xy_spread,
    $dim_value  = value,
    $dim_verb   = $verb,
    $dim_view   = view,
    $dim_width  = line_width
  ) children();

  module darrow(label,value,w) {

    module label(txt)
      rotate(xy_spread.y ? 0 : 90,Z)
        translate([0,+arrow_head_w/2])
          linear_extrude(thick)
            text(str(txt), valign="bottom", halign="center", size=arrow_body_w*3);

    function vertical(head_t,body_t,offset=-value/2) = let(
      head_l  = body_t*8/5
    ) [
      [0,offset+0],
      [head_t/2,offset+head_l],
      [body_t/2,offset+head_l],
      [body_t/2,offset+value-head_l],
      [head_t/2,offset+value-head_l],
      [0,offset+value],
      [-head_t/2,offset+value-head_l],
      [-body_t/2,offset+value-head_l],
      [-body_t/2,offset+head_l],
      [-head_t/2,offset+head_l],
    ];

    function horizontal(head_t,body_t,offset=-value/2) = let(
      head_l  = body_t*8/5
    ) [
      [offset+0,0],
      [offset+head_l,head_t/2],
      [offset+head_l,body_t/2],
      [offset+value-head_l,body_t/2],
      [offset+value-head_l,head_t/2],
      [offset+value,0],
      [offset+value-head_l,-head_t/2],
      [offset+value-head_l,-body_t/2],
      [offset+head_l,-body_t/2],
      [offset+head_l,-head_t/2],
    ];

    label =
      mode=="full"   ? (label ? str(label,"=",value) : value) :
      mode=="label"  ? (label ? label : undef) :
      mode=="value"  ? str(value) : undef;

    pts =
      xy_spread.x ?    // horizontal distribution
        vertical(arrow_head_w,arrow_body_w,offset=0) :
        xy_spread.y ?  // vertical distribution
          horizontal(arrow_head_w,arrow_body_w,offset=0) :
          assert(false,fl_error(["Bad value for xy_spread on XY plane:", str(xy_spread)])) [];
    // arrow positioning according to the bounding box
    t =
      xy_spread.y>0 ?      [bbox[0].x, bbox[1].y, bbox[0].z] :
      xy_spread.x>0 ?      [bbox[1].x, bbox[0].y, bbox[0].z] :
                        bbox[0] ;
    T_label =
      xy_spread.y ? X(value/2) :
      xy_spread.x ? Y(value/2) :
      assert(false,fl_error(["Bad value for spread:", str(xy_spread)])) [];

    translate(t) {
      linear_extrude(thick)
        polygon(pts);
      if (label)
        translate(T_label)
          label(label, $FL_ADD="ON");
    }
  }

  module reference_lines() {

    module line() let(
        width   = line_width/2,
        length  = xy_spread.x ? dims.x : dims.y,
        size    = xy_spread.x ? [length,width,thick] : [width,length,thick]
      ) fl_cube(size=size, octant=xy_spread, $FL_ADD="DEBUG");

    if (xy_spread.x) // vertical measure ⇒ horizontal reference
      for(y=[-value/2,+value/2])
        translate(Y(y))
          line();
    else if (xy_spread.y) // horizontal measure ⇒ vertical reference
      for(x=[-value/2,+value/2])
        translate(X(x))
          line();
    else
      fl_error(str("spread=",xy_spread));
  }

  // run with an execution context set by fl_vmanage{}
  module engine() let(
  ) if ($this_verb==FL_ADD) {
      context() {
        multmatrix(V) {
          color("black")
            darrow(label=label, value=value, w=line_width, $FL_ADD="ON");
          reference_lines();
        }
        children();
      }
    } else if ($this_verb==FL_BBOX) {
      multmatrix(V)
        fl_bb_add(corners=bbox,auto=true);
    } else
      fl_error(["unimplemented verb","'",$this_verb,"'"]);

  if (view==fl_currentView())
    fl_vmanage(verbs,[fl_bb_corners(value=bbox)])
      engine()
        children();
}
