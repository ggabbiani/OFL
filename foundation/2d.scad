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

include <shape_pie.scad> // dotSCAD
include <defs.scad>
use     <placement.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = true;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

/* [Supported verbs] */

// adds shapes to scene.
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
QUADRANT      = [+1,+1];  // [-1:+1]

/* [2D primitives] */

PRIMITIVE     = "circle arc";  // ["circle", "circle arc", "circle sector", "ellipse", "elliptic arc", "elliptic sector", "inscribed polygon"]
RADIUS        = 10;
// ellipse horiz. semi axis
A             = 10;
// ellipse vert. semi axis
B             = 6;
// arc/sector specific
START_ANGLE   = 0;    // [-360:360]
END_ANGLE     = 60;   // [-360:360]
// arc thickness
ARC_T         = 1;  // [0:10]
// Inscribed polygon edge number
IPOLY_N       = 3;  // [3:50]
// Show a circumscribed circle to inscribed polygon
IPOLY_CIRCLE  = true;

/* [Hidden] */

// echo($vpr=$vpr);
// echo($vpt=$vpt);
// echo($vpd=$vpd);
// echo($vpf=$vpf);

// $vpr  = [0, 0, 0];
// $vpt  = [0, 0, 0];
// $vpd  = 140;
// $vpf  = 22.5;

module __test__() {
  angles  = [START_ANGLE,END_ANGLE];
  verbs=[
    if (ADD!="OFF")   FL_ADD,
    if (AXES!="OFF")  FL_AXES,
    if (BBOX!="OFF")  FL_BBOX,
  ];
  quadrant  = PLACE_NATIVE ? undef : QUADRANT;

  module ipoly() {
    fl_ipoly(verbs,RADIUS,n=IPOLY_N,quadrant=quadrant);
    if (IPOLY_CIRCLE)
      fl_placeIf(!PLACE_NATIVE,quadrant=QUADRANT,bbox=fl_bb_ipoly(RADIUS,IPOLY_N)) #fl_circle(FL_ADD,RADIUS);
  }

  $FL_ADD=ADD;$FL_AXES=AXES;$FL_BBOX=BBOX;

  if      (PRIMITIVE == "circle"            ) fl_circle(verbs,RADIUS,quadrant=quadrant);
  else if (PRIMITIVE == "circle arc"        ) fl_arc(verbs,RADIUS,angles,ARC_T,quadrant=quadrant);
  else if (PRIMITIVE == "circle sector"     ) fl_sector(verbs,RADIUS,angles,quadrant=quadrant);
  else if (PRIMITIVE == "ellipse"           ) fl_ellipse(verbs,[A,B],quadrant=quadrant);
  else if (PRIMITIVE == "elliptic arc"      ) fl_ellipticArc(verbs,[A,B],angles,ARC_T,quadrant=quadrant);
  else if (PRIMITIVE == "elliptic sector"   ) fl_ellipticSector(verbs,[A,B],angles,quadrant=quadrant);
  else if (PRIMITIVE == "inscribed polygon" ) ipoly();
}

//**** 2d bounding box calculations *******************************************

// general polygon bounding box
function fl_bb_polygon(points) = let(
  x = [for(p=points) p.x],
  y = [for(p=points) p.y]
) [[min(x),min(y)],[max(x),max(y)]];

// exact inscribed polygon bounding box
function fl_bb_ipoly(radius,n) = fl_bb_polygon(fl_circle(radius,$fn=n));

// exact sector bounding box
function fl_bb_sector(
  radius  = 1,
  angles
) = let(
  interval  = __normalize__(angles),
  inf       = interval[0],
  sup       = interval[1],
  start     = ceil(inf / 90), // 0 ≤ start ≤ 3
  pts = [
    if ((sup-inf)<360) [0,0],
    if (inf%90!=0) let(alpha=inf)                           fl_circleXY(radius,alpha),
    for(i=[start:start+3]) let(alpha=i*90) if (alpha<=sup)  fl_circleXY(radius,alpha),
    if (sup%90!=0) let(alpha=sup)                           fl_circleXY(radius,alpha)
  ]
) fl_bb_polygon(pts);

// exact circle bounding box
function fl_bb_circle(radius=1) = [[-radius,-radius],[+radius,+radius]];

