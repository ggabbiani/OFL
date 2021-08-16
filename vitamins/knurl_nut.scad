/*
 * Created on Fri Jul 16 2021.
 *
 * Copyright © 2021 Giampiero Gabbiani.
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
include <../foundation/incs.scad>;

$fn       = 50;           // [3:50]
$FL_TRACE    = false;
$FL_RENDER   = false;
$FL_DEBUG    = false;

AXES      = false;
ADD       = true;
ASSEMBLY  = false;
BBOX      = false;
DRILL     = false;

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Hidden] */

module __test__() {
  verbs = [
    if (ADD)      FL_ADD,
    if (DRILL)    FL_DRILL,
    if (ASSEMBLY) FL_ASSEMBLY,
    if (BBOX)     FL_BBOX,
  ];

  for(i=[0:len(KnurlNuts)-1]) let(row=KnurlNuts[i],l=len(row)) translate(fl_Y(12*i)) {
    fl_trace("len(row)",len(row));
    arrange(axis=+FL_X,gap=3,types=row) { 
      if (l>0) let(type=row[0]) fl_placeIf(!PLACE_NATIVE,type,OCTANT) knut(verbs,type,fl_axes=AXES);
      if (l>1) let(type=row[1]) fl_placeIf(!PLACE_NATIVE,type,OCTANT) knut(verbs,type,fl_axes=AXES);
      if (l>2) let(type=row[2]) fl_placeIf(!PLACE_NATIVE,type,OCTANT) knut(verbs,type,fl_axes=AXES);
      if (l>3) let(type=row[3]) fl_placeIf(!PLACE_NATIVE,type,OCTANT) knut(verbs,type,fl_axes=AXES);
    }
  }
}

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

function knut_screw(type)   = fl_get(type,"screw");
function knut_l(type)       = fl_get(type,"FL_Z axis length");
function knut_tooth_h(type) = fl_get(type,"tooth height");
function knut_teeth(type)   = fl_get(type,"teeth number");
function knut_r(type)       = fl_get(type,"external radius");
function knut_rings(type)   = fl_get(type,"rings array [[height1,position1],[height2,position2,..]]");
function knut_bbox(type)    = bb_size(type);

module knut(verbs,type,fl_axes=false) {
  assert(verbs!=undef);

  r           = knut_r(type);
  l           = knut_l(type);
  screw       = knut_screw(type);
  screw_r     = screw_radius(screw);
  screw_l     = screw_shorter_than(l);
  rings       = knut_rings(type);
  tooth_h     = knut_tooth_h(type);
  teeth       = knut_teeth(type);
  bbox        = knut_bbox(type);

  module do_add() {
    difference() {
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
    translate(fl_Z(l/2)) %cube(size=bbox, center=true);
  }

  module do_layout()    {
    children();
  }
  module do_drill() {
    cylinder(r=r-0.2 /* tooth_h */, h=l);
  }

  module do_axes() {
    // translate(+fl_Z(center ? l : 0)) 
    fl_axes(size=bbox);
  }

  // translate(-fl_Z(center?l/2:0))
  fl_parse(verbs) {
    if ($verb==FL_ADD) {
      do_add();
      if (fl_axes)
        do_axes();
    } else if ($verb==FL_BBOX) {
      do_bbox();
    } else if ($verb==FL_ASSEMBLY) {
      do_layout() translate(fl_Z(l)) screw(screw,screw_l);
    } else if ($verb==FL_LAYOUT) { 
      do_layout() children();
    } else if ($verb==FL_DRILL) {
      color("orange") {
        do_drill();
      }
    } else if ($verb==FL_AXES) {
      do_axes();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

__test__();