/*
 * Base definitions for OpenSCAD.
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

include <TOUL.scad>               // TOUL       : The OpenScad Usefull Library
use     <scad-utils/spline.scad>  // scad-utils : Utility libraries for OpenSCAD

use     <base_geo.scad>
use     <base_string.scad>

function fl_version() = [2,7,0];

function fl_versionNumber() = let(
  version = fl_version()
) version.x*10000+version.y*100+version.z;

// May trigger debug statement in client modules / functions
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

// simple workaround for the z-fighting problem during preview
FL_NIL  = ($preview && !$FL_RENDER ? 0.01 : 0);
FL_NIL2 = 2*FL_NIL;

// PER SURFACE distance in case of movable parts to be doubled when applied to a diameter
fl_MVgauge  = 0.6;

// PER SURFACE distance in case of jointed parts to be doubled when applied to a diameter
fl_JNgauge  = fl_MVgauge/4;

// Recommended tolerance for FDM as stated in https://www.3dhubs.com/knowledge-base/how-design-snap-fit-joints-3d-printing/
fl_FDMtolerance = 0.5;

FL_X = [1,0,0];
FL_Y = [0,1,0];
FL_Z = [0,0,1];
FL_O = [0,0,0];

// identity matrix in homogeneous coordinates
FL_I=[
  [1,0,0,0],
  [0,1,0,0],
  [0,0,1,0],
  [0,0,0,1],
];

// translation matrix in homogeneous coordinates
function fl_T(t) = is_list(t)
  ? [
      [1,0,0, t.x ],
      [0,1,0, t.y ],
      [0,0,1, t.z ],
      [0,0,0, 1   ]
    ]
  : fl_T([t,t,t]);

// scale matrix in homogeneous coordinates
function fl_S(s) = is_list(s) 
  ? [
      [s.x, 0,    0,    0 ],
      [0,   s.y,  0,    0 ],
      [0,   0,    s.z,  0 ],
      [0,   0,    0,    1 ]
    ]
  : fl_S([s,s,s]);

// rotation around X matrix
function fl_Rx(theta) =
[
  [1,           0,            0,           0],
  [0,           cos(theta),   -sin(theta), 0],
  [0,           sin(theta),   cos(theta),  0],
  [0,           0,            0,           1]
];

// rotation around Y matrix
function fl_Ry(theta) = [
  [cos(theta),  0,            sin(theta),  0],
  [0,           1,            0,           0],
  [-sin(theta), 0,            cos(theta),  0],
  [0,           0,            0,           1]
];

// rotation around Z matrix
function fl_Rz(theta) = [
  [cos(theta),  -sin(theta),  0,  0],
  [sin(theta),  cos(theta),   0,  0],
  [0,           0,            1,  0],
  [0,           0,            0,  1]
];

function fl_Rxyz(angle) = fl_Rz(angle.z) * fl_Ry(angle.y) * fl_Rx(angle.x);

/*
 * rotation matrix about arbitrary axis.
 * TODO: check with more efficient alternative [here](https://gist.github.com/kevinmoran/b45980723e53edeb8a5a43c49f134724)
 */
function fl_R(
  u,      // arbitrary axis
  theta   // rotation angle around u
) =
  let(M = fl_align(u,FL_X))
  matrix_invert(M)  // align X to «u»
  * fl_Rx(theta)    // rotate «theta» about X
  * M;              // align «u» to X

function fl_X(x) = [x,0,0];
function fl_Y(y) = [0,y,0];
function fl_Z(z) = [0,0,z];

// TODO: make a case insensitive option
function fl_isSet(flag,list) = search([flag],list)!=[[]];

