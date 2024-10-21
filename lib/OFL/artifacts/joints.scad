/*!
 * Snap-fit joints, for 'how to' about snap-fit joint 3d printing, see also [How
 * do you design snap-fit joints for 3D printing? | Protolabs
 * Network](https://www.hubs.com/knowledge-base/how-design-snap-fit-joints-3d-printing/)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * chirurgia@cemsverona.it
 */

// include <../foundation/unsafe_defs.scad>
include <../foundation/dimensions.scad>
include <../foundation/label.scad>
include <../../Round-Anything/polyround.scad>

use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>
use <../foundation/fillet.scad>
use <../foundation/polymorphic-engine.scad>

//! prefix used for namespacing
FL_JNT_NS  = "jnt";

//! package inventory as a list of pre-defined and ready-to-use 'objects'
FL_JNT_INVENTORY = [
];

//! PolyRound points
function fl_jnt_sectPoints(type,value)  = fl_property(type,str(FL_JNT_NS,"/points"),value);
//! 3d polyhedron points
function fl_jnt_rectPoints(type,value)  = fl_property(type,str(FL_JNT_NS,"/rect/points"),value);

function fl_jnt_LongitudinalSection(
  //! total cantilever length (i.e. arm + tooth). This parameter is mandatory.
  length,
  //! arm length. This parameter is mandatory.
  arm_l,
  /*!
   * tooth length (mandatory parameter)
   */
  tooth_l,
  //! thickness in scalar or [root,end] form. Scalar value means constant thickness.
  h,
  //! undercut
  undercut,
  //! angle of inclination for the tooth
  alpha=30,
  //! move direction: +Z or -Z
  orientation=+Z,
) = let(
  this_ns = str(FL_JNT_NS,"/longitudinal section"),
  inverse   = orientation==-Z,
  h         = is_num(h) ? [h,h] : assert(is_list(h)) h,
  length    = assert(arm_l) assert(tooth_l) arm_l+tooth_l,
  r         = undercut/10,
  angular   = undercut/tan(alpha),
  // points in 'polyround' format [x,y,degree]
  pts       = assert(angular<=tooth_l) let(delta_x=h[0]-h[1]) [
    [0,                     -arm_l,                       0             ],  // 0
    [h[0],                  -arm_l,                       0             ],  // 1
    [delta_x+h[1],           0,                           0   ],  // 2
    [delta_x+h[1]+undercut, (inverse?angular:0),          inverse?r:r/2 ],  // 3
    [delta_x+h[1]+undercut,  tooth_l-(inverse?0:angular), inverse?r/2:r ],  // 4
    [delta_x+h[1],           tooth_l,                     inverse?0:r   ],  // 5
    [delta_x+0,              tooth_l,                     r/2           ],  // 6
    [delta_x+0,              0,                           0             ],  // 7
  ]
) [
  [str(this_ns,"/h"), h],
  [str(this_ns,"/l"), arm_l],
  [str(this_ns,"/length"), length],
  fl_jnt_sectPoints(value=pts),
  [str(this_ns,"/undercut"), undercut],
  [str(this_ns,"/reverse"), inverse],
  [str(this_ns,"/tooth"), tooth_l],
];

