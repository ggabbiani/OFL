/*
 * NopSCADlib pin header wrapper definitions.
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
include <../foundation/util.scad>

include <NopSCADlib/lib.scad>
include <NopSCADlib/vitamins/pin_headers.scad>

// namespace for pin headers engine
// TODO: extend namespace definition to other modules
FL_PHDR_NS  = "phdr";

//*****************************************************************************
// Pin header properties
// when invoked by «type» parameter act as getters
// when invoked by «value» parameter act as property constructors
function fl_phdr_geometry(type,value)  = fl_property(type,"phdr/size in [cols,rows]",value);

//*****************************************************************************
// helpers

// return the nop bounding box from its geometry
function fl_phdr_nopBBox(
  nop,      // NopSCADlib pin header
  geometry  // pin header size in [cols,rows]
) =
  let(
    w = hdr_pitch(nop)*geometry.x,
    d = hdr_pitch(nop)*geometry.y,
    h = hdr_pin_length(nop),
    b = hdr_pin_below(nop)
  ) [[-w/2,-d/2,-b],[+w/2,+d/2,h-b]];

// return the nop size from its geometry
function fl_phdr_nopSize(
  nop,      // NopSCADlib pin header
  geometry  // pin header size in [cols,rows]
) = let(bbox = fl_phdr_nopBBox(nop,geometry)) bbox[1]-bbox[0];

//*****************************************************************************
// constructor
function fl_phdr_new(
  name,
  description,  // optional description string
  nop,          // NopSCADlib base type
  geometry  = [1,1] // pin header size in [cols,rows]
) = let(
  bbox = fl_phdr_nopBBox(nop,geometry)
)
  [
    assert(is_string(name)) fl_name(value=name),
    assert(nop!=undef) fl_nopSCADlib(value=nop),
    if (description!=undef)
      assert(is_string(description)) fl_description(value=description),
    fl_phdr_geometry(value=geometry),
    fl_bb_corners(value=bbox),
    fl_director(value=+Z),fl_rotor(value=+X),
  ];

FL_PHDR_RPIGPIO = fl_phdr_new("FL_RPI_GPIO","Raspberry PI GPIO",2p54header,[20,2]);

FL_PHDR_DICT = [
  FL_PHDR_RPIGPIO,
];

module fl_pinHeader(
  verbs       = FL_ADD, // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  type,
  nop,                  // NopSCADlib header
  geometry    = [1,1],  // pin header size in [cols,rows]
  smt         = false,  // surface mount
  right_angle = false,
  color,
  cut_thick,            // thickness for FL_CUTOUT
  cut_tolerance=0,      // tolerance used during FL_CUTOUT
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant                // when undef native positioning is used
) {
  // echo(nop=nop);
  // echo(type=type);
  assert(is_list(verbs)||is_string(verbs),verbs);
  // FIXME: when called from fl_pcb the following assert fails
  // assert(fl_XOR(nop!=undef,type!=undef));

  nop       = type!=undef ? fl_nopSCADlib(type) : nop;
  geometry  = type!=undef ? fl_phdr_geometry(type) : geometry;
  bbox      =  type!=undef ? fl_bb_corners(type) : fl_phdr_nopBBox(nop,geometry);
  size      = bbox[1]-bbox[0];
  cols      = geometry.x;
  rows      = geometry.y;

  D     = direction ? fl_direction(direction=direction,default=[Z,X])  : FL_I;
  M     = octant    ? fl_octant(octant=octant,bbox=bbox)            : FL_I;

  fl_trace("hdr_pin_length",hdr_pin_length(nop));
  fl_trace("hdr_pin_below",hdr_pin_below(nop));
  fl_trace("hdr_pin_width",hdr_pin_width(nop));
  fl_trace("hdr_box_size",hdr_box_size(nop));
  fl_trace("hdr_box_wall",hdr_box_wall(nop));
  fl_trace("hdr_pitch",hdr_pitch(nop));

  module do_add() {
    pin_header(nop, cols, rows,smt=smt,right_angle=right_angle,colour=color);
  }
  module do_layout() {}
  module do_drill() {}

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);
    } else if ($verb==FL_CUTOUT) {
      assert(cut_thick!=undef);
      fl_modifier($modifier)
        fl_cutout(len=cut_thick,delta=cut_tolerance)
          do_add();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
