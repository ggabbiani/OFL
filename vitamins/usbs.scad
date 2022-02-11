/*
 * NopACADlib USB definitions wrapper.
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

include <../foundation/util.scad>

use     <NopSCADlib/vitamins/pcb.scad>

//*****************************************************************************
// USB properties
// when invoked by «type» parameter act as getters
// when invoked by «value» parameter act as property constructors
function fl_USB_type(type,value) = fl_property(type,"USB/type",value);

//*****************************************************************************
// USB constructors
function fl_USB_new(utype) =
  utype=="A"
  ? let(
      // following data definitions taken from NopSCADlib usb_Ax1() module
      h           = 6.5,
      v_flange_l  = 4.5,
      bar         = 0,
      // following data definitions taken from NopSCADlib usb_A() module
      l         = 17,
      w         = 13.25,
      flange_t  = 0.4,
      // calculated bounding box corners
      bbox      = [[-l/2,-w/2,0],[+l/2,+w/2,h]]
    ) [
      fl_USB_type(value=utype),
      fl_bb_corners(value=bbox),
      fl_director(value=+FL_X),fl_rotor(value=+FL_Y),
    ]
  : utype=="Ax2"
  ? let(
      // following data definitions taken from NopSCADlib usb_Ax2() module
      h           = 15.6,
      v_flange_l  = 12.15,
      bar         = 3.4,
      // following data definitions taken from NopSCADlib usb_A() module
      l           = 17,
      w           = 13.25,
      flange_t    = 0.4,
      // calculated bounding box corners
      bbox        = [[-l/2,-w/2,0],[+l/2,+w/2,h]]
    ) [
      fl_USB_type(value=utype),
      fl_bb_corners(value=bbox),
      fl_director(value=+FL_X),fl_rotor(value=+FL_Y),
    ]
  : utype=="B"
  ? let(
      // following data definitions taken from NopSCADlib usb_A() module
      l     = 16.4,
      w     = 12.2,
      h     = 11,
      // calculated bounding box corners
      bbox  = [[-l/2,-w/2,0],[+l/2,+w/2,h]]
    ) [
      fl_USB_type(value=utype),
      fl_bb_corners(value=bbox),
      fl_director(value=+FL_X),fl_rotor(value=+FL_Y),
    ]
  : utype=="C"
  ? let(
      // following data definitions taken from NopSCADlib usb_C() module
      l     = 7.35,
      w     = 8.94,
      h     = 3.26,
      // calculated bounding box corners
      bbox  = [[-l/2,-w/2,0],[+l/2,+w/2,h]]
    ) [
      fl_USB_type(value=utype),
      fl_bb_corners(value=bbox),
      fl_director(value=+FL_X),fl_rotor(value=+FL_Y),
    ]
  : assert(false) [];

FL_USB_TYPE_A   = fl_USB_new("A");
FL_USB_TYPE_Ax2 = fl_USB_new("Ax2");
FL_USB_TYPE_B   = fl_USB_new("B");
FL_USB_TYPE_C   = fl_USB_new("C");

FL_USB_DICT = [
  FL_USB_TYPE_A,
  FL_USB_TYPE_Ax2,
  FL_USB_TYPE_B,
  FL_USB_TYPE_C,
];

module fl_USB(
  verbs       = FL_ADD, // supported verbs: FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT
  type,
  cut_thick,            // thickness for FL_CUTOUT
  tolerance=0,      // tolerance used during FL_CUTOUT
  cut_drift=0,          // translation applied to cutout
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant,               // when undef native positioning is used
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(type!=undef);

  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  D     = direction ? fl_direction(proto=type,direction=direction)  : I;
  M     = octant    ? fl_octant(octant=octant,bbox=bbox)            : I;
  utype = fl_USB_type(type);

  fl_trace("cutout drift",cut_drift);

  module wrap() {
    if      (utype=="A")    usb_Ax1();
    else if (utype=="Ax2")  usb_Ax2();
    else if (utype=="B")    usb_B();
    else if (utype=="C")    usb_C();
    else assert(false,str("Unimplemented USB type ",utype));
  }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier)
        wrap();
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);
    } else if ($verb==FL_CUTOUT) {
      assert(cut_thick!=undef);
      fl_modifier($modifier)
        translate(+X(size.x/2+cut_drift))
          fl_cutout(len=cut_thick,z=X,x=Y,delta=tolerance)
            wrap();
    } else if ($verb==FL_FOOTPRINT) {
      assert(tolerance!=undef,tolerance);
      fl_modifier($modifier) fl_bb_add(bbox+tolerance*[[-1,-1,-1],[1,1,1]]);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
