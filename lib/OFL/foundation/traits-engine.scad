/*!
 * Type traits implementation file.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <core.scad>

function fl_tt_is2d(p) = len(p)==2 && is_num(p.x) && is_num(p.y);

function fl_tt_is3d(p) = len(p)==3 && is_num(p.x) && is_num(p.y) && is_num(p.z);

function fl_tt_isPosition(p) = fl_tt_is2d(p) || fl_tt_is3d(p);

function fl_tt_isOctant(3d) =
  fl_tt_is3d(3d)
  && (3d.x==0 || abs(3d.x)==1)
  && (3d.y==0 || abs(3d.y)==1)
  && (3d.z==0 || abs(3d.z)==1);

/*!
 * check whether «value» is a valid [axis,rotation angle] format:
 */
function fl_tt_isDirectionRotation(value) = let(
    direction = value[0],
    rotation  = value[1]
  )  (len(value)==2)
  && (fl_tt_is3d(direction))
  && (is_num(rotation));

/*!
 * check if «comp» is a valid component format:
 *
 *    ["engine", [position], [cut direction], [[director],rotation], type, properties]
 */
function fl_tt_isComponent(comp) = let(
  props = comp[5]
) (   is_string(comp[0])                  // engine
  &&  fl_tt_is3d(comp[1])                 // position
  // &&  fl_tt_isAxis(comp[2])               // cut direction
  &&  fl_tt_isDirectionRotation(comp[3])  // [direction,rotation]
  &&  is_list(comp[4])                    // type
  &&  (is_undef(props) || is_list(props)) // optional properties
);

/*!
 * Component specification list check
 *
 *    ["label", component]
 */
function fl_tt_isCompSpecList(specs) =
  fl_tt_isKVList(specs,f=function (value) fl_tt_isComponent(value));

/*!
 * return true when «bbox» is a bounding box in [low,high] format.
 *
 * A 3D bounding box (or 3D "bbox") is a volume of space that encloses a
 * three-dimensional object. The 3D bounding box is defined as a rectangular
 * parallelepiped, composed of six faces, each of which is a quadrilateral.
 * The 3D bounding box is usually defined by three dimensions: width, height
 * and depth. These three dimensions define the dimensions of the rectangular
 * parallelepiped.
 *
 * The [low,high] format is a list containing two 3d points:
 *
 * ```
 * low-point==min(x),min(y),min(z) of the bounding box
 * high-point==max(x),max(y),max(z) of the bounding box
 * ```
 *
 * **NOTE:** 0-sized bounding box are allowed
 *
 * TODO: When using a 3D bounding box, the coordinates of the 3D object are
 * often converted to coordinates local to the bounding box, making
 * manipulation of the object even easier.
 */
function fl_tt_isBoundingBox(
  //! bounding box to be verified
  bbox,
  2d=false
) = let(
  l1  = len(bbox[0]),
  l2  = len(bbox[1])
) (
  len(bbox)==2
  && (l1==2 || l1==3)
  && (l2==2 || l2==3)
  && (l1==l2)
  && (bbox[0].x<=bbox[1].x)
  && (bbox[0].y<=bbox[1].y)
  && (l1==2 ? 2d : (bbox[0].z<=bbox[1].z))
);

/*!
 * return true when «list» is a list and each item satisfy f(value)
 */
function fl_tt_isList(
  //! list to be verified
  list,
  //! check function
  f=function(value) true,
  //! optional list size
  size
) = let(
  len   = is_list(list) ? len(list) : -1,
  rest  = len>1 ? [for(i=[1:len-1]) list[i]] : []
) (
    (len>-1)
    && (size!=undef ? size==len : true)
    && (len>0 ? f(list[0]) : true)
    && (rest!=[] ? fl_tt_isList(rest,f) : true)
  );

/*!
 * true if «string» appears in «dictionary»
 */
function fl_tt_isInDictionary(string,dictionary,nocase=true) =
  assert(is_string(string))
  let(
    len   = len(dictionary),
    rest  = len>1 ? [for(i=[1:len-1]) dictionary[i]] : []
  ) dictionary==[] ? false
  : (nocase
    ? fl_str_lower(string)==fl_str_lower(dictionary[0])
    : string==dictionary[0]
    ) || fl_tt_isInDictionary(string,rest,nocase);

