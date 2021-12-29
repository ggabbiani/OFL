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
  * Layouts children along a list of holes.
  *
  * Point information is used for positioning.
  * normals, diameter and depth are passed back to children context.
  *
  * NOTE: supported normals are x,y or z semi-axis ONLY
  *
  * Children context:
  *  $depth     - hole depth
  *  $diameter  - hole diameter
  *  $i         - ordinal position inside «points»
  *  $normal
  */
module fl_lay_holes(
  // list of hole specs
  holes,
  // list of enabled normals (ex. ["+X","-z"])
  // A single string "s" is interpreted as ["s"] (ex. "-y" ⇒ ["-y"])
  enable  = ["-x","+x","-y","+y","-z","+z"]
) {
  assert(fl_tt_isHoleList(holes),holes);
  enable  = is_string(enable) ? [enable] : enable;
  assert(fl_tt_isList(enable,function(s) fl_tt_isAxisString(s)),enable);

  for($i=[0:len(holes)-1]) {
    hole      = holes[$i];
    point     = hole[0];
    $normal   = hole[1];
    $diameter = hole[2];
    $depth    = len(hole)==4 ? assert(is_num(hole[3])) hole[3] : 0;
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
  // list of holes specs
  holes,
  // list of enabled normals (ex. ["+X","-z"])
  // A single string "s" is interpreted as ["s"] (ex. "-y" ⇒ ["-y"])
  enable  = ["-x","+x","-y","+y","-z","+z"]
) {
  fl_lay_holes(holes,enable)
    translate(NIL*$normal) 
      fl_cylinder(h=$depth+NIL2,d=$diameter,direction=[-$normal,0]);
}
