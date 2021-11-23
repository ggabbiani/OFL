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
include <../foundation/defs.scad>

//*****************************************************************************
// USB keys
function fl_USB_typeKV(value)             = fl_kv("USB/type",value);

//*****************************************************************************
// USB getters
function fl_USB_type(type)              = fl_get(type,fl_USB_typeKV()); 

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
      fl_USB_typeKV(utype),
      fl_size(value=bbox[1]-bbox[0]),
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
      fl_USB_typeKV(utype),
      fl_size(value=bbox[1]-bbox[0]),
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
      fl_USB_typeKV(utype),
      fl_size(value=bbox[1]-bbox[0]),
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
      fl_USB_typeKV(utype),
      fl_size(value=bbox[1]-bbox[0]),
      fl_bb_corners(value=bbox),
      fl_director(value=+FL_X),fl_rotor(value=+FL_Y),
      // __fl_USB_coDriftKV__(1.17),
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

use     <usb.scad>
