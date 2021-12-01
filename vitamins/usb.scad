/*
 * NopACADlib USB engine wrapper.
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
include <../foundation/unsafe_defs.scad>
include <../foundation/defs.scad>
include <../foundation/layout.scad>
use     <../foundation/util.scad>
include <usbs.scad>

use     <NopSCADlib/vitamins/pcb.scad>

module fl_USB(
  verbs       = FL_ADD, // supported verbs: FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT
  type,
  co_thick,             // thickness for FL_CUTOUT
  cut_tolerance=0,       // tolerance used during FL_CUTOUT
  co_drift=0,           // translation applied to cutout
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant,               // when undef native positioning is used
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(type!=undef);

  axes    = fl_list_has(verbs,FL_AXES);
  verbs   = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  
  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  D     = direction ? fl_direction(proto=type,direction=direction)  : I;
  M     = octant    ? fl_octant(octant=octant,bbox=bbox)            : I;
  utype = fl_USB_type(type);

  fl_trace("cutout drift",co_drift);

  module wrap() {
    if      (utype=="A")    usb_Ax1();
    else if (utype=="Ax2")  usb_Ax2();
    else if (utype=="B")    usb_B();
    else if (utype=="C")    usb_C();
    else assert(false,str("Unimplemented USB type ",utype));
  }

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) 
          wrap();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_bb_add(bbox);
      } else if ($verb==FL_CUTOUT) {
        assert(co_thick!=undef);
        fl_modifier($FL_CUTOUT) 
          translate(+X(size.x/2+co_drift))
            fl_cutout(len=co_thick,z=X,x=Y,delta=cut_tolerance)
              wrap();
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes([size.x,size.y,1.5*size.z]);
  }
}
