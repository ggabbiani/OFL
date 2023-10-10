/*!
 * Base definitions for OpenSCAD.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <TOUL.scad>               // TOUL       : The OpenScad Useful Library
use     <scad-utils/spline.scad>  // scad-utils : Utility libraries for OpenSCAD

//*****************************************************************************
// language extension

/*!
 * implementation of switch statement as a function: when «value» matches a case,
 * corresponding value is returned, undef otherwise.
 *
 * example:
 *
 *     value = 2.5;
 *     result = fl_switch(value,[
 *         [2,  3.2],
 *         [2.5,4.0],
 *         [3,  4.0],
 *         [5,  6.4],
 *         [6,  8.0],
 *         [8,  9.6]
 *       ]
 *     );
 *
 * result will be set to 4.0.
 */
function fl_switch(
  //! the value to be checked
  value,
  //! a list with each item composed by a couple «expression result»/«value»
  cases,
  //! value returned in case of no match
  otherwise=undef
) = let(
  match = [for(case=cases) if (value==case[0]) case[1]]
) match ? match[0] : otherwise;

//*****************************************************************************
// versioning

function fl_version() = [4,0,0];

function fl_versionNumber() = let(
  version = fl_version()
) version.x*10000+version.y*100+version.z;

//*****************************************************************************
// status

module fl_status() {
  v=fl_version();
  echo(str("**OFL** Version : ",v.x,".",v.y,".",v.z));
  echo(str("**OFL** Debug   : ",fl_debug()));
}

//*****************************************************************************
// lists

//! quick sort algorithm
function sort(vec) =
  len(vec)==0 ? [] : let(
    pivot = vec[floor(len(vec)/2)],
    below = [for (y = vec) if (y  < pivot) y],
    equal = [for (y = vec) if (y == pivot) y],
    above = [for (y = vec) if (y  > pivot) y]
  ) concat(sort(below), equal, sort(above));

//*****************************************************************************
// assertions
// TODO: remove this section since DEPRECATED

module fl_assert(condition, message) {
  // echo($fl_asserts=$fl_asserts,condition=condition,message=message);
  if (fl_debug())
    echo("assertions enabled") assert(condition,str("****ASSERT****: ",message));
  children();
}

function fl_assert(condition,message,result) =
  // echo($fl_asserts=$fl_asserts,condition=condition,message=message,result=result)
  fl_debug()
    ? echo("assertions enabled") is_list(condition)
      ? assert(is_list(message)) condition ? assert(condition[0],message[0]) fl_assert(fl_pop(condition),message?fl_pop(message):[],result) : result
      : assert(condition,str("****ASSERT****: ",message)) result
    : /* echo("assertions disabled") */ result;

//*****************************************************************************
// lists

//! removes till the i-indexed element from the top of list «l»
function fl_pop(l,i=0) =
  // echo(l=l,i=i)
  let(len=len(l))
  assert(!is_undef(len) && len>i,str("i=",i," len=",len))
  i>len-2 ? [] : [for(j=[i+1:len(l)-1]) l[j]];

//! push «item» on tail of list «l»
function fl_push(list,item) = [each list,item];

//*****************************************************************************
// OFL GLOBALS

//! When true, disables PREVIEW corrections (see variable FL_NIL)
$FL_RENDER  = is_undef($FL_RENDER) ? !$preview : $FL_RENDER;

//! simple workaround for the z-fighting problem during preview
FL_NIL    = ($preview && !$FL_RENDER ? 0.01 : 0);
FL_2xNIL  = 2*FL_NIL;

//! PER SURFACE distance in case of movable parts to be doubled when applied to a diameter
fl_MVgauge  = 0.6;

//! PER SURFACE distance in case of jointed parts to be doubled when applied to a diameter
fl_JNgauge  = fl_MVgauge/4;

//! Recommended tolerance for FDM as stated in [How do you design snap-fit joints for 3D printing?](https://www.3dhubs.com/knowledge-base/how-design-snap-fit-joints-3d-printing/)
fl_FDMtolerance = 0.5;

