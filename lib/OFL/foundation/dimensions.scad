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
use <../foundation/polymorphic-engine.scad>

//! gap between dimension lines
$DIM_GAP=1;

//! prefix used for namespacing
FL_DIM_NS  = "dim";

// Dimension lines public properties

function fl_dim_label(type,value)  = fl_property(type,str(FL_DIM_NS,"/label"),value);
function fl_dim_value(type,value)  = fl_property(type,str(FL_DIM_NS,"/value"),value);

//! package inventory as a list of pre-defined and ready-to-use 'objects'
FL_DIM_INVENTORY = [
];

/*!
 * Constructor for dimension lines.
 *
 * This geometry is meant to be used on a 'top view' projection, with Z axis as normal.
 */
function fl_Dimension(
  //! mandatory value
  value,
  //! mandatory label string
  label,
)  = [
  fl_native(value=true),
  assert(label)       fl_dim_label(value=label),
  assert(value)       fl_dim_value(value=value),
];

/*!
 * Children context:
 *
 * - $dim_align   : current alignment
 * - $dim_label   : current dimension line label
 * - $dim_object  : bounded object
 * - $dim_spread  : spread vector
 * - $dim_value   : current value
 * - $dim_view    : dimension line bounded view
 * - $dim_width   : current line width
 * - $dim_level   : current dimension line stacking level (always positive)
 */
