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

/*
 * Builds a caddy around the passed object «type».
 * Any eventually passed children will be used during FL_ADD (for drilling) and FL_ASSEMBLY.
 *
 * Children context:
 * $verbs - list of verbs to be executed
 * $thick - see «thick» parameter
 *
 * Triggered verbs on children:
 * FL_DRILL,FL_CUTOUT (during FL_ADD)
 * FL_ADD,FL_ASSEMBLY (during FL_ASSEMBLY)
 *
 * TODO: FL_DRILL implementation
 */
module fl_caddy(
  verbs       = FL_ADD,     // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_FOOTPRINT, FL_LAYOUT
  type,
  thick,                    // walls thickness in the free form:
                            // [["+X",«+X thick value»],["-X",«-X thick value»],["+Y",«+Y thick value»],["-Y",«-Y thick value»],["+Z",«+Z thick value»],["-Z",«-Z thick value»]]. 
                            // Passed as scalar means same thickness for all the six walls:
                            // [["+X",«thick»],["-X",«thick»],["+Y",«thick»],["-Y",«thick»],["+X",«thick»],["-X",«thick»]]. 
                            // NOTE: any missing semi-axis thickness is set to 0
                            // examples:
                            // thick=[["+X",2.5],["-Z",5]]
                            // thick=2.5
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

  // delta da sommare agli spessori inviati ai figli
  t_deltas  = let(d=(tolerance+fillet)) [[d,d],[d,d],[d,d]];
  // spessore SENZA tolleranza e filetto
  thick     = is_num(thick) 
            ? [[thick,thick],[thick,thick],[thick,thick]] 
            : [[fl_get(thick,"-X",0),fl_get(thick,"+X",0)],[fl_get(thick,"-Y",0),fl_get(thick,"+Y",0)],[fl_get(thick,"-Z",0),fl_get(thick,"+Z",0)]];
  // payload CON tolleranza e filetto
  pload     = let(
                d     = tolerance+fillet,
                pload = fl_bb_corners(type),
                delta = [
                    [isSet(-X,faces)?d:0, isSet(-Y,faces)?d:0, isSet(-Z,faces)?tolerance:0],
                    [isSet(+X,faces)?d:0, isSet(+Y,faces)?d:0, isSet(+Z,faces)?tolerance:0]
                  ]) [pload[0]-delta[0],pload[1]+delta[1]];
  // bounding box = payload + spessori
  bbox      = let(
                delta = [
                    [isSet(-X,faces)?thick.x[0]:0, isSet(-Y,faces)?thick.y[0]:0, isSet(-Z,faces)?thick.z[0]:0],
                    [isSet(+X,faces)?thick.x[1]:0, isSet(+Y,faces)?thick.y[1]:0, isSet(+Z,faces)?thick.z[1]:0]
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
      let(
        $verbs  = [FL_DRILL,FL_CUTOUT],
        // ai figli inviamo lo spessore delle pareti + tolleranza e filetto
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
    // enrich children context with wall's thickness
    let($thick=thick+t_deltas) children();
  }

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