//! X axis
FL_X = [1,0,0];
//! Y axis
FL_Y = [0,1,0];
//! Z axis
FL_Z = [0,0,1];
//! Origin
FL_O = [0,0,0];

//! [Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping first octant
FL_O0 = [+1,+1,+1];
//! [Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping octant 1
FL_O1 = [-1,+1,+1];
//! [Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping octant 2
FL_O2 = [-1,-1,+1];
//! [Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping octant 3
FL_O3 = [+1,-1,+1];
//! [Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping octant 4
FL_O4 = [+1,-1,-1];
//! [Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping octant 5
FL_O5 = [-1,-1,-1];
//! [Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping octant 6
FL_O6 = [-1,+1,-1];
//! [Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping octant 7
FL_O7 = [+1,+1,-1];

//! Roman enumeration of first quadrant
FL_QI   = [+1,+1,undef];
//! Roman enumeration of quadrant 2
FL_QII  = [-1,+1,undef];
//! Roman enumeration of quadrant 3
FL_QIII = [-1,-1,undef];
//! Roman enumeration of quadrant 4
FL_QIV  = [+1,-1,undef];

//! identity matrix in homogeneous coordinates
FL_I=[
  [1,0,0,0],
  [0,1,0,0],
  [0,0,1,0],
  [0,0,0,1],
];

//! translation matrix in homogeneous coordinates
function fl_T(
  /*!
   * depending on the passed value the actual translation matrix will be:
   *
   * - scalar ⇒ [t,t,t]
   * - 2d space vector⇒ [t.x,t.y,0]
   * - 3d space vector⇒ [t.x,t.y,t.z]
   */
  t
) = let(
  l = len(t),
  t = is_undef(l) ? [t,t,t] : l==2 ? [t.x,t.y,0] : t
) assert(len(t)>=3) [
    [1,0,0, t.x ],
    [0,1,0, t.y ],
    [0,0,1, t.z ],
    [0,0,0, 1   ]
  ];

//! scale matrix in homogeneous coordinates
function fl_S(s) = is_list(s)
  ? [
      [s.x, 0,    0,    0 ],
      [0,   s.y,  0,    0 ],
      [0,   0,    s.z,  0 ],
      [0,   0,    0,    1 ]
    ]
  : fl_S([s,s,s]);

//! rotation around X matrix
function fl_Rx(theta) =
[
  [1,           0,            0,           0],
  [0,           cos(theta),   -sin(theta), 0],
  [0,           sin(theta),   cos(theta),  0],
  [0,           0,            0,           1]
];

//! rotation around Y matrix
function fl_Ry(theta) = [
  [cos(theta),  0,            sin(theta),  0],
  [0,           1,            0,           0],
  [-sin(theta), 0,            cos(theta),  0],
  [0,           0,            0,           1]
];

//! rotation around Z matrix
function fl_Rz(theta) = [
  [cos(theta),  -sin(theta),  0,  0],
  [sin(theta),  cos(theta),   0,  0],
  [0,           0,            1,  0],
  [0,           0,            0,  1]
];

//! composite rotation around X then Y then Z axis
function fl_Rxyz(angle) = fl_Rz(angle.z) * fl_Ry(angle.y) * fl_Rx(angle.x);

/*!
 * rotation matrix about arbitrary axis.
 *
 * TODO: check with more efficient alternative [here](https://gist.github.com/kevinmoran/b45980723e53edeb8a5a43c49f134724)
 */
function fl_R(
  //! arbitrary axis
  u,
  //! rotation angle around «u»
  theta
) =
  let(M = fl_align(u,FL_X))
  matrix_invert(M)  // align X to «u»
  * fl_Rx(theta)    // rotate «theta» about X
  * M;              // align «u» to X

//! Axis X * scalar «x». Generally used for X translation
function fl_X(x) = [x,0,0];
//! Axis Y * scalar «y». Generally used for Y translation
function fl_Y(y) = [0,y,0];
//! Axis Z * scalar «z». Generally used for Z translation
function fl_Z(z) = [0,0,z];

