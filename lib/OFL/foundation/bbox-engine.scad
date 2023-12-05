/*!
 * BoundingBox toolkit
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <core.scad>

/*!
 * invoked by «type» parameter acts as getter for the bounding box property
 *
 * invoked by «value» parameter acts as property constructor
 */
function fl_bb_corners(type,value)  = fl_property(type,"bb/bounding corners",value);

//! computes size from the bounding corners.
function fl_bb_size(type)       = assert(type,type) let(c=fl_bb_corners(type)) c[1]-c[0];

//! constructor for a new type with bounding box corners set as property
function fl_bb_new(
  negative  = [0,0,0],
  size      = [0,0,0],
  positive
) = [fl_bb_corners(value=[negative,positive==undef?negative+size:positive])];

//! bounding box translation
function fl_bb_center(type) = let(c=fl_bb_corners(type),sz=fl_bb_size(type)) c[0]+sz/2;

/*!
 * Converts a bounding box in canonic form into four vertices:
 *
 * a,b,c,d on plane y==corners[0].y
 *
 * A,B,C,D on plane y==corners[1].y
 */
function fl_bb_vertices(corners) = let(
  a   = corners[0]
  ,C  = corners[1]
  ,b  = [C.x,a.y,a.z]
  ,c  = [C.x,a.y,C.z]
  ,d  = [a.x,a.y,C.z]
  ,A  = [a.x,C.y,a.z]
  ,B  = [C.x,C.y,a.z]
  ,D  = [a.x,C.y,C.z]
) [a,b,c,d,A,B,C,D];

//! Applies a transformation matrix «M» to a bounding box
function fl_bb_transform(M,corners) = let(
  vertices  = [for(v=fl_bb_vertices(corners)) fl_transform(M,v)]
  ,Xs       = [for(v=vertices) v.x]
  ,Ys       = [for(v=vertices) v.y]
  ,Zs       = [for(v=vertices) v.z]
) [[min(Xs),min(Ys),min(Zs)],[max(Xs),max(Ys),max(Zs)]];

/*!
 * Calculates a cubic bounding block from a bounding blocks list
 */
function fl_bb_calc(
    //! list of bounding blocks to be included in the new one
    bbs
) =
  assert(len(bbs)>0,bbs)
let(
  xs  = [for(bb=bbs) bb[0].x],
  ys  = [for(bb=bbs) bb[0].y],
  zs  = [for(bb=bbs) bb[0].z],
  XS  = [for(bb=bbs) bb[1].x],
  YS  = [for(bb=bbs) bb[1].y],
  ZS  = [for(bb=bbs) bb[1].z]
) [[min(xs),min(ys),min(zs)],[max(XS),max(YS),max(ZS)]];

/*!
 * Calculates a cubic bounding block from a 3d point set.
 * See also 2d counter-part function fl_bb_polygon().
 */
function fl_bb_polyhedron(points) = let(
  xs  = [for(p=points) p.x],
  ys  = [for(p=points) p.y],
  zs  = [for(p=points) p.z]
) [[min(xs),min(ys),min(zs)],[max(xs),max(ys),max(zs)]];