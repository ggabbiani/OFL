/*!
 * Base definitions for OpenSCAD.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

// include <TOUL.scad>               // TOUL       : The OpenScad Useful Library
use     <../../scad-utils/spline.scad>  // scad-utils : Utility libraries for OpenSCAD

//**** language extension *****************************************************

module fl_extrude_if(condition, height)
  if (condition)
    linear_extrude(height)
      children();
  else
    children();

module fl_render_if(condition)
  if (condition)
    render()
      children();
  else
    children();

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
  //! value returned in case of no match or when «value» is undef
  otherwise
) = let(
  match = is_undef(value) ? [] : [for(case=cases) if (value==case[0]) case[1]]
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
  echo(str("**OFL** Version: ",v.x,".",v.y,".",v.z));
  if (fl_debug()) {
    // echo(str("**OFL** Debug                 : ",fl_debug()));
    echo(str("**OFL** Viewport translation  : ",$vpt));
    echo(str("**OFL** Viewport rotation     : ",$vpr));
    echo(str("**OFL** Camera distance       : ",$vpd));
    let(
      v = concat($vpt,$vpr,[$vpd])
    ) echo(str("**OFL** camera parameters  : ",v[0],",",v[1],",",v[2],",",v[3],",",v[4],",",v[5],",",v[6]));
  }
}

//*****************************************************************************
// assertions

//! compose an error message
function fl_error(
  //! string or vector of strings
  message
) = fl_strcat(concat(["***OFL ERROR***:"],is_list(message) ? message : [message])," ");

//! force an error if condition is true
module fl_error(
  //! error condition
  condition,
  //! string or vector of strings
  message
) assert(condition==false,fl_error(message));

//! check condition, forcing error when false
module fl_assert(
  //! condition to be asserted
  condition,
  //! string or vector of strings
  message
) assert(condition==true,fl_error(message));

//**** base transformations ***************************************************

//! transforms 3D to 2D coords by clipping Z plane
function fl_2(v) = assert(len(v)>1) [v.x,v.y];

//! transforms homogeneous to 3D coords
function fl_3(v)  = assert(len(v)>2) len(v)==3 ? v : [v.x,v.y,v.z] / v[3];

//! transforms 3D coords to homogeneous
function fl_4(v)  = assert(len(v)>2) len(v)==3 ? [v.x,v.y,v.z,1] : v / v[3];

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

//**** CAD control ************************************************************

/*!
 * Returns the rotation list corresponding to an OpenSCAD projection view.
 *
 * Example setting OpenSCAD projection programmatically by changing the variable
 * $vpn value to the "top" view:
 *
 *     $vpr = fl_view("top");
 *
 */
function fl_view(
  /*!
   * one of the following esoteric names:
   *
   * - "right"
   * - "top"
   * - "bottom"
   * - "left"
   * - "front"
   * - "back"
   */
  name
) =
  fl_switch(name,[["right",[90,0,90]],["top",O],["bottom",[180,0,0]],["left",[90,0,270]],["front",[90,0,0]],["back",[90,0,180]]],$vpr);

/*!
 * returns the esoteric name associated to the current OpenSCAD view:
 *
 * | Returned string  | Projection plane  |
 * | ---------------- | ----------------- |
 * | "right"          | YZ                |
 * | "top"            | XY                |
 * | "bottom"         | YX                |
 * | "left"           | ZY                |
 * | "front"          | XZ                |
 * | "back"           | ZX                |
 * | "other"          | -                 |
 */
function fl_currentView() =
  fl_switch($vpr,[[[90,0,90],"right"],[O,"top"],[[180,0,0],"bottom"],[[90,0,270],"left"],[[90,0,0],"front"],[[90,0,180],"back"]],"other");


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

/*!
 * function literal converting from 2d to 3d by projection on plane Z==0
 *
 * NOTE: it's safe to be used as function literal parameter in fl_list_transform()
 */
FL_3D = function(2d) [2d.x,2d.y,0];

/*!
 * function literal converting 3D to 2D coords by clipping Z plane
 *
 * NOTE: it's safe to be used as function literal parameter in fl_list_transform()
 */
