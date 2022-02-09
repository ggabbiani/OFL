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

include <type_trait.scad>
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
  *  $hole_depth  - hole depth
  *  $hole_d      - hole diameter
  *  $hole_i      - ordinal position inside «points»
  *  $hole_n      - hole normal
  */
module fl_lay_holes(
  // list of hole specs
  holes,
  // enabled normals in floating semi-axis list form
  enable  = [-X,+X,-Y,+Y,-Z,+Z],
  // thru-hole thickness
  thick=0
) {
  assert(fl_tt_isHoleList(holes),holes);
  assert(fl_tt_isAxisList(enable),enable);

  fl_trace("enable",enable);
  fl_trace("holes",holes);
  fl_trace("thick",thick);
  for($hole_i=[0:len(holes)-1]) {
    hole        = holes[$hole_i];
    point       = hole[0];
    $hole_n     = hole[1];
    $hole_d     = hole[2];
    $hole_depth = len(hole)==4 ? assert(is_num(hole[3])) hole[3] : thick;
    if (fl_3d_axisIsSet($hole_n,enable))
      translate(point)
        children();
  }
}

/**
  * Layouts holes according to their defined positions, depth and enabled normals.
  *
  * NOTE: supported normals are x,y or z semi-axis ONLY
  */
module fl_holes(
  // list of holes specs
  holes,
  // enabled normals in floating semi-axis list form
  enable  = [-X,+X,-Y,+Y,-Z,+Z],
  // thru-hole thickness
  thick=0
) {
  fl_lay_holes(holes,enable,thick)
    translate(NIL*$hole_n)
      fl_cylinder(h=$hole_depth+NIL2,d=$hole_d,direction=[-$hole_n,0]);
}