/*!
 * true if «kv» is a key/value pair satisfying f(value)
 */
function fl_tt_isKV(kv,dictionary=[],f=function (value) value!=undef) =
  assert(fl_tt_isList(dictionary,function(value) is_string(value)))
  let(
    key   = kv[0],
    value = kv[1]
  ) (
    (dictionary ? fl_tt_isInDictionary(key,dictionary) : true)
    && len(kv)==2
    && is_string(key) && f(value)
  );

/*!
 * true if «kv» is a key/value pair list with each item satisfying f(value)
 */
function fl_tt_isKVList(list,dictionary=[],f=function (value) value!=undef,size) =
  fl_tt_isList(list,function(value) fl_tt_isKV(value,dictionary=dictionary,f=f),size);

/*!
 * Semi-axis Key/value list
 *
 * Each item of the list is actually a key/value pair representing a value
 * associated to one semi-axis. The dimension of this representation is floating
 * from 0 (empty list) to 6 (complete list).
 *
 * example:
 *
 * ```
 * thick=[["+x",3],["-Z",1.5]];
 * ```
 *
 * indicates a thickness of 3mm along +X and of 1.5mm along +Z.
 */
function fl_tt_isAxisKVList(list) =
  assert(len(list)<=6,list)
  fl_tt_isKVList(
    list,
    dictionary=["-x","+x","±x","-y","+y","±y","-z","+z","±z"],
    f=function(value) is_num(value)
  );

/*!
 * Full semi axis value list.
 *
 * Each row represents values associated to X,Y and Z semi-axes.
 *
 * ```
 * [
 *  [«-x value»,«+x value»],
 *  [«-y value»,«+y value»],
 *  [«-z value»,«+z value»]
 * ]
 * ```
 *
 * example:
 *
 * ```
 * [
 *  [0,3],
 *  [0,0],
 *  [1.5,0]
 * ]
 * ```
 *
 * indicates a value of 3 along +X, 1.5 along -Z and 0 otherwise.
 */
function fl_tt_isAxisVList(
  list,
  element=function(x) is_num(x)||is_string(x)||is_bool(x)
) =
  fl_tt_isList(
    list,size=3,
    f=function(x) fl_tt_isList(
      x,size=2,
      f=element
      )
    );

/*!
 * plane in point-normal format: [<3d point>,<plane normal>]
 */
function fl_tt_isPointNormal(plane) = let(
    point = plane[0],
    n     = plane[1]
  )  (len(plane)==2)
  && (is_list(point) && len(point)==3)
  && (is_list(n) && len(n)==3);

function fl_tt_isPointNormalList(list) =
  fl_tt_isList(list,f=function(plane) fl_tt_isPointNormal(plane));

function fl_tt_isAxisString(s) =
  fl_tt_isInDictionary(
    string=s,
    dictionary=["-x","+x","±x","-y","+y","±y","-z","+z","±z"],
    nocase=true
  );

function fl_tt_isAxis(axis) = let(
  versor = fl_versor(axis)
) (versor==-FL_X||versor==+FL_X||versor==-FL_Y||versor==+FL_Y||versor==-FL_Z||versor==+FL_Z);

/*!
 * Floating semi-axis list.
 *
 * One row with matrix representation of cartesian semi-axes in whatever order.
 *
 * example:
 *
 * ```
 * floating_semi_axis_list = [-X,+Z,-Y];
 * ```
 *
 * TODO: rename with a decent name like fl_tt_isFloatingSemiAxisList()
 */
function fl_tt_isAxisList(list) =
  fl_tt_isList(list,f=function(axis) fl_tt_isAxis(axis));

/*!
 * verb list is either a single verb string or a list of verb strings.
 */
function fl_tt_isVerbList(verbs) =
  is_string(verbs) || fl_tt_isList(verbs,f=function(v) is_string(v));

function fl_tt_isColor(color) = len(color)==3
  && color[0]>=0 && color[0]<=1
  && color[1]>=0 && color[1]<=1
  && color[2]>=0 && color[2]<=1;