/*!
 * return true if «flag» is present in «list».
 * TODO: make a case insensitive option
 */
function fl_isSet(flag,list) = search([flag],list)!=[[]];

/******************************************************************************
 * verbs
 *****************************************************************************/

//! add a base shape (with no components nor screws)
FL_ADD        = "FL_ADD add base shape (no components nor screws)";
/*!
 * add predefined component shape(s).
 *
 * **NOTE:** this operation doesn't include screws, for these see variable FL_MOUNT
 */
FL_ASSEMBLY   = "FL_ASSEMBLY add predefined component shape(s)";
//! draws local reference axes
FL_AXES       = "FL_AXES draw of local reference axes";
//! adds a bounding box containing the object
FL_BBOX       = "FL_BBOX adds a bounding box containing the object";
//! layout of predefined cutout shapes (±X,±Y,±Z)
FL_CUTOUT     = "FL_CUTOUT layout of predefined cutout shapes (±X,±Y,±Z).";
//! test verb for library development
FL_DEPRECATED = "FL_DEPRECATED is a test verb. **DEPRECATED**";
/*!
 * composite verb serializing one ADD and ASSEMBLY operation.
 * See also variable FL_ADD and variable FL_ASSEMBLY
 */
FL_DRAW       = [FL_ADD,FL_ASSEMBLY];
//! layout of predefined drill shapes (like holes with predefined screw diameter)
FL_DRILL      = "FL_DRILL layout of predefined drill shapes (like holes with predefined screw diameter)";
//! adds a footprint to scene, usually a simplified ADD operation (see variable FL_ADD)
FL_FOOTPRINT  = "FL_FOOTPRINT adds a footprint to scene, usually a simplified FL_ADD";
//! adds vitamine holders to the scene. **Warning** this verb is **DEPRECATED**
FL_HOLDERS    = "FL_HOLDERS adds vitamine holders to the scene. **DEPRECATED**";
//! layout of user passed accessories (like alternative screws)
FL_LAYOUT     = "FL_LAYOUT layout of user passed accessories (like alternative screws)";
//! mount shape through predefined screws
FL_MOUNT      = "FL_MOUNT mount shape through predefined screws";
//! test verb for library development
FL_OBSOLETE   = "FL_OBSOLETE is a test verb. **OBSOLETE**";
//! adds a box representing the payload of the shape
FL_PAYLOAD    = "FL_PAYLOAD adds a box representing the payload of the shape";
//! add symbols and labels usually for debugging
FL_SYMBOLS    = "FL_SYMBOLS adds symbols and labels usually for debugging";

// Runtime behavior defaults
$FL_ADD       = is_undef($FL_ADD)       ? "ON"          : $FL_ADD;        // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
$FL_ASSEMBLY  = is_undef($FL_ASSEMBLY)  ? "ON"          : $FL_ASSEMBLY;   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
$FL_AXES      = is_undef($FL_AXES)      ? "ON"          : $FL_AXES;       // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
$FL_BBOX      = is_undef($FL_BBOX)      ? "TRANSPARENT" : $FL_BBOX;       // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
$FL_CUTOUT    = is_undef($FL_CUTOUT)    ? "ON"          : $FL_CUTOUT;     // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
$FL_DRILL     = is_undef($FL_DRILL)     ? "ON"          : $FL_DRILL;      // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
$FL_FOOTPRINT = is_undef($FL_FOOTPRINT) ? "ON"          : $FL_FOOTPRINT;  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
$FL_HOLDERS   = is_undef($FL_HOLDERS)   ? "ON"          : $FL_HOLDERS;    // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
$FL_LAYOUT    = is_undef($FL_LAYOUT)    ? "ON"          : $FL_LAYOUT;     // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
$FL_MOUNT     = is_undef($FL_MOUNT)     ? "ON"          : $FL_MOUNT;      // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
$FL_PAYLOAD   = is_undef($FL_PAYLOAD)   ? "DEBUG"       : $FL_PAYLOAD;    // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
$FL_SYMBOLS   = is_undef($FL_SYMBOLS)   ? "ON"          : $FL_SYMBOLS;    // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

