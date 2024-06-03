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

$DIM_MODE = "full"; // [full,label,value,silent]

/* [Hidden] */

//! prefix used for namespacing
FL_DIM_NS  = "dims";

// Dimension lines public properties

function fl_dims_label(type,value)  = fl_property(type,str(FL_DIM_NS,"/label"),value);
function fl_dims_value(type,value)  = fl_property(type,str(FL_DIM_NS,"/value"),value);

//! package inventory as a list of pre-defined and ready-to-use 'objects'
FL_DIM_INVENTORY = [
];

//! helper for new dimension 'object' definition
function fl_Dimension(
  //! mandatory value
  value,
  //! mandatory label string
  label,
  //! The object to which the dimension line is attached.
  object,
  /*!
   * Is the normal to the 2d view looking at the observer and implicitly defines
   * the orthogonal view to be used.
   */
  normal=+Z,
  /*!
   * Spread direction in the orthogonal view of the dimension lines.
   */
  spread=+X,
  /*!
   * By default the dimension line is centered on the «quadrant» parameter.
   */
  align=[0,0,0]
)  = let(
  // constructor specific variables
  // ...
) [
  fl_native(value=true),
  assert(label)   fl_dims_label(value=label),
  assert(value)   fl_dims_value(value=value),
  assert(object)  fl_bb_corners(value=fl_bb_corners(object)),
  [str(FL_DIM_NS,"/normal"),normal],
  [str(FL_DIM_NS,"/spread"),spread],
  [str(FL_DIM_NS,"/align"),align],
];

/*!
 * Children context:
 *
 * - $dim_quadrant  : current spread
 * - $dim_width     : current line width
 * - $dim_gap       : initial gap from the object bounding-box and between
 *  subsequent lines in case of stacking
 * - $dim_align     : current alignment
 * - $dim_level     : current dimension line stacking level (always positive)
 * - $dim_normal    : «normal» parameter
 */
module fl_dimension(
  //! supported verbs: FL_ADD
  verbs       = FL_ADD,
  geometry,
  //! line width
  line_width,
  //! lines gap
  gap=1,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! see constructor fl_parm_Debug()
  debug
) {
  $dim_level = is_undef($dim_level) ? 1 : $dim_level+1;

  value     = fl_dims_value(geometry);
  spread    = fl_property(geometry,str(FL_DIM_NS,"/spread"));
  normal    = fl_property(geometry,str(FL_DIM_NS,"/normal"));
  align     = fl_property(geometry,str(FL_DIM_NS,"/align"));
  bbox      = fl_bb_corners(geometry);
  label     = fl_dims_label(geometry);

  body_w    = assert(line_width) line_width ? line_width : value/8;
  thick     = line_width*2;
  font      = "Symbola:style=Regular";
  quad_sgn  = _sign_(spread);
  quad_abs  = _abs_(spread);
  trans     = _offset_(spread, bbox, gap)+_align_(align,value);
  horiz     = _abs_(spread)==Y;

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
    $dim_quadrant = spread,
    $dim_width    = line_width,
    $dim_gap      = gap,
    $dim_align    = align,
    // $dim_level    = $dim_level+1,
    $dim_normal   = normal
  ) children();

  module label(text,horizontal=true)
    rotate(horiz ? 0 : 90,Z)
      translate([0,+body_w])
        resize([0,body_w*3,0],auto=[true,true,false])
          linear_extrude(thick)
            text(str(text), valign="bottom", halign="center", font=font);

  module darrow(label,value,w,horizontal=true) {
    head_l    = body_w*8/5;

    module head(direction) let(
      head_w  = body_w*8/3
    ) fl_cylinder(h=head_l, d1=head_w, d2=0, direction=direction);

    rotate(horiz ? 90 : 0,Z)
      linear_extrude(thick)
        projection() {
          for(i=[-1,+1])
            translate(i*Y(value/2-head_l))
              head([i*Y,0]);
          fl_cylinder(h=value-2*head_l, d=body_w, octant=O, direction=[+Y,0]);
        }
  }

  module reference_lines() {

    module line() let(
        width   = line_width/2,
        length  = abs(spread.x ? bbox[(sign(spread.x)+1)/2].x : spread.y ? bbox[(sign(spread.y)+1)/2].y : bbox[(sign(spread.z)+1)/2].z) + $dim_level*gap,
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
            fl_direct(direction=[normal,0])
              translate(-thick/2*normal) {
                darrow(label=label, value=value, w=line_width, horizontal=horiz, $FL_ADD="ON");
                let(
                  label =
                    $DIM_MODE=="full" ? (label ? str(label,"=",value) : value) :
                    $DIM_MODE=="label" ? (label ? label : undef) :
                    $DIM_MODE=="value" ? str(value) : undef
                ) if (label)
                  label(label, horizontal=horiz, $FL_ADD="ON");
              }
          reference_lines();
        }
        translate(gap*spread)
          children();
      }
    } else
      fl_error(true,["unimplemented verb","'",$this_verb,"'"]);

  // fl_polymorph() manages standard parameters and prepares the execution
  // context for the engine.
  fl_polymorph(verbs,geometry,octant,direction,debug)
    engine()
      children();
}

d         = 4;
h         = 10;
cylinder  = fl_cylinder_defaults(h=h,d=d);
line_w    = 0.1;

dim_radius    = fl_Dimension(value=d/2,  label="radius",   object=cylinder, normal=+Z, spread=-Y, align=+X);
dim_diameter  = fl_Dimension(value=d,    label="diameter", object=cylinder, normal=+Z, spread=-Y, align=O);
dim_height    = fl_Dimension(value=h,    label="height",   object=cylinder, normal=+Z, spread=+X, align=+Y);

fl_dimension(geometry=dim_radius,line_width=line_w)
  fl_dimension(geometry=dim_diameter,line_width=$dim_width);
fl_dimension(geometry=dim_height, line_width=line_w);

projection()
  fl_cylinder(h=h,d=d,$fn=100);
