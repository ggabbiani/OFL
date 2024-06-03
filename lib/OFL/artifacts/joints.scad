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

include <../foundation/unsafe_defs.scad>
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

//! creates a cantilever joint with rectangle cross-section
function fl_jnt_RectCantilever(
  //! optional description
  description,
  //! total cantilever length (i.e. arm + tooth)
  length,
  //! thickness in scalar or [root,end] form. Scalar value means constant thickness.
  h,
  //! width in scalar or [root,end] form. Scalar value means constant width.
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
  namespace = str(FL_JNT_NS,"/cantilever"),
  h         = is_num(h) ? [h,h] : assert(is_list(h)) h,
  b         = is_num(b) ? [b,b] : assert(is_list(b)) b,
  tooth_l   = assert(is_num(alpha)) undercut / tan(alpha),
  l         = assert(length>tooth_l,tooth_l) length - tooth_l,
  r         = undercut/10,
  m         = R(Z,180)*T(-Z(length/2-tooth_l))*R(Y,-90)*T(X(length/2)-Z(b[1]/2)),
  inverse   = orientation==-Z,
  p         = [
    [0,         inverse ? undercut : 0, inverse ? r : 0   ],
    [-tooth_l,  inverse ? 0 : undercut, inverse ? 0 : r/2 ],
    [-tooth_l,  0,                      0                 ],
    [-tooth_l, -h[1],                   0                 ],
    [0,        -h[1],                   r/2               ],
  ],
  arm_points  = [
    [ -(tooth_l+l), -h[0],  -b[0]/2+b[1]/2 ], // 0
    [ p[1].x,       p[4].y, 0 ],              // 1
    [ p[1].x,       0,      0 ],              // 2
    [ -(tooth_l+l), 0,      -b[0]/2+b[1]/2 ], // 3

    [ -(tooth_l+l), -h[0],  +b[0]/2+b[1]/2  ],// 4
    [ p[1].x,       p[4].y, +b[1]  ],         // 5
    [ p[1].x,       0,      +b[1]  ],         // 6
    [ -(tooth_l+l), 0,      +b[0]/2+b[1]/2  ],// 7
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
  [str(namespace,"/l"), l],
  [str(namespace,"/length"), length],
  fl_jnt_points(value=p),
  fl_bb_corners(value=corners),
  [str(namespace,"/arm"), [arm_points,arm_faces]],
  [str(namespace,"/undercut"), undercut],
];

//! creates a cantilever joint with constant rectangle cross-section
function fl_jnt_RectCantileverConst(
  //! optional description
  description,
  //! total cantilever length (i.e. arm + tooth)
  length,
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
  fl_jnt_RectCantilever(description,length,h,b,undercut,alpha,orientation,fillet);

/*!
 * Creates a cantilever joint with a scaled section thickness from «h» to «h»/2
 */
function fl_jnt_RectCantileverScaledThickness(
  //! optional description
  description,
  //! total cantilever length (i.e. arm + tooth)
  length,
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
  fl_jnt_RectCantilever(description,length,[h,h/2],b,undercut,alpha,orientation,fillet);

/*!
 * Creates a cantilever joint with a scaled section width from «b» to «b»/4
 */
function fl_jnt_RectCantileverScaledWidth(
  //! optional description
  description,
  //! total cantilever length (i.e. arm + tooth)
  length,
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
  fl_jnt_RectCantilever(description,length,h,[b,b/4],undercut,alpha,orientation,fillet);

/*!
 * Creates a cantilever joint with a scaled section thickness from «h» to «h»/2
 * and a scaled section width from «b» to «b»/4
 */
function fl_jnt_RectCantileverFullScaled(
  //! optional description
  description,
  //! total cantilever length (i.e. arm + tooth)
  length,
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
  fl_jnt_RectCantilever(description,length,[h,h/2],[b,b/4],undercut,alpha,orientation,fillet);

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
  echo(this=this);
  namespace = str(FL_JNT_NS,"/cantilever");

  b         = fl_property(this,str(namespace,"/b"));
  h         = fl_property(this,str(namespace,"/h"));
  m         = fl_property(this,str(namespace,"/m"));
  l         = fl_property(this,str(namespace,"/l"));
  length    = fl_property(this,str(namespace,"/length"));
  arm       = fl_property(this,str(namespace,"/arm"));
  undercut  = fl_property(this,str(namespace,"/undercut"));
  pts       = fl_jnt_points(this);

  // run with an execution context set by fl_polymorph{}
  module engine() let(

  ) if ($this_verb==FL_ADD || $this_verb==FL_FOOTPRINT) {
      multmatrix(m)
      {
        linear_extrude(b[1])
          polygon(polyRound(pts, fn=$fn));
        polyhedron(points=arm[0], faces=arm[1]);
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