//! given a verb returns the corresponding modifier value
function fl_verb2modifier(verb)  =
    verb==FL_ADD        ? $FL_ADD
  : verb==FL_ASSEMBLY   ? $FL_ASSEMBLY
  : verb==FL_AXES       ? $FL_AXES
  : verb==FL_BBOX       ? $FL_BBOX
  : verb==FL_CUTOUT     ? $FL_CUTOUT
  : verb==FL_DRILL      ? $FL_DRILL
  : verb==FL_FOOTPRINT  ? $FL_FOOTPRINT
  : verb==FL_HOLDERS    ? $FL_HOLDERS
  : verb==FL_LAYOUT     ? $FL_LAYOUT
  : verb==FL_MOUNT      ? $FL_MOUNT
  : verb==FL_PAYLOAD    ? $FL_PAYLOAD
  : verb==FL_SYMBOLS    ? $FL_SYMBOLS
  : assert(false,str("Unsupported verb ",verb)) undef;

/*!
 * Modifier module for verbs.
 */
module fl_modifier(
  //! "OFF","ON","ONLY","DEBUG","TRANSPARENT"
  behavior,
  reset=true
) {
  fl_trace("behavior",behavior);
  // Runtime behavior reset vs pass-through
  if (reset) {
    $FL_ADD       = behavior;
    $FL_ASSEMBLY  = behavior;
    $FL_AXES      = behavior;
    $FL_BBOX      = behavior;
    $FL_CUTOUT    = behavior;
    $FL_DRILL     = behavior;
    $FL_FOOTPRINT = behavior;
    $FL_HOLDERS   = behavior;
    $FL_LAYOUT    = behavior;
    $FL_MOUNT     = behavior;
    $FL_PAYLOAD   = behavior;
    $FL_SYMBOLS   = behavior;
  }
  if      (behavior=="ON")                children();
  else if (behavior=="OFF")              *children();
  else if (behavior=="ONLY")             !children();
  else if (behavior=="DEBUG")            #children();
  else if (behavior=="TRANSPARENT")      %children();
  else assert(false,str("Unknown behavior ('",behavior,"')."));
}

//! deprecated function call
function fl_deprecated(bad,value,replacement) = let(
    complain  = str("***DEPRECATED***: ", bad, " is deprecated and ", replacement!=undef ? str("will be replaced by ", replacement, " in next major release.") : "WILL NOT BE REPLACED.")
  ) echo(complain) value;

/*!
 * setup a verb list according on the setting of the runtime attributes
 *
 * example:
 *
 *     verbs         = fl_verbList([FL_ADD,FL_ASSEMBLY,FL_AXES])
 *
 * is functionally equivalent to the following:
 *
 *     verbs = [
 *       if ($FL_ADD!="OFF")      FL_ADD,
 *       if ($FL_ASSEMBLY!="OFF") FL_ASSEMBLY,
 *       if ($FL_BBOX!="OFF")     FL_BBOX,
 *     ]
 *
 * if elsewhere the attribute variables as been set like this:
 *
 *     $FL_ADD       = "OFF"
 *     $FL_ASSEMBLY  = "ON"
 *     $FL_BBOX      = "DEBUG"
 *
 * «verbs» will hold the following contents:
 *
 *     [FL_ASSEMBLY,FL_BBOX]
 *
 * while FL_ADD is ignored since its runtime attribute is "OFF"
 */
function fl_verbList(
  /*!
   * list of supported verbs whose runtime attribute is checked for they
   * eventual insertion in the returned list
   */
  supported
) = [
  for(verb=supported)
    let(attribute=fl_verb2modifier(verb))
    // assert(attribute!=undef,str("Unmapped verb ",verb))
    if (attribute!="OFF") assert(attribute,str("Unmapped verb ",verb)) verb
];

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
function fl_dxf(type,value)         = fl_property(type,"DXF model file",value);
function fl_engine(type,value)      = fl_property(type,"engine",value);
function fl_holes(type,value)       = assert(is_undef(value)||fl_tt_isHoleList(value),value) fl_property(type,"holes",value);
function fl_material(type,value,default)
                                    = fl_property(type,"material (actually a color)",value,default);
