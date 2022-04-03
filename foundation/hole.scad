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

include <3d.scad>
include <symbol.scad>
include <type_trait.scad>

// constructor
function fl_Hole(
    position,
    d,
    normal  = +Z,
    // when depth is null hole is pass-through
    depth = 0,
    opts  = []
  ) = [position,normal,d,depth,opts];

/**
 * prepare context for children() holes
 *
 * $hole_center
 * $hole_d          - hole diameter
 * $hole_depth      - hole depth (set to «thick» for pass-thru)
 * $hole_direction  - [$hole_n,0]
 * $hole_i          - OPTIONAL ordinal position
 * $hole_n          - hole normal
 * $hole_screw      - OPTIONAL hole screw
 */
module fl_hole_Context(
  hole,
  // fallback thickness
  thick,
  ordinal,
  // fallback screw
  screw
) {
  $hole_i       = ordinal;
  $hole_center  = hole[0];
  $hole_n       = hole[1];
  $hole_direction  = [$hole_n,0];
  $hole_d       = hole[2];
  $hole_depth   = hole[3] ? hole[3] : thick;
  $hole_screw   = let(s=fl_optional(hole[4],"hole/screw")) s ? s : screw;
  
  children();
}

/**
  * Layouts children along a list of holes.
  *
  * See fl_hole_Context() for context variables passed to children().
  *
  * NOTE: supported normals are x,y or z semi-axis ONLY
  *
  */
module fl_lay_holes(
  // list of hole specs
  holes,
  // enabled normals in floating semi-axis list form
  enable  = [-X,+X,-Y,+Y,-Z,+Z],
  // pass-through thickness
  thick=0,
  // fallback screw
  screw
) {
  assert(fl_tt_isHoleList(holes),holes);
  assert(fl_tt_isAxisList(enable),enable);

  fl_trace("enable",enable);
  fl_trace("holes",holes);
  fl_trace("thick",thick);

  for($hole_i=[0:len(holes)-1])
    fl_hole_Context(holes[$hole_i],thick,$hole_i,screw)
      if (fl_3d_axisIsSet($hole_n,enable))
        translate($hole_center)
          children();
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
  // pass-through thickness
  thick=0,
  // fallback screw
  screw
) {
  fl_lay_holes(holes,enable,thick,screw)
    translate(NIL*$hole_n)
      fl_cylinder(h=$hole_depth+NIL2,d=$hole_d,direction=[-$hole_n,0]);
}

/**
  * Layouts of hole symbols
  *
  * NOTE: supported normals are x,y or z semi-axis ONLY
  */
module fl_hole_debug(
  // list of holes specs
  holes,
  // enabled normals in floating semi-axis list form
  enable  = [-X,+X,-Y,+Y,-Z,+Z],
  // pass-through thickness
  thick=0,
  // fallback screw
  screw
) {
  fl_lay_holes(holes,enable,thick,screw)
    translate(NIL*$hole_n)
      fl_sym_hole($FL_ADD="ON");
}
