/*
 * Hole engine implementation.
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

include <unsafe_defs.scad>
use     <type_trait.scad>
include <3d.scad>

/**
  * Layouts children along a list of points.
  *
  * Point information is used for positioning, normals are passed back to 
  * children through context.
  *
  * NOTE: supported normals are x,y or z semi-axis ONLY
  *
  * Children context:
  *  $i        - ordinal position inside «points»
  *  $normal
  */
module fl_lay_points(
  // list of point-normal pairs
  points,
  // list of enabled normals (ex. ["+X","-z"])
  // A single string "s" is interpreted as ["s"] (ex. "-y" ⇒ ["-y"])
  enable  = ["-x","+x","-y","+y","-z","+z"]
) {
  assert(fl_tt_isPointNormalList(points),points);
  enable  = is_string(enable) ? [enable] : enable;
  assert(fl_tt_isList(enable,function(s) isAxisString(s)),enable);

  for($i=[0:len(points)-1]) {
    plane   = points[$i];
    point   = plane[0];
    $normal = plane[1];
    if ((($normal==-X) && fl_tt_isInDictionary("-x",enable))
    ||  (($normal==+X) && fl_tt_isInDictionary("+x",enable))
    ||  (($normal==-Y) && fl_tt_isInDictionary("-y",enable))
    ||  (($normal==+Y) && fl_tt_isInDictionary("+y",enable))
    ||  (($normal==-Z) && fl_tt_isInDictionary("-z",enable))
    ||  (($normal==+Z) && fl_tt_isInDictionary("+z",enable)))
      translate(point)
        children();
  }
}

/**
  * Layouts holes according to their defined positions and enabled normals.
  *
  * NOTE: supported normals are x,y or z semi-axis ONLY
  */
module fl_holes(
  // list of point-normal pairs
  points,
  // list of enabled normals (ex. ["+X","-z"])
  // A single string "s" is interpreted as ["s"] (ex. "-y" ⇒ ["-y"])
  enable  = ["-x","+x","-y","+y","-z","+z"],
  // hole depth
  thick,
  // hole radius
  r
) {
  assert(is_num(thick),thick);
  assert(is_num(r),r);

  fl_lay_points(points,enable)
    translate(NIL*$normal) 
      fl_cylinder(h=thick+NIL2,r=r,direction=[-$normal,0]);
}