function fl_name(type,value)        = fl_property(type,"name",value);
function fl_native(type,value)      = fl_property(type,"OFL native type (boolean)",value,type!=undef?false:undef);
function fl_nopSCADlib(type,value,default)
                                    = fl_property(type,"Verbatim NopSCADlib definition",value,default);
function fl_pcb(type,value)         = fl_property(type,"embedded OFL pcb",value);
// pay-load bounding box, it contributes to the overall bounding box calculation
function fl_payload(type,value)     = fl_property(type,"payload bounding box",value);
function fl_tag(type,value)         = fl_property(type,"product tag",value);
function fl_screw(type,value)       = fl_property(type,"screw",value);
function fl_stl(type,value)         = fl_property(type,"STL geometry file",value);
function fl_tolerance(type,value)   = fl_property(type,"tolerance",value);
function fl_vendor(type,value)      = fl_property(type,"vendor",value);
/*
 * cut-out directions in floating semi-axis list form as described in fl_tt_isAxisList().
 *
 * This property represents the list of cut-out directions supported by the passed type.
 */
function fl_cutout(type,value)      = fl_property(type,"cut-out direction list",value);
//*****************************************************************************
// Derived getters
function fl_size(type)    = fl_bb_size(type);
function fl_width(type)   = fl_size(type).x;
function fl_height(type)  = fl_size(type).y;
function fl_thick(type)   = fl_size(type).z;

//*****************************************************************************
// type check
function fl_has(type,property,check=function(value) true) =
  assert(is_string(property))
  assert(is_list(type))
  assert(is_function(check))
  let(i=search([property],type))
  i != [[]] ? assert(len(type[i[0]])==2,"Malformed type") check(type[i[0]][1]) : false;

/*!
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

//! Aligns children from u1 to u2 and move to position
module fl_overlap(u1,u2,position) {
  translate(position)
    fl_align(u1,u2)
      children();
}

//! Draws a fl_vector [out|in]ward P
module fl_vector(P,outward=true,endpoint="arrow",ratio=20) {
  assert(is_list(P));
  length  = norm(P);
  d       = length / ratio;
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

//! Draws a fl_versor facing point P
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

//! Generate a shade of grey to pass to color().
function fl_grey(n) = [0.01, 0.01, 0.01] * n;

/*!
 * returns the canonical axis color when invoked by «axis»
 *
 *     X ⟹ red
 *     Y ⟹ green
 *     Z ⟹ blue
 *
 * or the corresponding color palette if invoked by «color»
 *
 * __NOTE__: «axis» and «color» are mutually exclusive.
 */
function fl_palette(color,axis) = assert(
  (color!=undef && axis==undef)||color==undef && axis!=undef,str("color=",color,",axis=",axis)
) let(
  versor = axis
  ? assert(!fl_debug() || fl_tt_isAxis(axis),axis) fl_versor(axis)
  : assert(!fl_debug() || fl_tt_isColor(color),color) undef
) versor ? (  (versor==FL_X||versor==-FL_X) ? "red"
            : (versor==FL_Y||versor==-FL_Y) ? "green"
            : (versor==FL_Z||versor==-FL_Z) ? "blue"
            : assert(false, axis) undef)
          : (
              color=="bronze"        ? "#CD7F32"
            : color=="copper red"    ? "#CB6D51"
            : color=="copper penny"  ? "#AD6F69"
            : color=="pale copper"   ? "#DA8A67"
            : color);

/*!
 * Set current color and alpha channel, using variable $fl_filament when «color» is
 * undef. When variable $fl_debug is true, color information is ignored and debug
 * modifier is applied to children().
 */
