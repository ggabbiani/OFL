/*!
 * 2D primitives.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <unsafe_defs.scad>

use <mngm-engine.scad>
use <bbox-engine.scad>

include <../../ext/Round-Anything/polyround.scad>

/*!
 * polyRound() wrapper.
 *
 * Context variables:
 *
 * | Name             | Context   | Description                                         |
 * | ---------------- | --------- | --------------------------------------------------- |
 * | $fl_polyround    | Parameter | when true polyRound() is called, otherwise radiipoints are transformed in normal 2d points ready for polygon() |
 */
function fl_2d_polyRound(radiipoints,fn=5,mode=0) =
  $fl_polyround ? polyRound(radiipoints,fn,mode) : [for(p=radiipoints) [p.x,p.y]] ;

/*!
 * High-level (OFL 'objects' only) verb-driven OFL API management for
 * two-dimension spaces.
 *
 * It does pretty much the same things like fl_2d_vloop{} but with a different
 * interface and enriching the children context with new context variables.
 *
 * **Usage:**
 *
 *     // An OFL object is a list of [key,values] items
 *     object = fl_Object(...);
 *
 *     ...
 *
 *     // this engine is called once for every verb passed to module fl_vmanage
 *     module engine() let(
 *       ...
 *     ) if ($this_verb==FL_ADD)
 *       ...;
 *
 *       else if ($this_verb==FL_BBOX)
 *       ...;
 *
 *       else if ($this_verb==FL_CUTOUT)
 *       ...;
 *
 *       else if ($this_verb==FL_DRILL)
 *       ...;
 *
 *       else if ($this_verb==FL_LAYOUT)
 *       ...;
 *
 *       else if ($this_verb==FL_MOUNT)
 *       ...;
 *
 *       else
 *         fl_error(["unimplemented verb",$this_verb]);
 *
 *     ...
 *
 *     fl_2d_vmanage(verbs,object,octant=octant,direction=direction)
 *       engine(thick=T)
 *         // child passed to engine for further manipulation (ex. during FL_LAYOUT)
 *         fl_circle(...);
 *
 * Context variables:
 *
 * | Name             | Context   | Description                                         |
 * | ---------------- | --------- | --------------------------------------------------- |
 * |                  | Children  | see fl_generic_vmanage{} Children context                     |
 */
module fl_2d_vmanage(
  verbs,
  this,
  //! when undef native positioning is used
  quadrant
) {
  fl_generic_vmanage(
    verbs,
    this,
    positioning = quadrant,
    m           = function(quadrant,bbox) fl_octant(octant,this),
    d           = function(direction)     fl_direction(direction)
  ) {
    children();
    fl_axes(size=1.2*$this_size);
  }
}

/*!
 * Low-level verb-driven OFL API management.
 *
 * Two-dimensional steps:
 *
 * 1. verb looping
 * 2. quadrant translation
 *
 * **1. Verb looping:**
 *
 * Each passed verb triggers in turn the children modules with an execution
 * context describing:
 *
 * - the verb actually triggered;
 * - the OpenSCAD character modifier descriptor (see also [OpenSCAD User Manual/Modifier
 *   Characters](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Modifier_Characters))
 *
 * Verb list like `[FL_ADD, FL_DRILL]` will loop children modules two times,
 * once for the FL_ADD implementation and once for the FL_DRILL.
 *
 * The only exception to this is the FL_AXES verb, that needs to be executed
 * outside the canonical transformation pipeline (without applying «quadrant» translations).
 * FL_AXES implementation - when passed in the verb list - is provided
 * automatically by the library.
 *
 * So a verb list like `[FL_ADD, FL_AXES, FL_DRILL]` will trigger the children
 * modules twice: once for FL_ADD and once for FL_DRILL. OFL will trigger an
 * internal FL_AXES 2d implementation.
 *
 * **2. Quadrant translation**
 *
 * A coordinate system divides two-dimensional spaces in four
 * [quadrants](https://en.wikipedia.org/wiki/Quadrant_(plane_geometry)).
 *
 * Using the bounding-box information provided by the 2d «bbox» parameter, we
 * can fit the shapes defined by children modules exactly in one quadrant.
 *
 * Context variables:
 *
 * | Name       | Context   | Description
 * | ---------- | --------- | ---------------------
 * |            | Children  | see fl_generic_vloop{} context variables
 */
module fl_2d_vloop(
  //! verb list
  verbs,
  //! mandatory bounding box
  bbox,
  //! when undef native positioning is used
  quadrant
) {
  $this_quadrant  = quadrant;
  fl_generic_vloop(
    verbs,
    bbox,
    M = fl_quadrant(quadrant, bbox=bbox)
  ) {
    children();
    fl_axes(size=let(size=bbox[1]-bbox[0]) assert(len(size)==2) 1.2*[size.x,size.y]);
  }
}

//! returns the angle between vector «a» and «b»
function fl_2d_angleBetween(a,b) = atan2(b.y,b.x)-atan2(a.y,a.x);;

/*!
 * Returns the bisector of the angle formed by lines «line1» and «line2».
 *
 * The resulting line is in standard form ax+by+c=0 ⇒[a,b,c]
 */
function fl_2d_bisector(line1,line2) = let(
  a1    = line1[0], b1 = line1[1], c1=line1[2],
  a2    = line2[0], b2 = line2[1], c2=line2[2],
  a     = a1*sqrt(a2*a2+b2*b2)+a2*sqrt(a1*a1+b1*b1),
  b     = b1*sqrt(a2*a2+b2*b2)+b2*sqrt(a1*a1+b1*b1),
  c     = c1*sqrt(a2*a2+b2*b2)+c2*sqrt(a1*a1+b1*b1)
) [a,b,c];

/*!
 * line constructor, result in standard form ax+by+c=0.
 *
 * Example 1: line from two points A and B
 *
 *     line = fl_2d_Line(A,B);
 *
 * Example 2: line from one point P and slope m
 *
 *     line = fl_2d_Line(P,m=m);
 *
 * Example 3: vertical line x=k
 *
 *     line = fl_2d_Line(x=k);
 *
 * Example 4: horizontal line y=q
 *
 *     line = fl_2d_Line(y=q);
 */
function fl_2d_Line(A,B,m,x,y) =
  A && B && is_undef(m) ? [ +A.y-B.y, +B.x-A.x, +A.x*B.y-B.x*A.y  ]:
  A && is_undef(B) && m ? [ -m,       +1,       -A.y+m*A.x        ]:
  is_num(x)             ? [ +1,        0,       -x                ]:
  assert(is_num(y),y)     [  0,       +1,       -y                ];

//! canonical circle centered in «C» with radius «r»
/*!
 * Circle constructor, result in canonical form x^2+y^2+ax+by+c=0 ⇒[1,1,a,b,c].
 *
 * Example: circle with center in point C and radius r
 *
 *     circle = fl_2d_Circle(C,B);
 */