function fl_jnt_RingCantilever(
  //! optional description
  description,
  //! total cantilever length (i.e. arm + tooth)
  length,
  //! arm length
  arm_l,
  /*!
   * tooth length: automatically calculated according to «alpha» angle if undef
   */
  tooth_l,
  //! thickness in scalar or [root,end] form. Scalar value means constant thickness.
  h,
  /*!
   * angular width in scalar or [root,end] form. Scalar value means constant
   * angular width.
   */
  theta,
  undercut,
  //! angle of inclination for the tooth
  alpha=30,
  //! move direction: +Z or -Z
  orientation=+Z,
  //! outer radius
  r,
  /*!
   * optional fillet radius.
   *
   * - 0 ⇒ no fillet
   * - "auto" ⇒ auto calculated radius
   * - scalar ⇒ client defined radius value
   *
   * __NOTE__: currently not (yet) implemented
   */
  fillet=0
) = let(
  h         = is_list(h) ? h : [h,h],
  tooth_l   =
    tooth_l ? tooth_l :
    length ? assert(arm_l && length>arm_l,str("arm_l=",arm_l,", length=",length)) length-arm_l :
    assert(is_num(alpha)) undercut / tan(alpha),
  cantilever_ns = str(FL_JNT_NS,"/cantilever"),
  this_ns = str(cantilever_ns,"/ring"),
  section   = fl_jnt_LongitudinalSection(length,arm_l,tooth_l,h,undercut,alpha,orientation),
  2d_bb     = fl_bb_arc(r=r+undercut, angles=[90-theta/2,90+theta/2], thick=h[0]+undercut),
  3d_bb     = [
    [2d_bb[0].x,2d_bb[0].y,-arm_l],
    [2d_bb[1].x,2d_bb[1].y,tooth_l]
  ],
  ring      = [
    fl_native(value=true),
    if (description) fl_description(value=description),
    fl_engine(value=this_ns),
    fl_bb_corners(value=3d_bb),
    assert(theta) [str(this_ns,"/theta"),         theta ],
    assert(r)     [str(this_ns,"/r2"),            r     ],
  ]
) concat(ring,section);

function fl_jnt_RingCantileverConst(
  //! optional description
  description,
  //! total cantilever length (i.e. arm + tooth)
  length,
  //! arm length
  arm_l,
  /*!
   * tooth length: automatically calculated according to «alpha» angle if undef
   */
  tooth_l,
  //! thickness in scalar.
  h,
  /*!
   * angular width in scalar or [root,end] form. Scalar value means constant
   * angular width.
   */
  theta,
  undercut,
  //! angle of inclination for the tooth
  alpha=30,
  //! move direction: +Z or -Z
  orientation=+Z,
  //! outer radius
  r,
  /*!
   * optional fillet radius.
   *
   * - 0 ⇒ no fillet
   * - "auto" ⇒ auto calculated radius
   * - scalar ⇒ client defined radius value
   *
   * __NOTE__: currently not (yet) implemented
   */
  fillet=0
) = fl_jnt_RingCantilever(description,length,arm_l,tooth_l,h,theta,undercut,alpha,orientation,r);

function fl_jnt_RingCantileverFullScaled(
  //! optional description
  description,
  //! total cantilever length (i.e. arm + tooth)
  length,
  //! arm length
  arm_l,
  /*!
   * tooth length: automatically calculated according to «alpha» angle if undef
   */
  tooth_l,
  //! root thickness in scalar.
  h,
  /*!
   * angular width in scalar or [root,end] form. Scalar value means constant
   * angular width.
   */
  theta,
  undercut,
  //! angle of inclination for the tooth
  alpha=30,
  //! move direction: +Z or -Z
  orientation=+Z,
  //! outer radius
  r,
  /*!
   * optional fillet radius.
   *
   * - 0 ⇒ no fillet
   * - "auto" ⇒ auto calculated radius
   * - scalar ⇒ client defined radius value
   *
   * __NOTE__: currently not (yet) implemented
   */
  fillet=0
) = fl_jnt_RingCantilever(
  description,
  length,
  arm_l,
  tooth_l,
  [h,h/2],
  theta,
  undercut,
  alpha,
  orientation,
  r
);

/*!
 * creates a cantilever joint with rectangle cross-section.
 *
 * The following pictures show the relations between the passed parameters and
 * the object geometry:
 *
 * __FRONT VIEW__:
 *
 * ![Front view](800x600/fig_joints_front_view.png)
 *
 * __RIGHT VIEW__:
 *
 * ![Right view](800x600/fig_joints_right_view.png)
 *
 * __TOP VIEW__
 *
 * ![Top view](800x600/fig_joints_top_view.png)
 */