module fl_color(color,alpha=1) {
  color = color ? color : fl_filament();
  if (fl_debug())
    #children();
  else let(
    c = fl_palette(color=color)
  ) if (c!="ignore") {
      color(c,alpha)
        children();
    } else
      children();
}

function fl_parse_l(l,l1,def)              = (l!=undef ? l : (l1!=undef ? l1 : undef));
function fl_parse_radius(r,r1,d,d1,def)    = (r!=undef ? r : (r1!=undef ? r1 : (d!=undef ? d/2 : (d1!=undef ? d1/2:undef))));
function fl_parse_diameter(r,r1,d,d1,def)  = (d!=undef ? d : (d1!=undef ? d1 : (r!=undef ? 2*r : (r1!=undef ? 2*r1:undef))));

//! true when n is multiple of m
function fl_isMultiple(n,m) = (n % m == 0);

//! true when n is even
function fl_isEven(n) = fl_isMultiple(n,2);

//! true when n is odd
function fl_isOdd(n) = !fl_isEven(n);

//! transforms 3D to 2D coords
function fl_2(v) =
  assert(len(v)>1)
  [v.x,v.y];

//! transforms homogeneous to 3D coords
function fl_3(v)  =
  assert(len(v)>2)
  len(v)==3 ? v : [v.x,v.y,v.z] / v[3];

//! transforms 3D coords to homogeneous
function fl_4(v)  =
  assert(len(v)>2)
  len(v)==3 ? [v.x,v.y,v.z,1] : v / v[3];

/*!
 * Returns M * v , actually transforming v by M.
 *
 * **NOTE:** result in 3d format
 */
function fl_transform(
  //! 4x4 transformation matrix
  M,
  //! fl_vector (in homogeneous or 3d format)
  v
) =
  assert(len(M)==4 && len(M[0])==4,str("Bad matrix M(",M,")"))
  assert(is_list(v) && len(v)>2,str("Bad vector v(",v,")"))
  fl_3(M * fl_4(v));

//**** math utils *************************************************************

function fl_XOR(c1,c2)        = (c1 && !c2) || (!c1 && c2);
function fl_accum(v)          = [for(p=v) 1]*v;
function fl_sub(list,from,to) = [for(i=from;i<to;i=i+1) list[i]];

//**** lists ******************************************************************

/*!
 * return the list item whose calculated value is max.
 *
 * Return 'undef' in case of empty «list».
 */
function fl_max(
  //! item list
  list,
  /*!
   * string literal assigning items a value: essentially it determines the way
   * a 'score' is mapped to a corresponding list item for the 'max' evaluation
   *
   * As default simply returns the item (i.e. the 'score' is the item itself).
   */
  value=function(item) item,
  _i_=0
) = (_i_+1)<len(list) ? let(other=fl_max(list,value,_i_+1)) value(list[_i_])>value(other) ? list[_i_] : list[_i_+1] : list[_i_];

//**** dictionary *************************************************************

function fl_dict_search(dictionary,name) = [
  for(item=dictionary) let(n=fl_name(item)) if (name==n) item
];

/*!
 * build a dictionary with rows constituted by items with equal property as
 * retrieved by «func»
 */
function fl_dict_organize(dictionary,range,func) =
  [for(value=range)
    [for(item=dictionary) let(property=func(item)) if (property==value) item]
  ];

/*!
 * Optional getter, no error when property is not found.
 *
 * Return «default» when «type» is undef or empty, or when «key» is not found
 *
 * | type    | key     | default | key found | result    | semantic |
 * | ------- | ------- | ------- | --------- | --------- | -------- |
 * | undef   | *       | *       | *         | default   | GETTER   |
 * | defined | defined | *       | false     | default   | GETTER   |
 * | defined | defined | *       | true      | value     | GETTER   |
 *
 * **ERROR** in all the other cases
 */
function fl_optional(type,key,default) =
  type==undef ? default : let(r=search([key],type)) r!=[[]] ? type[r[0]][1] : default;

