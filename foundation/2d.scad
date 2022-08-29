/*
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL).
 *
 * OFL is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * OFL is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with OFL.  If not, see <http: //www.gnu.org/licenses/>.
 */

//! 2D primitives.

include <unsafe_defs.scad>

function __clip__(inf,x,sup) = x<=inf?inf:x>=sup?sup:x;

//**** 2d bounding box calculations *******************************************

//! general 2d polygon bounding box
function fl_bb_polygon(points) = let(
  x = [for(p=points) p.x],
  y = [for(p=points) p.y]
) [[min(x),min(y)],[max(x),max(y)]];

/*!
 * Calculates the exact bounding box of a polygon inscribed in a circumference.
 * See also [fl_bb_polygon()](#function-fl_bb_polygon).
 *
 * __NOTE__: «r» and «d» are mutually exclusive.
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
  //!
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
  //! start|end angles in whatever order
  angles
) = let(
  radius  = d!=undef ? d/2 : r
) assert($fn>2)
  assert(is_num(radius),str("radius=",radius))
  assert(is_list(angles),str("angles=",angles))
  fl_ellipticSector(e=[radius,radius],angles=angles);

module fl_sector(
  verbs = FL_ADD,
  r     = 1,
  d,
  angles,
  quadrant
) {
  assert(is_list(angles),str("angles=",angles));

  radius  = d!=undef ? d/2 : r; assert(is_num(radius),str("radius=",radius));
  points  = fl_sector(r=radius,angles=angles);
  bbox    = fl_bb_sector(r=radius,angles=angles);
  size    = bbox[1] - bbox[0];
  M       = fl_quadrant(quadrant,bbox=bbox);
  fl_trace("radius",radius);
  fl_trace("points",points);
  fl_trace("bbox",bbox);
  fl_trace("size",size);

  fl_manage(verbs,M,size=size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) polygon(points);
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) translate(bbox[0]) square(size=size, center=false);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
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
   * __NOTE__: the provided angles are always reduced in the form [inf,sup] with:
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

//! line to line intersection as from [Line–line intersection](https://en.wikipedia.org/wiki/Line-line_intersection)
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
   * __NOTE__: the provided angles are always reduced in the form [inf,sup] with:
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
  //! ellipse in [a,b] form
  e,
  //! start|end angles in whatever order
  angles,
  quadrant
) {
  assert(e!=undef && angles!=undef);
  a     = e[0];
  b     = e[1];
  bbox  = fl_bb_ellipticSector(e,angles);
  size  = bbox[1]-bbox[0];
  M     = fl_quadrant(quadrant,bbox=bbox);

  fl_manage(verbs,M,size=size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) polygon(fl_ellipticSector(e,angles));
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) translate(bbox[0]) square(size=size, center=false);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

//**** elliptic arc ***********************************************************

//! Exact elliptic arc bounding box
function fl_bb_ellipticArc(
  //! outer ellipse in [a,b] form
  e,
  //! start|end angles
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
  //! outer ellipse in [a,b] form
  e,
  //! start|end angles
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
  M     = fl_quadrant(quadrant,bbox=bbox);

  fl_manage(verbs,M,size=size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) difference() {
        fl_ellipticSector(verbs=$verb, angles=angles, e=e                 );
        fl_ellipticSector(verbs=$verb, angles=angles, e=[a-thick,b-thick] );
      }
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) translate(bbox[0]) square(size=size, center=false);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

//**** elliptic annulus *******************************************************

module fl_ellipticAnnulus(
  //! supported verbs: FL_ADD, FL_AXES, FL_BBOX
  verbs     = FL_ADD,
  //! outer ellipse in [a,b] form
  e,
  //! subtracted to outer ellipses axes defines the internal one
  thick,
  quadrant
  ) {
  fl_ellipticArc(verbs,e,[0,360],thick,quadrant);
}

//**** ellipse ****************************************************************

//! r(θ): polar equation of ellipse «e» by «θ»
function fl_ellipseR(e,theta) = let(
    a           = e[0],
    b           = e[1],
    b_cos_theta = b*cos(theta),
    a_sin_theta = a*sin(theta)
  ) a*b / sqrt(b_cos_theta*b_cos_theta+a_sin_theta*a_sin_theta);

//! Returns a 2d list [x,y]: rectangular value of ellipse «e» by «t» (parametric) or «angle» (polar) input
function fl_ellipseXY(
  //! ellipse in [a,b] form
  e,
  //! parametric input 0≤t<360
  t,
  //! polar input 0≤angle<360
  angle
) =
assert(is_list(e))
assert(fl_XOR(t!=undef,angle!=undef))
let(
  a           = e[0],
  b           = e[1],
  parametric  = t!=undef
) parametric ? [a*cos(t),b*sin(t)] : fl_ellipseXY(e,t=fl_ellipseT(e,angle=angle));

//! APPROXIMATED ellipse perimeter
function fl_ellipseP(e) =
assert(e[0]>0 && e[1]>0,str("e=",e))
let(
  a = e[0],
  b = e[1],
  h = (a-b)*(a-b)/(a+b)/(a+b)
) PI*(a+b)*(1+3*h/(10+sqrt(4-3*h)));

function ramp(angle) = 180*floor((angle+90)/180);

// function step(angle) = cos(angle)>=0 ? 1 : -1;
function step(angle) = sin(angle/3)==1 ? 1 : cos(angle)>0 ? 1 : -1;

/*!
 * Converts «θ» value to the corresponding ellipse «t» parameter
 *
 * __NOTE__: we need to extend the theoretical function behiond ±π/2 codomain,
 * for that we use ramp() and step() function accordingly.
 */
