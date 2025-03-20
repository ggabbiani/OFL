/*!
 * Snap-fit joints, for 'how to' about snap-fit joint 3d printing, see also [How
 * do you design snap-fit joints for 3D printing?](https://www.hubs.com/knowledge-base/how-design-snap-fit-joints-3d-printing/)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../foundation/dimensions.scad>
include <../foundation/label.scad>

use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>
use <../foundation/fillet.scad>

//! prefix used for namespacing
FL_JNT_NS  = "jnt";

//! namespace for cantilever attributes: jnt/cantilever
FL_JNT_CANTILEVER_NS  = str(FL_JNT_NS,"/cantilever");
//! namespace for rectangular cantilever attributes: jnt/cantilever/rect
FL_JNT_RECT_NS        = str(FL_JNT_CANTILEVER_NS,"/rect");
//! namespace for ring cantilever attributes: jnt/cantilever/ring
FL_JNT_RING_NS        = str(FL_JNT_CANTILEVER_NS,"/ring");
//! namespace for cantilever section attributes: jnt/cantilever/section
FL_JNT_SECTION_NS     = str(FL_JNT_CANTILEVER_NS,"/section");

//! package inventory as a list of pre-defined and ready-to-use 'objects'
FL_JNT_INVENTORY = [
];

/*
 * Returns the section component object used __internally__ by the snap-fit
 * joint constructors.
 */
function __Section__(
  //! arm length. This parameter is mandatory.
  arm,
  /*!
   * tooth length (mandatory parameter)
   */
  tooth,
  //! thickness in scalar or [root,end] form. Scalar value means constant thickness.
  h,
  //! undercut
  undercut,
  //! angle of inclination for the tooth
  alpha
) = let(
  h = is_num(h) ? [h,h] : assert(is_list(h)) h
) [
  [str(FL_JNT_SECTION_NS,"/h"             ),  h         ],
  [str(FL_JNT_SECTION_NS,"/arm"           ),  arm       ],
  [str(FL_JNT_SECTION_NS,"/undercut"      ),  undercut  ],
  [str(FL_JNT_SECTION_NS,"/tooth"         ),  tooth     ],
  [str(FL_JNT_SECTION_NS,"/alpha"         ),  alpha     ]
];