// exact arc bounding box
function fl_bb_arc(radius,angles,width) =
assert(is_num(radius),str("«radius» must be a number (",radius,")"))
assert(is_list(angles))
assert(is_num(width))
let(
  interval  = __normalize__(angles),
  inf       = interval[0],
  sup       = interval[1],
  start     = ceil(inf / 90),  // 0 <= start <= 3
  RADIUS    = radius+width,
  pts = [
    // internal sector
    if (inf%90!=0) let(alpha=inf)                           fl_circleXY(radius,alpha),
    for(i=[start:start+3]) let(alpha=i*90) if (alpha<=sup)  fl_circleXY(radius,alpha),
    if (sup%90!=0) let(alpha=sup)                           fl_circleXY(radius,alpha),
    // external sector
    if (inf%90!=0) let(alpha=inf)                           fl_circleXY(RADIUS,alpha),
    for(i=[start:start+3]) let(alpha=i*90) if (alpha<=sup)  fl_circleXY(RADIUS,alpha),
    if (sup%90!=0) let(alpha=sup)                           fl_circleXY(RADIUS,alpha)
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
  radius=1
  ,angles   // start|end angles in whatever order
) = 
assert($fn>2) 
assert(is_num(radius),str("radius=",radius))
assert(is_list(angles),str("angles=",angles))
shape_pie(radius,__normalize__(angles));

module fl_sector(verbs=FL_ADD,radius=1, angles, quadrant) {
  assert(is_list(verbs)||is_string(verbs));
  assert(is_num(radius),str("radius=",radius));
  assert(is_list(angles),str("angles=",angles));

  axes    = fl_list_has(verbs,FL_AXES);
  verbs   = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);
  points  = fl_sector(radius,angles);
  bbox    = fl_bb_sector(radius,angles);
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
  inf       = angles[0],
  sup       = angles[1],
  start     = ceil(inf / 90), // 0 ≤ start ≤ 3
  pts = assert(start>=0 && start<=3,start) [
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
  c = (in1==false || (t>=0 && t<=1)) && (in2==false || (u>=0 && u<=1)) 
) assert(D!=0)  // no intersection
  assert(c)     // intersection outside segments
  [x1+t*(x2-x1),y1+t*(y2-y1)];

function fl_ellipticSector(e,angles) = 
assert(is_list(e),str("e=",e))
// echo(str("***e***=",e))
// echo(str("***angles***=",angles))
assert(is_list(angles),str("angles=",angles))
let(
  O     = [0,0],
  a     = e[0],
  b     = e[1],
  step  = 360 / __frags__(fl_ellipseP(e)),
  // angles  = __normalize__(angles),
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
    [[0, 0], first],
    // m > n ? [] : [
      // for(i = m; i <= n; i = i + 1)
      //   let(alpha = step * i,p=fl_ellipseXY(e,theta=alpha)) p
    
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

  a     = e[0];
  b     = e[1];
  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);
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
  width   // added to radius defines the external radius
) = 
assert(is_list(e)     ,str("e=",e))
assert(is_list(angles),str("angles=",angles))
assert(is_num(width)  ,str("width=",width))
let(
  a = e[0],
  b = e[1],

  inf       = angles[0],
  sup       = angles[1],
  start     = ceil(inf / 90),  // 0 <= start <= 3
  E         = assert(start>=0 && start<=3,start) e+[width,width],
  pts = [
    // internal sector
    if (inf%90!=0) let(alpha=inf)                           fl_ellipseXY(e,angle=alpha),
    for(i=[start:start+3]) let(alpha=i*90) if (alpha<=sup)  fl_ellipseXY(e,angle=alpha),
    if (sup%90!=0) let(alpha=sup)                           fl_ellipseXY(e,angle=alpha),
    // external sector
    if (inf%90!=0) let(alpha=inf)                           fl_ellipseXY(E,angle=alpha),
    for(i=[start:start+3]) let(alpha=i*90) if (alpha<=sup)  fl_ellipseXY(E,angle=alpha),
    if (sup%90!=0) let(alpha=sup)                           fl_ellipseXY(E,angle=alpha)
  ]
) fl_bb_polygon(pts);

