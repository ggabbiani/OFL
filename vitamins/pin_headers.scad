/*
 * NopSCADlib pin header wrapper definitions.
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
include <../foundation/defs.scad>

include <NopSCADlib/lib.scad>
include <NopSCADlib/vitamins/pin_headers.scad>

// namespace for pin headers engine
// TODO: extend namespace definition to other modules
FL_PHDR_NS  = "phdr";

//*****************************************************************************
// keys

// pin header size in [cols,rows]
function fl_phdr_geometryKV(value)  = fl_kv("PCB/size",value);

//*****************************************************************************
// getters
function fl_phdr_geometry(type)     = fl_get(type,fl_phdr_geometryKV()); 

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
) =
  [
    assert(is_string(name)) fl_nameKV(name),
    assert(nop!=undef) fl_nopSCADlibKV(nop),
    if (description!=undef) 
      assert(is_string(description)) fl_descriptionKV(description),
    fl_phdr_geometryKV(geometry),
    let(
      w = hdr_pitch(nop)*geometry.x,
      d = hdr_pitch(nop)*geometry.y,
      h = hdr_pin_length(nop),
      b = hdr_pin_below(nop),
      bbox = [[-w/2,-d/2,-b],[+w/2,+d/2,h-b]]
    ) fl_sizeKV(bbox[1]-bbox[0]),
  ];

FL_PHDR_RPIGPIO = fl_phdr_new("FL_RPI_GPIO","Raspberry PI GPIO",2p54header,[20,2]);

FL_PHDR_DICT = [
  FL_PHDR_RPIGPIO,
];

use     <pin_header.scad>