function fl_jnt_RectCantilever(
  //! optional description
  description,
  //! total cantilever length (i.e. arm + tooth)
  length,
  //! arm length
  arm_l,
  /*!
   * tooth length: automatically calculated according to «alpha» angle if undef
   */
  tooth_l,
  //! thickness in scalar or [root,end] form. Scalar value means constant thickness.
  h,
  //! width in scalar or [root,end] form. Scalar value means constant width.
  b,
  undercut,
  //! angle of inclination for the tooth
  alpha=30,
  //! move direction: +Z or -Z
  orientation=+Z,
  /*!
   * optional fillet radius.
   *
   * - 0 ⇒ no fillet
   * - "auto" ⇒ auto calculated radius
   * - scalar ⇒ client defined radius value
   *
   * __NOTE__: currently not (yet) implemented
   */
  fillet=0
) = let(
  cant_ns   = str(FL_JNT_NS,"/cantilever"),
  this_ns   = str(cant_ns,"/rect"),
  h         = is_num(h) ? [h,h] : assert(is_list(h)) h,
  b         = is_num(b) ? [b,b] : assert(is_list(b)) b,
  section   = fl_jnt_LongitudinalSection(length,arm_l,tooth_l,h,undercut,alpha,orientation),
  sec_p     = fl_jnt_sectPoints(section),
  tooth_l   =
    tooth_l ? tooth_l :
    length ? assert(arm_l && length>arm_l,str("arm_l=",arm_l,", length=",length)) length-arm_l :
    assert(is_num(alpha)) undercut / tan(alpha),
  length    = arm_l+tooth_l,
  r         = undercut/10,
  angular   = undercut/tan(alpha),
  // 3d format polyhedron points
  pts         = assert(angular<=tooth_l) [
    [-b[0]/2, 0,        -arm_l  ],      // 0
    [+b[0]/2, 0,        -arm_l  ],      // 1
    [+b[0]/2, +h[0],    -arm_l  ],      // 2
    [-b[0]/2, +h[0],    -arm_l  ],      // 3

    [-b[1]/2, 0,          0  ],         // 4
    [+b[1]/2, 0,          0  ],         // 5
    [+b[1]/2, +h[1],      0  ],         // 6
    [-b[1]/2, +h[1],      0  ],         // 7

    [-b[1]/2, -undercut, +sec_p[3].y],  // 8
    [+b[1]/2, -undercut, +sec_p[3].y],  // 9

    [-b[1]/2, -undercut,  +sec_p[4].y], // 10
    [+b[1]/2, -undercut,  +sec_p[4].y], // 11

    [-b[1]/2,  0,         +sec_p[5].y],  // 12
    [+b[1]/2,  0,         +sec_p[5].y],  // 13

    [-b[1]/2,  +h[1],     +sec_p[6].y],  // 14
    [+b[1]/2,  +h[1],     +sec_p[6].y],  // 15
  ],
  // faces (polyhedron part)
  faces     = [
    [0,1,2,3],
    [5,6,2,1],
    [1,0,4,5],
    [0,3,7,4],
    [3,2,6,7],
    [7,6,5,4],
    // [9,5,4,8],
    // [10,11,9,8],
    // [12,13,11,10],
    // [14,15,13,12],
    // [15,14,7,6],
    // [13,15,6,5,9,11],
    // [14,12,10,8,4,7],
  ],
  rect      = [
    fl_native(value=true),
    if (description) fl_description(value=description),
    fl_engine(value=this_ns),
    fl_bb_corners(value=fl_bb_polyhedron(pts)),
    assert(b)     [str(this_ns,"/b"),  b     ],
    fl_jnt_rectPoints(value=pts),
    [str(this_ns,"/faces"),  faces ],
    fl_dimensions(value=fl_DimensionPack([
      fl_Dimension(length,"length"),
      fl_Dimension(arm_l,"arm"),
      fl_Dimension(h[0],"h[0]"),
      fl_Dimension(h[1],"h[1]"),
      fl_Dimension(b[0],"b[0]"),
      fl_Dimension(b[1],"b[1]"),
      fl_Dimension(undercut,"undercut"),
      fl_Dimension(tooth_l,"tooth"),
    ])),
  ]
) concat(rect,section);