function fl_2d_Circo(C,r) = let(
  a=-2*C.x,b=-2*C.y,c=C.x*C.x+C.y*C.y-r*r
) [1,1,a,b,c];

/*!
 * Returns the line slope.
 *
 * Example 1: slope of a line in standard form
 *
 *     slope = fl_2d_slope(line=[a,b,c]);
 *
 * Example 2: slope angle of the line crossing two points A and B
 *
 *     slope = fl_2d_slope(A,B);
 */
function fl_2d_slope(
  //! two points crossed by the line
  A,B,
  //! line in standard form ax+by+c=0
  line,
) =
  line ?
    let(a=line[0],b=line[1],c=line[2])    -a/b :
    assert(!is_undef(A) && !is_undef(B))   (B.y-A.y)/(B.x-A.x);

/*!
  * Returns the angle formed by the positive X semi-axis and the part of
  * «line» lying in the upper half-plane.
  *
  * Example 1: slope angle of a line in standard form
  *
  *     angle = fl_2d_slopeAngle(line=[a,b,c]);
  *
  * Example 2: slope angle of the line crossing two points A and B
  *
  *     angle = fl_2d_slopeAngle(A,B);
  */
function fl_2d_slopeAngle(
  //! two points crossed by the line
  A,B,
  //! line in standard form
  line
) = let(
  line  = line ? line : fl_2d_Line(A,B)
) let(a=line[0],b=line[1],c=line[2]) atan2(-a,b);

/*!
 * Intersection point between «line» and «line2» or between «line» and «circle».
 *
 * NOTE: in case of intersection between a first grade equation (line1) and a
 * quadratic one (circle) the result can be a single 2d point or a list of two
 * points depending if line is tangential or not to the circle.
 */
function fl_2d_intersection(
    //! line in standard form ax+by+c=0 ⇒[a,b,c]
  line,
    //! line in standard form ax+by+c=0 ⇒[a,b,c]
  line2,
  //! circumference in canonical form X^2+y^2+ax+by+c=0 ⇒[1,1,a,b,c]
  circle
) = let(
  ll  = function(line1,line2)
    let(
      a1      = line1[0], b1 = line1[1], c1=line1[2],
      a2      = line2[0], b2 = line2[1], c2=line2[2],
      delta   = +a1*b2-a2*b1,
      delta_x = -c1*b2+c2*b1,
      delta_y = -a1*c2+a2*c1
    ) [delta_x,delta_y]/delta,
  lc  = function (line,circle)
    let(
      a = line[0],     b=line[1],         c=line[2],
      d = circle[2],    e=circle[3],        f=circle[4],
      A = (a*a+b*b)/b,  B=(2*a*c+b*d-a*e),  C=(c*c-b*c*e+b*b*f)/b,
      x = fl_quadraticSolve(A,B,C), y=is_num(x)?-(a*x+c)/b:[-(a*x[0]+c)/b,-(a*x[1]+c)/b]
    ) is_num(x) ? [x,y] : [[x[0],y[0]],[x[1],y[1]]]
) line && line2 ? ll(line,line2) : assert(line && circle) lc(line,circle);

//**** 2d bounding box calculations *******************************************

/*!
 * Returns the bounding box of a 2d polygon.
 * See also 3d counter-part function fl_bb_polyhedron().
 */
function fl_bb_polygon(
  /*!
   * list of x,y points of the polygon to be used with
   * [polygon](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_the_2D_Subsystem#polygon)
   *
   * **NOTE**: even if safe to be used for 3d points, the result will be
   * a 2d bounding box.
   */
  points
) = let(
  x = [for(p=points) p.x],
  y = [for(p=points) p.y]
) [[min(x),min(y)],[max(x),max(y)]];

/*!
 * Calculates the exact bounding box of a polygon inscribed in a circumference.
 * See also fl_bb_polygon().
 *
 * __NOTE:__ «r» and «d» are mutually exclusive.
 */
function fl_bb_ipoly(
  //! radius of the circumference
  r,
  //! diameter of the circumference
  d,
  //! number of edges for the inscribed polygon
  n) = let(
  radius  = r!=undef ? r : d
) assert(is_num(radius),str("radius=",radius)) fl_bb_polygon(fl_circle(r=radius,$fn=n));

//! Returns the exact bounding box of a sector.
function fl_bb_sector(
  //! radius of the sector
  r = 1,
  //! diameter of the sector
  d,
  /*!
   * list containing the start and ending angles for the sector.
   *
   * __NOTE:__ the provided angles are always reduced in the form [inf,sup] with:
   *
   *     sup ≥ inf
   *     distance = sup - inf
   *       0° ≤ distance ≤ +360°
   *       0° ≤   inf    < +360°
   *       0° ≤   sup    < +720°
   */
  angles
) = let(
  radius    = d!=undef ? d/2 : r,
  interval  = __normalize__(angles),
  inf       = interval[0],
  sup       = interval[1],
  start     = ceil(inf / 90), // 0 ≤ start ≤ 3
  pts = [
    if ((sup-inf)<360) [0,0],                                                           // origin added
    if (inf%90!=0) let(alpha=inf)                           fl_circleXY(radius,alpha),  // inferior interval added
    for(i=[start:start+3]) let(alpha=i*90) if (alpha<=sup)  fl_circleXY(radius,alpha),  //
    if (sup%90!=0) let(alpha=sup)                           fl_circleXY(radius,alpha)   // superior interval added
  ]
) assert(is_num(radius),str("radius=",radius)) fl_bb_polygon(pts);

//! exact circle bounding box
function fl_bb_circle(r=1,d) = let(
  radius  = d!=undef ? d/2 : r
) assert(is_num(radius),str("radius=",radius)) [[-radius,-radius],[+radius,+radius]];

//! exact arc bounding box
function fl_bb_arc(r=1,d,angles,thick) =
  assert(is_list(angles),angles)
  let(
    radius    = d!=undef ? d/2 : r,
    interval  = __normalize__(angles),
    inf       = interval[0],
    sup       = interval[1],
    start     = ceil(inf / 90),  // 0 <= start <= 3
    radius_int    =
      assert(is_num(radius),radius)
      assert(is_num(thick),thick)
      assert(thick<radius,str("thick=",thick,",radius=",radius))
      radius-thick,
    pts = [
      if (inf%90!=0)
        for(r=[radius_int,radius])
          fl_circleXY(r,inf),
      for(alpha=[90*start:90:90*(start+3)])
        if (alpha<=sup)
          for(r=[radius_int,radius])
            fl_circleXY(r,alpha),
      if (sup%90!=0)
        for(r=[radius_int,radius])
          fl_circleXY(r,sup),
    ]
  ) fl_bb_polygon(pts);

//**** sector *****************************************************************

