/*!
 * NopACADlib USB definitions wrapper.
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
 * along with OFL.  If not, see <http://www.gnu.org/licenses/>.
 */

include <../foundation/util.scad>

FL_USB_NS = "usb";

//*****************************************************************************
// USB properties
// when invoked by «type» parameter act as getters
// when invoked by «value» parameter act as property constructors
function fl_USB_type(type,value)    = fl_property(type,"usb/type",value);
function fl_USB_flange(type,value)  = fl_property(type,"usb/flange",value);

//*****************************************************************************
//! USB constructor
function fl_USB_new(utype,flange=true) =
  utype=="Ax1"
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
      fl_USB_flange(value=flange),
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
      fl_USB_flange(value=true),
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
      fl_USB_flange(value=false),
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
      fl_USB_flange(value=false),
    ]
  : utype=="uA"
  ? let(
      // following data definitions taken from NopSCADlib usb_uA() module
      l = 6,
      iw1 = 7,
      h = 2.65,
      t = 0.4,
      // calculated bounding box corners
      bbox        = [[-l/2,-(iw1+2*t)/2,0],[+l/2,+(iw1+2*t)/2,h]]
    ) [
      fl_USB_type(value=utype),
      fl_bb_corners(value=bbox),
      fl_director(value=+FL_X),fl_rotor(value=+FL_Y),
      fl_USB_flange(value=flange),
    ]
  : assert(false) [];

FL_USB_TYPE_Ax1     = fl_USB_new("Ax1");
FL_USB_TYPE_Ax1_NF  = fl_USB_new("Ax1",false);
FL_USB_TYPE_Ax2     = fl_USB_new("Ax2");
FL_USB_TYPE_B       = fl_USB_new("B");
FL_USB_TYPE_C       = fl_USB_new("C");
FL_USB_TYPE_uA      = fl_USB_new("uA");
FL_USB_TYPE_uA_NF   = fl_USB_new("uA",false);

FL_USB_DICT = [
  FL_USB_TYPE_Ax1,
  FL_USB_TYPE_Ax1_NF,
  FL_USB_TYPE_Ax2,
  FL_USB_TYPE_B,
  FL_USB_TYPE_C,
  FL_USB_TYPE_uA,
  FL_USB_TYPE_uA_NF,
];