FL_ADD        = "FL_ADD adds shapes to scene.";
FL_ASSEMBLY   = "FL_ASSEMBLY layout of predefined auxiliary shapes (like predefined screws).";
FL_AXES       = "FL_AXES draw of local reference axes.";
FL_BBOX       = "FL_BBOX adds a bounding box containing the object.";
FL_CUTOUT     = "FL_CUTOUT layout of predefined cutout shapes (±X,±Y,±Z).";
FL_DRILL      = "FL_DRILL layout of predefined drill shapes (like holes with predefined screw diameter).";
FL_FOOTPRINT  = "FL_FOOTPRINT adds a footprint to scene, usually a simplified FL_ADD.";
FL_HOLDERS    = "FL_HOLDERS adds vitamine holders to the scene. **DEPRECATED**";
FL_LAYOUT     = "FL_LAYOUT layout of user passed accessories (like alternative screws).";
FL_PAYLOAD    = "FL_PAYLOAD adds a box representing the payload of the shape";
FL_DEPRECATED = "FL_DEPRECATED is a test verb. **DEPRECATED**";
FL_OBSOLETE   = "FL_OBSOLETE is a test verb. **OBSOLETE**";

// Runtime behaviour defaults
$FL_ADD       = "ON";
$FL_ASSEMBLY  = "ON";
$FL_AXES      = "ON";
$FL_BBOX      = "TRANSPARENT";
$FL_CUTOUT    = "ON";
$FL_DRILL     = "ON";
$FL_FOOTPRINT = "ON";
$FL_HOLDERS   = "ON";
$FL_LAYOUT    = "ON";
$FL_PAYLOAD   = "DEBUG";

/*
 * Modifier module for verbs.
 */
module fl_modifier(
  behaviour // OFF,ON,ONLY,DEBUG,TRANSPARENT
) {
  if (behaviour==undef||behaviour=="ON")   children();
  else if (behaviour=="OFF")              *children();
  else if (behaviour=="ONLY")             !children();
  else if (behaviour=="DEBUG")            #children();
  else if (behaviour=="TRANSPARENT")      %children();
  else assert(false,str("Unknown behaviour ('",behaviour,"')."));
}

$FL_FILAMENT  = "DodgerBlue";

// deprecated function call
function fl_deprecated(bad,value,replacement) = let(
    complain  = str("***DEPRECATED***: ", bad, " is deprecated and ", replacement!=undef ? str("will be replaced by ", replacement, " in next major release.") : "WILL NOT BE REPLACED.")
  ) echo(complain) value;

// generic property getter with default value when not found 
function fl_get(type,key,default) = 
  assert(key!=undef)
  assert(type!=undef)
  let(index_list=search([key],type))
  index_list != [[]] 
  ? type[index_list[0]][1] 
  : assert(default!=undef,str("Key not found ***",key,"***")) default;

/**
 * 'bipolar' property helper: 
 *
 * type/key{/default} ↦ value       (property getter)
 * key{/value}        ↦ [key,value] (property constructor)
 *
 * It concentrates property key definition reducing possible mismatch when 
 * referring to property key in the more usual getter/setter function pair.
 */
function fl_property(type,key,value,default)  = 
  assert(key!=undef)
  type!=undef 
  ? fl_get(type,key,default)              // property getter
  : assert(default==undef)  [key,value];  // property constructor

//*****************************************************************************
// General properties
// when invoked by «type» parameter act as getters
// when invoked by «value» parameter act as property constructors
// NOTE: when called without «type» and «value» parameters, it acts as a 
// constructor with undef value, usable for retrieving the key after '0' post
// indexing, as in the following examples:
// fl_connectors()[0]   ↦ "connectors"
// fl_description()[0]  ↦ "description"
function fl_connectors(type,value)  = fl_property(type,"connectors",value);
function fl_description(type,value) = fl_property(type,"description",value); 
function fl_director(type,value)    = fl_property(type,"director",value);
// holes in [«point»,«surface normal»,«diameter»,«optional depth»] format
function fl_holes(type,value)       = fl_property(type,"holes",value);
function fl_name(type,value)        = fl_property(type,"name",value);
function fl_material(type,value,default)    
                                    = fl_property(type,"material (actually a color)",value,default);
function fl_native(type,value)      = fl_property(type,"OFL native type (boolean)",value,false);
function fl_nopSCADlib(type,value,default)  
                                    = fl_property(type,"Verbatim NopSCADlib definition",value,default);
function fl_rotor(type,value)       = fl_property(type,"rotor",value);
function fl_screw(type,value)       = fl_property(type,"screw",value);
function fl_vendor(type,value)      = fl_property(type,"vendor",value);