/*!
 * reduces an angular interval in the form [inf,sup] with:
 * sup ≥ inf
 * distance = sup - inf
 *   0° ≤ distance ≤ +360°
 *   0° ≤   inf    < +360°
 *   0° ≤   sup    < +720°
 */
function __normalize__(angles) =
  assert(is_list(angles),str("angles=",angles))
  let(
    sorted    = [min(angles),max(angles)],
    d         = sorted[1] - sorted[0],          // d ≥ 0°
    distance  = d>360 ? 360 : d,                // 0° ≤ distance ≤ +360°
    inf       = (sorted[0] % 360 + 360) % 360   // 0° ≤   inf    < +360°
  )
  assert(d>=0)
  assert(distance>=0 && distance<=360)
  assert(inf>=0 && inf<360)
  [inf,inf+distance];

function fl_sector(
  r=1,
  d,
  /*!
   * list containing the start and ending angles for the sector.
   *
   * __NOTE:__ the provided angles are always reduced in the form [inf,sup] with:
   *
   *     sup ≥ inf
   *     distance = sup - inf
   *       0° ≤ distance ≤ +360°
   *       0° ≤   inf    < +360°
   *       0° ≤   sup    < +720°
   */
  angles
) = let(
  radius  = d!=undef ? d/2 : r
) assert(is_num(radius),str("radius=",radius))
  assert(is_list(angles),str("angles=",angles))
  fl_ellipticSector(e=[radius,radius],angles=angles);

module fl_sector(
  verbs = FL_ADD,
  r     = 1,
  d,
  /*!
   * list containing the start and ending angles for the sector.
   *
   * __NOTE:__ the provided angles are always reduced in the form [inf,sup] with:
   *
   *     sup ≥ inf
   *     distance = sup - inf
   *       0° ≤ distance ≤ +360°
   *       0° ≤   inf    < +360°
   *       0° ≤   sup    < +720°
   */
  angles,
  quadrant
) {
  assert(is_list(angles),str("angles=",angles));

  radius  = d!=undef ? d/2 : r; assert(is_num(radius),str("radius=",radius));
  points  = fl_sector(r=radius,angles=angles);
  bbox    = fl_bb_sector(r=radius,angles=angles);
  size    = bbox[1] - bbox[0];

  fl_2d_vloop(verbs,bbox,quadrant=quadrant) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) polygon(points);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) translate(bbox[0]) square(size=size, center=false);

    } else {
      fl_error(["unimplemented verb",$this_verb]);
    }
  }
}

//**** elliptic sector ********************************************************

//! Exact elliptic sector bounding box
function fl_bb_ellipticSector(
  //! ellipse in [a,b] form
  e,
  /*!
   * list containing the start and ending angles for the sector.
   *
   * __NOTE:__ the provided angles are always reduced in the form [inf,sup] with:
   *
   *     sup ≥ inf
   *     distance = sup - inf
   *       0° ≤ distance ≤ +360°
   *       0° ≤   inf    < +360°
   *       0° ≤   sup    < +720°
   */
  angles
) =
  assert(len(e)==2,str("e=",e))
  assert(len(angles)==2,str("angles=",angles))
  let(
    a = e[0],
    b = e[1],
    angles    = __normalize__(angles),
    inf       = angles[0],
    sup       = angles[1],
    start     = ceil(inf / 90), // 0 ≤ start ≤ 3
    pts =  /* assert(start>=0 && start<=3,start)  */[
      if ((sup-inf)<360) [0,0],
      if (inf%90!=0) let(alpha=inf)                           fl_ellipseXY(e,angle=alpha),
      for(i=[start:start+3]) let(alpha=i*90) if (alpha<=sup)  fl_ellipseXY(e,angle=alpha),
      if (sup%90!=0) let(alpha=sup)                           fl_ellipseXY(e,angle=alpha)
    ]
  ) fl_bb_polygon(pts);

function __frags__(perimeter) =
  $fn == 0
    ?  max(min(360 / $fa, perimeter / $fs), 5)
    :  $fn >= 3 ? $fn : 3;

/*!
 * line to line intersection as from [Line–line intersection](https://en.wikipedia.org/wiki/Line-line_intersection)
 */
function fl_intersection(
  //! first line in [P0,P1] format
  line1,
  //! second line in [P0,P1] format
  line2,
  //! solution valid if inside segment 1
  in1     = true,
  //! solution valid if inside segment 2
  in2     = true
) = let(
  x1  = line1[0].x,
  y1  = line1[0].y,
  x2  = line1[1].x,
  y2  = line1[1].y,
  x3  = line2[0].x,
  y3  = line2[0].y,
  x4  = line2[1].x,
  y4  = line2[1].y,
  D   = (x1-x2)*(y3-y4)-(y1-y2)*(x3-x4),

  t = ((x1-x3)*(y3-y4)-(y1-y3)*(x3-x4))/D,
  u = ((x1-x3)*(y1-y2)-(y1-y3)*(x1-x2))/D,
  c1  = (in1==false || (t>=0 && t<=1)),
  c2  = (in2==false || (u>=0 && u<=1))
) assert(D!=0)      // no intersection
  assert(c1,line1)  // intersection outside segment 1
  assert(c2,line2)  // intersection outside segment 2
  [x1+t*(x2-x1),y1+t*(y2-y1)];

/*!
 * Calculates the point of an elliptic sectors.
 */