//! creates a cantilever joint with constant rectangle cross-section
function fl_jnt_RectCantileverConst(
  //! optional description
  description,
  //! total cantilever length (i.e. arm + tooth)
  length,
  l,
  //! thickness in scalar.
  h,
  //! width in scalar.
  b,
  undercut,
  alpha=30,
  //! move direction: +Z or -Z
  orientation=+Z,
  /*!
   * optional fillet radius.
   *
   * - 0 ⇒ no fillet
   * - "auto" ⇒ auto calculated radius
   * - scalar ⇒ client defined radius value
   */
  fillet=0
)  = let(
) assert(is_num(h) && is_num(b) && h && b)
  fl_jnt_RectCantilever(description,length,l,h,b,undercut,alpha,orientation,fillet);

/*!
 * Creates a cantilever joint with a scaled section thickness from «h» to «h»/2
 */
function fl_jnt_RectCantileverScaledThickness(
  //! optional description
  description,
  //! total cantilever length (i.e. arm + tooth)
  length,
  l,
  //! thickness in scalar.
  h,
  //! width in scalar.
  b,
  undercut,
  alpha=30,
  //! move direction: +Z or -Z
  orientation=+Z,
  /*!
   * optional fillet radius.
   *
   * - 0 ⇒ no fillet
   * - "auto" ⇒ auto calculated radius
   * - scalar ⇒ client defined radius value
   */
  fillet=0
)  = let(
) assert(is_num(h) && is_num(b) && h && b)
  fl_jnt_RectCantilever(description,length,l,[h,h/2],b,undercut,alpha,orientation,fillet);

/*!
 * Creates a cantilever joint with a scaled section width from «b» to «b»/4
 */
function fl_jnt_RectCantileverScaledWidth(
  //! optional description
  description,
  //! total cantilever length (i.e. arm + tooth)
  length,
  l,
  //! thickness in scalar.
  h,
  //! width in scalar.
  b,
  undercut,
  alpha=30,
  //! move direction: +Z or -Z
  orientation=+Z,
  /*!
   * optional fillet radius.
   *
   * - 0 ⇒ no fillet
   * - "auto" ⇒ auto calculated radius
   * - scalar ⇒ client defined radius value
   */
  fillet=0
)  = let(
) assert(is_num(h) && is_num(b) && h && b)
  fl_jnt_RectCantilever(description,length,l,h,[b,b/4],undercut,alpha,orientation,fillet);

/*!
 * Creates a cantilever joint with a scaled section thickness from «h» to «h»/2
 * and a scaled section width from «b» to «b»/4
 */
function fl_jnt_RectCantileverFullScaled(
  //! optional description
  description,
  //! total cantilever length (i.e. arm + tooth)
  length,
  l,
  //! thickness in scalar.
  h,
  //! width in scalar.
  b,
  undercut,
  alpha=30,
  //! move direction: +Z or -Z
  orientation=+Z,
  /*!
   * optional fillet radius.
   *
   * - 0 ⇒ no fillet
   * - "auto" ⇒ auto calculated radius
   * - scalar ⇒ client defined radius value
   */
  fillet=0
)  = let(
) assert(is_num(h) && is_num(b) && h && b)
  fl_jnt_RectCantilever(description,length,l,[h,h/2],[b,b/4],undercut,alpha,orientation,fillet);

/*!
 * Children context:
 *
 * - $fl_thickness: radial thickness for FL_DRILL operations for ring shaped
 *   joints
 * - $FL_tolerance: tolerance for FL_FOOTPRINT operations
 */
