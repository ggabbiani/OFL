/*!
 * NopSCADlib USB definitions wrapper.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../ext/NopSCADlib/utils/core/core.scad>
include <../foundation/unsafe_defs.scad>

use <../foundation/2d-engine.scad>
use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>
use <../foundation/mngm-engine.scad>
use <../foundation/util.scad>

FL_USB_NS = "usb";

//*****************************************************************************
// USB properties
// when invoked by «type» parameter act as getters
// when invoked by «value» parameter act as property constructors
function fl_USB_flange(type,value)  = fl_property(type,"usb/flange",value);

//*****************************************************************************
FL_USB_TYPE_Ax1_NF_SM = let(
  // h = 6.5, l = 10, w = 13.25
  h = 5.8, l = 10, w = 13.25
) [
  fl_engine(value="USB/A SM"),
  fl_bb_corners(value=[[-l,-w/2,0],[0,+w/2,h]]),
  // fl_director(value=+X),fl_rotor(value=+Y),
  fl_cutout(value=[+FL_X,-FL_X,+FL_Y,-FL_Y,+FL_Z,-FL_Z]),
  fl_USB_flange(value=false),
];

FL_USB_TYPE_Ax1 = let(
  // from NopSCADlib usb_Ax1() module
  h=6.5, v_flange_l=4.5, bar=0,
  // from NopSCADlib usb_A() module
  l=17,w=13.25,flange_t= 0.4
) [
  fl_engine(value="USB/Ax1"),
  fl_bb_corners(value=[[-l/2,-w/2,0],[+l/2,+w/2,h]]),
  // fl_director(value=+FL_X),fl_rotor(value=+FL_Y),
  fl_cutout(value=[+FL_X,-FL_X,+FL_Y,-FL_Y,+FL_Z,-FL_Z]),
  fl_USB_flange(value=true),
];

FL_USB_TYPE_Ax1_NF = let(
  // from NopSCADlib usb_Ax1() module
  h=6.5,
  // from NopSCADlib usb_A() module
  l=17,w=13.25,flange_t= 0.4
) [
  fl_engine(value="USB/Ax1"),
  fl_bb_corners(value=[[-l/2,-w/2,0],[+l/2,+w/2,h]]),
  // fl_director(value=+FL_X),fl_rotor(value=+FL_Y),
  fl_cutout(value=[+FL_X,-FL_X,+FL_Y,-FL_Y,+FL_Z,-FL_Z]),
  fl_USB_flange(value=false),
];

FL_USB_TYPE_Ax2 = let(
  // from NopSCADlib usb_Ax2() module
  h=15.6,
  // from NopSCADlib usb_A() module
  l=17, w=13.25, flange_t=0.4
) [
  fl_engine(value="USB/Ax2"),
  fl_bb_corners(value=[[-l/2,-w/2,0],[+l/2,+w/2,h]]),
  // fl_director(value=+FL_X),fl_rotor(value=+FL_Y),
  fl_cutout(value=[+FL_X,-FL_X,+FL_Y,-FL_Y,+FL_Z,-FL_Z]),
  fl_USB_flange(value=true),
];

FL_USB_TYPE_B   = let(
  // from NopSCADlib usb_A() module
  l=16.4, w=12.2, h=11
) [
  fl_engine(value="USB/B"),
  fl_bb_corners(value=[[-l/2,-w/2,0],[+l/2,+w/2,h]]),
  // fl_director(value=+FL_X),fl_rotor(value=+Y),
  fl_cutout(value=[+FL_X,-FL_X,+FL_Y,-FL_Y,+FL_Z,-FL_Z]),
  fl_USB_flange(value=false),
];

FL_USB_TYPE_C   = let(
  // from NopSCADlib usb_C() module
  l=7.35, w=8.94, h=3.26
) [
  fl_engine(value="USB/C"),
  fl_bb_corners(value=[[-l/2,-w/2,0],[+l/2,+w/2,h]]),
  // fl_director(value=+X),fl_rotor(value=+Y),
  fl_cutout(value=[+FL_X,-FL_X,+FL_Y,-FL_Y,+FL_Z,-FL_Z]),
  fl_USB_flange(value=false),
];

FL_USB_TYPE_uA = let(
  // from NopSCADlib usb_uA() module
  l = 6, iw1 = 7, h = 2.65, t = 0.4
) [
  fl_engine(value="USB/uA"),
  fl_bb_corners(value=[[-l/2,-(iw1+2*t)/2,0],[+l/2,+(iw1+2*t)/2,h]]),
  // fl_director(value=+X),fl_rotor(value=+Y),
  fl_cutout(value=[+FL_X,-FL_X,+FL_Y,-FL_Y,+FL_Z,-FL_Z]),
  fl_USB_flange(value=true),
];

FL_USB_TYPE_uA_NF = let(
  // from NopSCADlib usb_uA() module
  l = 6, iw1 = 7, h = 2.65, t = 0.4
) [
  fl_engine(value="USB/uA"),
  fl_bb_corners(value=[[-l/2,-(iw1+2*t)/2,0],[+l/2,+(iw1+2*t)/2,h]]),
  // fl_director(value=+X),fl_rotor(value=+Y),
  fl_cutout(value=[+FL_X,-FL_X,+FL_Y,-FL_Y,+FL_Z,-FL_Z]),
  fl_USB_flange(value=false),
];

FL_USB_DICT = [
  FL_USB_TYPE_Ax1_NF_SM,
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
  cut_tolerance=0,
  //! translation applied to cutout (default 0)
  cut_drift=0,
  /*!
   * Cutout direction list in floating semi-axis list (see also fl_tt_isAxisList()).
   *
   * Example:
   *
   *     cut_direction=[+X,+Z]
   *
   * in this case the usb will perform a cutout along +X and +Z.
   *
   * **Note:** axes specified must be present in the supported cutout direction
   * list (retrievable through fl_cutout() getter)
   */
  cut_direction,
  //! tongue color
  tongue="white",
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(type!=undef);

  flange  = fl_USB_flange(type);
  bbox    = fl_bb_corners(type);
  size    = fl_bb_size(type);
  D       = direction ? fl_direction(direction) : FL_I;
  M       = fl_octant(octant,bbox=bbox);
  engine  = fl_engine(type);

  module wrap() {
    if      (engine=="USB/A SM") usb_A_sm($verb);
    else if (engine=="USB/Ax1")  usb_Ax1(tongue=tongue,flange=flange);
    else if (engine=="USB/Ax2")  usb_Ax2(tongue=tongue);
    else if (engine=="USB/B")    usb_B();
    else if (engine=="USB/C")    usb_C();
    else if (engine=="USB/uA")   usb_uA(flange=flange);
    else assert(false,engine);
  }

  module usb_A_sm(verb) {
    Tshield = 0.35;
    Rext    = 0.32;
    Rint    = Rext-0.1;

    module tongue() {
      l = 8.38;
      w = 11.10;
      h = 1.84;

      translate([-l, 0 , h / 2])
        hull() {
          fl_linear_extrude(length=(l-2),direction=[FL_X,90])
            fl_square(size=[w, h]);

          fl_linear_extrude(length=l,direction=[FL_X,90])
            fl_square(size=[w - 1, h - 1]);
        }
    }

    module do_add() {
      translate(+Z(size.z/2)) {
        fl_color("silver")
          fl_linear_extrude(length=size.x,direction=[-FL_X,0])
            difference() {
              fl_square(size=[size.z,size.y],corners=Rext);
              fl_square(size=[size.z-2*Tshield,size.y-2*Tshield],corners=Rint);
            }
        fl_color(tongue)
          tongue();
        fl_color(fl_grey(30))
          translate(-fl_X(size.x-Tshield))
            fl_linear_extrude(length=Tshield,direction=[-FL_X,0])
              fl_square(size=[size.z-2*Tshield,size.y-2*Tshield],corners=Rint);
      }
    }

    if (verb==FL_ADD) {
      do_add();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",verb));
    }
  }

  module do_cutout() {
    for(axis=cut_direction)
      if (fl_isInAxisList(axis,fl_cutout(type)))
        let(
          sys = [axis.x ? -Z : X ,O,axis],
          t   = (bbox[fl_list_max(axis)>0 ? 1 : 0]*axis+cut_drift)*axis
        )
        translate(t)
          fl_cutout(cut_thick,sys.z,sys.x,delta=cut_tolerance)
            wrap($verb=FL_ADD,$FL_ADD=$FL_CUTOUT);
            // do_footprint();
      else
        echo(str("***WARN***: Axis ",axis," not supported"));
  }

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier)
        wrap();

    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_CUTOUT) {
      assert(cut_drift!=undef);
      assert(cut_thick!=undef);

      fl_modifier($modifier)
        // if (engine=="USB/A SM")
        //   wrap();
        // else
          // translate(+fl_X(size.x/2+cut_drift))
            do_cutout();
            // fl_cutout(len=cut_thick,z=FL_X,x=FL_Y,delta=tolerance)
            //   wrap();

    } else if ($verb==FL_FOOTPRINT) {
      // FIXME: re-implement «tolerance» parameter by $fl_tolerance special
      // variable
      // assert(tolerance!=undef,tolerance);
      fl_modifier($modifier) fl_bb_add(bbox/* +tolerance*[[-1,-1,-1],[1,1,1]] */);

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

module usb_A_tongue(color) {
  l = 9;
  w = 12;
  h = 2;
  fl_color(color?color:"white")
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