function fl_ellipticSector(
  //! ellipses in [a,b] form
  e,
  /*!
   * list containing the start and ending angles for the sector.
   *
   * __NOTE:__ the provided angles are always reduced in the form [inf,sup] with:
   *
   *     sup ≥ inf
   *     distance = sup - inf
   *       0° ≤ distance ≤ +360°
   *       0° ≤   inf    < +360°
   *       0° ≤   sup    < +720°
   */
  angles
) =
  assert(is_list(e),str("e=",e))
  assert(is_list(angles),str("angles=",angles))
  let(
    O         = [0,0],
    angles    = __normalize__(angles),
    distance  = angles[1]-angles[0]
  )
  e[0]!=e[1] ?
    // ELLIPTIC COMMONS
    let(
        a     = e[0],
        b     = e[1],
        step  = 360 / __frags__(fl_ellipseP(e))
    ) distance!=360 ?
      // **********************************************************************
      // ELLIPTIC SECTOR
      let(
        t = [fl_ellipseT(e,angles[0]),fl_ellipseT(e,angles[1])],
        m = floor(angles[0] / step) + 1,
        n = floor(angles[1] / step),
        M = floor(t[0]/step) + 1,
        N = floor(t[1]/step),
        // FIRST AND LAST POINTS ARE CALCULATED IN POLAR FORM
        first = let(
            ray   = [O,fl_ellipseXY(e,angle=angles[0])],
            edge  = [fl_ellipseXY(e,angle=(m-1)*step),fl_ellipseXY(e,angle=m*step)]
          ) fl_intersection(ray,edge),
        last  = let(
            ray   = [O,fl_ellipseXY(e,angle=angles[1])],
            edge  = [fl_ellipseXY(e,angle=n*step),fl_ellipseXY(e,angle=(n+1)*step)]
          ) fl_intersection(ray,edge),
        pts   = concat(
          // origin «O» and point «first» included only if angular distance <360°
          (distance<360) ? [O, first] : [],
          // INFRA POINTS ARE CALCULATED IN PARAMETRIC «T» FORM
          M > N ? [] : [
            for(i = M; i <= N; i = i + 1)
              fl_ellipseXY(e,t=step * i)
          ],
          angles[1]==step * n ? [] : [last]
        )
      ) pts
      // **********************************************************************
      // ELLIPSE
      : let(
        angles  = [0,360],
        m     = floor(angles[0] / step) + 1,
        n     = floor(angles[1] / step),
        // FIRST AND LAST POINTS ARE CALCULATED IN POLAR FORM
        first = let(
            ray   = [O,fl_ellipseXY(e,angle=angles[0])],
            edge  = [fl_ellipseXY(e,angle=(m-1)*step),fl_ellipseXY(e,angle=m*step)]
          ) fl_intersection(ray,edge),
        last  = let(
            ray   = [O,fl_ellipseXY(e,angle=angles[1])],
            edge  = [fl_ellipseXY(e,angle=n*step),fl_ellipseXY(e,angle=(n+1)*step)]
          ) fl_intersection(ray,edge),
        pts   = concat(
          // origin «O» and point «first» included only if angular distance <360°
          ((angles[1]-angles[0])<360) ? [O, first] : [],
          // INFRA POINTS ARE CALCULATED IN PARAMETRIC «T» FORM
          m > n ? [] : [
            for(i = m; i <= n; i = i + 1)
              fl_ellipseXY(e,t=step * i)
          ],
          angles[1]==step * n ? [] : [last]
        )
      ) pts
  :
  // CIRCLE OPTIMIZATIONS
  let(
    r     = e[0],
    step  = 360 / __frags__(2*PI*r)
  ) distance!=360 ?
    // ************************************************************************
    // CIRCULAR SECTOR
    let(
      m     = floor(angles[0] / step) + 1,
      n     = floor(angles[1] / step),
      // FIRST AND LAST POINTS ARE CALCULATED IN POLAR FORM
      first = let(
          ray   = [O,fl_circleXY(r,angles[0])],
          edge  = [fl_circleXY(r,(m-1)*step),fl_circleXY(r,m*step)]
        ) fl_intersection(ray,edge),
      last  = let(
          ray   = [O,fl_circleXY(r,angles[1])],
          edge  = [fl_circleXY(r,n*step),fl_circleXY(r,(n+1)*step)]
        ) fl_intersection(ray,edge),
      pts   = concat(
        // origin «O» and point «first» included only if angular distance <360°
        (distance<360) ? [O, first] : [],
        // INFRA POINTS
        m > n ? [] : [
          for(i = m; i <= n; i = i + 1)
            fl_circleXY(r,step * i)
        ],
        angles[1]==step * n ? [] : [last]
      )
    ) pts
  : // ************************************************************************
    // CIRCLE
    let(
      n     = floor(360 / step),
      pts   = [for(i = 1; i <= n; i = i + 1) fl_circleXY(r,step * i)]
    ) pts;

module fl_ellipticSector(
  //! supported verbs: FL_ADD, FL_AXES, FL_BBOX
  verbs     = FL_ADD,
  /*!
   * ellipse in [a,b] form with
   *
   * - a: length of the X semi-axis
   * - b: length of the Y semi-axis
   */
  e,
  /*!
   * list containing the start and ending angles for the sector.
   *
   * __NOTE:__ the provided angles are always reduced in the form [inf,sup] with:
   *
   *     sup ≥ inf
   *     distance = sup - inf
   *       0° ≤ distance ≤ +360°
   *       0° ≤   inf    < +360°
   *       0° ≤   sup    < +720°
   */
  angles,
  quadrant
) {
  assert(e!=undef && angles!=undef);
  a     = e[0];
  b     = e[1];
  bbox  = fl_bb_ellipticSector(e,angles);
  size  = bbox[1]-bbox[0];

  fl_2d_vloop(verbs,bbox,quadrant=quadrant) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) polygon(fl_ellipticSector(e,angles));
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) translate(bbox[0]) square(size=size, center=false);
    } else {
      fl_error(["unimplemented verb",$this_verb]);
    }
  }
}

//**** elliptic arc ***********************************************************

//! Exact elliptic arc bounding box
function fl_bb_ellipticArc(
  /*!
   * outer ellipse in [a,b] form with
   *
   * - a: length of the X semi-axis
   * - b: length of the Y semi-axis
   */
  e,
  /*!
   * list containing the start and ending angles for the sector.
   *
   * __NOTE:__ the provided angles are always reduced in the form [inf,sup] with:
   *
   *     sup ≥ inf
   *     distance = sup - inf
   *       0° ≤ distance ≤ +360°
   *       0° ≤   inf    < +360°
   *       0° ≤   sup    < +720°
   */
  angles,
  //! subtracted to «e» semi-axes defines the inner ellipse ones
  thick
) =
assert(is_list(e),e)
assert(is_list(angles),angles)
assert(is_num(thick) && thick<min(e),thick)
let(
  angles    = __normalize__(angles),
  inf       = angles[0],
  sup       = angles[1],
  start     = ceil(inf / 90),
  e_int     = e-[thick,thick],
  pts = [
    if (inf%90!=0)
      for(ellipse=[e_int,e])
        fl_ellipseXY(ellipse,angle=inf),
    for(alpha=[90*start:90:90*(start+3)])
      if (alpha<=sup)
        for(ellipse=[e_int,e])
          fl_ellipseXY(ellipse,angle=alpha),
    if (sup%90!=0)
      for(ellipse=[e_int,e])
        fl_ellipseXY(ellipse,angle=sup),
  ]
) fl_bb_polygon(pts);