module fl_dimension(
  //! supported verbs: FL_ADD
  verbs       = FL_ADD,
  geometry,
  /*!
   * Position of the measure line with respect to its distribute direction:
   *
   * - "centered": default value
   * - "positive": aligned in the positive half of the view plane
   * - "negative": aligned in the negative half of the view plane
   * - «scalar signed value»: position of the start of the measurement line on
   *   the normal to its distribution vector
   */
  align,
  /*!
   * Distribute direction of stacked dimension lines.
   */
  spread,
  gap,
  //! dimension line thickness
  line_width,
  //! The object to which the dimension line is attached.
  object,
  /*!
   * Name of the projection plane view:
   *
   * - "right"  ⇒ XZ plane
   * - "top"    ⇒ XY plane
   * - "bottom" ⇒ YX plane
   * - "left"   ⇒ ZY plane
   */
  view,
  //! see constructor fl_parm_Debug()
  debug
) {
  assert(view=="right"||view=="top"||view=="bottom"||view=="left",view);
  assert(align=="centered"||align=="positive"||align=="+"||align=="negative"||align=="-"||is_num(align),align);

  $dim_level = is_undef($dim_level) ? 1 : $dim_level+1;

  value         = fl_dim_value(geometry);
  label         = fl_dim_label(geometry);

  // attribute inheritance from stacked dimension lines
  align         = is_undef(align) ? is_undef($dim_align) ? "centered" : $dim_align : align;
  spread        = spread  ? spread  : $dim_spread;
  spread_sgn    = fl_3d_sign(spread);
  gap           = gap ? gap : $dim_gap;
  line_width    = line_width ? line_width : $dim_width;
  object        = object  ? object  : $dim_object;
  view          = view ? view : $dim_view;

  // plane.x and plane.y represent the X and Y axis in the specific 2d
  // projection view
  plane         =
    view=="right"   ? [+Y,+Z] :
    view=="top"     ? [+X,+Y] :
    view=="bottom"  ? [+X,-Y] :
    /* "left" */      [-Y,+Z] ;
  plane_n       = cross(plane.x,plane.y);
  // measure lines are parallel to this vector
  measure_vec   = fl_3d_abs(cross(plane_n,spread));

  // translation on 'measure_vec'
  T      = let (
    t = align=="centered"             ? 0 :
        align=="positive"||align=="+" ? +value/2 :
        align=="negative"||align=="-" ? -value/2 :
        assert(is_num(align)) value/2 + align
  ) T(t*measure_vec);

  arrow_body_w  = line_width ? line_width : value/8;
  arrow_text_w  = arrow_body_w*3;
  arrow_head_w  = arrow_body_w*8/3;
  thick         = arrow_body_w;
  bbox          = bbox(fl_bb_corners(object));
  dims          = bbox[1]-bbox[0];
  // enrich geometry with bounding box
  geometry      = concat(geometry,[fl_bb_corners(value=bbox)]);
  font          = "Symbola:style=Regular";

  echo(bbox=bbox,T=T);

  // bounding box calculation
  function bbox(
    // embedded object bounding box
    embed
  ) = let(
    // gap(s) to add along the distribution vector
    gaps = $dim_level*gap
  ) let(
    length  = spread_sgn*embed[_step_(spread_sgn)][_index_(spread)]+gaps,
    dims    = spread.y ? [value,length,thick] : [length,value,thick],
    // translation along distribution vector
    dist_t  = spread_sgn<0 ? -dims[_index_(spread)] : 0,
    low     = spread.y ? [-dims.x/2, dist_t, -dims.z/2] : [dist_t, -dims.y/2, -dims.z/2]
  ) [low,low+dims];

  function alignment() = let(delta=value/2)
    spread==-Y ?
      X((1+sign(align.x))*delta) :
      [O,O];

  function _align_(align,value) = let(delta=value/2) [
    sign(align.x)*delta,
    sign(align.y)*delta,
    sign(align.z)*delta
  ];
  function _offset_(quad,bbox,gap) = [
    let(s=sign(quad.x)) (s==0 ? 0 : bbox[(s+1)/2].x) + s*gap,
    let(s=sign(quad.y)) (s==0 ? 0 : bbox[(s+1)/2].y) + s*gap,
    let(s=sign(quad.z)) (s==0 ? 0 : bbox[(s+1)/2].z) + s*gap,
  ];

  function _index_(axis) = axis.x ? 0 : axis.y ? 1 : 2;
  function _step_(value) = value<0 ? 0 : 1;

  module context() let(
    $dim_align  = align,
    $dim_gap    = gap,
    $dim_label  = label,
    $dim_object = object,
    $dim_spread = spread,
    $dim_value  = value,
    $dim_view   = view,
    $dim_width  = line_width
  ) children();

  module darrow(label,value,w) {

    module label(txt)
      rotate(spread.y ? 0 : 90,Z)
        translate([0,+arrow_head_w/2])
          resize([0,arrow_body_w*3,0],auto=[true,true,false])
            linear_extrude(thick)
              text(str(txt), valign="bottom", halign="center", font=font);

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
      $DIM_MODE=="full"   ? (label ? str(label,"=",value) : value) :
      $DIM_MODE=="label"  ? (label ? label : undef) :
      $DIM_MODE=="value"  ? str(value) : undef;

    echo(plane=plane,"current x",let(s="XYZ") s[_index_(plane.x)]);
    pts = _index_(spread)==0 ?  // horizontal distribution on the view plane
      vertical(arrow_head_w,arrow_body_w,offset=0) :
      _index_(spread)==1 ?      // vertical distribution on the view plane
      horizontal(arrow_head_w,arrow_body_w,offset=0) :
      assert(false,fl_error(["Bad value for spread:", str(spread)])) [];
    // arrow positioning according to the bounding box
    t =
      spread.y>0 ?      [bbox[0].x, bbox[1].y, bbox[0].z] :
      spread.x>0 ?      [bbox[1].x, bbox[0].y, bbox[0].z] :
                        bbox[0] ;
    T_label =
      spread.y ? X(value/2) :
      spread.x ? Y(value/2) :
      assert(false,fl_error(["Bad value for spread:", str(spread)])) [];
    echo(t=t,T_label=T_label)
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
        length  = spread.x ? dims.x : dims.y,
        size    = spread.x ? [length,width,thick] : [width,length,thick]
      ) fl_cube(size=size, octant=spread, $FL_ADD="DEBUG");

    if (spread.x) // vertical measure ⇒ horizontal reference
      for(y=[-value/2,+value/2])
        translate(Y(y))
          line();
    else if (spread.y) // horizontal measure ⇒ vertical reference
      for(x=[-value/2,+value/2])
        translate(X(x))
          line();
    else
      fl_error(true,str("spread=",spread));
  }

  // run with an execution context set by fl_polymorph{}
  module engine() let(
  ) if ($this_verb==FL_ADD) {
      context() {
        multmatrix(T) {
          color("black")
            darrow(label=label, value=value, w=line_width, $FL_ADD="ON");
          reference_lines();
        }
        children();
      }
    } else if ($this_verb==FL_BBOX) {
      multmatrix(T)
        fl_bb_add(corners=bbox,auto=true);
    } else
      fl_error(true,["unimplemented verb","'",$this_verb,"'"]);

  if (view==fl_currentView())
    fl_polymorph(verbs,geometry,octant)
      engine()
        children();
}