//*****************************************************************************
// Derived getters
function fl_size(type)    = fl_bb_size(type);
function fl_width(type)   = fl_size(type).x;
function fl_height(type)  = fl_size(type).y;
function fl_thick(type)   = fl_size(type).z;

//*****************************************************************************
// Bounding Box

// when invoked by «type» parameter acts as getter
// when invoked by «value» parameter acts as property constructor
function fl_bb_corners(type,value)  = let(key="bb/bounding corners")
  type!=undef
  ? let(value = fl_property(type,key)) is_function(value) ? value(type) : value
  : fl_property(key=key,value=value);

// computes size from the bounding corners.
function fl_bb_size(type)       = assert(type) let(c=fl_bb_corners(type)) c[1]-c[0];

// functions
function fl_bb_new(
  negative  = [0,0,0],
  size      = [0,0,0],
  positive
) = [fl_bb_corners(value=[negative,positive==undef?negative+size:positive])];

// bounding box translation
function fl_bb_center(type) = let(c=fl_bb_corners(type),sz=fl_bb_size(type)) c[0]+sz/2;

// Converts a bounding box in canonic form into four vertices:
// a,b,c,d on plane y==bbcorner[0].y
// A,B,C,D on plane y==bbcorner[1].y
function fl_bb_vertices(bbcorners) = let(
  a   = bbcorners[0]
  ,C  = bbcorners[1]
  ,b  = [C.x,a.y,a.z]
  ,c  = [C.x,a.y,C.z]
  ,d  = [a.x,a.y,C.z]
  ,A  = [a.x,C.y,a.z]
  ,B  = [C.x,C.y,a.z]
  ,D  = [a.x,C.y,C.z]
) [a,b,c,d,A,B,C,D];

// Applies a transformation matrix «M» to a bounding box
function fl_bb_transform(M,bbcorners) = let(
  vertices  = [for(v=fl_bb_vertices(bbcorners)) fl_transform(M,v)]
  ,Xs       = [for(v=vertices) v.x]
  ,Ys       = [for(v=vertices) v.y]
  ,Zs       = [for(v=vertices) v.z]
) [[min(Xs),min(Ys),min(Zs)],[max(Xs),max(Ys),max(Zs)]];

//*****************************************************************************
// type check
function fl_has(type,property,check=function(value) true) =
  assert(is_string(property))
  assert(is_list(type))
  assert(is_function(check))
  let(i=search([property],type)) 
  i != [[]] ? assert(len(type[i[0]])==2,"Malformed type") check(type[i[0]][1]) : false;

module fl_parse(verbs) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  for($verb=is_list(verbs) ? verbs : [verbs]) {
    tokens = split($verb);
    fl_trace(tokens[0]);
    if (fl_isSet("**DEPRECATED**",tokens)) {
      fl_trace(str("***WARN*** ", tokens[0], " is marked as DEPRECATED and will be removed in future version!"),always=true);
    } else if (fl_isSet("**OBSOLETE**",tokens)) {
      assert(false,str(tokens[0], " is marked as OBSOLETE!"));
    }
    children();
  }
}

function fl_trace(a1,a2,n=0,always=false) =
  a2!=undef ? str(strcat([for (i=[$parent_modules-1:-1:n]) parent_module(i)],"->"),": ",str(a1,"==",a2))
  : str(strcat([for (i=[$parent_modules-1:-1:n]) parent_module(i)],"->"),": ",a1);

module fl_trace(a1,a2,n=1,always=false) {
  assert(a1!=undef);
  if ($FL_TRACE||always) echo(fl_trace(a1,a2,n,always));
}

/*
 * Applies a Rotation Matrix for aligning fl_vector A (from) to fl_vector B (to).
 *
 * Taken from 
 * [How to Calculate a Rotation Matrix to Align Vector A to Vector B in 3D](https://gist.github.com/kevinmoran/b45980723e53edeb8a5a43c49f134724)
 */
