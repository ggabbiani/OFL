/*
 * 2D primitives.
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
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

include <defs.scad>
use     <placement.scad>

function __clip__(inf,x,sup) = x<=inf?inf:x>=sup?sup:x;

//**** 2d bounding box calculations *******************************************

// general 2d polygon bounding box
function fl_bb_polygon(points) = let(
  x = [for(p=points) p.x],
  y = [for(p=points) p.y]
) [[min(x),min(y)],[max(x),max(y)]];

// exact inscribed polygon bounding box
function fl_bb_ipoly(r,d,n) = let(
  radius  = r!=undef ? r : d
) assert(is_num(radius),str("radius=",radius)) fl_bb_polygon(fl_circle(r=radius,$fn=n));

// exact sector bounding box
function fl_bb_sector(
  r       = 1,
  d,
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

// exact circle bounding box
function fl_bb_circle(r=1,d) = let(
  radius  = d!=undef ? d/2 : r
) assert(is_num(radius),str("radius=",radius)) [[-radius,-radius],[+radius,+radius]];

// exact arc bounding box
function fl_bb_arc(r=1,d,angles,thick) =
assert(is_list(angles),str("angles must be a list (",angles,")"))
let(
  radius    = d!=undef ? d/2 : r,
  interval  = __normalize__(angles),
  inf       = interval[0],
  sup       = interval[1],
  start     = ceil(inf / 90),  // 0 <= start <= 3
  RADIUS    = 
    assert(is_num(radius),str("«radius» must be a number (",radius,")"))
    assert(is_num(thick), str("«thick» must be a number (",thick,")"))
    radius+thick,
  pts = [
    if (inf%90!=0) for(r=[radius,RADIUS]) fl_circleXY(r,inf),
    for(alpha=[90*start:90:90*(start+3)]) if (alpha<=sup) for(r=[radius,RADIUS]) fl_circleXY(r,alpha),
    if (sup%90!=0) for(r=[radius,RADIUS]) fl_circleXY(r,sup),
  ]
) fl_bb_polygon(pts);

//**** sector *****************************************************************

// reduces an angular interval in the form [inf,sup] with:
// sup ≥ inf
// distance = sup - inf
//    0° ≤ distance ≤ +360°
//    0° ≤   inf    < +360°
//    0° ≤   sup    < +720°
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
  angles  // start|end angles in whatever order
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
  assert(is_list(verbs)||is_string(verbs));
  assert(is_list(angles),str("angles=",angles));

  radius  = d!=undef ? d/2 : r; assert(is_num(radius),str("radius=",radius));
  axes    = fl_list_has(verbs,FL_AXES);
  verbs   = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);
  points  = fl_sector(r=radius,angles=angles);
  bbox    = fl_bb_sector(r=radius,angles=angles);
  size    = bbox[1] - bbox[0];
  M       = quadrant ? fl_quadrant(quadrant=quadrant,bbox=bbox) : FL_I;
  fl_trace("radius",radius);
  fl_trace("points",points);
  fl_trace("bbox",bbox);
  fl_trace("size",size);
  fl_trace("axes",axes);

  multmatrix(M) fl_parse(verbs) {
    if ($verb==FL_ADD) {
      fl_modifier($FL_ADD) polygon(points);
    } else if ($verb==FL_BBOX) {
      fl_modifier($FL_BBOX) translate(bbox[0]) square(size=size, center=false);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
  if (axes)
    fl_modifier($FL_AXES) fl_axes(size=size);
}

//**** elliptic sector ********************************************************

// Exact elliptic sector bounding box
function fl_bb_ellipticSector(
  e,      // ellipse in [a,b] form
  angles  // start|end angles
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

// line to line intersection as from https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection
function fl_intersection(
  line1,          // first line in [P0,P1] format
  line2,          // second line in [P0,P1] format
  in1     = true, // solution valid if inside segment 1
  in2     = true  // solution valid if inside segment 2
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

function fl_ellipticSector(e,angles) = 
  assert(is_list(e),str("e=",e))
  assert(is_list(angles),str("angles=",angles))
  let(
    fa    = $fa,
    fn    = $fn,
    fs    = $fs,
    O     = [0,0],
    a     = e[0],
    b     = e[1],
    step  = 360 / __frags__(fl_ellipseP(e),$fa=fa,$fn=fn,$fs=fs),
    angles  = __normalize__(angles),
    t     = [fl_ellipseT(e,angles[0]),fl_ellipseT(e,angles[1])],
    m     = floor(angles[0] / step) + 1,
    n     = floor(angles[1] / step),
    M     = floor(t[0]/step) + 1,
    N     = floor(t[1]/step),
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
      M > N ? [] : [
        for(i = M; i <= N; i = i + 1)
          fl_ellipseXY(e,t=step * i)
      ],
      angles[1]==step * n ? [] : [last]
    )
  ) pts;

module fl_ellipticSector(
  verbs     = FL_ADD, // supported verbs: FL_ADD, FL_AXES, FL_BBOX,
  e,                  // ellipse in [a,b] form
  angles,             // start|end angles in whatever order
  quadrant
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(e!=undef && angles!=undef);
  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);
  a     = e[0];
  b     = e[1];
  bbox  = fl_bb_ellipticSector(e,angles);
  size  = bbox[1]-bbox[0];
  M     = quadrant ? fl_quadrant(quadrant=quadrant,bbox=bbox) : FL_I;

  multmatrix(M) fl_parse(verbs) {
    if ($verb==FL_ADD) {
      fl_modifier($FL_ADD) polygon(fl_ellipticSector(e,angles));
    } else if ($verb==FL_BBOX) {
      fl_modifier($FL_BBOX) translate(bbox[0]) square(size=size, center=false);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
  if (axes)
    fl_modifier($FL_AXES) fl_axes(size=size);
}

//**** elliptic arc ***********************************************************

// Exact elliptic arc bounding box
function fl_bb_ellipticArc(
  e,      // ellipse in [a,b] form
  angles, // start|end angles
  thick   // added to radius defines the external radius
) = 
assert(is_list(e)     ,str("e=",e))
assert(is_list(angles),str("angles=",angles))
assert(is_num(thick)  ,str("thick=",thick))
let(
  angles    = __normalize__(angles),
  inf       = angles[0],
  sup       = angles[1],
  start     = ceil(inf / 90),
  E         = e+[thick,thick],
  pts = [
    if (inf%90!=0) for(ellipse=[e,E]) fl_ellipseXY(ellipse,angle=inf),
    for(alpha=[90*start:90:90*(start+3)]) if (alpha<=sup) for(ellipse=[e,E]) fl_ellipseXY(ellipse,angle=alpha),
    if (sup%90!=0) for(ellipse=[e,E])   fl_ellipseXY(ellipse,angle=sup),
  ]
) fl_bb_polygon(pts);

module fl_ellipticArc(
  verbs     = FL_ADD, // supported verbs: FL_ADD, FL_AXES, FL_BBOX
  e,                  // ellipse in [a,b] form
  angles,             // start|end angles
  thick,              // added to radius defines the external radius
  quadrant
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(is_list(e)     ,str("e=",e));
  assert(is_list(angles),str("angles=",angles));
  assert(is_num(thick)  ,str("thick=",thick));

  a     = e[0];
  b     = e[1];
  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);
  bbox  = fl_bb_ellipticArc(e,angles,thick);
  size  = bbox[1]-bbox[0];
  M     = quadrant ? fl_quadrant(quadrant=quadrant,bbox=bbox) : FL_I;

  multmatrix(M) fl_parse(verbs) {
    if ($verb==FL_ADD) {
      fl_modifier($FL_ADD) difference() {
        fl_ellipticSector(verbs=$verb, e=[a+thick,b+thick] ,angles=angles);
        fl_ellipticSector(verbs=$verb, e=e, angles=angles);
      }
    } else if ($verb==FL_BBOX) {
      fl_modifier($FL_BBOX) translate(bbox[0]) square(size=size, center=false);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
  if (axes)
    fl_modifier($FL_AXES) fl_axes(size=size);
}

//**** elliptic annulus *******************************************************

module fl_ellipticAnnulus(
  verbs     = FL_ADD, // supported verbs: FL_ADD, FL_AXES, FL_BBOX
  e,                  // ellipse in [a,b] form
  thick,              // added to radius defines the external radius
  quadrant
  ) {
  fl_ellipticArc(verbs,e,[0,360],thick,quadrant);
} 

//**** ellipse ****************************************************************

// r(θ): polar equation of ellipse «e» by «θ»
function fl_ellipseR(e,theta) = let(
    a           = e[0],
    b           = e[1],
    b_cos_theta = b*cos(theta),
    a_sin_theta = a*sin(theta)
  ) a*b / sqrt(b_cos_theta*b_cos_theta+a_sin_theta*a_sin_theta);

// [x,y]: rectangular value of ellipse «e» by «t» (parametric) or «angle» (polar) input
function fl_ellipseXY(
  e,    // ellipse in [a,b] form
  t,    // parametric input 0≤t<360
  angle // polar input 0≤angle<360
) =
assert(is_list(e))
assert(fl_XOR(t!=undef,angle!=undef))
let(
  a           = e[0],
  b           = e[1],
  parametric  = t!=undef
) parametric ? [a*cos(t),b*sin(t)] : fl_ellipseXY(e,t=fl_ellipseT(e,angle=angle));

// APPROXIMATED ellipse perimeter 
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

// converts «θ» value to the corresponding ellipse «t» parameter
// NOTE: we need to extend the theoretical function behiond ±π/2 codomain, 
// for that we use ramp() and step() function accordingly.
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

// Exact ellipse bounding box
function fl_bb_ellipse(
  e // ellipse in [a,b] form
) = let(a=e[0],b=e[1]) assert(is_list(e),str("e=",e)) [[-a,-b],[+a,+b]];

function fl_ellipse(
  e // ellipse in [a,b] form
) = let(
  a=e[0],b=e[1],fa=$fa,fn=$fn,fs=$fs
  ) fl_ellipticSector([a,b],[0,360],$fa=fa,$fn=fn,$fs=fs);

module fl_ellipse(
  verbs   = FL_ADD, // supported verbs: FL_ADD, FL_AXES, FL_BBOX
  e,                // ellipse in [a,b] form
  quadrant
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(e!=undef);

  a     = e[0];
  b     = e[1];
  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);
  bbox  = fl_bb_ellipse(e);
  size  = bbox[1]-bbox[0];
  M     = quadrant ? fl_quadrant(quadrant=quadrant,bbox=bbox) : FL_I;

  fa    = $fa;
  fn    = $fn;
  fs    = $fs;

  multmatrix(M) fl_parse(verbs) {
    if ($verb==FL_ADD) {
      fl_modifier($FL_ADD) polygon(fl_ellipse(e,$fa=fa,$fn=fn,$fs=fs));
    } else if ($verb==FL_BBOX) {
      fl_modifier($FL_BBOX) translate(bbox[0]) square(size=size, center=false);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
  if (axes)
    fl_modifier($FL_AXES) fl_axes(size=size);
}

//**** circle *****************************************************************

// Rectangular value [x,y] of circle of ray «r» by «t» (parametric)
function fl_circleXY(
  r,  // radius of the circle
  t   // 0≤t<360, angle that the ray from (0,0) to (x,y) makes with +X 
) = r*[cos(t),sin(t)];

function fl_circle(r=1) = fl_sector(r=r,angles=[0,360]);

module fl_circle(
  verbs = FL_ADD,
  r,
  d,
  quadrant
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  radius  = r!=undef ? r : d/2; assert(is_num(radius));
  bbox    = fl_bb_circle(r=radius);
  size    = bbox[1] - bbox[0];
  M       = quadrant ? fl_quadrant(quadrant=quadrant,bbox=bbox) : FL_I;
  fl_trace("quadrant",quadrant);
  fl_trace("M",M);
  fl_trace("bbox",bbox);
  fl_trace("axes",axes);

  multmatrix(M)  fl_parse(verbs) {
    if ($verb==FL_ADD) {
      fl_modifier($FL_ADD) polygon(fl_circle(r=radius));
    } else if ($verb==FL_BBOX) {
      fl_modifier($FL_BBOX) translate(bbox[0]) %square(size=size, center=false);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
  if (axes)
    fl_modifier($FL_AXES) fl_axes(size=size);
}

//**** annulus ****************************************************************

module fl_annulus(
  verbs     = FL_ADD,
  r,          // INTERNAL radius
  d,          // INTERNAL diameter
  thick,      // added to radius defines the external radius
  quadrant
  ) {
  fl_arc(verbs,r,d,[0,360],thick,quadrant);
} 

//**** arc ********************************************************************

module fl_arc(
  verbs     = FL_ADD,
  r,          // INTERNAL radius
  d,          // INTERNAL diameter
  angles,     // start and stop angles
  thick,      // added to radius defines the external radius
  quadrant
  ) {
  assert(is_list(verbs)||is_string(verbs));
  assert(is_list(angles));
  assert(is_num(thick));

  axes    = fl_list_has(verbs,FL_AXES);
  verbs   = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  radius  = r!=undef ? r : d/2; assert(is_num(radius));
  bbox    = fl_bb_arc(r=radius,angles=angles,thick=thick);
  size    = bbox[1] - bbox[0];
  M       = quadrant ? fl_quadrant(quadrant=quadrant,bbox=bbox) : FL_I;

  multmatrix(M) fl_parse(verbs) {
    if ($verb==FL_ADD) {
      fl_modifier($FL_ADD) difference() {
        fl_sector($verb, r=radius + thick,angles=angles);
        fl_sector($verb, r=radius, angles=angles);
      }
    } else if ($verb==FL_BBOX) {
      fl_modifier($FL_BBOX) if (size.x>0 && size.y>0) translate(bbox[0]) square(size=size, center=false);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
  if (axes)
    fl_modifier($FL_AXES) fl_axes(size=size);
} 

//**** inscribed polygon ******************************************************

// Regular polygon inscribed a circonference
module fl_ipoly(
  verbs   = FL_ADD
  ,r  // circumscribed circle radius
  ,d  // circumscribed circle diameter
  ,n  // number of edges
  ,quadrant
) {
  assert(is_list(verbs)||is_string(verbs));
  assert(fl_XOR(r,d));

  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  radius  = r!=undef ? r : d/2; assert(is_num(radius));
  points  = fl_circle(r=radius,$fn=n);

  bbox    = fl_bb_polygon(points);
  size    = bbox[1] - bbox[0];
  M       = quadrant ? fl_quadrant(quadrant=quadrant,bbox=bbox) : FL_I;
  fl_trace("bbox",bbox);
  fl_trace("axes",axes);

  multmatrix(M) fl_parse(verbs) {
    if ($verb==FL_ADD) {
      fl_modifier($FL_ADD) polygon(points);
    } else if ($verb==FL_BBOX) {
      fl_modifier($FL_BBOX) translate(bbox[0]) %square(size=size, center=false);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
  if (axes)
    fl_modifier($FL_AXES) fl_axes(size=size);
}

//**** square *****************************************************************

function fl_square(
  size      = [1,1],
  // List of four values (one for each quadrant) each in the following format:
  //   [a,b]    ⇒ ellipse with semi-axis a and b
  //   scalar r ⇒ circle of radius r (or ellipse with a==b==r)
  // corners=R         ⇒ corners=[R,R,R,R] == corners=[[R,R],[R,R],[R,R],[R,R]] == rounded rectangle with FOUR CIRCULAR ARCS with radius=R
  // corners=[a,b]     ⇒ corners=[[a,b],[a,b],[a,b],[a,b]] == rounded rectangle with FOUR ELLIPTICAL ARCS with e=[a,b]
  // Default corners=0 ⇒ corners=[0,0,0,0] == corners=[[0,0],[0,0],[0,0],[0,0]]) == squared rectangle
  // any combination is allowed i.e.
  // corners=[r,[a,b],0,0] ⇒ corners=[[r,r],[a,b],[0,0],[0,0]] == rectangle with circular arc on quadrant I, elliptical arc on quadrant II and squared on quadrants III,IV
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
  corners = [0,0,0,0],// List of four radiuses, one for each quadrant's corners.
                        // Each zero means that the corresponding corner is squared.
                        // Defaults to a 'perfect' rectangle with four squared corners.
                        // Scalar value R for «vertices» means corners=[R,R,R,R]
  quadrant
) {
  assert(is_list(verbs)||is_string(verbs));

  axes      = fl_list_has(verbs,FL_AXES);
  verbs     = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  points  = fl_square(size,corners);
  bbox    = [[-size.x/2,-size.y/2],[+size.x/2,+size.y/2]];
  M       = quadrant ? fl_quadrant(quadrant=quadrant,bbox=bbox) : FL_I;

  fl_trace("size",size);
  fl_trace("corners",corners);
  fl_trace("points",points);
  
  multmatrix(M) fl_parse(verbs) {
    if ($verb==FL_ADD) {
      fl_modifier($FL_ADD) polygon(points);
    } else if ($verb==FL_BBOX) {
      fl_modifier($FL_BBOX) %fl_square(size=size,$FL_ADD=$FL_BBOX);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
  if (axes)
    fl_modifier($FL_AXES) fl_axes(size=size);
}

/**
 * Creates a grid on any 2d children geometry passed.
 */
module fl_2d_grid(
  // bounding box of the generated grid, only the 2d part of it is actually used.
  bbox,
  // distance between centers of two adjacent holes
  shift,
  // holes by diameter
  d,
  // or radius
  r,
  // holes are circles approximation whose edge number can be reduced 
  // actually drawning a polygon
  edges=$fn,
  // rotation about +Z of the resulting hole geometry
  rotation=0
) {
  assert(bbox!=undef);
  assert(fl_XOR(d!=undef,r!=undef),str("d=",d,",r=",r));

  rad     = d ? d/2 : rad;
  diam    = rad ? 2*rad : diam;
  size    = bbox[1]-bbox[0];
  tan_60  = tan(60);

  difference() {
    children();
    for(x=[bbox[0].x+shift-rad:shift:bbox[1].x],row=[0:1:2*size.y/shift/tan_60]) {
      y = bbox[0].y+shift-rad+row*shift*tan_60/2;
      c = [x+(row%2!=0 ? shift/2 : 0),y];
      if (c.x<bbox[1].x && c.y<bbox[1].y)
        translate(c) rotate(rotation,+FL_Z) fl_circle(d=diam,$fn=edges);
    }
  }
  // #fl_bb_add(bbox,2d=true);
}