module fl_ellipticArc(
  //! supported verbs: FL_ADD, FL_AXES, FL_BBOX
  verbs     = FL_ADD,
  /*!
   * outer ellipse in [a,b] form with
   *
   * - a: length of the X semi-axis
   * - b: length of the Y semi-axis
   */
  e,
  /*!
   * list containing the start and ending angles for the sector.
   *
   * __NOTE:__ the provided angles are always reduced in the form [inf,sup] with:
   *
   *     sup ≥ inf
   *     distance = sup - inf
   *       0° ≤ distance ≤ +360°
   *       0° ≤   inf    < +360°
   *       0° ≤   sup    < +720°
   */
  angles,
  //! subtracted to «e» semi-axes defines the inner ellipse ones
  thick,
  quadrant
) {
  assert(is_list(e),e);
  // assert(is_list(angles),angles);
  // assert(is_num(thick),thick);

  a     = e.x;
  b     = e.y;
  bbox  = fl_bb_ellipticArc(e,angles,thick);
  size  = bbox[1]-bbox[0];

  fl_2d_vloop(verbs,bbox,quadrant=quadrant) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) difference() {
        fl_ellipticSector(verbs=$verb, angles=angles, e=e);
        fl_ellipse(verbs=$verb, e=[a-thick,b-thick]);
      }
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) translate(bbox[0]) square(size=size, center=false);
    } else {
      fl_error(["unimplemented verb",$this_verb]);
    }
  }
}

//**** elliptic annulus *******************************************************

module fl_ellipticAnnulus(
  //! supported verbs: FL_ADD, FL_AXES, FL_BBOX
  verbs     = FL_ADD,
  /*!
   * outer ellipse in [a,b] form with
   *
   * - a: length of the X semi-axis
   * - b: length of the Y semi-axis
   */
  e,
  //! subtracted to outer ellipses axes defines the internal one
  thick,
  quadrant
  ) {
  fl_ellipticArc(verbs,e,[0,360],thick,quadrant);
}

//**** ellipse ****************************************************************

//! r(θ): polar equation of ellipse «e» by «θ»
function fl_ellipseR(
  /*!
   * ellipse in [a,b] form with
   *
   * - a: length of the X semi-axis
   * - b: length of the Y semi-axis
   */
  e,
  theta
) = let(
    a           = e[0],
    b           = e[1],
    b_cos_theta = b*cos(theta),
    a_sin_theta = a*sin(theta)
  ) a*b / sqrt(b_cos_theta*b_cos_theta+a_sin_theta*a_sin_theta);

/**!
 * Returns a 2d list [x,y]: rectangular value of ellipse «e» by «t»
 * (parametric) or «angle» (polar) input
 */
function fl_ellipseXY(
  /*!
   * ellipse in [a,b] form with
   *
   * - a: length of the X semi-axis
   * - b: length of the Y semi-axis
   */
  e,
  //! parametric input 0≤t<360
  t,
  //! polar input 0≤angle<360
  angle
) =
assert(is_list(e))
let(
  a           = e[0],
  b           = e[1]
) t!=undef
  ? assert(angle==undef) [a*cos(t),b*sin(t)]                        // parametric
  : assert(t==undef) fl_ellipseXY(e,t=fl_ellipseT(e,angle=angle));  // polar

//! APPROXIMATED ellipse perimeter
function fl_ellipseP(e) =
assert(e[0]>0 && e[1]>0,str("e=",e))
let(
  a = e[0],
  b = e[1],
  h = (a-b)*(a-b)/(a+b)/(a+b)
) PI*(a+b)*(1+3*h/(10+sqrt(4-3*h)));

function __clip__(inf,x,sup) = x<=inf?inf:x>=sup?sup:x;

function __ramp__(angle) = 180*floor((angle+90)/180);

function __step__(angle) = sin(angle+90)==0 ? -sign(sin(angle)) : sign(sin(angle+90));
// function __step__(angle) = sin(angle+90)>=0 ? 1 : -1;
// function __step__(angle) = sin(angle/3)==1 ? 1 : cos(angle)>=0 ? 1 : -1;

/*!
 * Converts «θ» value to the corresponding ellipse «t» parameter
 *
 * __NOTE:__ we need to extend the theoretical function beyond ±π/2 codomain,
 * for that we use __ramp__() and __step__() function accordingly.
 */
function fl_ellipseT(e,angle) =
assert(is_list(e),str("e=",e))
assert(is_num(angle),str("angle=",angle))
let(
  a     = e[0],
  b     = e[1],
  t     = asin(__clip__(-1,fl_ellipseR(e,angle)*sin(angle)/b,1)),
  ramp  = __ramp__(angle),
  step  = __step__(angle)
) ramp+step*t;

//! Exact ellipse bounding box
function fl_bb_ellipse(
  /*!
   * ellipse in [a,b] form with
   *
   * - a: length of the X semi-axis
   * - b: length of the Y semi-axis
   */
  e
) = let(a=e[0],b=e[1]) assert(is_list(e),str("e=",e)) [[-a,-b],[+a,+b]];

function fl_ellipse(
  /*!
   * ellipse in [a,b] form with
   *
   * - a: length of the X semi-axis
   * - b: length of the Y semi-axis
   */
  e
) = let(
  a=e[0],b=e[1],fa=$fa,fn=$fn,fs=$fs
  ) fl_ellipticSector([a,b],[0,360],$fa=fa,$fn=fn,$fs=fs);

module fl_ellipse(
  //! supported verbs: FL_ADD, FL_AXES, FL_BBOX
  verbs   = FL_ADD,
  /*!
   * ellipse in [a,b] form with
   *
   * - a: length of the X semi-axis
   * - b: length of the Y semi-axis
   */
  e,
  quadrant
) {
  assert(e!=undef);

  a     = e[0];
  b     = e[1];
  bbox  = fl_bb_ellipse(e);
  size  = bbox[1]-bbox[0];

  fa    = $fa;
  fn    = $fn;
  fs    = $fs;

  fl_2d_vloop(verbs,bbox,quadrant=quadrant) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) polygon(fl_ellipse(e,$fa=fa,$fn=fn,$fs=fs));
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) translate(bbox[0]) square(size=size, center=false);
    } else {
      fl_error(["unimplemented verb",$this_verb]);
    }
  }
}

//**** circle *****************************************************************

//! Rectangular value [x,y] of circle of ray «r» by «t» (parametric/polar)
function fl_circleXY(
  //! radius of the circle
  r,
  //! 0≤t<360, angle that the ray from (0,0) to (x,y) makes with +X
  t
) = r*[cos(t),sin(t)];

function fl_circle(r=1,center=[0,0]) = let(
  points  = fl_sector(r=r,angles=[0,360])
) center!=[0,0] ? [for(p=points) [p.x+center.x,p.y+center.y]] : points;

module fl_circle(
  verbs = FL_ADD,
  r,
  d,
  quadrant
) {
  radius  = r!=undef ? r : d/2; assert(is_num(radius));
  bbox    = fl_bb_circle(r=radius);
  size    = bbox[1] - bbox[0];

  fl_2d_vloop(verbs,bbox,quadrant) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) polygon(fl_circle(r=radius));
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) translate(bbox[0]) %square(size=size, center=false);
    } else {
      fl_error(["unimplemented verb",$this_verb]);
    }
  }
}

//**** annulus ****************************************************************