FL_2D = function(3d) fl_2(3d);

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
  t = is_num(t) ? [t,t,t] : assert(is_list(t),t) len(t)==2 ? [t.x,t.y,0] : assert(len(t)>=3,t) [t.x,t.y,t.z]
) [
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

//**** verbs ******************************************************************

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
  : assert(false,str("Unsupported verb ",verb)) undef;

/*!
 * Modifier module for verbs.
 */
module fl_modifier(
  //! "OFF","ON","ONLY","DEBUG","TRANSPARENT"
  behavior,
  reset=true
) {
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
 *     verbs         = fl_verbList([FL_ADD,FL_ASSEMBLY,FL_AXES]);
 *
 * is functionally equivalent to the following:
 *
 *     verbs = [
 *       if ($FL_ADD!="OFF")      FL_ADD,
 *       if ($FL_ASSEMBLY!="OFF") FL_ASSEMBLY,
 *       if ($FL_BBOX!="OFF")     FL_BBOX,
 *     ];
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

//**** General properties *****************************************************

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
/*
 * Layout directions in floating semi-axis list form as described in
 * fl_tt_isAxisList(). Represents the list of layout directions supported by the
 * passed type.
 *
 * **NOTE**: this property is generally setup automatically by constructors
 * from normals to holes eventually defined.
 */
// function fl_layouts(type,value)      = fl_property(type,"layout direction list",value);
function fl_material(type,value,default)
                                    = fl_property(type,"material (actually a color)",value,default);
function fl_name(type,value)        = fl_property(type,"name",value);
/*!
 * TODO: duplicate of fl_OFL()?!
 */
function fl_native(type,value)      = fl_property(type,"OFL native type (boolean)",value,type!=undef?false:undef);
function fl_nominal(type,value)     = fl_property(type,"Nominal property for «type»",value);
function fl_nopSCADlib(type,value,default)
                                    = fl_property(type,"Verbatim NopSCADlib definition",value,default);
/*!
 * when present and true indicates the object is an OFL one
 *
 * TODO: duplicate of fl_native()?!
 */
function fl_OFL(type,value,default) = fl_property(type,"Naturally born OFL",value,default);
function fl_pcb(type,value)         = fl_property(type,"embedded OFL pcb",value);
//! pay-load bounding box, it contributes to the overall bounding box calculation
function fl_payload(type,value)     = fl_property(type,"payload bounding box",value);
function fl_tag(type,value)         = fl_property(type,"product tag",value);
function fl_screw(type,value)       = fl_property(type,"screw",value);
function fl_stl(type,value)         = fl_property(type,"STL geometry file",value);
function fl_tolerance(type,value)   = fl_property(type,"tolerance",value);
function fl_vendor(type,value)      = fl_property(type,"vendor",value);
/*!
 * cut-out directions in floating semi-axis list form as described in
 * fl_tt_isAxisList().
 *
 * This property represents the list of cut-out directions supported by the
 * passed type.
 *
 * TODO: rename as plural
 */
function fl_cutout(type,value)      = fl_property(type,"cut-out direction list",value);
function fl_dimensions(type,value)  = fl_property(type,"dimension line pack",value);

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
 * modifier is applied to children(). If «color» is equal to "ignore" no color
 * is applied to children.
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

//**** math utils *************************************************************

function fl_XOR(c1,c2)        = (c1 && !c2) || (!c1 && c2);
function fl_accum(v)          = [for(p=v) 1]*v;

//! returns a vector in which each item is the sum of the previous ones
function fl_cumulativeSum(v) = [
  for (i = [0 : len(v) - 1])
    fl_accum([for(j=[0:i]) v[j]])
];

/*!
 * Ascii string to number conversion function atof() by Jesse Campbell.
 *
 * Scientific notation support added by Alexander Pruss.
 *
 * Copyright © 2017, Jesse Campbell <www.jbcse.com>
 *
 * SPDX-License-Identifier: CC-BY-4.0
 */
function fl_atof(str) =
  len(str)==0 ?
    0 : let(
      expon1 = search("e", str),
      expon = len(expon1) ? expon1 : search("E", str)
    ) len(expon) ? fl_atof(substr(str,pos=0,len=expon[0])) * pow(10, fl_atoi(substr(str,pos=expon[0]+1)))
    : let(
      multiplyBy = (str[0] == "-") ? -1 : 1,
      str = (str[0] == "-" || str[0] == "+") ? substr(str, 1, len(str)-1) : str,
      decimal = search(".", str),
      beforeDecimal = decimal == [] ? str : substr(str, 0, decimal[0]),
      afterDecimal = decimal == [] ? "0" : substr(str, decimal[0]+1)
    ) (multiplyBy * (fl_atoi(beforeDecimal) + fl_atoi(afterDecimal)/pow(10,len(afterDecimal))));

/*!
 * Returns the numerical form of a string
 *
 * Usage:
 *
 *     echo(fl_atoi("491585"));                 // 491585
 *     echo(fl_atoi("-15"));                    // -15
 *     echo(fl_atoi("01110", 2));               // 14
 *     echo(fl_atoi("D5A4", 16));               // 54692
 *     echo(fl_atoi("-5") + fl_atoi("10") + 5); // 10
 *
 * Original code pasted from TOUL: [The OpenScad Usefull
 * Library](http://www.thingiverse.com/thing:1237203)
 *
 * Copyright © 2015, Nathanaël Jourdane <nathanael@jourdane.net>
 *
 * SPDX-License-Identifier: CC-BY-4.0
 */
function fl_atoi(
  //! The string to converts (representing a number)
  str,
  /*!
   * The base conversion of the number
   *
   * | Value  | Description           |
   * | ------ | --------------------- |
   * | 2      | for binary            |
   * | 10     | for decimal (default) |
   * | 16     | for hexadecimal       |
   */
  base=10,
  i=0, nb=0
) =
	i == len(str) ? (str[0] == "-" ? -nb : nb) :
	i == 0 && str[0] == "-" ? fl_atoi(str, base, 1) :
	fl_atoi(str, base, i + 1,
		nb + search(str[i], "0123456789ABCDEF")[0] * pow(base, len(str) - i - 1));

//**** strings ****************************************************************

/*!
 *
 * Returns a substring of a string.
 *
 * Usage:
 *
 *     str = "OpenScad is a free CAD software.";
 *     echo(substr(str, 12)); // "a free CAD software."
 *     echo(substr(str, 12, 10)); // "a free CAD"
 *     echo(substr(str, len=8)); // or substr(str, 0, 8); // "OpenScad"
 *
 * Original code pasted from TOUL: [The OpenScad Useful
 * Library](http://www.thingiverse.com/thing:1237203)
 *
 * Copyright © 2015, Nathanaël Jourdane <nathanael@jourdane.net>
 *
 * SPDX-License-Identifier: CC-BY-4.0
 */
function fl_substr(
  //! the original string
  str,
  //! (optional): the substring position (0 by default).
  pos=0,
  //! (optional): the substring length (string length by default).
  len=-1,
  substr=""
) =
	len == 0 ?
    substr :
    len == -1 ?
      fl_substr(str, pos, len(str)-pos, substr) :
      fl_substr(str, pos+1, len-1, str(substr, str[pos]));

/*!
 * Returns a string of a concatenated vector of substrings `v`, with an optionally
 * separator `sep` between each. See also: fl_split().
 *
 * Usage:
 *     v = ["OpenScad", "is", "a", "free", "CAD", "software."];
 *     echo(fl_strcat(v));      // "OpenScadisafreeCADsoftware."
 *     echo(fl_strcat(v, " ")); // "OpenScad is a free CAD software."
 *
 * Original code pasted from TOUL: [The OpenScad Useful
 * Library](http://www.thingiverse.com/thing:1237203)
 *
 * Copyright © 2015, Nathanaël Jourdane <nathanael@jourdane.net>
 *
 * SPDX-License-Identifier: CC-BY-4.0
*/
function fl_strcat(
  //! The vector of string to concatenate
  v,
  //! A separator which will added between each substrings
  sep="",
  str="", i=0, j=0
) =
	i == len(v) ? str :
	j == len(v[i])-1 ? fl_strcat(v, sep,
		str(str, v[i][j], i == len(v)-1 ? "" : sep),   i+1, 0) :
	fl_strcat(v, sep, str(str, v[i][j]), i, j+1);

/*!
 * Returns a vector of substrings by cutting the string `str` each time where `sep` appears.
 * See also: fl_strcat(), str2vec()
 *
 * Usage:
 *
 *     str = "OpenScad is a free CAD software.";
 *     echo(fl_split(str));                 // ["OpenScad", "is", "a", "free", "CAD", "software."]
 *     echo(fl_split(str)[3]);              // "free"
 *     echo(fl_split("foo;bar;baz", ";"));  // ["foo", "bar", "baz"]
 *
 * Original code pasted from TOUL: [The OpenScad Useful
 * Library](http://www.thingiverse.com/thing:1237203)
 *
 * Copyright © 2015, Nathanaël Jourdane <nathanael@jourdane.net>
 *
 * SPDX-License-Identifier: CC-BY-4.0
 */
function fl_split(
  //! the original string
  str,
  //! The separator who cuts the string (" " by default)
  sep=" ",
  i=0, word="", v=[]
) =
	i == len(str) ? concat(v, word) :
	str[i] == sep ? fl_split(str, sep, i+1, "", concat(v, word)) :
	fl_split(str, sep, i+1, str(word, str[i]), v);

//**** lists ******************************************************************

/*!
 * calculates the median INDEX of a list
 */
function fl_list_medianIndex(l) = let(
  n = len(l)
) fl_isOdd(n) ? (n+1)/2-1 : n/2-1;

//! removes till the i-indexed element from the top of list «l»
function fl_pop(l,i=0) =
  // echo(l=l,i=i)
  let(len=len(l))
  assert(!is_undef(len) && len>i,str("i=",i," len=",len))
  i>len-2 ? [] : [for(j=[i+1:len(l)-1]) l[j]];

//! push «item» on tail of list «l»
function fl_push(list,item) = [each list,item];

//! returns a sub list
function fl_list_sub(list,from,to) = let(
  to  = is_undef(to) ? len(list)-1 : to
) [for(i=from;i<=to;i=i+1) list[i]];

/*!
 * Returns the «list» head according to «n»:
 *
 * - n>0: returns the first «n» elements of «list»
 * - n<0: returns «list» minus the last «n» items
 * - n==0: returns []
 *
 * example:
 *
 *     list=[1,2,3,4,5,6,7,8,9,10]
 *     fl_list_head(list,3)==[1,2,3]
 *
 * example:
 *
 *     list=[1,2,3,4,5,6,7,8,9,10]
 *     fl_list_head(list,-7)==[1,2,3]
 */
function fl_list_head(list,n) = let(
    len=len(list)
  )
  n==0 ?
    [] :
    len==0 ?
      [] :
      n>0 ?
        +n>=len ? list : [for(i=[0 : n-1     ]) list[i]]:
        -n>=len ? []   : [for(i=[0 : len-1+n ]) list[i]];

/*!
 * Returns the «list» tail according to «n»:
 *
 * - n>0: returns the last «n» elements of «list»
 * - n<0: returns «list» minus the first «n» items
 * - n==0: returns []
 *
 * example:
 *
 *     list=[1,2,3,4,5,6,7,8,9,10]
 *     fl_list_tail(list,3)==[8,9,10]
 *
 * example:
 *
 *     list=[1,2,3,4,5,6,7,8,9,10]
 *     fl_list_tail(list,-7)==[8,9,10]
 */
function fl_list_tail(list,n) = let(
    len=len(list)
  )
  n==0 ?
    [] :
    len==0 ?
      [] :
      n>0 ?
        +n>=len ? list  : [for(i=[len-n :len-1  ]) list[i]]:
        -n>=len ? []    : [for(i=[-n    :len-1  ]) list[i]];

/*!
 * Transforms each item in «list» applying the homogeneous transformation matrix
 * «M». By default the in() and out() lambdas manage 3d points, but overloading
 * them it is possible to manage different input/output formats like in the
 * following example:
 *
 *     // list of 2d points
 *     list    = [[1,2],[3,4],[5,6]];
 *     // desired translation in 2d space
 *     t       = [1,2];
 *     // translation matrix
 *     M       = fl_T(t);
 *     result  = fl_list_transform(
 *       list,
 *       M,
 *       // extend a 2d point into 3d space plane Z==0
 *       function(2d) [2d.x,2d.y,0],
 *       // conversion from 3d to 2d space again
 *       function(3d) [3d.x,3d.y]
 *     );
 *     // «expected» result is a list of translated 2d points
 *     expected = [for(item=list) item+t];
 *     assert(result==expected);
 *
 */
function fl_list_transform(list,M,in=function(3d) 3d,out=function(3d) 3d)  = [
  for(p=[for(p=list) fl_transform(M,in(p))]) out(p)
];

/*!
 * pack two list in a new one like in the following code:
 *
 *     labels = ["label 1", "label 2", "label 3", "label 4"];
 *     values = [1, 2, 3];
 *     result = fl_list_pack(labels,values);
 *
 * if equivalent to:
 *
 *     result = [
 *       ["label 1",  1     ],
 *       ["label 2",  2     ],
 *       ["label 3",  3     ],
 *       ["label 4",  undef ]
 *     ]
 */
function fl_list_pack(left,right) = let(
  l_len = assert(is_list(left))   len(left),
  r_len = assert(is_list(right))  len(right)
) [
  for(i=[0:max(l_len,r_len)-1]) [i<l_len ? left[i] : undef, i<r_len ? right[i] : undef]
];

/*!
 * return the items from «list» matching a list of conditions.
 *
 * example 1: filter out numbers from a list of heterogeneous values
 *
 *     heters = ["a", 4, -1, false, 5, "a string"];
 *     nums   = fl_list_filter(heters,function(item) is_num(item));
 *
 * the returned list «nums» is equal to `[4, -1, 5]`
 *
 * example 2: include only items matching two conditions executed in sequence:
 *
 * 1. is a number
 * 2. is positive
 *
 *         let(
 *           list      = ["a", 4, -1, false, 5, "a string"],
 *           expected  = [4,5],
 *           result    = fl_list_filter(list,[
 *             function(item) is_num(item),// check if number (first)
 *             function(item) item>0       // check if positive (last)
 *           ])
 *         ) assert(result==expected,result) echo(result=result);
 *
 * __NOTE__: filter execution order is the same of their occurrence in
 * «filters». In the example above the list is first reduced to just the
 * numbers, then each remaining item is checked for positiveness.
 */
function fl_list_filter(
  //! the list to be filtered
  list,
  //! either a function literal or a list of function literals called on each «list» item
  filter
) = let(
  filter  = is_list(filter) ? filter : filter ? [filter] : [],
  len     = len(filter)
)
len==0 ?
  list :
  let(
    current = filter[0],
    result  = [for(item=list) if (current(item)) item]
  ) fl_list_filter(result,fl_list_tail(filter,-1));

/*!
 * Return the «list» item with max score. Return undef if «list» is empty.
 */
function fl_list_max(
  list,
  /*!
   * function that assigns a score to an element in the «list»: default to item
   * itself.
   */
  score=function(item) item
) =
  assert(is_list(list),list)
  list==[] ? undef : len(list)==1 ? list[0]
  : let(
      head  = list[0],
      rest  = [for(i=[1:len(list)-1]) list[i]],
      other = fl_list_max(rest,score)
    ) score(head)>score(other) ? head : other;

/*!
 * Return the «list» item with min score. Return undef if «list» is empty.
 */
function fl_list_min(
  list,
  /*!
   * function that assigns a score to an element in the «list»: default to item
   * itself.
   */
  score=function(item) item
) =
  assert(is_list(list),list)
  list==[] ? undef : len(list)==1 ? list[0]
  : let(
      head  = list[0],
      rest  = [for(i=[1:len(list)-1]) list[i]],
      other = fl_list_min(rest,score)
    ) score(head)<score(other) ? head : other;

//! strips duplicates from a «dict»
function fl_list_unique(dict) =
  len(dict)==1 ? dict : let(
    // this lambda isolates the first list element (head) from the rest
    split     = function (list) let(
      len = len(list)
    ) assert(len>1,"list must contain at least 2 items")
      len==2 ? [list[0],[list[1]]]
      : let(
        head  = list[0],
        tail  = [for(i=[1:len-1]) list[i]]
      ) [head,tail],
    // search    = function(match,list) [for(i=[0:len(list)-1]) if (list[i]==match) i],
    partition = split(dict),
    head      = partition[0],
    tail      = partition[1],
    result    = fl_list_unique(tail),
    missing   = search([head],result)==[[]]
  ) missing ? concat([head],result) : result;

//! quick sort «vec» (from [oampo/missile](https://github.com/oampo/missile))
function fl_list_sort(vec,cmp=function(e1,e2) (e1-e2)) =
  vec==[] ? vec :
  let(
    pivot = vec[floor(len(vec)/2)],
    below = [for (e=vec) if (cmp(e,pivot)<0)  e],
    equal = [for (e=vec) if (cmp(e,pivot)==0) e],
    above = [for (e=vec) if (cmp(e,pivot)>0)  e]
  ) concat(fl_list_sort(below,cmp), equal, fl_list_sort(above,cmp));

/*!
 * Logic AND between two lists.
 *
 * Example:
 *
 *     a         = [   +X,+Y,-Y,-Z],
 *     b         = [-X      ,-Y,-Z],
 *     result    = fl_list_AND(a,b),
 *     expected  = [-Y,-Z]
 *
 */
function fl_list_AND(a,b,index_only=false) = [for(i=search(a,b)) if (i!=[]) index_only ? i : b[i]];

//**** dictionary *************************************************************

//! return a list with the names of the objects present in «dictionary»
function fl_dict_names(dictionary) = [for(item=dictionary) fl_name(item)];

function fl_dict_search(dictionary,name) = [
  for(item=dictionary) let(n=fl_name(item)) if (name==n) item
];

/*!
 * build a dictionary with rows constituted by items with equal property as
 * retrieved by «func».
 *
 * example:
 *
 *       dict = [
 *         ["first", 7],
 *         ["second",9],
 *         ["third", 9],
 *         ["fourth",2],
 *         ["fifth", 2],
 *       ];
 *
 *       result   = fl_dict_organize(dictionary=dict, range=[0:10], func=function(item) item[1]);
 *
 * is functionally equal to:
 *
 *       result = [
 *         [], //  0
 *         [], //  1
 *         [   //  2
 *           ["fourth", 2],
 *           ["fifth",  2]
 *         ],
 *         [], // 3
 *         [], // 4
 *         [], // 5
 *         [], // 6
 *         [   // 7
 *           ["first", 7]
 *         ],
 *         [], // 8
 *         [   // 9
 *           ["second", 9], ["third", 9]
 *         ],
 *         []  // 10
 *       ];
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
  ? (let(value=type[index_list[0]][1]) is_function(value) ? value(type,key,default) : value)
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
  call_chain  = fl_strcat([for (i=[$parent_modules-1:-1:0]) parent_module(i)],"->"),
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
      call_chain  = fl_strcat([for (i=[$parent_modules-1:-1:1]) parent_module(i)],"->")
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

//! return a string that is the concatenation of all the list members
function fl_str_concat(list) =
  assert(is_list(list))
  len(list)==0 ? ""
  : len(list)==1 ? list[0]
  : let(
    first=list[0],
    rest=[for(i=[1:len(list)-1]) list[i]]
  ) str(first,fl_str_concat(rest));

//! recursively flatten infinitely nested list
function fl_list_flatten(list) =
  assert(is_list(list))
  [
    for (i=list) let(sub = is_list(i) ? fl_list_flatten(i) : [i])
      for (i=sub) i
  ];

function fl_list_has(list,item) = len(fl_list_filter(list,function(curr) curr==item))>0;

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

//**** Common parameter helpers ***********************************************

// function fl_parm_triState(value) = value=="undef" ? undef : is_num(value) ? x : fl_atoi(value);

/*!
 * This format uses the real numbers sign to distinguish couple of values passed
 * in a list.
 *
 * The function takes an unordered pair of two opposite signed values and
 * returns an ordered list with the negative value at position 0 and the
 * positive at position 1.
 *
 * When the input is in scalar form, both the negative/positive will be set to
 * it with sign flag set accordingly.
 *
 * This type can be used for storing semi-axis related values like - for
 * example - thickness values. While providing a free and compact input
 * representation, the transformed value is still compatible with the input (so
 * can be forwarded to other signed-value parameters), while simplifying the
 * fetch of its components being the transformed positions 'normalized' in
 * fixed-form with negative/positive parts at index 0/1 respectively.
 *
 * Example 1:
 *
 *     ordered    = fl_list_SignedPair([+3,-7]);
 *
 * «ordered» is equal to `[-7,+3]`.
 *
 * Example 2:
 *
 *     ordered    = fl_list_SignedPair(-5);
 *
 * «ordered» is now equal to `[-5,+5]`.
 *
 * This type is used - for example - for specifying a thickness value along an
 * axis.
 */
function fl_parm_SignedPair(list) =
    is_undef(list)  ? [0,0]
  : is_list(list)   ?
    list==[] ? [0,0]
    : let(
        negative = let(m=min(list)) m<0 ? m : 0,
        positive = let(m=max(list)) m>0 ? m : 0
      ) [negative,positive]
  : assert(is_num(list),list) [-abs(list),abs(list)];

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
  o_x = x=="undef" ? undef : is_num(x) ? x : fl_atoi(x),
  o_y = y=="undef" ? undef : is_num(y) ? y : fl_atoi(y),
  o_z = z=="undef" ? undef : is_num(z) ? z : fl_atoi(z)
) [o_x,o_y,o_z];

//! constructor for debug context parameter
function fl_parm_Debug(
  //! when true, labels to symbols are assigned and displayed
  labels  = false,
  //! when true symbols are displayed
  symbols = false,
  /*!
   * a string or a list of strings equals to the component label of which
   * direction information will be shown
   */
  components = [],
  //! dimension lines
  dimensions = false
) = [labels,symbols,components,dimensions];

//! When true debug labels are turned on
function fl_parm_labels(debug) = is_undef(debug) ? false : assert(is_bool(debug[0])) debug[0];

//! When true debug symbols are turned on
function fl_parm_symbols(debug) = is_undef(debug) ? false : assert(is_bool(debug[1])) debug[1];

//! When «debug» is not undef, checks if component «label» is marked for debugging
function fl_parm_components(debug,label) =
  is_undef(debug) ?
    false :
    let(components = debug[2])
    is_list(components) ?
      search([label],components)!=[[]] :
      is_string(components) ?
        components==label :
        assert(false,str("debug information must be a string or a list of strings: ", components)) undef;

//! When true dimension lines are turned on
function fl_parm_dimensions(debug) = is_undef(debug) ? false : assert(is_bool(debug[3])) debug[3];

//! return true if any of the debug flag is turned on, false otherwise
function fl_parm_debug(debug) =
  is_undef(debug) ?
    false :
    fl_parm_labels(debug) || fl_parm_symbols(debug) || debug[2] || fl_parm_dimensions(debug);

/*!
 * Multi valued verb-dependent tolerance parameter.
 *
 * OFL engines generally parse input parameters just once before processing the
 * passed verb list. This implies that for each parameter the corresponding
 * value will never change upon verb invocation. Even if generally sensible,
 * this approach has some drawbacks when the parameter is asked to change its
 * value between different verbs (for example a «tolerance» could be different
 * during an FL_DRILL or FL_FOOTPRINT verb invocations). To avoid the split of a
 * verb-list engine invocation in as many different invocation as the desired
 * parameter requires, the parameter can assume a verb-dependent value like
 * in the following code example:
 *
 *     tolerance=[
 *       [FL_DRILL,     0.1],
 *       [FL_FOOTPRINT, 0.2]
 *     ]
 *     ...
 *     fl_engine(verbs=[FL_DRILL,FL_FOOTPRINT],tolerance=tolerance,...);
 *
 * Inside the engine the tolerance value for the currently executed verb can be
 * retrieved by the following code:
 *
 *     tolerance = fl_parm_tolerance(default=0.05);
 *
 * functionally equivalent to:
 *
 *     tolerance = is_undef($fl_tolerance) ? 0 : fl_optProperty($fl_tolerance, $verb,
 *     default=$fl_tolerance);
 *
 * and will result in:
 *
 * | verb             | value |
 * | ----             | ----  |
 * | FL_DRILL         | 0.1   |
 * | FL_FOOTPRINT     | 0.2   |
 * | all other cases  | 0.05  |
 */
function fl_parm_tolerance(verb=is_undef($verb)?$this_verb:$verb, default=0) =
  is_undef($fl_tolerance) ? default : fl_optProperty($fl_tolerance, verb, default=$fl_tolerance );

/*!
 * Multi valued verb-dependent thickness parameter.
 *
 * See fl_parm_tolerance() for details.
 */
function fl_parm_thickness(verb=is_undef($verb)?$this_verb:$verb, default=0) =
  is_undef($fl_thickness) ? default : fl_optProperty($fl_thickness, verb, default=$fl_thickness );

//**** Common parameter helpers ***********************************************

module fl_context_dump()
  echo(
  $FL_ADD        = $FL_ADD       ,
  $FL_ASSEMBLY   = $FL_ASSEMBLY  ,
  $FL_AXES       = $FL_AXES      ,
  $FL_BBOX       = $FL_BBOX      ,
  $FL_CUTOUT     = $FL_CUTOUT    ,
  $FL_DRILL      = $FL_DRILL     ,
  $FL_FOOTPRINT  = $FL_FOOTPRINT ,
  $FL_HOLDERS    = $FL_HOLDERS   ,
  $FL_LAYOUT     = $FL_LAYOUT    ,
  $FL_MOUNT      = $FL_MOUNT     ,
  $FL_PAYLOAD    = $FL_PAYLOAD
  ) children();