/*!
 * Creates a cantilever snap-fit joint with rectangle cross-section.
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
  //! arm length
  arm,
  //! tooth length
  tooth,
  //! thickness in scalar or [root,end] form. Scalar value means constant thickness.
  h,
  //! width in scalar or [root,end] form. Scalar value means constant width.
  b,
  undercut,
  //! angle of inclination for the tooth
  alpha=30,
) = let(
  // YZ section constructor in RADII POINTS.
  SectionYZ = function(
    undercut,
    // arm length
    arm,
    // tooth (max) length
    tooth,
    // angle formed by the upper tooth
    alpha,
    // thickness in the form [min,max]
    h
  ) let(
    r = roundness(undercut),
    A = [h[0],      -arm      ],
    B = [h[1],      0         ],  // needed only for calculating C
    D = [0,         tooth     ],
    C = fl_2d_intersection(fl_2d_Line(A,B),fl_2d_Line(y=D.y)),
    F = [-undercut, 0         ],
    E = fl_2d_intersection(fl_2d_Line(x=F.x),fl_2d_Line(D,m=tan(90-alpha))),
    G = [0,         0         ],
    H = [0,         -arm      ]
  ) [
    RadiusPoint(G,r*2), // 0
    RadiusPoint(H),     // 1
    RadiusPoint(A),     // 2
    RadiusPoint(C,r/2), // 3
    RadiusPoint(D,r*2), // 4
    RadiusPoint(E,r*2), // 5
    RadiusPoint(F,r)    // 6
  ],
  // XZ section in RADII POINTS needed when b[1]≠b[0]
  SectionXZ = function (
    undercut,
    // arm length
    arm,
    // tooth (max) length
    tooth,
    // width in the form [min,max]
    b
  ) let(
    half  = b/2,
    r     = roundness(undercut)
  ) [
    [-half[1],  tooth,  0   ],  // 0
    [-half[1],  0,      r*2 ],  // 1
    [-half[0],  -arm,   0   ],  // 2
    [+half[0],  -arm,   0   ],  // 3
    [+half[1],  0,      r*2 ],  // 4
    [+half[1],  tooth,  0   ]   // 5
  ],

  h         = is_num(h) ? [h,h] : assert(is_list(h)) h,
  b         = is_num(b) ? [b,b] : assert(is_list(b)) b,
  section   = __Section__(arm,tooth,h,undercut,alpha),
  // r         = undercut/10,
  // angular   = undercut/tan(alpha),
  sectionYZ = SectionYZ(undercut,arm,tooth,alpha,h),
  sectionXZ = SectionXZ(undercut,arm,tooth,b),
  bbox      = let(
    xz   = fl_bb_polygon(sectionXZ),
    yz   = fl_bb_polygon(sectionYZ)
  ) [[xz[0][0],yz[0][0],yz[0][1]],[xz[1][0],yz[1][0],yz[1][1]]],
  rect      = fl_Object(
    bbox,
    description = description,
    engine      = FL_JNT_RECT_NS,
    others      = [
      fl_cutout(value=[+Z]),
      [str(FL_JNT_CANTILEVER_NS,"/b"),          b         ],
      [str(FL_JNT_CANTILEVER_NS,"/section YZ"), sectionYZ ],
      [str(FL_JNT_CANTILEVER_NS,"/section XZ"), sectionXZ ],

      fl_dimensions(value=fl_DimensionPack([
        fl_Dimension(arm,       "arm"       ),
        fl_Dimension(h[0],      "h[0]"      ),
        fl_Dimension(h[1],      "h[1]"      ),
        fl_Dimension(b[0],      "b[0]"      ),
        fl_Dimension(b[1],      "b[1]"      ),
        fl_Dimension(undercut,  "undercut"  ),
        fl_Dimension(tooth,     "tooth"     ),
      ])),
    ]
  )
) concat(rect,section);

function fl_jnt_RingCantilever(
  //! optional description
  description,
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
  //! arm radius
  r
) = let(
  /*
  * YZ section in RADII POINTS.
  *
  * NOTE: all points are on the negative X half-plane
  */
  SectionYZ = function(
    undercut,
    // arm length
    arm,
    // tooth (max) length
    tooth,
    // angle formed by the upper tooth
    alpha,
    // thickness in the form [min,max]
    h,
    // arm radius
    radius
  ) let(
    r = roundness(undercut),
    A = [h[0]-radius,      -arm      ],
    B = [h[1]-radius,      0         ], // needed only for calculating C
    D = [0-radius,         tooth     ],
    C = fl_2d_intersection(fl_2d_Line(A,B),fl_2d_Line(y=D.y)),
    F = [-(undercut+radius), 0         ],
    E = fl_2d_intersection(fl_2d_Line(x=F.x),fl_2d_Line(D,m=tan(90-alpha))),
    G = [0-radius,         0         ],
    H = [0-radius,         -arm      ]
  ) [
    RadiusPoint(G,r*2), // 0
    RadiusPoint(H),     // 1
    RadiusPoint(A),     // 2
    RadiusPoint(C,r/2), // 3
    RadiusPoint(D,r*2), // 4
    RadiusPoint(E,r*2), // 5
    RadiusPoint(F,r)    // 6
  ],

  h         = is_num(h) ? [h,h] : assert(is_list(h)) h,
  section   = __Section__(arm_l,tooth_l,h,undercut,alpha),
  sectionYZ = SectionYZ(undercut,arm_l,tooth_l,alpha,h,r),
  2d_bb     = fl_bb_arc(r=r+undercut, angles=[-90-theta/2,-90+theta/2], thick=h[0]+undercut),
  3d_bb     = [
    [2d_bb[0].x,2d_bb[0].y,-arm_l],
    [2d_bb[1].x,2d_bb[1].y,tooth_l]
  ],
  ring      = fl_Object(
    3d_bb,
    description = description,
    engine      = FL_JNT_RING_NS,
    others      = [
      fl_cutout(value=[+Z]),
      [str(FL_JNT_CANTILEVER_NS,"/section YZ"),   sectionYZ ],
      assert(theta) [str(FL_JNT_RING_NS,"/theta"),theta     ],
      assert(r)     [str(FL_JNT_RING_NS,"/arm r"),r         ],

      fl_dimensions(value=fl_DimensionPack([
        fl_Dimension(arm_l,     "arm"       ),
        fl_Dimension(h[0],      "h[0]"      ),
        fl_Dimension(h[1],      "h[1]"      ),
        fl_Dimension(undercut,  "undercut"  ),
        fl_Dimension(tooth_l,   "tooth"     ),
      ])),
    ]
  )
) concat(ring,section);

