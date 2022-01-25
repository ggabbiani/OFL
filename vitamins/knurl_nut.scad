/*
 * Knurl nuts (aka known as 'inserts') definition module.
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

include <knurl_nuts.scad>
include <../foundation/unsafe_defs.scad>

use     <../foundation/3d.scad>
use     <../foundation/layout.scad>
// use     <../foundation/placement.scad>

module knut(
  verbs,
  type,
  direction,            // desired direction [director,rotation], native direction when undef ([+Z])
  octant,               // when undef native positioning is used
) {
  assert(verbs!=undef);
  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  r       = fl_knut_r(type);
  l       = fl_knut_thick(type);
  screw   = fl_screw(type);
  screw_r = screw_radius(screw);
  screw_l = screw_shorter_than(l);
  rings   = fl_knut_rings(type);
  tooth_h = fl_knut_tooth(type);
  teeth   = fl_knut_teeth(type);
  bbox    = fl_bb_corners(type);
  size    = fl_bb_size(type);
  D       = direction ? fl_direction(proto=type,direction=direction)  : FL_I;
  M       = octant    ? fl_octant(octant=octant,bbox=bbox)            : FL_I;

  fl_trace("bbox",bbox);
  fl_trace("size",size);

  module tooth(r,h) {
    assert(r!=undef||h!=undef);
    // echo(str("r=", r));
    hh = (h==undef) ? r * 3 / 2 : h;
    rr = (r==undef) ? h * 2 / 3 : r;
    translate([hh-rr,0,0]) rotate(240,FL_Z) circle(rr,$fn=3);
  }

  module toothed_circle(
    n,      // number of teeth
    r,      // inner circle
    h       // tooth height
    ) {
    for(i=[0:n])
      rotate([0,0,i*360/n])
        translate([r,0,0])
          tooth(h=h);
    circle(r=r);
    // %circle(r+h);
    // #circle(r);
  }

  module toothed_nut(
    n=100,  // number of teeth
    r,      // inner circle
    R,      // outer circle
    thick,
    center=false
    ) {
    translate([0,0,center?-thick/2:0])
      linear_extrude(thick) {
        difference() {
          toothed_circle(n=n,r=r,h=R-r);
          circle(r=r);
        }
      }
  }

  module do_add() {
    fl_color("gold") difference() {
      union() {
        for(ring=rings)
          translate([0, 0, ring[1]])
            toothed_nut(r=screw_r,R=r,thick=ring[0],n=teeth);
        cylinder(r=r-tooth_h, h=l);
      }
      translate(-fl_Z(FL_NIL)) cylinder(r=screw_r, h=l+2*FL_NIL);
    }
    // #cylinder(r=r, h=l);
  }

  module do_bbox() {
    translate(+Z(l/2)) fl_cube(size=size+[0,0,2*NIL], octant=O);
  }

  module do_layout()    {
    translate(fl_Z(l)) children();
  }
  module do_drill() {
    fl_cylinder(r=r-0.2 /* tooth_h */, h=l,octant=+Z);
  }

  // translate(-fl_Z(center?l/2:0))
  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_add();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) do_bbox();
      } else if ($verb==FL_ASSEMBLY) {
        fl_modifier($FL_ASSEMBLY) do_layout()  screw(screw,screw_l);
      } else if ($verb==FL_LAYOUT) {
        fl_modifier($FL_LAYOUT) do_layout() children();
      } else if ($verb==FL_DRILL) {
        fl_modifier($FL_DRILL) do_drill();
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=size);
  }
}