module fl_annulus(
  verbs     = FL_ADD,
  //! outer radius
  r,
  //! outer diameter
  d,
  //! subtracted to outer radius defines the internal one
  thick,
  quadrant
  ) {
  fl_arc(verbs,r,d,[0,360],thick,quadrant);
}

//**** arc ********************************************************************

module fl_arc(
  verbs     = FL_ADD,
  //! outer radius
  r,
  //! outer diameter
  d,
  /*!
   * list containing the start and ending angles for the sector.
   *
   * __NOTE:__ the provided angles are always reduced in the form [inf,sup] with:
   *
   *     sup ≥ inf
   *     distance = sup - inf
   *       0° ≤ distance ≤ +360°
   *       0° ≤   inf    < +360°
   *       0° ≤   sup    < +720°
   */
  angles,
  //! subtracted to radius defines the inner one
  thick,
  quadrant
  ) {
  assert(is_list(angles));
  assert(is_num(thick));

  radius  = r!=undef ? r : d/2; assert(is_num(radius));
  bbox    = fl_bb_arc(r=radius,angles=angles,thick=thick);
  size    = bbox[1] - bbox[0];
  // epsilon = 1;  // needed for eliminating edge-fighting problem

  fl_2d_vloop(verbs,bbox,quadrant=quadrant) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) difference() {
        fl_sector($verb, angles=angles, r=radius      );
        fl_circle(r=radius-thick);
      }
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) if (size.x>0 && size.y>0) translate(bbox[0]) square(size=size, center=false);
    } else {
      fl_error(["unimplemented verb",$this_verb]);
    }
  }
}

//**** inscribed polygon ******************************************************

//! Regular polygon inscribed a circumference
module fl_ipoly(
  verbs   = FL_ADD,
  //! circumscribed circle radius
  r,
  //! circumscribed circle diameter
  d,
  //! number of edges
  n,
  quadrant
) {
  assert(fl_XOR(r,d));

  radius  = r!=undef ? r : d/2; assert(is_num(radius));
  points  = fl_circle(r=radius,$fn=n);

  bbox    = fl_bb_polygon(points);
  size    = bbox[1] - bbox[0];

  fl_2d_vloop(verbs,bbox,quadrant=quadrant) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) polygon(points);
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) translate(bbox[0]) %square(size=size, center=false);
    } else {
      fl_error(["unimplemented verb",$this_verb]);
    }
  }
}

//**** square *****************************************************************

function fl_square(
  /*!
   * square size as 2d list or scalar
   */
  size      = 1,
  /*!
   * List of four values (one for each quadrant). Each of them can be passed in
   * one of the following formats:
   *
   *     [a,b]    ⇒ ellipse with semi-axis a and b
   *     scalar r ⇒ circle of radius r (or ellipse with a==b==r)
   *
   * It is also possible to use some shortcuts like the following:
   *
   *     corners=R      ⇒ corners=[R,R,R,R] == corners=[[R,R],[R,R],[R,R],[R,R]] == rounded rectangle with FOUR CIRCULAR ARCS with radius=R
   *     corners=[a,b]  ⇒ corners=[[a,b],[a,b],[a,b],[a,b]] == rounded rectangle with FOUR ELLIPTICAL ARCS with e=[a,b]
   *
   * Default
   *
   *     corners=0      ⇒ corners=[0,0,0,0] == corners=[[0,0],[0,0],[0,0],[0,0]]) == squared rectangle
   *
   * Any combination is allowed i.e.
   *
   *     corners=[r,[a,b],0,0] ⇒ corners=[[r,r],[a,b],[0,0],[0,0]] == rectangle with circular arc on quadrant I, elliptical arc on quadrant II and squared on quadrants III,IV
   */
  corners  = [0,0,0,0]
) =
  assert(is_num(corners) || len(corners)==2 || len(corners)==4)
  let(
    size = is_num(size) ? [size,size] : size,
    bbox      = [[-size.x/2,-size.y/2],[+size.x/2,+size.y/2]],
    corners  = is_num(corners) ? let(e=[corners,corners]) [e,e,e,e]                                 // same circular arc x 4
              : len(corners)==2 ? let(e=corners)            [e,e,e,e]                                 // same elliptical arc x 4
              : /*  len(corners)==4  */                      [for(v=corners) is_num(v) ? [v,v] : v],  // 4 elliptical arcs
    points    = /* echo(str("r ", r)) */ let(
        e = /* echo(str("corners ", corners)) */ (corners[0]==corners[1] && corners[1]==corners[2] && corners[2]==corners[3]) ? corners[0] : undef
      ) (e!=undef && size.x!=size.y && size.x==2*e.x && size.y==2*e.y) ? /* echo("***PERFECT CIRCLE | ELLIPSE***") */ fl_ellipse(e=e)
      : let(v1=corners[0],v2=corners[1]) assert(size.x-v1.x-v2.x>=0,"***BAD PARAMETER*** horiz semi-axes sum on corner 0 and 1 exceeds width!") // check corner[0],corner[1]
        let(v1=corners[1],v2=corners[2]) assert(size.y-v1.y-v2.y>=0,"***BAD PARAMETER*** vert semi-axes sum on corner 1 and 2 exceeds height!") // check corner[1],corner[2]
        let(v1=corners[2],v2=corners[3]) assert(size.x-v1.x-v2.x>=0,"***BAD PARAMETER*** horiz semi-axes sum on corner 2 and 3 exceeds width!") // check corner[2],corner[3]
        let(v1=corners[3],v2=corners[0]) assert(size.y-v1.y-v2.y>=0,"***BAD PARAMETER*** vert semi-axes sum on corner 3 and 0 exceeds height!") // check corner[3],corner[0]
        let(
        // quadrant I
        q1  = let(
          e = corners[0],
          M = [
            [1,0,bbox[1].x-e.x],
            [0,1,bbox[1].y-e.y],
            [0,0,1            ]
          ],
          points  = (e.x>0 && e.y>0) ? [for(p=fl_ellipticSector(e,angles=[0,90])) let(point=M*[p.x,p.y,1]) [point.x,point.y]] : [bbox[1]]
        ) /* echo(str("len(q1)=", len(points))) */ len(points)>1 ? [for(i=[1:len(points)-1]) points[i]] : points,  // we can safely remove the first point (origin)
        // quadrant II
        q2  = let(
          e = corners[1],
          M = [
            [1,0,bbox[0].x+e.x],
            [0,1,bbox[1].y-e.y],
            [0,0,1            ]
          ],
          points  = (e.x>0 && e.y>0) ? [for(p=fl_ellipticSector(e,angles=[90,180])) let(point=M*[p.x,p.y,1]) [point.x,point.y]] : [[bbox[0].x,bbox[1].y]]
        ) /* echo(str("len(q2)=", len(points))) */ len(points)>1 ? [for(i=[1:len(points)-1]) points[i]] : points,  // we can safely remove the first point (origin)
        // quadrant III
        q3  = let(
          e = corners[2],
          M = [
            [1,0,bbox[0].x+e.x],
            [0,1,bbox[0].y+e.y],
            [0,0,1            ]
          ],
          points  = (e.x>0 && e.y>0) ? [for(p=fl_ellipticSector(e,angles=[180,270])) let(point=M*[p.x,p.y,1]) [point.x,point.y]] : [bbox[0]]
        ) /* echo(str("len(q3)=", len(points))) */ len(points)>1 ? [for(i=[1:len(points)-1]) points[i]] : points,  // we can safely remove the first point (origin)
        // quadrant IV
        q4  = let(
          e = corners[3],
          M = [
            [1,0,bbox[1].x-e.x],
            [0,1,bbox[0].y+e.y],
            [0,0,1            ]
          ],
          points  = (e.x>0 && e.y>0) ? [for(p=fl_ellipticSector(e,angles=[270,360])) let(point=M*[p.x,p.y,1]) [point.x,point.y]] : [[bbox[1].x,bbox[0].y]]
        ) /* echo(str("len(q4)=", len(points))) */ len(points)>1 ? [for(i=[1:len(points)-1]) points[i]] : points  // we can safely remove the first point (origin)
      ) concat(
        let(q=q1,len=len(q)) len>1 ? [for(i=[1:len-1]) q[i]] : q,
        let(q=q2,len=len(q)) len>1 ? [for(i=[1:len-1]) q[i]] : q,
        let(q=q3,len=len(q)) len>1 ? [for(i=[1:len-1]) q[i]] : q,
        let(q=q4,len=len(q)) len>1 ? [for(i=[1:len-1]) q[i]] : q
      )
  ) points;