module fl_USB(
  //! supported verbs: FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT
  verbs = FL_ADD,
  type,
  //! thickness for FL_CUTOUT
  cut_thick,
  //! tolerance used during FL_CUTOUT
  tolerance=0,
  //! translation applied to cutout (default 0)
  cut_drift=0,
  //! tongue color (default "white")
  tongue,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant,
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(type!=undef);

  tongue  = tongue!=undef ? tongue : "white";
  flange  = fl_USB_flange(type);
  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  D     = direction ? fl_direction(proto=type,direction=direction)  : I;
  M     = fl_octant(octant,bbox=bbox);
  utype = fl_USB_type(type);
  fl_trace("D",D);
  fl_trace("cutout drift",cut_drift);

  module wrap() {
    if      (utype=="Ax1")  usb_Ax1(tongue=tongue,flange=flange);
    else if (utype=="Ax2")  usb_Ax2();
    else if (utype=="B")    usb_B();
    else if (utype=="C")    usb_C();
    else if (utype=="uA")   usb_uA(flange=flange);
    else assert(false,str("Unimplemented USB type ",utype));
  }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier)
        wrap();

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_CUTOUT) {
      assert(cut_drift!=undef);
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

module usb_A_tongue(color) {
    l = 9;
    w = 12;
    h = 2;

    color(color==undef?"white":color)
        translate([-1, 0 , h / 2])
            rotate([90, 0, 90])
                hull() {
                    linear_extrude(l - 2)
                        square([w, h], center = true);

                    linear_extrude(l)
                        square([w - 1, h - 1], center = true);
                }
}

//! Draw USB type A single socket
module usb_Ax1(cutout = false,tongue="white",flange=true) {
    usb_A(h = 6.5, v_flange_l = 4.5, bar = 0, cutout = cutout, tongue=tongue, flange=flange);
}

//! Draw USB type A dual socket
module usb_Ax2(cutout = false,tongue="white") {
    usb_A(h = 15.6, v_flange_l = 12.15, bar = 3.4, cutout = cutout, tongue=tongue);
}

module usb_A(h, v_flange_l, bar, cutout, tongue, flange=true) {
    l = 17;
    w = 13.25;
    flange_t = 0.4;
    h_flange_h = 0.8;
    h_flange_l = 11;
    v_flange_h = 1;
    socket_h = (h - 2 * flange_t - bar) / 2;

    translate_z(h / 2)
        if(cutout)
            rotate([90, 0, 90])
                rounded_rectangle([w + 2 * v_flange_h + 2 * panel_clearance,
                                   h + 2 * h_flange_h + 2 * panel_clearance, 100], r = cnc_bit_r);
        else {
            color("silver") rotate([0, 90, 0]) {
                linear_extrude(l, center = true)
                    difference() {
                        square([h, w], center = true);

                        for(s = [-1, 1])
                            translate([s * (bar / 2 + socket_h / 2), 0])
                                square([socket_h, w - 2 * flange_t], center = true);
                    }

                translate_z(-l / 2 + 0.5)
                    cube([h, w, 1], center = true);

                if (flange) translate_z(l / 2 - flange_t)
                    linear_extrude(flange_t) difference() {
                        union() {
                            square([h + 2 * h_flange_h, h_flange_l], center = true);

                            square([v_flange_l, w + 2 * v_flange_h], center = true);
                        }
                        square([h - eps, w - eps], center = true);
                    }
                }

                for(z = bar ?  [-1, 1] : [0])
                    translate_z(z * (bar / 2 + socket_h / 2))
                        usb_A_tongue(tongue);
            }
}

//! Draw Molex dual USB A connector suitable for perf board
module molex_usb_Ax2(cutout, tongue) {
    w = 15.9;
    h = 16.6;
    l = 17;
    pin_l = 2.8;
    clearance = 0.2;
    tag_l = 4.4;
    tag_r = 0.5;
    tag_w = 1.5;
    tag_t = 0.3;
    tag_p = 5.65;

    if(cutout)
        translate([0, -w / 2 - clearance, -clearance])
            cube([100, w + 2 * clearance, h + 2 * clearance]);
    else {
        color(silver)
            translate([-l / 2, 0])
                rotate([90, 0, 90])
                    translate([-w / 2, 0]) {
                        cube([w, h, l - 9]);

                        linear_extrude(l)
                            difference() {
                                square([w, h]);

                                for(z = [-1, 1])
                                    translate([w / 2, h / 2 + z * 8.5 / 2])
                                        square([12.6, 5.08], center = true);
                            }
                    }

        for(z = [-1, 1])
            translate_z(h / 2 + z * 8.5 / 2)
                usb_A_tongue(tongue);

        color(silver)
            rotate(-90) {
                for(x = [-1.5 : 1 : 1.5], y = [0.5 : 1 : 1.5])
                    translate([inch(x / 10), -l / 2 + inch(y / 10)])
                        hull() {
                            cube([0.6, 0.3, 2 * pin_l - 2], center = true);

                            cube([0.4, 0.3, 2 * pin_l], center = true);
                        }

                for(side = [-1, 1], end = [0, 1])
                    translate([side * w / 2, -l / 2 + tag_w / 2 + end * tag_p])
                        rotate(-side * 90)
                            hull() {
                                translate([0, tag_l - tag_r])
                                    cylinder(r = tag_r, h = tag_t);

                                translate([-tag_w / 2, 0])
                                    cube([tag_w, eps, tag_t]);
                            }
            }
    }
}

//! Draw Molex USB A connector suitable for perf board
module molex_usb_Ax1(cutout, tongue) {
    w = 15.3;
    h = 7.7;
    l = 14.5;
    pin_l = 2.8;
    clearance = 0.2;
    tag_l = 4.4;
    tag_r = 0.5;
    tag_w = 1.5;
    tag_t = 0.3;

    if(cutout)
        translate([0, -w / 2 - clearance, -clearance])
            cube([100, w + 2 * clearance, h + 2 * clearance]);
    else {
        color(silver)
            translate([-l / 2, 0])
                rotate([90, 0, 90])
                    translate([-w / 2, 0]) {
                        cube([w, h, l - 9]);

                        linear_extrude(l)
                            difference() {
                                square([w, h]);

                                  translate([w / 2, h / 2])
                                    square([12.6, 5.08], center = true);
                            }
                    }

        translate([-1.5, 0, h / 2])
            usb_A_tongue(tongue);

        color(silver)
            rotate(-90) {
                for(x = [-1.5 : 1 : 1.5])
                    translate([inch(x / 10), - l / 2 + inch(0.05)])
                        hull() {
                            cube([0.6, 0.3, 2 * pin_l - 2], center = true);

                            cube([0.4, 0.3, 2 * pin_l], center = true);
                        }

                for(side = [-1, 1])
                    translate([side * w / 2, -l / 2 + 4.2])
                        rotate(-side * 90)
                            hull() {
                                translate([0, tag_l - tag_r])
                                    cylinder(r = tag_r, h = tag_t);

                                translate([-tag_w / 2, 0])
                                    cube([tag_w, eps, tag_t]);
                            }
            }
    }
}

//! Draw USB micro A connector
module usb_uA(cutout = false, flange = true) {
    l = 6;
    iw1 = 7;
    iw2 = 5.7;
    ih1 = 1;
    ih2 = 1.85;
    h = 2.65;
    t = 0.4;
    flange_h = 3;
    flange_w = 8;

    module D() {
        hull() {
            translate([-iw1 / 2, h - t - ih1])
                square([iw1, ih1]);

            translate([-iw2 / 2, h - t - ih2])
                square([iw2, ih2]);
        }
    }

    if(cutout)
        rotate([90, 0, 90])
            linear_extrude(100)
                offset((flange_h - ih2) / 2 + 2 * panel_clearance)
                    D();
    else
        color("silver") rotate([90, 0, 90]) {
            linear_extrude(l, center = true)
                difference() {
                    offset(t)
                        D();

                    D();
                }

            translate_z(-l / 2)
                linear_extrude(1)
                    offset(t)
                        D();

            if (flange) translate_z(l / 2 - t)
                linear_extrude(t) difference() {
                    union() {
                        translate([0, h - t - ih1 / 2])
                            square([flange_w, ih1], center = true);

                        translate([0, h / 2 + flange_h / 4])
                            square([iw1, flange_h / 2], center = true);

                        translate([0, h / 2 - flange_h / 4])
                            square([iw2, flange_h / 2], center = true);
                    }
                    D();
                }
        }
}

//! Draw USB C connector
module usb_C(cutout = false) {
    l = 7.35;
    w = 8.94;
    h = 3.26;
    t = 0.4;
    flange_h = 3;
    flange_w = 8;

    module O()
        translate([0, h / 2])
            rounded_square([w, h], h / 2 - 0.5, center = true);

    if(cutout)
        rotate([90, 0, 90])
            linear_extrude(100)
                offset(2 * panel_clearance)
                    O();
    else
        color("silver") rotate([90, 0, 90]) {
            linear_extrude(l, center = true)
                difference() {
                    O();

                    offset(-t)
                        O();
                }

            translate_z(-l / 2)
                linear_extrude(2.51)
                    O();

        }
}

//! Draw USB B connector
module usb_B(cutout = false) {
    l = 16.4;
    w = 12.2;
    h = 11;
    tab_w = 5.6;
    tab_h = 3.2;
    d_h = 7.78;
    d_w = 8.45;
    d_w2 = 5;
    d_h2 = d_h - (d_w - d_w2) / 2;

    module D()
        hull() {
            translate([-d_w / 2, 0])
                square([d_w, d_h2]);
            translate([-d_w2 /2, 0])
                square([d_w2, d_h]);
        }


    if(cutout)
        translate([50, 0, h / 2 - panel_clearance])
            cube([100, w + 2 * panel_clearance, h + 2 * panel_clearance], center = true);
    else
        translate_z(h / 2) rotate([90, 0, 90]) {
            color("silver")  {
                linear_extrude(l, center = true)
                    difference() {
                        square([w, h], center = true);

                    translate([0, -d_h / 2])
                        offset(delta = 0.2)
                            D();
                    }
                translate_z(-l / 2 + 0.1)
                    cube([w, h, 0.2], center = true);
            }

            color("white") {
                linear_extrude(l - 0.4, center = true)
                    difference() {
                        square([w - 0.2, h - 0.2], center = true);

                        translate([0, -d_h / 2])
                            difference() {
                                D();

                                translate([0, d_h / 2])
                                    square([tab_w, tab_h], center = true);
                            }
                    }
                translate_z( -(l - 0.4) / 2 + 1)
                    cube([w - 0.2, h - 0.2, 2], center = true);
            }
    }
}