function fl_ellipseT(e,angle) =
assert(is_list(e),str("e=",e))
assert(is_num(angle),str("angle=",angle))
let(
  a     = e[0],
  b     = e[1],
  t     = asin(__clip__(-1,fl_ellipseR(e,angle)*sin(angle)/b,1)),
  ramp  = ramp(angle),
  step  = step(angle)
) ramp+step*t;

//! Exact ellipse bounding box
function fl_bb_ellipse(
  //! ellipse in [a,b] form
  e
) = let(a=e[0],b=e[1]) assert(is_list(e),str("e=",e)) [[-a,-b],[+a,+b]];

function fl_ellipse(
  //! ellipse in [a,b] form
  e
) = let(
  a=e[0],b=e[1],fa=$fa,fn=$fn,fs=$fs
  ) fl_ellipticSector([a,b],[0,360],$fa=fa,$fn=fn,$fs=fs);

module fl_ellipse(
  //! supported verbs: FL_ADD, FL_AXES, FL_BBOX
  verbs   = FL_ADD,
  //! ellipse in [a,b] form
  e,
  quadrant
) {
  assert(e!=undef);

  a     = e[0];
  b     = e[1];
  bbox  = fl_bb_ellipse(e);
  size  = bbox[1]-bbox[0];
  M     = fl_quadrant(quadrant,bbox=bbox);

  fa    = $fa;
  fn    = $fn;
  fs    = $fs;

  fl_manage(verbs,M,size=size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) polygon(fl_ellipse(e,$fa=fa,$fn=fn,$fs=fs));
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) translate(bbox[0]) square(size=size, center=false);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

//**** circle *****************************************************************

//! Rectangular value [x,y] of circle of ray «r» by «t» (parametric)
function fl_circleXY(
  //! radius of the circle
  r,
  //! 0≤t<360, angle that the ray from (0,0) to (x,y) makes with +X
  t
) = r*[cos(t),sin(t)];

// function fl_circle(r=1) = fl_sector(r=r,angles=[0,360]);

function fl_circle(r=1,center=[0,0]) = let(
    points  = fl_sector(r=r,angles=[0,360]),
    T = [
      [1,0, center.x],
      [0,1, center.y],
      [0,0, 1       ]
    ]
  ) center!=[0,0]
  ? [for(p=points) let(t=T*[p.x,p.y,1]) [t.x,t.y]]
  : points;

module fl_circle(
  verbs = FL_ADD,
  r,
  d,
  quadrant
) {
  radius  = r!=undef ? r : d/2; assert(is_num(radius));
  bbox    = fl_bb_circle(r=radius);
  size    = bbox[1] - bbox[0];
  M       = fl_quadrant(quadrant,bbox=bbox);
  fl_trace("quadrant",quadrant);
  fl_trace("M",M);
  fl_trace("bbox",bbox);

  fl_manage(verbs,M,size=size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) polygon(fl_circle(r=radius));
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) translate(bbox[0]) %square(size=size, center=false);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
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
  //! start and stop angles
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
  M       = fl_quadrant(quadrant,bbox=bbox);

  fl_trace("radius",radius);

  fl_manage(verbs,M,size=size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) difference() {
        fl_sector($verb, angles=angles, r=radius      );
        fl_sector($verb, angles=angles, r=radius-thick);
      }
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) if (size.x>0 && size.y>0) translate(bbox[0]) square(size=size, center=false);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