function roundness(undercut) = undercut/10;

function RadiusPoint(point,radius=0) = [point.x,point.y,radius];

/*!
 * Add a snap-fit joint.
 *
 * Context variables:
 *
 * | Name             | Context   | Description                                           |
 * | ---------------- | --------- | ----------------------------------------------------- |
 * | $fl_thickness    | Parameter | Used during FL_CUTOUT (see also fl_parm_thickness())  |
 * | $fl_tolerance    | Parameter | Used during FL_FOOTPRINT (see fl_parm_tolerance())    |
 */
module fl_jnt_joint(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  this,
  /*!
   * optional fillet radius.
   *
   * - undef  ⇒ auto calculated radius respecting build constrains
   * - 0      ⇒ no fillet
   * - scalar ⇒ client defined radius value
   *
   * TODO: to be moved among fl_jnt_joint{} parameters since this parameter
   * doesn't modify the object bounding box.
   */
  fillet,
  //! translation applied to cutout
  cut_drift=0,
  /*!
   * FL_CUTOUT direction list, if undef then the preferred cutout direction
   * attribute is used.
   */
  cut_dirs,
  //! clearance used by FL_CUTOUT
  cut_clearance=0,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction
) {

  // YZ section resize
  function resizeYZ(radii,delta) = let(
    resize  = function(i,delta) let(p=radii[i]) [p.x+delta.x,p.y+delta.y,p[2]]
  ) [
    resize(0, [-delta, -delta ]), // G
    resize(1, [-delta, -delta ]), // H
    resize(2, [+delta, -delta ]), // A
    // resize(3, [+delta, -delta ]), // B
    resize(3, [+delta, +delta ]), // C
    resize(4, [-delta, +delta ]), // D
    resize(5, [-delta, +delta ]), // E
    resize(6, [-delta, -delta ])  // F
  ];

  // front section resize
  function resizeXZ(radii,delta) = let(
    resize  = function(i,delta) let(p=radii[i]) [p.x+delta.x,p.y+delta.y,p[2]]
  ) [
    resize(0, [-delta, +delta]),
    resize(1, [-delta, -delta]),
    resize(2, [-delta, -delta]),
    resize(3, [+delta, -delta]),
    resize(4, [+delta, -delta]),
    resize(5, [+delta, +delta]),
  ];

  engine        = fl_engine(this);
  preferred_co  = fl_cutout(this);
  cut_dirs      = cut_dirs ? cut_dirs : preferred_co;

  // Other specific attributes are retrieved by the relevant engine
  sectionYZ = fl_property(this,str(FL_JNT_CANTILEVER_NS,"/section YZ"     ));
  h         = fl_property(this,str(FL_JNT_SECTION_NS,   "/h"              ));
  arm       = fl_property(this,str(FL_JNT_SECTION_NS,   "/arm"            ));
  undercut  = fl_property(this,str(FL_JNT_SECTION_NS,   "/undercut"       ));
  tooth     = fl_property(this,str(FL_JNT_SECTION_NS,   "/tooth"          ));
  length    = arm+tooth;
  fillet    = is_undef(fillet) ? min(undercut/4,0.6*h[0]) : fillet;
  dims      = fl_dimensions(this);

  debug_enabled = fl_dbg_symbols() || fl_dbg_labels();

  /*
   * Returns the quadrilateral exactly delimiting the fillet section on the
   * (eventually oblique) side AB. The fillet section will be actually defined
   * subtracting the tangent circumference with center C and radius fillet.
   *
   * Polygon points returned:
   *
   * - A: third point of the YZ cantilever section
   * - F: intersection between line x=C.x and y=A.y
   * - C: center of the circumference
   * - G: intersection between AB and the line crossing C and ⟂ to AB
   *
   * NOTE: see also [snap-fit thread](https://www.geogebra.org/m/mnyer5yq)
   */
  function AFCG() = let(
    A         = let(p=sectionYZ[2]) [p.x,p.y],
    // actually is now the section point C, but nothing changes for the
    // algorithm since section points A,B and C are all aligned.
    B         = let(p=sectionYZ[3]) [p.x,p.y],
    // line AB
    r_ab      = fl_2d_Line(A,B),
    // line y=C.y
    q         = [0,1,-A.y-fillet],
    beta      = fl_2d_slopeAngle(A,B),
    // line crossing A with half slope of the line AB
    bisect    = let(m=tan(beta/2)) [-m,1,-A.y+m*A.x],
    C         = fl_2d_intersection(bisect,q),
    // G: intersection between line crossing C and ⟂ r_ab and r_ab
    G = let(
      a = r_ab[0],b=r_ab[1],c=r_ab[2],m=-a/b,
      x = b ? -(b*C.x+b*m*C.y+c*m)/(a*m-b) : -c/a,
      y = b ? (-x+C.x+m*C.y)/m : C.y
    )  [x,y],
    // F: intersection between line x=C.x and y=A.y
    F = [C.x,A.y]
  ) [A,F,C,G];

  // execution context set by fl_vmanage{}
  module engine()
    echo(str("R<",min(0.6*h[0],undercut)))
    if (engine==str(FL_JNT_CANTILEVER_NS,"/rect"))
      rect_engine()
        children();
    else
      assert(engine==str(FL_JNT_CANTILEVER_NS,"/ring"),engine)
      ring_engine()
        children();

  module opt_debug()
    if (debug_enabled)
      #children();
    else
      children();

  module rect_engine() {
    sectionXZ = fl_property(this,str(FL_JNT_CANTILEVER_NS,"/section XZ" ));
    b         = fl_property(this,str(FL_JNT_CANTILEVER_NS,  "/b"        ));

    module tolerant_extrude(length,tolerance) let(
      // centering to the symmetry Y-axis
      post = T(-X(length/2+tolerance))
    ) multmatrix(post)
        fl_linear_extrude(direction=[+X,90], length=length+2*tolerance)
          children();

    module do_add(fillet,tolerance) {
      opt_debug() {
        let(
          // radii points
          sectionYZ = tolerance ? resizeYZ(sectionYZ,tolerance) : sectionYZ,
          sectionXZ = tolerance ? resizeXZ(sectionXZ,tolerance) : sectionXZ,
          AFCG      = AFCG(),
          C         = AFCG[2]
        ) intersection() {
          tolerant_extrude(length=b[0], tolerance=tolerance) {
            polygon(fl_2d_polyRound(sectionYZ,fn=$fn));
            if (fillet) {
              // fillet on Y<0 half-plane
              translate([-tolerance,-(arm+tolerance)])
                difference() {
                  fl_square(size=fillet,quadrant=-X+Y);
                  fl_circle(r=fillet,quadrant=-X+Y);
                }
              // fillet on Y>0 half-plane
              translate([+tolerance,-tolerance])
                difference() {
                  polygon(AFCG);
                  translate([C.x,C.y])
                    fl_circle(r=fillet);
                }
            }
          }
          if (b[0]!=b[1])
            translate(-Y(undercut+tolerance))
              fl_linear_extrude(direction=[+Y,180], length=h[0]+fillet*2+undercut+2*tolerance)
                polygon(polyRound(sectionXZ,fn=$fn));
        }
      }
    }

    module do_footprint(fillet,tolerance)
      do_add(fillet=fillet,tolerance=tolerance,$FL_ADD=$FL_FOOTPRINT);

    module do_cutout(clearance) {
      fl_cutoutLoop(cut_dirs, fl_cutout(this))
        if ($co_preferred) {
          // arm
          translate(-Z(length+clearance))
            translate(-Z(cut_drift))
              fl_new_cutout($this_bbox,$co_current,drift=cut_drift,trim=Z(arm),$fl_tolerance=clearance,$fl_thickness=cut_drift+$fl_thickness+length+2*clearance)
                do_footprint(fillet=0,tolerance=clearance,$FL_FOOTPRINT=$FL_CUTOUT);
          // hook
          translate(-Z(tooth+clearance))
            fl_new_cutout($this_bbox,$co_current,drift=cut_drift,trim=-Z(roundness(undercut)),$fl_tolerance=clearance,$fl_thickness=$fl_thickness+tooth+2*clearance)
              do_footprint(fillet=0,tolerance=clearance,$FL_FOOTPRINT=$FL_CUTOUT);
        } else
          fl_new_cutout($this_bbox,$co_current,drift=cut_drift)
            do_footprint($FL_FOOTPRINT=$FL_CUTOUT);
    }

    if ($this_verb==FL_ADD) {
      do_add(fillet=fillet,tolerance=0);
      let(
        curr_view     = fl_currentView(),
        3d_sectionYZ  = [for(p=sectionYZ) fl_transform(fl_direction([+X,90]),[p.x,p.y,0])],
        3d_sectionXZ  = [for(p=sectionXZ) fl_transform(fl_direction([-Y,0]),[p.x,p.y,0])]
      ) {
        if (fl_dbg_symbols()) {
          fl_3d_polyhedronSymbols(3d_sectionYZ, 0.1,"silver");
          fl_3d_polyhedronSymbols(3d_sectionXZ, 0.1,"gold");
        }
        if (fl_dbg_labels()) {
          fl_3d_polyhedronLabels(3d_sectionYZ,0.1,"S");
          fl_3d_polyhedronLabels(3d_sectionXZ,0.1,"F");
        }
      }

      if (fl_dbg_dimensions()) let(
          $dim_object = this,
          $dim_width  = $dim_width ? $dim_width : 0.05
        ) {
          let($dim_view="right") {
            let($dim_distr="h+") {
              fl_dimension(geometry=fl_property(dims,"arm"),        align="negative");
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
            let($dim_distr="h+") {
              fl_dimension(geometry=fl_property(dims,"arm"),        align="negative");
              fl_dimension(geometry=fl_property(dims,"tooth"),    align="positive");
            }
            let($dim_distr="v+")
              fl_dimension(geometry=fl_property(dims,"b[1]"));
            let($dim_distr="v-")
              fl_dimension(geometry=fl_property(dims,"b[0]"));
          }
      }

    } else if ($this_verb==FL_FOOTPRINT) {
      do_footprint(fillet=fillet,tolerance=$fl_tolerance);

    } else if ($this_verb==FL_BBOX)
      fl_bb_add(corners=$this_bbox,auto=true,$FL_ADD=$FL_BBOX);

    else if ($this_verb==FL_CUTOUT)
      do_cutout(cut_clearance);

    else
      fl_error(["unimplemented verb",$this_verb]);
  }

  module ring_engine() {
    theta   = fl_property(this,str(FL_JNT_RING_NS,"/theta"));
    r2      = fl_property(this,str(FL_JNT_RING_NS,"/arm r"));
    r1      = r2-h[0];  // internal radius

    /*
     * theta increment re-calculation: needed only if applying tolerance
     * to «theta»: IS IT REALLY NEEDED?
     */
    function theta_delta(tolerance,radius) = 2*asin(tolerance/2/radius);

    module tolerant_extrude(angle,radius,tolerance) let(
      delta = assert(!is_undef(tolerance)) theta_delta(tolerance, radius),
      // centering to the symmetry Y-axis
      post  = Rz(+90-angle/2)
    ) multmatrix(post)
        rotate(-delta,Z)
          rotate_extrude(angle=angle+2*delta)
            children();

    /*
     * we could exactly apply the same do_cutout{} module as for the rect
     * engine, but this is faster.
     */
    module do_cutout(clearance) {
      fl_cutoutLoop(cut_dirs, fl_cutout(this))
        if ($co_preferred) {
          // arm
          translate(-Z(arm+clearance))
            linear_extrude(height=length+2*clearance+$fl_thickness) let(
              delta = theta_delta(clearance, r2),
              theta = theta + 2*delta
            ) fl_sector(
                r       = r2+clearance,
                angles  = [-90-theta/2,-90+theta/2],
                $FL_ADD = $FL_CUTOUT
              );
          // hook
          translate(-Z(tooth+clearance))
            fl_new_cutout(
              $this_bbox,
              $co_current,
              drift=cut_drift,
              trim=-Z(roundness(undercut)),
              $fl_thickness=$fl_thickness+tooth+2*clearance,
              $fl_tolerance=clearance
            ) do_footprint(fillet=0,tolerance=0,$FL_FOOTPRINT=$FL_CUTOUT);
        } else
          fl_new_cutout($this_bbox,$co_current,drift=cut_drift)
            do_footprint(fillet=0,tolerance=clearance,$FL_FOOTPRINT=$FL_CUTOUT);
    }

    module do_add(fillet,tolerance) {
      opt_debug() let(
        // radii points
        sectionYZ = tolerance ? resizeYZ(sectionYZ,tolerance) : sectionYZ,
        AFCG      = AFCG(),
        C         = AFCG[2]
      ) tolerant_extrude(angle=theta,radius=r2,tolerance=tolerance) {
        polygon(fl_2d_polyRound(sectionYZ,fn=$fn));
        if (fillet) {
          // fillet on Y<-r2 half-plane
          translate([-(tolerance+r2),-(arm+tolerance)])
            difference() {
              fl_square(size=fillet,quadrant=-X+Y);
              fl_circle(r=fillet,quadrant=-X+Y);
            }
          // fillet on Y>-r2 half-plane
          translate([+tolerance,-tolerance])
            difference() {
              polygon(AFCG);
              translate(C)
                fl_circle(r=fillet);
            }
        }
      }
    }

    module do_footprint(fillet,tolerance)
      do_add(fillet=fillet, tolerance=tolerance, $FL_ADD=$FL_FOOTPRINT);

    if ($this_verb==FL_ADD) {
      do_add(fillet=fillet,tolerance=0);
      curr_view     = fl_currentView();
      3d_sectionYZ  = [for(p=sectionYZ) fl_transform(fl_direction([+X,90]),[p.x,p.y,0])];
      let(
        curr_view     = fl_currentView(),
        3d_sectionYZ  = [for(p=sectionYZ) fl_transform(fl_direction([+X,90]),[p.x,p.y,0])]
      ) {
        if (fl_dbg_symbols())
          fl_3d_polyhedronSymbols(3d_sectionYZ, 0.1,"silver");
        if (fl_dbg_labels())
          fl_3d_polyhedronLabels(3d_sectionYZ,0.1,"S");
      }

      // dimensions are suspended for the ring engine since there are problems
      // with asymmetrical bounding boxes.
      // TODO: fix dimension lines when applied to asymmetrical bounding boxes
      // if (fl_dbg_dimensions()) let(
      //     $dim_object = this,
      //     $dim_width  = $dim_width ? $dim_width : 0.05
      //   ) {
      // }

    } else if ($this_verb==FL_BBOX)
      fl_bb_add(corners=$this_bbox,auto=true,$FL_ADD=$FL_BBOX);

    else if ($this_verb==FL_CUTOUT) {
      do_cutout(cut_clearance);

    } else if ($this_verb==FL_FOOTPRINT) {
      do_footprint(fillet=fillet,tolerance=$fl_tolerance);

    } else
      fl_error(["unimplemented verb",$this_verb]);
  }

  // fl_vmanage() manages standard parameters and prepares the execution
  // context for the engine.
  fl_vmanage(verbs,this,octant=octant,direction=direction)
    engine()
      children();
}
