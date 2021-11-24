/*
 * Generic caddy artifact.
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org).
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

include <foundation/unsafe_defs.scad>
include <foundation/incs.scad>
include <vitamins/incs.scad>

// TODO: FL_DRILL implementation
module fl_caddy(
  verbs       = FL_ADD,     // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  type,
  thick,                    // walls thickness in the form [[-X,+X],[-Y,+Y],[-Z,+Z]]. Scalar means same value for each semi-axis.
  faces,                    // faces defined by their othonormal axis
  tolerance   = fl_JNgauge, // SCALAR added to each internal payload dimension.
  fillet      = 0,          // fillet radius, when > 0 a fillet is inserted where needed
  direction,                // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant,                   // when undef native positioning is used
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(thick);

  function isSet(semi_axis,faces) = let(
      rest  = len(faces)>1 ? [for(i=[1:len(faces)-1]) faces[i]] : []
    ) len(faces)==0 ? false : faces[0]==semi_axis ? true : isSet(semi_axis,rest);

  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  thick     = is_num(thick) ? [[thick,thick],[thick,thick],[thick,thick]] : thick;
  pload     = fl_bb_corners(type);
  bbox      = let(
                delta = [
                    [isSet(-FL_X,faces)?thick.x[0]+tolerance+fillet:0, isSet(-FL_Y,faces)?thick.y[0]+tolerance+fillet:0, isSet(-FL_Z,faces)?thick.z[0]+tolerance:0],
                    [isSet(+FL_X,faces)?thick.x[1]+tolerance+fillet:0, isSet(+FL_Y,faces)?thick.y[1]+tolerance+fillet:0, isSet(+FL_Z,faces)?thick.z[1]+tolerance:0]
                  ]) [pload[0]-delta[0],pload[1]+delta[1]];
  size      = bbox[1]-bbox[0];
  D         = direction ? fl_direction(default=[+FL_Z,+FL_X],direction=direction)  : FL_I;
  M         = octant    ? fl_octant(octant=octant,bbox=bbox)            : FL_I;

  module do_add() {
    difference() {
      translate(bbox[0]) {
        for(f=faces) 
          if (f==+FL_X) {
            translate(+fl_X(size.x)) fl_cube(size=[thick.x[1],size.y,size.z],octant=-FL_X+FL_Y+FL_Z);
          } else if (f==-FL_X) {
            fl_cube(size=[thick.x[0],size.y,size.z],octant=+FL_X+FL_Y+FL_Z);
          } else if (f==+FL_Y) {
            translate(+fl_Y(size.y)) fl_cube(size=[size.x,thick.y[1],size.z],octant=+FL_X-FL_Y+FL_Z);
          } else if (f==-FL_Y) {
            fl_cube(size=[size.x,thick.y[0],size.z],octant=+FL_X+FL_Y+FL_Z);
          } else if (f==+FL_Z) {
            translate(+fl_Z(size.z)) fl_cube(size=[size.x,size.y,thick.z[1]],octant=+FL_X+FL_Y-FL_Z);
          } else if (f==-FL_Z) {
            fl_cube(size=[size.x,size.y,thick.z[0]],octant=+FL_X+FL_Y+FL_Z);
          }
        if (fillet) {
          if (isSet(+X,faces) && isSet(-Z,faces))
            translate([size.x-thick.x[1],0,thick.z[0]]) fl_fillet([FL_ADD],r=fillet,h=size.y,direction=[+Y,180]);
          if (isSet(+X,faces) && isSet(+Z,faces))
            translate([size.x-thick.x[1],0,size.z-thick.z[1]]) fl_fillet([FL_ADD],r=fillet,h=size.y,direction=[+Y,90]);
          if (isSet(+Z,faces) && isSet(-X,faces))
            translate([thick.x[0],0,size.z-thick.z[1]]) fl_fillet([FL_ADD],r=fillet,h=size.y,direction=[+Y,0]);
          if (isSet(-X,faces) && isSet(-Z,faces))
            translate([thick.x[0],0,thick.z[0]]) fl_fillet([FL_ADD],r=fillet,h=size.y,direction=[+Y,-90]);
          if (isSet(-Y,faces) && isSet(-Z,faces))
            translate([0,thick.y[0],thick.z[0]]) fl_fillet([FL_ADD],r=fillet,h=size.x,direction=[+X,+90]);
          if (isSet(+Z,faces) && isSet(-Y,faces))
            translate([0,thick.y[0],size.z-thick.z[1]]) fl_fillet([FL_ADD],r=fillet,h=size.x,direction=[+X,0]);
          if (isSet(+Z,faces) && isSet(+Y,faces))
            translate([0,size.y-thick.y[1],size.z-thick.z[1]]) fl_fillet([FL_ADD],r=fillet,h=size.x,direction=[+X,-90]);
          if (isSet(-Z,faces) && isSet(+Y,faces))
            translate([0,size.y-thick.y[1],thick.z[0]]) fl_fillet([FL_ADD],r=fillet,h=size.x,direction=[+X,+180]);
        }
      }
      let($verb=[FL_DRILL,FL_CUTOUT]) children();
    }
  }
  module do_bbox() {}
  module do_assembly() {}
  module do_layout() {}
  module do_drill() {}

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) 
          fl_color($FL_FILAMENT)
            do_add() children();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_bb_add(corners=bbox);
      } else if ($verb==FL_LAYOUT) {
        fl_modifier($FL_LAYOUT) do_layout()
          children();
      } else if ($verb==FL_PAYLOAD) {
        fl_modifier($FL_PAYLOAD) fl_bb_add(pload);
      } else if ($verb==FL_FOOTPRINT) {
        fl_modifier($FL_FOOTPRINT);
      } else if ($verb==FL_ASSEMBLY) {
        fl_modifier($FL_ASSEMBLY) let($verb=[FL_ADD,FL_ASSEMBLY]) children();
      } else if ($verb==FL_DRILL) {
        fl_modifier($FL_DRILL);
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=size);
  }
}