//**** inscribed polygon ******************************************************

//! Regular polygon inscribed a circonference
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
  M       = fl_quadrant(quadrant,bbox=bbox);
  fl_trace("bbox",bbox);

  fl_manage(verbs,M,size=size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) polygon(points);
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) translate(bbox[0]) %square(size=size, center=false);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

//**** square *****************************************************************

function fl_square(
  size      = [1,1],
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
   * Aany combination is allowed i.e.
   *
   *     corners=[r,[a,b],0,0] ⇒ corners=[[r,r],[a,b],[0,0],[0,0]] == rectangle with circular arc on quadrant I, elliptical arc on quadrant II and squared on quadrants III,IV
   */
  corners  = [0,0,0,0]
) =
  assert(is_num(corners) || len(corners)==2 || len(corners)==4)
  let(
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

module fl_square(
  verbs   = FL_ADD,
  size    = [1,1],
  /*!
   * List of four radiuses, one for each quadrant's corners.
   * Each zero means that the corresponding corner is squared.
   * Defaults to a 'perfect' rectangle with four squared corners.
   * Scalar value R for «vertices» means corners=[R,R,R,R]
   *
   * See also [function fl_square()](#function-fl_square) for more complete examples.
  */
  corners = [0,0,0,0],
  quadrant
) {
  assert(is_list(verbs)||is_string(verbs));

  points  = fl_square(size,corners);
  bbox    = [[-size.x/2,-size.y/2],[+size.x/2,+size.y/2]];
  M       = fl_quadrant(quadrant,bbox=bbox);

  fl_trace("size",size);
  fl_trace("corners",corners);
  fl_trace("points",points);

  fl_manage(verbs,M,size=size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) polygon(points);
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) %fl_square(size=size,$FL_ADD=$FL_BBOX);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

//**** frame ******************************************************************

module fl_2d_frame(
  verbs   = FL_ADD,
  //! outer size
  size    = [1,1],
  /*!
  List of four radiuses, one for each quadrant's corners.
  Each zero means that the corresponding corner is squared.
  Defaults to a 'perfect' rectangle with four squared corners.
  One scalar value R means corners=[R,R,R,R]
  */
  corners = [0,0,0,0],
  //! subtracted to size defines the internal size
  thick,
  quadrant
) {
  assert(is_num(thick));

  size_int    = size - 2*[thick,thick];
  corners_int = let(
      delta = [thick,thick],
      zero  = [0,0]
    )
    // corners==scalar
    is_num(corners) ? let(
      e = corners>thick ? [corners,corners]-delta : zero
    ) [e,e,e,e]
    // corners==ellipsis ([a,b])
    : len(corners)==2 ? let(
      e = min(corners)>thick ? corners-delta : zero
    ) [e,e,e,e]
    // corners==[scalar|ellipsis,scalar|ellipsis,scalar|ellipsis,scalar|ellipsis,]
    : len(corners)==4 ? [
      for(v=corners)
        // 4 scalar
        is_num(v) ? v>thick ? [v,v]-delta : zero
        // 4 ellipses
        : min(v)>thick ? v-delta : zero
    ]
    : assert(false,corners);

  bbox    = [[-size.x/2,-size.y/2],[+size.x/2,+size.y/2]];
  M       = fl_quadrant(quadrant,bbox=bbox);

  fl_manage(verbs,M,size=size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) difference() {
        fl_square($verb,size,corners);
        fl_square($verb,size_int,corners_int);
      }
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_square(size=size);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

//**** 2d placement ***********************************************************

/*!
 * Calculates the translation matrix needed for moving a shape in the provided
 * 2d quadrant.
 */
function fl_quadrant(
  //! 2d quadrant
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
    delta   = [sign(quadrant.x) * half.x,sign(quadrant.y) * half.y,0]
  ) T(-corner[0]-half+delta)
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
  //! when true placement is ignored
  condition ,
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