function fl_align(from,to) =
  assert(is_list(from))
  assert(is_list(to),str("to=",to))
  assert(norm(from)>0)
  assert(norm(to)>0)

  let(u1 = fl_versor(from),u2 = fl_versor(to))
  u1==u2 ? FL_I : 
  u1==-u2 ? fl_S(-1) : // in this case the algorithm would fails, so we use a simpler way
  let(
    axis  = cross( u1, u2 ), // cross product == prodotto vettoriale: normale al piano [u1,u2] 
    cosA  = u1 * u2, // dot product == prodotto scalare: Σa[i]*b[i] nullo se u1 e u2 sono ortogonali
    k     = 1.0 / (1.0 + cosA)
  )
  [
        [(axis.x * axis.x * k) + cosA, (axis.y * axis.x * k) - axis.z, (axis.z * axis.x * k) + axis.y,0],
        [(axis.x * axis.y * k) + axis.z,(axis.y * axis.y * k) + cosA,(axis.z * axis.y * k) - axis.x,  0],
        [(axis.x * axis.z * k) - axis.y,(axis.y * axis.z * k) + axis.x,(axis.z * axis.z * k) + cosA,  0],
        [0,     0,    0,    1]
  ];

module fl_align(from,to) {
  assert(is_list(from));
  assert(is_list(to));
  assert(norm(from)>0);
  assert(norm(to)>0);
  
  u1 = fl_versor(from);
  u2 = fl_versor(to);
  if (u1==u2)
    children();
  else if (u1==-u2) // in this case the algorithm would fails, so we use a simpler way
    multmatrix(fl_S(-1)) children();
  else {
    axis  = cross( u1, u2 ); // cross product == prodotto vettoriale: normale al piano [u1,u2] 
    cosA  = u1 * u2; // dot product == prodotto scalare: Σa[i]*b[i] nullo se u1 e u2 sono ortogonali
    k     = 1.0 / (1.0 + cosA);
    multmatrix(
      [
        [(axis.x * axis.x * k) + cosA, (axis.y * axis.x * k) - axis.z, (axis.z * axis.x * k) + axis.y,0],
        [(axis.x * axis.y * k) + axis.z,(axis.y * axis.y * k) + cosA,(axis.z * axis.y * k) - axis.x,  0],
        [(axis.x * axis.z * k) - axis.y,(axis.y * axis.z * k) + axis.x,(axis.z * axis.z * k) + cosA,  0],
        [0,     0,    0,    1]
      ])
      children();
  }
}

// Aligns children from u1 to u2 and move to position
module fl_overlap(u1,u2,position) {
  translate(position)
    fl_align(u1,u2)
      children();
}

// Draws a fl_vector [out|in]ward P
module fl_vector(P,outward=true,endpoint="arrow") { 
  assert(is_list(P));
  length  = norm(P);
  d       = length / 20;
  head_r  = 1.5 * d;

  if (norm(P)>0) {
    fl_align(FL_Z,P)
      color("grey") {
        if (outward)
          translate(fl_Z(length-head_r)) cylinder(r2=0,r1=head_r,h=head_r);
        else
          cylinder(r1=0,r2=head_r,h=head_r);
        if (outward)
          cylinder(d = d, h = length - head_r, $fn = 32);
        else
          translate(+fl_Z(head_r)) cylinder(d = d, h = length-head_r, $fn = 32);
      }
  }
}

// Draws a fl_versor facing point P
module fl_versor(P) {
  fl_vector(fl_versor(P));
}

module fl_axes(size=1,reverse=false) {
  sz  = is_list(size) 
      ? assert(size.x>=0 && size.y>=0 && (size.z==undef||size.z>=0)) size 
      : assert(size>=0) [size,size,size];
  fl_trace("Size:",sz);
  color("red")   fl_vector(sz.x*FL_X,reverse==undef || !reverse);
  color("green") fl_vector(sz.y*FL_Y,reverse==undef || !reverse);
  if (sz.z) color("blue")  fl_vector(sz.z*FL_Z,reverse==undef || !reverse);
}

/* A do-nothing helper */
// module fl_nop() {
//   sphere(0);
// }

// debug switch on $FL_DEBUG
module fl_color(color,alpha=1) {

  function palette(name) =
    name=="bronze"        ? "#CD7F32"
    : name=="copper red"  ? "#CB6D51"
    : name=="copper penny"? "#AD6F69"
    : name=="pale copper" ? "#DA8A67"
    : name;

