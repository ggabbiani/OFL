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
include <foundation/fillet.scad>

/*
 * Builds a caddy around the passed object «type».
 * Even if not mandatory - when passed - children will be used during
 * FL_ADD (for drilling), FL_ASSEMBLY (for rendering) and FL_LAYOUT.
 *
 * Children must implement the following verbs:
 * FL_DRILL,FL_CUTOUT (used during FL_ADD)
 * FL_ADD,FL_ASSEMBLY (used during FL_ASSEMBLY)
 *
 * Context passed to children:
 *
 * $thick - see «thick» parameter
 * $verbs - list of verbs to be executed
 *
 * TODO: FL_DRILL implementation
 */
module fl_caddy(
  verbs       = FL_ADD,     // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_FOOTPRINT, FL_LAYOUT
  type,
  thick,                    // walls thickness in the fixed form: [[-x,+x],[-y,+y],[-z+z]]
                            // Passed as scalar means same thickness for all the six walls:
                            // [[«thick»,«thick»],[«thick»,«thick»],[«thick»«thick»]].
                            // examples:
                            // thick=[[0,2.5],[0,0],[5,0]]
                            // thick=2.5
  faces,                    // faces defined by their othonormal axis
  tolerance   = fl_JNgauge, // SCALAR added to each internal payload dimension.
  fillet      = 0,          // fillet radius, when > 0 a fillet is inserted where needed
  direction,                // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant,                   // when undef native positioning is used
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(thick);

  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  // delta to add to children thicknesses
  t_deltas  = let(d=(tolerance+fillet)) [
    [fl_isSet(-X,faces)?d:0,fl_isSet(+X,faces)?d:0],
    [fl_isSet(-Y,faces)?d:0,fl_isSet(+Y,faces)?d:0],
    [fl_isSet(-Z,faces)?tolerance:0,fl_isSet(+Z,faces)?tolerance:0]
  ];
  // thickness without tolerance and fillet
  thick     = is_num(thick) ? [[thick,thick],[thick,thick],[thick,thick]] : thick;
  // payload with tolerance and fillet
  pload     = let(
                d     = tolerance+fillet,
                pload = fl_bb_corners(type),
                delta = [
                    [fl_isSet(-X,faces)?d:0, fl_isSet(-Y,faces)?d:0, fl_isSet(-Z,faces)?tolerance:0],
                    [fl_isSet(+X,faces)?d:0, fl_isSet(+Y,faces)?d:0, fl_isSet(+Z,faces)?tolerance:0]
                  ]) [pload[0]-delta[0],pload[1]+delta[1]];
  // bounding box = payload + spessori
  bbox      = let(
                delta = [
                    [fl_isSet(-X,faces)?thick.x[0]:0, fl_isSet(-Y,faces)?thick.y[0]:0, fl_isSet(-Z,faces)?thick.z[0]:0],
                    [fl_isSet(+X,faces)?thick.x[1]:0, fl_isSet(+Y,faces)?thick.y[1]:0, fl_isSet(+Z,faces)?thick.z[1]:0]
                  ]) [pload[0]-delta[0],pload[1]+delta[1]];
  size      = bbox[1]-bbox[0];
  D         = direction ? fl_direction(default=[+Z,+X],direction=direction) : I;
  M         = octant    ? fl_octant(octant=octant,bbox=bbox)                : I;

  fl_trace("thick",thick);

  module do_add() {
    fl_trace("faces",faces);
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
          if (fl_isSet(+X,faces) && fl_isSet(-Z,faces))
            translate([size.x-thick.x[1],0,thick.z[0]]) fl_fillet([FL_ADD],r=fillet,h=size.y,direction=[+Y,180]);
          if (fl_isSet(+X,faces) && fl_isSet(+Z,faces))
            translate([size.x-thick.x[1],0,size.z-thick.z[1]]) fl_fillet([FL_ADD],r=fillet,h=size.y,direction=[+Y,90]);
          if (fl_isSet(+Z,faces) && fl_isSet(-X,faces))
            translate([thick.x[0],0,size.z-thick.z[1]]) fl_fillet([FL_ADD],r=fillet,h=size.y,direction=[+Y,0]);
          if (fl_isSet(-X,faces) && fl_isSet(-Z,faces))
            translate([thick.x[0],0,thick.z[0]]) fl_fillet([FL_ADD],r=fillet,h=size.y,direction=[+Y,-90]);
          if (fl_isSet(-Y,faces) && fl_isSet(-Z,faces))
            translate([0,thick.y[0],thick.z[0]]) fl_fillet([FL_ADD],r=fillet,h=size.x,direction=[+X,+90]);
          if (fl_isSet(+Z,faces) && fl_isSet(-Y,faces))
            translate([0,thick.y[0],size.z-thick.z[1]]) fl_fillet([FL_ADD],r=fillet,h=size.x,direction=[+X,0]);
          if (fl_isSet(+Z,faces) && fl_isSet(+Y,faces))
            translate([0,size.y-thick.y[1],size.z-thick.z[1]]) fl_fillet([FL_ADD],r=fillet,h=size.x,direction=[+X,-90]);
          if (fl_isSet(-Z,faces) && fl_isSet(+Y,faces))
            translate([0,size.y-thick.y[1],thick.z[0]]) fl_fillet([FL_ADD],r=fillet,h=size.x,direction=[+X,+180]);
        }
      }
      let(
        $verbs  = [FL_DRILL,FL_CUTOUT],
        // children thickness must include also tolerance and fillet
        $thick  = thick+t_deltas
      ) children();
    }
  }
  module do_bbox() {}
  module do_drill() {}

  module do_assembly() {
    // enrich children context with $verbs
    let($verbs=[FL_ADD,FL_ASSEMBLY]) do_layout() children();
  }

  module do_layout() {
    let(
      // enrich children context with wall's thickness
      $thick  = thick+t_deltas
    ) children();
  }

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD)
          fl_color($FL_FILAMENT)
            do_add() children();

      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_bb_add(corners=bbox,$FL_ADD=$FL_BBOX);

      } else if ($verb==FL_LAYOUT) {
        // FIXME: apply right $verbs context value during layout
        fl_modifier($FL_LAYOUT) do_layout()
          children();

      } else if ($verb==FL_PAYLOAD) {
        fl_modifier($FL_PAYLOAD) fl_bb_add(pload);

      } else if ($verb==FL_FOOTPRINT) {
        fl_modifier($FL_FOOTPRINT);

      } else if ($verb==FL_ASSEMBLY) {
        fl_modifier($FL_ASSEMBLY) do_assembly() children();

      } else if ($verb==FL_DRILL) {
        fl_modifier($FL_DRILL) echo(str("***WARN***: ",$verb," not yet implemented"));

      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=1.1*size);
  }
}