/*!
 * Mandatory property getter with default value when not found
 *
 * Never return undef.
 *
 * | type    | key     | default | key found | result    | semantic |
 * | ------- | ------- | ------- | --------- | --------- | -------- |
 * | defined | defined | *       | true      | value     | GETTER   |
 * | defined | defined | defined | false     | default   | GETTER   |
 *
 * **ERROR** in all the other cases
 */
function fl_get(type,key,default) =
  assert(key!=undef)
  assert(type!=undef)
  let(index_list=search([key],type))
  index_list != [[]]
  ? type[index_list[0]][1]
  : assert(default!=undef,str("Key not found ***",key,"*** in ",type)) default;

//**** key/values *************************************************************

/*!
 * 'bipolar' property helper:
 *
 * - type/key{/default} ↦ returns the property value (error if property not found)
 * - key{/value}        ↦ returns the property [key,value] (acts as a property constructor)
 *
 * It concentrates property key definition reducing possible mismatch when
 * referring to property key in the more usual getter/setter function pair.
 *
 * This getter never return undef.
 *
 * | type    | key     | default | key found | result      | semantic |
 * | ------- | ------- | ------- | --------- | ----------- | -------- |
 * | undef   | defined | undef   | *         | [key,value] |  SETTER  |
 * | defined | defined | *       | true      | value       |  GETTER  |
 * | defined | defined | defined | false     | default     |  GETTER  |
 *
 * **ERROR** in all the other cases
 */
function fl_property(type,key,value,default)  =
  assert(key!=undef)
  type!=undef
  ? fl_get(type,key,default)              // property getter
  : assert(default==undef)  [key,value];  // property constructor

/*!
 * 'bipolar' optional property helper:
 *
 * - type/key{/default} ↦ returns the property value (no error if property not found)
 * - key{/value}        ↦ returns the property [key,value] (acts as a property constructor)
 *
 * This getter returns 'undef' when the key is not found and no default is passed.
 *
 * | type    | key     | default | key found | result      | semantic |
 * | ------- | ------- | ------- | --------- | ----------- | -------- |
 * | undef   | defined | undef   | *         | [key,value] | SETTER   |
 * | defined | defined | *       | false     | default     | GETTER   |
 * | defined | defined | *       | true      | value       | GETTER   |
 *
 * **ERROR** in all the other cases
 */
function fl_optProperty(type,key,value,default) =
  type!=undef ? fl_optional(type,key,default) : fl_property(key=key,value=value);

//**** base geometry **********************************************************

function fl_versor(v) = assert(is_list(v),v) v / norm(v);

function fl_isParallel(a,b,exact=true) = let(prod = fl_versor(a)*fl_versor(b)) (exact ? prod : abs(prod))==1;

function fl_isOrthogonal(a,b) = a*b==0;

//**** Base tracing helpers ***************************************************

/*!
 * trace helper function.
 *
 * See module fl_trace{}.
 */
function fl_trace(msg,result,always=false) = let(
  call_chain  = strcat([for (i=[$parent_modules-1:-1:0]) parent_module(i)],"->"),
  mdepth      = $parent_modules
) assert(msg)
  (always||(!is_undef($FL_TRACES) && ($FL_TRACES==-1||$FL_TRACES>=mdepth)))
  ? echo(mdepth,str(call_chain,": ",msg,"==",result)) result
  : result;

/*!
 * trace helper module.
 *
 * prints «msg» prefixed by its call order either if «always» is true or if its
 * current call order is ≤ $FL_TRACES.
 *
 * Used $special variables:
 *
 * - $FL_TRACES affects trace messages according to its value:
 *   - -2   : all traces disabled
 *   - -1   : all traces enabled
 *   - [0,∞): traces with call order ≤ $FL_TRACES are enabled
 */