  module do() {color(palette(color),alpha) children();}

  if ($FL_DEBUG) #do() children();
  else do() children();
}

function fl_parse_l(l,l1,def)              = (l!=undef ? l : (l1!=undef ? l1 : undef));
function fl_parse_radius(r,r1,d,d1,def)    = (r!=undef ? r : (r1!=undef ? r1 : (d!=undef ? d/2 : (d1!=undef ? d1/2:undef))));
function fl_parse_diameter(r,r1,d,d1,def)  = (d!=undef ? d : (d1!=undef ? d1 : (r!=undef ? 2*r : (r1!=undef ? 2*r1:undef))));

/* true when n is multiple of m */
function fl_isMultiple(n,m) = (n % m == 0);

/* true when n is even */
function fl_isEven(n) = fl_isMultiple(n,2);

/* true when n is odd */
function fl_isOdd(n) = !fl_isEven(n);

// transforms 3D to 2D coords
function fl_2(v) =
  assert(len(v)>1)
  [v.x,v.y];

// transforms homogeneous to 3D coords
function fl_3(v)  =
  assert(len(v)>2)
  len(v)==3 ? v : [v.x,v.y,v.z] / v[3];

// transforms 3D coords to homogeneous
function fl_4(v)  = 
  assert(len(v)>2)
  len(v)==3 ? [v.x,v.y,v.z,1] : v / v[3];

// Returns M * v , actually transforming v by M.
// NOTE: result in 3d format
function fl_transform(
  M,// 4x4 transformation matrix
  v // fl_vector (in homogeneous or 3d format)
) =
  assert(len(M)==4 && len(M[0])==4,str("Bad matrix M(",M,")"))
  assert(is_list(v) && len(v)>2,str("Bad vector v(",v,")"))
  fl_3(M * fl_4(v));

//**** list utils *************************************************************

FL_EXCLUDE_ANY  = ["AND",function(one,other) one!=other];
FL_INCLUDE_ALL  = ["OR", function(one,other) one==other];

function fl_list_filter(list,operator,compare,__result__=[],__first__=true) =
// echo(list=list,compare=compare,operator=operator,__result__=__result__,__first__=__first__)
assert(is_list(list)||is_string(list),list)
assert(is_list(compare)||is_string(compare),compare)
let(
  s_list  = is_list(list) ? list : [list],
  c_list  = is_string(compare) ? [compare] : compare,
  len     = len(c_list),
  logic   = operator[0],
  f       = operator[1],
  string  = c_list[0],
  match   = [for(item=(logic=="OR" || __first__) ? s_list:__result__) if (f(item,string)) item],
  result  = (logic=="OR") ? concat(__result__,match) : match
)
// echo(match=match, result=result) 
len==1 ? result : fl_list_filter(s_list,operator,[for(i=[1:len-1]) c_list[i]],result,false);

function fl_list_has(list,item) = len(fl_list_filter(list,FL_INCLUDE_ALL,item))>0;

//**** math utils *************************************************************

function fl_XOR(c1,c2)        = (c1 && !c2) || (!c1 && c2);
function fl_accum(v)          = [for(p=v) 1]*v;
function fl_sub(list,from,to) = [for(i=from;i<to;i=i+1) list[i]];

//**** internally used 'lazy' math ************************************************

// function _sum_(x,y) = (x!=undef && y!=undef) ? x + y : undef;
// function _sub_(x,y) = (x!=undef && y!=undef) ? x - y : undef;
// function _mul_(x,y) = (x!=undef && y!=undef) ? x * y : undef;
// function _div_(x,y) = (x!=undef && y!=undef) ? x / y : undef;
// function _lst_(l)   = fl_accum(l)!=undef ? l : undef;

// function fl_synonymous(syns) = 
//   echo(syns=syns)
//   syns==[] 
//   ? echo("Empty --> UNDEF") undef 
//   : syns[0]!=undef 
//     ? echo(str("First OK --> syns[0]=",syns[0])) syns[0] 
//     : len(syns)==1
//       ? echo("Last KO --> UNDEF") undef 
//       : echo("Current KO --> RECURSION") fl_synonymous([for(i=[1:len(syns)-1]) syns[i]]);
