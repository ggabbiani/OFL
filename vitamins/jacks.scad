/*
 * NopACADlib Jack definitions wrapper.
 *
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org)
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

include <../foundation/3d.scad>
include <../foundation/connect.scad>
include <../foundation/label.scad>
include <../foundation/tube.scad>
include <../foundation/util.scad>

FL_JACK_NS = "jack";

FL_JACK_BARREL = let(
  // following data definitions taken from NopSCADlib jack() module
  l = 12,
  w = 7,
  h = 6,
  ch = 2.5,
  // calculated bounding box corners
  bbox      = [[-l/2,-w/2,0],[+l/2+ch,+w/2,h]]
) [
  fl_bb_corners(value=bbox),
  fl_director(value=+FL_X),fl_rotor(value=+FL_Y),
  fl_engine(value="fl_jack_barrelEngine"),
];

FL_JACK_MCXJPHSTEM1 = let(
  name  = "50Ω MCX EDGE MOUNT JACK PCB CONNECTOR",
  w     = 6.7,
  l     = 9.3,
  h     = 5,
  sz    = [w,l,h],
  axis  = [0,0,0.4],
  bbox  = [[-w/2,0,-h/2+axis.z],[+w/2,l,+h/2+axis.z]],
  d_ext = 6.7,
  head  = 6.25,
  tail  = sz.y - head,
  jack  = sz.y-2
) [
  fl_name(value=name),
  fl_bb_corners(value=bbox),
  fl_director(value=-Y),fl_rotor(value=+X),
  fl_engine(value="fl_jack_mcxjphstem1Engine"),
  fl_connectors(value=[
    conn_Socket("antenna",+X,-Z,[0,0,axis.z],size=3.45,octant=-X-Y,direction=[-Z,180])
  ]),
  ["axis of symmetry",  axis],
  ["external diameter", d_ext],
  ["head",              head],
  ["tail",              tail],
  ["jack length",       jack]
];

FL_JACK_DICT = [
  FL_JACK_BARREL,
  FL_JACK_MCXJPHSTEM1,
];

module fl_jack(
  verbs       = FL_ADD, // supported verbs: FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT
  type,
  cut_thick,            // thickness for FL_CUTOUT
  cut_tolerance=0,      // tolerance used during FL_CUTOUT
  cut_drift=0,          // translation applied to cutout
  // see function fl_parm_setDebug()
  debug,
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant,               // when undef native positioning is used
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(type!=undef);
  engine  = fl_engine(type);
  if (engine=="fl_jack_barrelEngine")
    fl_jack_barrelEngine(verbs,type,cut_thick,cut_tolerance,cut_drift,debug,direction,octant);
  else if (engine=="fl_jack_mcxjphstem1Engine")
    fl_jack_mcxjphstem1Engine(verbs,type,cut_thick,cut_tolerance,cut_drift,debug,direction,octant);
  else
    assert(false,str("Engine '",engine,"' unknown."));
}

module fl_jack_barrelEngine(
  // supported verbs: FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT
  verbs       = FL_ADD,
  type,
  // thickness for FL_CUTOUT
  cut_thick,
  // tolerance used during FL_CUTOUT
  cut_tolerance=0,
  // translation applied to cutout
  cut_drift=0,
  // see function fl_parm_setDebug()
  debug,
  // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  // when undef native positioning is used
  octant,
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(type!=undef);

  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  D     = direction ? fl_direction(proto=type,direction=direction)  : I;
  M     = octant    ? fl_octant(octant=octant,bbox=bbox)            : I;

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier)
        jack();
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);
    } else if ($verb==FL_CUTOUT) {
      assert(cut_thick!=undef);
      fl_modifier($modifier)
        translate(+X(bbox[1].x-2.5+cut_drift))
          fl_cutout(len=cut_thick,z=X,x=-Z,delta=cut_tolerance,trim=X(-size.x/2),cut=true)
            jack();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

// FIXME: issue when directioning, likely to be related to the 'D' matrix when director is not +Z
/**
 * Engine for RF MCX edge mount jack pcb connector
 * specs taken from https://www.rfconnector.com/mcx/edge-mount-jack-pcb-connector
 */
module fl_jack_mcxjphstem1Engine(
  // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  type,
  // thickness for FL_CUTOUT
  cut_thick,
  // tolerance used during FL_CUTOUT
  cut_tolerance=0,
  // translation applied to cutout
  cut_drift=0,
  // see function fl_parm_setDebug()
  debug,
  // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  // when undef native positioning is used
  octant,
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  bbox    = fl_bb_corners(type);
  size    = fl_bb_size(type);
  d_ext   = fl_get(type,"external diameter");
  axis    = fl_get(type, "axis of symmetry");
  head    = fl_get(type,"head");
  tail    = fl_get(type,"tail");
  jack    = fl_get(type,"jack length");
  Mshape  = T(+Y(size.y)) * Rx(90);
  conns   = fl_connectors(type);
  echo(debug=debug);
  D       = direction ? fl_direction(proto=type,direction=direction)  : I;
  M       = octant    ? fl_octant(octant=octant,bbox=bbox)            : I;

  module do_add() {
    multmatrix(Mshape) {
      fl_color("gold") {
        difference() {
          fprint();
          translate([0,axis.z,-NIL])
            fl_cylinder(d=3.45,h=size.y+NIL);
          translate([0,0,-NIL])
            fl_cube(size=[size.x,size.z,size.y-head+NIL2],octant=-Y+Z);
          translate([0,axis.z,-NIL])
            fl_cube(size=[size.x,size.z,size.y-head+NIL2],octant=+Y+Z);
        }
        // female jack
        let(l=jack)
        translate([0,axis.z,0])
          fl_tube(d=0.95+NIL2,thick=0.1,h=l);
        // closing bottom
        translate([0,axis.z,size.y-head+NIL])
          fl_tube(d=3.45+NIL2,thick=(3.45-1.88)/2,h=1);
      }
      fl_color("white") translate([0,axis.z,size.y-head+NIL])
        fl_tube(d=1.88+NIL2,thick=(1.88-0.95)/2,h=1);
    }
  }

  module do_cutout() {
    assert(cut_thick);
    translate(-Y(cut_drift))
      multmatrix(Mshape)
        translate([0,axis.z,size.y])
          fl_cylinder(d=3.45+cut_tolerance*2,h=cut_thick);
  }

  module fprint() {
    difference() {
      translate(+Y(axis.z))
        fl_cylinder(d=d_ext,h=size.y-NIL);
      // lower cut
      fl_cube(size=[size.x,size.z,size.y+0*NIL],octant=-Y+Z);
      // upper cut
      translate([0,size.z/2+axis.z,0])
        fl_cube(size=[size.x,size.z,size.y+NIL2],octant=+Y+Z);
    }
    fl_cube(size=[4.8,size.z/2-axis.z,size.y-NIL],octant=-Y+Z);
  }

  module do_footprint() {
    multmatrix(Mshape)
      fprint();
  }

  fl_manage(verbs,M,D,size,debug,connectors=conns) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_CUTOUT) {
      fl_modifier($modifier) do_cutout();

    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) do_footprint();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
