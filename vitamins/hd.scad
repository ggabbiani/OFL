/*
 * Hard disk implementation file.
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
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

include <hds.scad>
include <sata-adapters.scad>

include <../foundation/unsafe_defs.scad>
// // use     <OFL/foundation/placement.scad>
// use     <OFL/foundation/util.scad>
use     <screw.scad>

//*****************************************************************************
// HD properties
// when invoked by «type» parameter act as getters
// when invoked by «value» parameter act as property constructors
function hd_screw_len(type,t)   = assert(t!=undef) screw_longer_than(fl_get(type,"hole depth")+t);

/*
 * Context passed to children (screws):
 *
 *  $director   - screw direction vector
 *  $direction  - [$director,0]
 *  $octant     - undef
 *  $thick      - thickness along current direction
 *  $length     - screw length 
 */
module fl_hd(
  verbs,
  type,
  // surface thickness for FL_DRILL and FL_CUTOUT in the form [[-X,+X],[-Y,+Y],[-Z,+Z]].
  thick,          
  // faces to be used during children layout
  faces=[-X,+X,-Z], 
  // tolerance for the holder part and FL_CUTOUT
  tolerance   = fl_JNgauge, 
  connectors = false,
  // rail lens during FL_DRILL in the form [[-X,+X],[-Y,+Y],[-Z,+Z]].
  dr_rail=[[0,0],[0,0],[0,0]],
  // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,        
  // when undef native positioning is used
  octant            
  ) {
  assert(verbs!=undef);
  assert(type!=undef);
  assert(is_bool(connectors));

  // TODO: make it public somehow
  function isSet(semi_axis,faces) =
    assert(faces!=undef)
    let(
      len   = len(faces),
      rest  = len>1 ? [for(i=[1:len-1]) faces[i]] : []
    ) len==0 ? false : faces[0]==semi_axis ? true : isSet(semi_axis,rest);

  // TODO: make it public somehow
  function fl_isParallel(a,b) = fl_versor(a)*fl_versor(b)==1;

  // // TODO: make it public somehow
  // function fl_isParallel(a,b) = abs(fl_versor(a)*fl_versor(b))==1;

  // TODO: make it public somehow
  function fl_isOrthogonal(a,b) = a*b==0;

  // TODO: make it public somehow
  function fl_axisThick(axis,thick) = 
      axis==-X ? thick.x[0]
    : axis==+X ? thick.x[1]
    : axis==-Y ? thick.y[0]
    : axis==+Y ? thick.x[1]
    : axis==-Z ? thick.z[0]
    : thick.z[1];

  function railLen(axis) = 
      axis==-X ? dr_rail.x[0]
    : axis==+X ? dr_rail.x[1]
    : axis==-Y ? dr_rail.y[0]
    : axis==+Y ? dr_rail.x[1]
    : axis==-Z ? dr_rail.z[0]
    : dr_rail.z[1];

  axes        = fl_list_has(verbs,FL_AXES);
  verbs       = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);
  screw       = fl_screw(type);
  screw_r     = screw_radius(screw);
  screw_hole  = fl_get(type,"hole depth");
  corner_r    = fl_get(type,"corner radius");
  size        = fl_size(type);
  conns       = fl_connectors(type);
  plug        = fl_sata_instance(type);
  Mpd         = fl_get(type,"Mpd");
  block_lower = fl_get(type,"screw block lower");
  block_upper = fl_get(type,"screw block upper");
  D           = direction ? fl_direction(type,direction=direction): I;
  M           = octant    ? fl_octant(type,octant=octant)         : I;

  module do_layout(faces) {
    assert(faces!=undef);
    // horizontal layout
    h_indexes = [
      if (isSet(-X,faces)) -1,
      if (isSet(+X,faces)) +1,
    ];
    for(i=h_indexes) {
      $director   = i*X;
      $direction  = [$director,0];
      $octant     = undef;
      $thick      = fl_axisThick($director,thick);
      $length     = $thick+screw_hole+tolerance;
      delta       = fl_width(type)/2+fl_axisThick($director,thick)+tolerance;
      // lower block
      translate([i*delta,block_lower.y,block_lower.z])
        children();
      // upper block
      translate([i*delta,block_upper.y,block_upper.z])
        children();
    }
    // vertical layout
    if (isSet(-Z,faces))
      for(i=[-1,+1]) {
        $director   = -Z;
        $direction  = [$director,0];
        $octant     = undef;
        $thick      = fl_axisThick($director,thick);
        $length     = $thick+screw_hole+tolerance;
        delta       = -(fl_axisThick($director,thick)+tolerance);
        translate([i*block_lower.x,block_lower.y,delta])
          children();
        translate([i*block_upper.x,block_upper.y,delta])
          children();
      }
  }

  module do_add() {
    difference() {
      fl_color("dimgray") difference() {
        linear_extrude(height=size.z) fl_square(size=size,r=corner_r,quadrant=+Y);
        do_layout([-X,+X,-Z]) let(
          l = fl_axisThick($director,thick)+screw_hole
        ) fl_screw(FL_FOOTPRINT,screw,len=l,octant=$octant,direction=[$director,0]);
      }
      multmatrix(Mpd) fl_sata_powerDataPlug(FL_FOOTPRINT,plug,tolerance=tolerance);
    }
    multmatrix(Mpd) fl_sata_powerDataPlug(type=plug);

    if (connectors)
      for(c=conns) fl_conn_add(c,2);
  }

  module do_bbox() {
    translate([0,size.y/2,size.z/2])
      cube(size,true);
  }

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_add();

      } else if ($verb==FL_ASSEMBLY) {
        fl_modifier($FL_ASSEMBLY) do_layout(faces)
          fl_screw(type=screw,len=$length,direction=$direction);

      } else if ($verb==FL_LAYOUT) {
        fl_modifier($FL_LAYOUT) do_layout(faces)
          children();

      } else if ($verb==FL_DRILL) {
        fl_modifier($FL_DRILL) do_layout(faces)
          fl_rail(railLen($direction[0])) 
            if ($children) children(); 
            else fl_screw(FL_FOOTPRINT,screw,len=$length,direction=$direction);

      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) do_bbox();

      } else if ($verb==FL_FOOTPRINT) {
        fl_modifier($FL_FOOTPRINT) do_bbox();

      } else if ($verb==FL_CUTOUT) {
        echo(str("**WARN**: unimplemented verb ",$verb));

      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_axes(size*1.2);
  }
}
