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
  /*!
   * Spread direction in the orthogonal view of the dimension lines.
   */
  spread=+X,
  //! dimension line thickness
  line_width,
  //! The object to which the dimension line is attached.
  object,
  /*!
   * one of the following:
   * - "right"
   * - "top"
   * - "bottom"
   * - "left"
   */
  view="top"
)  = let(
  horiz         = spread.y!=0,
  arrow_body_w  = line_width ? line_width : value/8,
  arrow_text_w  = arrow_body_w*3,
  thick         = arrow_body_w*2,
  bbox          = let(
    width = arrow_body_w+arrow_text_w,
    dims  = [value,width,thick]
  ) horiz ? [-dims/2,+dims/2] : [[-dims.y/2,-dims.x/2,-thick/2],[+dims.y/2,+dims.x/2,+thick/2]]
) [
  fl_native(value=true),
  assert(label)       fl_dim_label(value=label),
  assert(value)       fl_dim_value(value=value),
                      fl_bb_corners(value=bbox),
  assert(object)      [str(FL_DIM_NS,"/embedded object bounding box"),fl_bb_corners(object)],
  assert(line_width)  [str(FL_DIM_NS,"/line width"),line_width],
                      [str(FL_DIM_NS,"/spread"),spread],
                      [str(FL_DIM_NS,"/arrow body thickness"),arrow_body_w],
                      [str(FL_DIM_NS,"/arrow text thickness"),arrow_text_w],
                      [str(FL_DIM_NS,"/thick"),arrow_text_w],
                      [str(FL_DIM_NS,"/view"),view],
];

/*!
 * Children context:
 *
 * - $dim_align   : current alignment
 * - $dim_label   : current dimension line label
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
   * By default the dimension line is centered on the «spread» parameter.
   */
  align=[0,0,0],
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! see constructor fl_parm_Debug()
  debug
) {
  $dim_level = is_undef($dim_level) ? 1 : $dim_level+1;

  value         = fl_dim_value(geometry);
  label         = fl_dim_label(geometry);
  emb_bbox      = fl_property(geometry, str(FL_DIM_NS,"/embedded object bounding box"));
  line_width    = fl_property(geometry, str(FL_DIM_NS,"/line width"));
  spread        = fl_property(geometry, str(FL_DIM_NS,"/spread"));
  bbox          = fl_bb_corners(geometry);
  arrow_body_w  = fl_property(geometry, str(FL_DIM_NS,"/arrow body thickness"));
  arrow_text_w  = fl_property(geometry, str(FL_DIM_NS,"/arrow text thickness"));
  thick         = fl_property(geometry, str(FL_DIM_NS,"/thick"));
  view          = fl_property(geometry, str(FL_DIM_NS,"/view"));

  horiz         = _abs_(spread)==Y;
  font          = "Symbola:style=Regular";
  quad_sgn      = _sign_(spread);
  quad_abs      = _abs_(spread);
  trans         = _offset_(spread, emb_bbox, $DIM_GAP)+_align_(align,value);

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

  function _sign_(axis) = axis==-X || axis==-Y || axis==-Z ? -1 : +1;
  function _abs_(axis)  = [for(i=axis) abs(i)];

  module context() let(
    $dim_align  = align,
    $dim_label  = label,
    $dim_spread = spread,
    $dim_value  = value,
    $dim_view   = assert(view) view,
    $dim_width  = line_width
  ) children();

  module label(txt)
    rotate(horiz ? 0 : 90,Z)
      translate([0,+arrow_body_w])
        resize([0,arrow_body_w*3,0],auto=[true,true,false])
          linear_extrude(thick)
            text(str(txt), valign="bottom", halign="center", font=font);

  module darrow(label,value,w) {
    head_l    = arrow_body_w*8/5;

    module head(direction) let(
      arrow_head_w  = arrow_body_w*8/3
    ) fl_cylinder(h=head_l, d1=arrow_head_w, d2=0, direction=direction);

    rotate(horiz ? 90 : 0,Z)
      linear_extrude(thick)
        projection() {
          for(i=[-1,+1])
            translate(i*Y(value/2-head_l))
              head([i*Y,0]);
          fl_cylinder(h=value-2*head_l, d=arrow_body_w, octant=O, direction=[+Y,0]);
        }
  }

  module reference_lines() {

    module line() let(
        width   = line_width/2,
        length  = abs(spread.x ? emb_bbox[(sign(spread.x)+1)/2].x : spread.y ? emb_bbox[(sign(spread.y)+1)/2].y : emb_bbox[(sign(spread.z)+1)/2].z) + $dim_level*$DIM_GAP,
        size    = spread.x ? [length,width,thick] : spread.y ? [width,length,thick] : [length,thick,width]
      ) fl_cube(size=size, octant=-spread, $FL_ADD="DEBUG");

    if (spread.x) // reference line parallel to X axis
      for(y=[-value/2,+value/2])
        translate(Y(y))
          line();
    else if (spread.y) // reference line parallel to Y axis
      for(x=[-value/2,+value/2])
        translate(X(x))
          line();
    else if (spread.z) // reference line parallel to Z axis
      for(z=[-value/2,+value/2])
        translate(Z(z))
          line();
    else
      fl_error(true,str("spread=",spread));
  }

  // run with an execution context set by fl_polymorph{}
  module engine() let(
  ) if ($this_verb==FL_ADD) {
      context() {
        translate(trans) {
          color("black")
              translate(-Z(thick/2)) {
                darrow(label=label, value=value, w=line_width, $FL_ADD="ON");
                let(
                  label =
                    $DIM_MODE=="full" ? (label ? str(label,"=",value) : value) :
                    $DIM_MODE=="label" ? (label ? label : undef) :
                    $DIM_MODE=="value" ? str(value) : undef
                ) if (label)
                  label(label, $FL_ADD="ON");
              }
          reference_lines();
        }
        translate($DIM_GAP*spread)
          children();
      }
    } else
      fl_error(true,["unimplemented verb","'",$this_verb,"'"]);

  if (view==fl_currentView())
    fl_polymorph(verbs,geometry,octant,direction,debug)
      engine()
        children();
}