module fl_trace(
  //! message to be printed
  msg,
  //! optional value generally usable for printing a variable content
  value,
  //! when true the trace is always printed
  always=false
) {
  mdepth      = $parent_modules-1;
  if (always||(!is_undef($FL_TRACES) && ($FL_TRACES==-1||$FL_TRACES>=mdepth)))
    let(
      call_chain  = strcat([for (i=[$parent_modules-1:-1:1]) parent_module(i)],"->")
    ) echo(mdepth,str(call_chain?call_chain:"***",": ",is_undef(value)?msg:str(msg,"==",value))) children();
  else
    children();
}

//**** string utilities *******************************************************

function fl_str_upper(s) = let(len=len(s))
  len==0 ? ""
  : len==1 ? let(
      c   = s[0],
      cp  = ord(c),
      uc = cp>=97 && cp<=122 ? str(chr(ord(c)-32)) : c
    ) uc
  : str(fl_str_upper(s[0]),fl_str_upper([for(i=[1:len-1]) s[i]]));

function fl_str_lower(s) = let(
    len=len(s)
  )
  len==0 ? ""
  : len==1 ? let(
      c   = s[0],
      cp  = ord(c),
      lc = cp>=65 && cp<=90 ? str(chr(ord(c)+32)) : c
    ) lc
  : str(fl_str_lower(s[0]),fl_str_lower([for(i=[1:len-1]) s[i]]));

//! recursively flatten infinitely nested list
function fl_list_flatten(list) =
  assert(is_list(list))
  [
    for (i=list) let(sub = is_list(i) ? fl_list_flatten(i) : [i])
      for (i=sub) i
  ];

//! see fl_list_filter() «operator» parameter
FL_EXCLUDE_ANY  = ["AND",function(one,other) one!=other];
//! see fl_list_filter() «operator» parameter
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

/*****************************************************************************
 * Common parameter helpers
 *****************************************************************************/

//**** Global getters *********************************************************

/*!
 * When true fl_assert() is enabled
 *
 * **TODO**: remove since deprecated.
 */
function fl_asserts() = is_undef($fl_asserts) ? false : assert(is_bool($fl_asserts)) $fl_asserts;

//! When true debug statements are turned on
function fl_debug() = is_undef($fl_debug)
? /* echo("**DEBUG** false")  */ false
: assert(is_bool($fl_debug),$fl_debug) /* echo(str("**DEBUG** ",$fl_debug)) */ $fl_debug;

//! Default color for printable items (i.e. artifacts)
function fl_filament() = is_undef($fl_filament)
? "DodgerBlue"
: assert(is_string($fl_filament)) $fl_filament;

//**** Common parameters ******************************************************

/*!
 * Constructor for the octant parameter from values as passed by customizer
 * (see fl_octant() for the semantic behind).
 *
 * Each dimension can assume one out of four values:
 *
 * - "undef": mapped to undef
 * - -1,0,+1: untouched
 */
function fl_parm_Octant(x,y,z) = let(
  o_x = x=="undef" ? undef : is_num(x) ? x : atoi(x),
  o_y = y=="undef" ? undef : is_num(y) ? y : atoi(y),
  o_z = z=="undef" ? undef : is_num(z) ? z : atoi(z)
) [o_x,o_y,o_z];

//! constructor for debug context parameter
function fl_parm_Debug(
  //! when true, labels to symbols are assigned and displayed
  labels  = false,
  //! when true symbols are displayed
  symbols = false,
  /*
   * a string or a list of strings equals to the component label of which
   * direction information will be shown
   */
  components = []
) = [labels,symbols,components];

//! When true debug labels are turned on
function fl_parm_labels(debug) = is_undef(debug) ? false : assert(is_bool(debug[0])) debug[0];

//! When true debug symbols are turned on
function fl_parm_symbols(debug) = is_undef(debug) ? false : assert(is_bool(debug[1])) debug[1];

// When true show direction information of the component with «label»
function fl_parm_components(debug,label) = let(
  dbg = debug[2]
)   is_undef(debug) ? false
  : is_list(dbg) ? search([label],dbg)!=[[]]
  : is_string(dbg) ? dbg==label
  : assert(false,str("debug information must be a string or a list of strings: ", dbg)) undef;