module fl_ellipticArc(
  verbs     = FL_ADD, // supported verbs: FL_ADD, FL_AXES, FL_BBOX,
  e,                  // ellipse in [a,b] form
  angles,             // start|end angles
  width,              // added to radius defines the external radius
  quadrant
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(is_list(e)     ,str("e=",e));
  // echo(angles=angles);
  assert(is_list(angles),str("angles=",angles));
  assert(is_num(width)  ,str("width=",width));

  a     = e[0];
  b     = e[1];
  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);
  bbox  = fl_bb_ellipticArc(e,angles,width);
  size  = bbox[1]-bbox[0];
  M     = quadrant ? fl_quadrant(quadrant=quadrant,bbox=bbox) : FL_I;

  multmatrix(M) fl_parse(verbs) {
    if ($verb==FL_ADD) {
      fl_modifier($FL_ADD) difference() {
        fl_ellipticSector(verbs=$verb, e=[a+width,b+width] ,angles=angles);
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

//**** ellipse ****************************************************************

// r(θ): polar value of ellipse «e» by «θ»
function fl_ellipseR(e,theta) = let(
    a           = e[0],
    b           = e[1],
    e_cos_theta = fl_ellipseE(e) * cos(theta)
  ) b / sqrt(1-e_cos_theta*e_cos_theta);

// [x,y]: rectangular value of ellipse «e» by «t» (parametric) or «angle» (polar) input
function fl_ellipseXY(
  e,    // ellipse in [a,b] form
  t,    // parametric input 0≤t<360
  angle // polar input 0≤a<360
) =
assert(is_list(e))
assert(fl_XOR(t!=undef,angle!=undef))
// assert(t==undef || (t>=0  &&  t<=360),str("t=",t))
// assert(theta==undef || (theta>=0 && theta<=360),str("theta=",theta))
let(
  a = e[0],
  b = e[1]
) t!=undef ? [a*cos(t),b*sin(t)] : fl_ellipseXY(e,t=fl_ellipseT(e,angle));

// Approximated ellipse perimeter 
function fl_ellipseP(e) = 
assert(e[0]>0 && e[1]>0,str("e=",e))
let(
  a = e[0],
  b = e[1],
  h = (a-b)*(a-b)/(a+b)/(a+b)
) PI*(a+b)*(1+3*h/(10+sqrt(4-3*h)));

// eccentricity of ellipse «e»
function fl_ellipseE(e) =
assert(e[0]>0 && e[1]>0,str("e=",e))
let(
  a = e[0],
  b = e[1]
) sqrt(1-b*b/a/a);

// converts «θ» value to the corresponding ellipse «t» parameter
function fl_ellipseT(e,angle) =
assert(is_list(e),str("e=",e))
assert(is_num(angle),str("angle=",angle))
let(
  a = e[0],
  b = e[1],
  t = asin(fl_ellipseR(e,angle)*sin(angle)/b)
) angle>270 ? t+360 : angle>90 ? 180-t : t;

// Exact ellipse bounding box
function fl_bb_ellipse(
  e // ellipse in [a,b] form
) = let(a=e[0],b=e[1]) assert(is_list(e),str("e=",e)) [[-a,-b],[+a,+b]];

function fl_ellipse(
  e // ellipse in [a,b] form
) = let(a=e[0],b=e[1]) fl_ellipticSector([a,b],[0,360]);

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

  multmatrix(M) fl_parse(verbs) {
    if ($verb==FL_ADD) {
      fl_modifier($FL_ADD) polygon(fl_ellipse(e));
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

function fl_circle(radius=1) = fl_sector(radius,[0,360]);

module fl_circle(verbs=FL_ADD,radius,quadrant) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  bbox  = fl_bb_circle(radius);
  size  = bbox[1] - bbox[0];
  M     = quadrant ? fl_quadrant(quadrant=quadrant,bbox=bbox) : FL_I;
  fl_trace("quadrant",quadrant);
  fl_trace("M",M);
  fl_trace("bbox",bbox);
  fl_trace("axes",axes);

  multmatrix(M)  fl_parse(verbs) {
    if ($verb==FL_ADD) {
      fl_modifier($FL_ADD) polygon(fl_circle(radius));
    } else if ($verb==FL_BBOX) {
      fl_modifier($FL_BBOX) translate(bbox[0]) %square(size=size, center=false);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
  if (axes)
    fl_modifier($FL_AXES) fl_axes(size=size);
}

//**** arc ********************************************************************

module fl_arc(
  verbs   = FL_ADD
  ,radius // internal radius
  ,angles // start and stop angles
  ,width  // added to radius defines the external radius
  ,quadrant
  ) {
  assert(is_list(verbs)||is_string(verbs));
  assert(is_num(radius));
  assert(is_list(angles));
  assert(is_num(width));

  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  bbox  = fl_bb_arc(radius,angles,width);
  size  = bbox[1] - bbox[0];
  M     = quadrant ? fl_quadrant(quadrant=quadrant,bbox=bbox) : FL_I;

  multmatrix(M) fl_parse(verbs) {
    if ($verb==FL_ADD) {
      fl_modifier($FL_ADD) difference() {
        fl_sector(verbs=$verb, radius=radius + width,angles=angles);
        fl_sector(verbs=$verb, radius=radius, angles=angles);
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

  radius  = r ? r : d/2;
  points  = fl_circle(radius,$fn=n);

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

__test__();