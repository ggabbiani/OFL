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
 */

// include <../foundation/unsafe_defs.scad>
include <../foundation/dimensions.scad>
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
function fl_jnt_points(type,value)  = fl_property(type,str(FL_JNT_NS,"/points"),value);

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
   */
  fillet=0
)  = echo(
  arm_l=arm_l,
  tooth_l=tooth_l,
  length=length
) assert(undercut)
let(
  namespace = str(FL_JNT_NS,"/cantilever"),
  inverse   = orientation==-Z,
  h         = is_num(h) ? [h,h] : assert(is_list(h)) h,
  b         = is_num(b) ? [b,b] : assert(is_list(b)) b,
  tooth_l   =
    tooth_l ? tooth_l :
    length ? assert(arm_l && length>arm_l,str("arm_l=",arm_l,", length=",length)) length-arm_l :
    assert(is_num(alpha)) undercut / tan(alpha),
  length    = arm_l+tooth_l,
  r         = undercut/10,
  m         = (inverse?T(-Z(tooth_l)):I)*R(Z,180)*T(-Z(length/2-tooth_l))*R(Y,-90)*T(X(length/2)-Z(b[1]/2)),
  angular   = undercut/tan(alpha),
  // tooth points in 'polyround' format
  p         = assert(angular<=tooth_l) [
    [0,         inverse ? undercut : 0, inverse ? r : r ],
    [inverse ? -(tooth_l-angular) : -angular,  undercut, inverse ? 0 : r/2 ],
    [-tooth_l,  inverse ? 0 : undercut, inverse ? 0 : r/2 ],
    [-tooth_l,  0,                      0                 ],
    [-tooth_l, -h[1],                   0                 ],
    [0,        -h[1],                   r/2               ],
  ],
  arm_points  = [
    [ -(tooth_l+arm_l), -h[0],  -b[0]/2+b[1]/2 ], // 0
    [ p[2].x,       p[4].y, 0 ],              // 1
    [ p[2].x,       0,      0 ],              // 2
    [ -(tooth_l+arm_l), 0,      -b[0]/2+b[1]/2 ], // 3

    [ -(tooth_l+arm_l), -h[0],  +b[0]/2+b[1]/2  ],// 4
    [ p[2].x,       p[4].y, +b[1]  ],         // 5
    [ p[2].x,       0,      +b[1]  ],         // 6
    [ -(tooth_l+arm_l), 0,      +b[0]/2+b[1]/2  ],// 7
  ],
  arm_faces = [
    [0,1,2,3],  // bottom
    [4,5,1,0],  // front
    [7,6,5,4],  // top
    [5,6,2,1],  // right
    [6,7,3,2],  // back
    [7,4,0,3],  // left
  ],
  corners   = fl_bb_transform(m,[
    [arm_points[0].x,arm_points[0].y,min(arm_points[0].z,0)],
    [p[0].x,p[inverse?0:1].y,max(b[1],arm_points[7].z)]
  ])
) [
  fl_native(value=true),
  if (description) fl_description(value=description),
  fl_engine(value=namespace),
  [str(namespace,"/b"), b],
  [str(namespace,"/h"), h],
  [str(namespace,"/m"), m],
  [str(namespace,"/l"), arm_l],
  [str(namespace,"/length"), length],
  fl_jnt_points(value=p),
  fl_bb_corners(value=corners),
  [str(namespace,"/arm"), [arm_points,arm_faces]],
  [str(namespace,"/undercut"), undercut],
  [str(namespace,"/reverse"), inverse],
  [str(namespace,"/tooth"), tooth_l],
  [str(namespace,"/dimensions"), fl_DimensionPack([
    fl_Dimension(length,"length"),
    fl_Dimension(arm_l,"arm"),
    fl_Dimension(h[0],"h[0]"),
    fl_Dimension(h[1],"h[1]"),
    fl_Dimension(b[0],"b[0]"),
    fl_Dimension(b[1],"b[1]"),
    fl_Dimension(undercut,"undercut"),
    fl_Dimension(tooth_l,"tooth"),
  ])],
];

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
  namespace = str(FL_JNT_NS,"/cantilever");

  b         = fl_property(this,str(namespace,"/b"));
  h         = fl_property(this,str(namespace,"/h"));
  m         = fl_property(this,str(namespace,"/m"));
  l         = fl_property(this,str(namespace,"/l"));
  length    = fl_property(this,str(namespace,"/length"));
  arm       = fl_property(this,str(namespace,"/arm"));
  undercut  = fl_property(this,str(namespace,"/undercut"));
  pts       = fl_jnt_points(this);
  dims      = fl_property(this,str(namespace,"/dimensions"));
  reverse   = fl_property(this,str(namespace,"/reverse"));
  tooth_l   = fl_property(this,str(namespace,"/tooth"));

  // run with an execution context set by fl_polymorph{}
  module engine() let(

  ) if ($this_verb==FL_ADD || $this_verb==FL_FOOTPRINT) {
      multmatrix(m)
      {
        // tooth
        linear_extrude(b[1])
          polygon(polyRound(pts, fn=$fn));
        // arm
        polyhedron(points=arm[0], faces=arm[1]);
      }
      if (fl_parm_dimensions(debug)) let(
          $dim_object = this,
          $dim_width  = $dim_width ? $dim_width : 0.05
        ) {
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
  fl_polymorph(verbs,this,octant,direction,debug)
    engine()
      children();
}