/*!
 * Draw a 2d square centered at the origin.
 */
module fl_square(
  verbs   = FL_ADD,
  /*!
   * square size as 2d list or scalar
   */
  size      = 1,
  /*!
   * List of four radiuses, one for each quadrant's corners.
   * Each zero means that the corresponding corner is squared.
   * Defaults to a 'right' rectangle with four squared corners.
   * Scalar value R for «corners» means corners=[R,R,R,R]
   *
   * See also function fl_square() for more complete examples.
  */
  corners = [0,0,0,0],
  quadrant
) {
  assert(is_list(verbs)||is_string(verbs));

  size    = is_num(size) ? [size,size] : size;
  points  = fl_square(size,corners);
  bbox    = [[-size.x/2,-size.y/2],[+size.x/2,+size.y/2]];
  M       = fl_quadrant(quadrant,bbox=bbox);

  fl_trace("size",size);
  fl_trace("corners",corners);
  fl_trace("points",points);

  fl_2d_vloop(verbs,bbox,quadrant) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) polygon(points);
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) %fl_square(size=size,$FL_ADD=$FL_BBOX);
    } else {
      fl_error(["unimplemented verb",$this_verb]);
    }
  }
}

//**** frame ******************************************************************

function fl_2d_frame_intCorners(
  //! outer size
  size    = [1,1],
  /*!
   * List of four radiuses, one for each quadrant's corners.
   * Each zero means that the corresponding corner is squared.
   * Defaults to a 'perfect' rectangle with four squared corners.
   * One scalar value R means corners=[R,R,R,R]
   */
  corners = [0,0,0,0],
  //! subtracted to size defines the internal size
  thick
) = let(
  delta = [thick,thick],
  zero  = [0,0]
) // corners==scalar
  is_num(corners) ? let(
    e = corners>thick ? [corners,corners]-delta : zero
  ) [e,e,e,e]
  // corners==ellipsis ([a,b])
  : len(corners)==2 ? let(
    e = min(corners)>thick ? corners-delta : zero
  ) [e,e,e,e]
  // corners==[scalar|ellipsis,scalar|ellipsis,scalar|ellipsis,scalar|ellipsis]
  : len(corners)==4 ? [
    for(v=corners)
      // scalar
      is_num(v) ? v>thick ? [v,v]-delta : zero
      // ellipsis
      : min(v)>thick ? v-delta : zero
  ]
  : assert(false,corners) undef;

/*!
 * Add a 2d square frame according to corners and thick specifications.
 *
 * Example:
 *
 * A frame with the following corners:
 *
 * - I quadrant: r=3
 * - II quadrant: r=2
 * - III quadrant: r=4
 * - IV quadrant: r=0 (no roundness)
 *
 * is produced by the following code
 *
 *     use <OFL/foundation/2d-engine.scad>
 *     ...
 *     fl_2d_frame(size=[15,10],corners=[3,2,4,0],thick=2,$fn=50);
 *
 * and will result as in the following picture:
 *
 * ![2d frame](256x256/fig_2d_frame.png)
 */
module fl_2d_frame(
  verbs   = FL_ADD,
  //! outer size
  size    = [1,1],
  /*!
   * List of four radiuses, one for each quadrant's corners.
   * Each zero means that the corresponding corner is squared.
   * Defaults to a 'perfect' rectangle with four squared corners.
   * One scalar value R means corners=[R,R,R,R]
   */
  corners = [0,0,0,0],
  //! subtracted to size defines the internal size
  thick,
  quadrant
) {
  assert(is_num(thick));

  size        = is_num(size) ? [size,size] : size;
  size_int    = size - 2*[thick,thick];
  corners_int = fl_2d_frame_intCorners(size,corners,thick);

  bbox    = [[-size.x/2,-size.y/2],[+size.x/2,+size.y/2]];

  fl_2d_vloop(verbs,bbox,quadrant=quadrant) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) difference() {
        fl_square($verb,size,corners);
        fl_square($verb,size_int,corners_int);
      }
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_square(size=size);
    } else {
      fl_error(["unimplemented verb",$this_verb]);
    }
  }
}

//**** 2d placement ***********************************************************

/*!
 * Constructor for the quadrant parameter from values as passed by customizer
 * (see fl_quadrant() for the semantic behind).
 *
 * Each dimension can assume one out of the following values:
 *
 * - "undef": mapped to undef
 * - "-1","0","+1": mapped to -1,0,+1 respectively
 * - -1,0,+1: untouched
 */
function fl_parm_Quadrant(x,y) = let(
  o_x = x=="undef" ? undef : is_string(x) ? let(value=fl_atoi(x)) assert(is_num(value)) value : x,
  o_y = y=="undef" ? undef : is_string(y) ? let(value=fl_atoi(y)) assert(is_num(value)) value : y
) [
  assert(is_undef(o_x)||o_x==0||abs(o_x)==1,x) o_x,
  assert(is_undef(o_y)||o_y==0||abs(o_y)==1,y) o_y
];

/*!
 * Calculates the translation matrix needed for moving a shape in the provided
 * 2d quadrant.
 */