module fl_jnt_joint(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  this,
  // ==========================================================================
  // module specific parameters
  parameter,
  // ...
  // ==========================================================================
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! see constructor fl_parm_Debug()
  debug
) {
  cantilever_ns = str(FL_JNT_NS,"/cantilever");
  engine        = fl_engine(this);
  debug_enabled = fl_parm_symbols(debug) || fl_parm_labels(debug);
  debug_sz      = debug_enabled ? 0.1 /* fl_2d_closest(pts)/3 */ : undef;
  sec_ns        = str(FL_JNT_NS,"/longitudinal section");

  module context() let(
    $fl_thickness = is_undef($fl_thickness) ? 0 : $fl_thickness,
    $fl_tolerance = is_undef($fl_tolerance) ? 0 : $fl_tolerance
  ) children();

  // run with an execution context set by fl_polymorph{}
  module engine()
    context()
      if (engine==str(FL_JNT_NS,"/cantilever/rect"))
        rect_engine()
          children();
      else if (engine==str(FL_JNT_NS,"/cantilever/ring"))
        ring_engine()
          children();
      else
        fl_error(true,["unimplemented engine",engine]);

  module ring_engine() let(
    h         = fl_property(this,str(sec_ns,"/h")),
    l         = fl_property(this,str(sec_ns,"/l")),
    length    = fl_property(this,str(sec_ns,"/length")),
    undercut  = fl_property(this,str(sec_ns,"/undercut")),
    pts       = fl_jnt_sectPoints(this),
    // dims      = fl_dimensions(this),
    reverse   = fl_property(this,str(sec_ns,"/reverse")),
    tooth_l   = fl_property(this,str(sec_ns,"/tooth")),

    theta = fl_property(this,str(engine,"/theta")),
    r2    = fl_property(this,str(engine,"/r2")),
    r1    = r2-h[0],
    pre   = T(X(r2-h[0])),
    post  = Rz(+90-theta/2)

  ) if ($this_verb==FL_ADD) {

    if (fl_parm_symbols(debug))
      // multmatrix(pre)
        fl_2d_polygonSymbols(pts, 0.1);

    if (fl_parm_labels(debug))
      // multmatrix(pre)
        fl_2d_polygonLabels(pts, 0.1);

    if (debug_enabled)
      // multmatrix(pre)
        #polygon(polyRound(pts, fn=$fn));
    else
      multmatrix(post)
        rotate_extrude(angle=theta)
          multmatrix(pre)
            polygon(polyRound(pts, fn=$fn));

  } else if ($this_verb==FL_AXES)
    fl_doAxes($this_size,$this_direction);

  else if ($this_verb==FL_BBOX)
    fl_bb_add(corners=$this_bbox,auto=true,$FL_ADD=$FL_BBOX);

  else if ($this_verb==FL_CUTOUT) {
    pts = [for(i=[2:len(pts)-1]) let(p=pts[i]) if (i==2) [p.x,p.y,0] else p];
    // theta increment
    theta = let(delta = 2*asin($fl_tolerance/2/r2)) theta + 2*delta;
    post  = Rz(+90-theta/2);
    multmatrix(post)
      rotate_extrude(angle=theta)
        multmatrix(pre)
          intersection() {
            offset(delta=$fl_thickness)
              polygon(polyRound(pts, fn=$fn));
            translate(X(h[1])-Y($fl_tolerance))
              fl_square(size=[undercut+$fl_thickness,tooth_l+2*$fl_tolerance],quadrant=+X+Y);
          }

  } else if ($this_verb==FL_FOOTPRINT) {
    // theta increment
    theta = let(delta = 2*asin($fl_tolerance/2/r2)) theta + 2*delta;
    post  = Rz(+90-theta/2);
    multmatrix(post)
      rotate_extrude(angle=theta)
        multmatrix(pre)
          offset(delta=$fl_tolerance)
            polygon(polyRound(pts, fn=$fn));

  } else
    fl_error(true,["unimplemented verb",$this_verb]);

  module rect_engine() let(
    rect_ns   = str(cantilever_ns,"/rect"),
    h         = fl_property(this,str(sec_ns,"/h")),
    b         = fl_property(this,str(rect_ns,"/b")),
    l         = fl_property(this,str(sec_ns,"/l")),
    length    = fl_property(this,str(sec_ns,"/length")),
    undercut  = fl_property(this,str(sec_ns,"/undercut")),
    pts       = fl_jnt_rectPoints(this),
    dims      = fl_dimensions(this),
    reverse   = fl_property(this,str(sec_ns,"/reverse")),
    tooth_l   = fl_property(this,str(sec_ns,"/tooth")),
    faces     = fl_property(this,str(rect_ns,"/faces")),
    sect      = fl_jnt_sectPoints(this)
  ) if ($this_verb==FL_ADD || $this_verb==FL_FOOTPRINT) {
      // multmatrix(m)
      // {
        // tooth
        // if (fl_parm_symbols(debug))
        //   fl_2d_polygonSymbols(pts, 0.1);
        // if (fl_parm_labels(debug))
        //   fl_2d_polygonLabels(pts, 0.1, "T");
        // if (debug_enabled)
        //   #polygon(polyRound(pts, fn=$fn));
        // else
        //   linear_extrude(b[1])
        //     polygon(polyRound(pts, fn=$fn));
        // // arm
        // if (fl_parm_symbols(debug))
        //   fl_3d_polyhedronSymbols(arm[0], 0.1);
        // if (fl_parm_labels(debug))
        //   fl_3d_polyhedronLabels(arm[0], 0.1, "A");
        // if (debug_enabled)
        //   #polyhedron(points=arm[0], faces=arm[1]);
        // else
        //   polyhedron(points=arm[0], faces=arm[1]);
      // }
      tooth = [for(i=[2:len(sect)-1]) sect[i]];
      m     = T(+Y(h[1]))*R(X,90)*R(-Y,90)*T(-X(h[0]-h[1]))*T(-Z(b[1]/2));

      multmatrix(m)
        if (debug_enabled)
          #polygon(polyRound(tooth, fn=$fn));
        else
          linear_extrude(b[1])
            polygon(polyRound(tooth, fn=$fn));

      if (fl_parm_symbols(debug))
        fl_3d_polyhedronSymbols(pts, 0.1);
      if (fl_parm_labels(debug))
        fl_3d_polyhedronLabels(pts, 0.1);
      if (debug_enabled)
        #polyhedron(points=pts,faces=faces);
      else
        polyhedron(points=pts, faces=faces);

      if (fl_parm_dimensions(debug)) let(
          $dim_object = this,
          $dim_width  = $dim_width ? $dim_width : 0.05
        ) {
          echo("****");
          let($dim_view="right") {
            let($dim_distr="h+") translate(-Z(reverse?tooth_l:0)) {
              fl_dimension(geometry=fl_property(dims,"arm"),        align="negative")
                fl_dimension(geometry=fl_property(dims,"length"), align=-l);
              fl_dimension(geometry=fl_property(dims,"tooth"),    align="positive");
            }
            let($dim_distr="v-")
              fl_dimension(geometry=fl_property(dims,"h[0]"),   align="positive");
            let($dim_distr="v+") {
              fl_dimension(geometry=fl_property(dims,"h[1]"),     align="positive");
              fl_dimension(geometry=fl_property(dims,"undercut"), align=-undercut);
            }
          }
          let($dim_view="top") {
            let($dim_distr="v+")
              fl_dimension(geometry=fl_property(dims,"b[1]"))
                fl_dimension(geometry=fl_property(dims,"b[0]"));
            let($dim_distr="h+") {
              fl_dimension(geometry=fl_property(dims,"undercut"), align="negative");
              fl_dimension(geometry=fl_property(dims,"h[1]"),     align="positive")
                fl_dimension(geometry=fl_property(dims,"h[0]"),  align="positive");
            }
          }
          let($dim_view="front") {
            let($dim_distr="h+") translate(-Z(reverse?tooth_l:0)) {
              fl_dimension(geometry=fl_property(dims,"arm"),        align="negative")
                fl_dimension(geometry=fl_property(dims,"length"), align=-l);
              fl_dimension(geometry=fl_property(dims,"tooth"),    align="positive");
            }
            let($dim_distr="v+")
              fl_dimension(geometry=fl_property(dims,"b[1]"));
            let($dim_distr="v-")
              fl_dimension(geometry=fl_property(dims,"b[0]"));
          }
      }

    } else if ($this_verb==FL_AXES)
      fl_doAxes($this_size,$this_direction);

    else if ($this_verb==FL_BBOX)
      fl_bb_add(corners=$this_bbox,auto=true,$FL_ADD=$FL_BBOX);

    else
      fl_error(true,["unimplemented verb",$this_verb]);

  // fl_polymorph() manages standard parameters and prepares the execution
  // context for the engine.
  fl_polymorph(verbs,this,octant=octant,direction=direction,debug=debug)
    engine()
      children();
}