function fl_quadrant(
  /*!
   * 2d quadrant vector, each component can assume one out of four values
   * modifying the corresponding x or y position in the following manner:
   *
   * - undef: translation invariant (no translation)
   * - -1: object on negative semi-axis
   * - 0: object midpoint on origin
   * - +1: object on positive semi-axis
   *
   * Example 1:
   *
   *     quadrant=[undef,undef]
   *
   * no translation in any dimension
   *
   * Example 2:
   *
   *     quadrant=[0,0]
   *
   * object center [midpoint x, midpoint y] on origin
   *
   * Example 3:
   *
   *     quadrant=[+1,undef]
   *
   *  object on X positive semi-space, no Y translated
   */
  quadrant,
  //! type with "bounding corners" property
  type,
  //! bounding box corners, overrides «type» settings
  bbox,
  //! returned matrix if «quadrant» is undef
  default=I
) = quadrant ? let(
    corner  = bbox ? bbox : fl_bb_corners(type),
    half    = (corner[1] - corner[0]) / 2,
    delta   = [
      is_undef(quadrant.x) ? undef : assert(is_num(quadrant.x),quadrant) sign(quadrant.x) * half.x,
      is_undef(quadrant.y) ? undef : assert(is_num(quadrant.y),quadrant) sign(quadrant.y) * half.y,
      0
    ],
    t       = [
      is_undef(quadrant.x) ? 0 : -corner[0].x-half.x+delta.x,
      is_undef(quadrant.y) ? 0 : -corner[0].y-half.y+delta.y,
      0
    ]
  ) T(t)
  : assert(default) default;

module fl_2d_place(
  type,
  //! 2d quadrant
  quadrant,
  //! bounding box corners
  bbox
) {
  bbox  = bbox ? bbox : assert(type) fl_bb_corners(type);
  M     = fl_quadrant(quadrant,bbox=bbox,default=undef);
  fl_trace("M",M);
  fl_trace("bbox",bbox);
  fl_trace("quadrant",quadrant);
  multmatrix(M) children();
}

module fl_2d_placeIf(
  //! when false, placement is ignored
  condition,
  type,
  //! 2d quadrant
  quadrant,
  //! bounding box corners
  bbox
) {
  fl_trace("type",type);
  fl_trace("bbox",bbox);
  fl_trace("condition",condition);
  if (condition) fl_2d_place(type,quadrant,bbox) children();
  else children();
}

module fl_2d_polygonSymbols(poly, size) let(
  size  = is_undef(size)?fl_2d_closest(poly)/3:size
) for(p=poly)
    fl_sym_point(point=[p.x,p.y,0], size=size);

module fl_2d_polygonLabels(poly,size,label="P") let(
  size  = is_undef(size)?fl_2d_closest(poly)/3:size
) for(i=[0:len(poly)-1])
    let(p=poly[i])
      translate([p.x+size/3,p.y+size/3,0])
        rotate($vpr ? $vpr : [70, 0, 315])
          fl_label(string=str(label,"[",i,"]"),fg="black",size=size);

//**** 2d algorithms **********************************************************

function fl_2d_dist(p1,p2) = let(
  delta = p1-p2
) sqrt(delta.x*delta.x+delta.y*delta.y);

/*!
 * Calculate the smallest distance in O(n*Log(n)) time using Divide and Conquer
 * strategy.
 *
 * See also:
 *
 * [Closest Pair of Points using Divide and Conquer algorithm - GeeksforGeeks](https://www.geeksforgeeks.org/closest-pair-of-points-using-divide-and-conquer-algorithm/)
 *
 * [Closest Pair of Points | O(nlogn) Implementation - GeeksforGeeks](https://www.geeksforgeeks.org/closest-pair-of-points-onlogn-implementation/?source=post_page-----49ba679ce3c7--------------------------------)
 *
 * [Algorithms StudyNote-4: Divide and Conquer — Closest Pair | by Fiona Wu | Medium](https://itzsyboo.medium.com/algorithms-studynote-4-divide-and-conquer-closest-pair-49ba679ce3c7)
 *
 * Usage example:
 *
 *     pts  = [[x1,y1],[x2,y2],...,[xn,yn]];
 *     d    = fl_2d_closest(pts);
 */
function fl_2d_closest(
  //! list of 2d points
  pts,
  //! when true «points» are in ASCENDING X order
  pre_ordered=false
) = let(
  // list must be in X-ASCENDING order
  ordered = pre_ordered ? pts : fl_list_sort(pts,function(e1,e2) (e1.x-e2.x)),
  n       = len(pts)
) n<=1 ? undef :
  n==2 ? fl_2d_dist(ordered[1],ordered[0]) :
  let(
    m       = floor(n/2),
    // m       = fl_list_medianIndex(ordered),
    left    = [for(i=[0:m]) ordered[i]],
    d_left  = fl_2d_closest(left,pre_ordered=true),
    right   = [for(i=[m+1:n-1]) ordered[i]],
    d_right = fl_2d_closest(right,pre_ordered=true),
    deltas  = [
      if (!is_undef(d_left))  d_left,
      if (!is_undef(d_right)) d_right,
    ],
    d       = min(deltas),
    middle  = fl_3d_medianValue(ordered,X,true),
    // Build a list containing all the points closer than d to the line
    // equation: x=middle
    strip   = [for(p=ordered) if (abs(p.x-middle)<d) p],
    // recursive lambda finding the minimum distance point couple inside a 2d
    // region described above
    stripClosest = function(strip,d) let(
        n = len(strip)
      ) n<=1 ? d :
        let(
          // list must be in Y-DESCENDING order
          // y_ordered = fl_list_sort(strip,function(e1,e2) (e2.y-e1.y)),
          y_ordered = strip,
          deltas    = [
            for(i=[0:n-1],j=[i+1:1:n-1])
              if ((y_ordered[j].y-y_ordered[i].y)<d)
                fl_2d_dist(y_ordered[i],y_ordered[j])
          ]
        ) deltas ? min(deltas) : d,
    // this is an alternative lambda function to the above. it should be quicker
    // implementing a shortcut during the minimum distance detection loop
    stripClosest2 = function(strip,d) let(
        n = len(strip)
      ) n<=1 ? d :
        let(
          last = function(list,condition,_i_=0,_this_=last) let(n=len(list))
            n==0 ? -1 :
              condition(list[0]) ? _this_(fl_list_tail(list,-1),condition,_i_+1) :
              _i_,
          // list must be in Y-DESCENDING order
          y_ordered = fl_list_sort(strip,function(e1,e2) (e2.y-e1.y)),
          deltas    = [
            for(i=[0:n-1],j=[i+1:1:last(y_ordered,function(p) ((p.y-y_ordered[i].y)<d))-1])
              fl_2d_dist(y_ordered[i],y_ordered[j])
          ]
        ) deltas ? min(deltas) : d
  ) min(d,stripClosest2(strip,d));
