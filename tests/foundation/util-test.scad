/*
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org).
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

include <../../foundation/util.scad>

include <../../vitamins/screw.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Commons] */

// select the utility to be tested
UTIL        = "rail"; // [rail, plane align, cutout]
// thickness of the test plane to be 'railed'
PLANE_T    = 2.5;

/* [Meta screw test] */

// used if different test
META_SCREW  = "M2_cap_screw"; // [No632_pan_screw,M2_cap_screw,M2_cs_cap_screw,M2_dome_screw,M2p5_cap_screw,M2p5_pan_screw,M3_cap_screw,M3_cs_cap_screw,M3_dome_screw,M3_grub_screw,M3_hex_screw,M3_low_cap_screw,M3_pan_screw,M4_cap_screw,M4_cs_cap_screw,M4_dome_screw,M4_grub_screw,M4_hex_screw,M4_pan_screw,M5_cap_screw,M5_cs_cap_screw,M5_dome_screw,M5_hex_screw,M5_pan_screw,M6_cap_screw,M6_cs_cap_screw,M6_hex_screw,M6_pan_screw,M8_cap_screw,M8_hex_screw,No2_screw,No4_screw,No6_cs_screw,No6_screw,No8_screw]
// screw length
META_LEN    = 10;

/* [Rail test] */

ADD       = true;
ASSEMBLY  = false;

// length of the rail
RAIL_LEN  = 10; // [0:100]

/* [Plane align test] */
PLANE_SRC_AXIS_1  = [1,0,0]; // [-1:0.1:1]
PLANE_SRC_AXIS_2  = [0,1,0]; // [-1:0.1:1]

PLANE_DST_AXIS_1  = [1,0,0]; // [-1:0.1:1]
PLANE_DST_AXIS_2  = [0,1,0]; // [-1:0.1:1]

/* [Cutout test] */

// axis to use (detects the cutout plane on O)
CO_AXIS = "Z";  // [X,-X,Y,-Y,Z,-Z]
// distance of the new outline from the original outline
CO_DELTA = 0; // [0:0.1:1]
// translation applied BEFORE the projection() useful for trimming when CO_CUT=true
CO_TRIM  = [0,0,0]; // [-5:0.1:5]
// when true only the cutout plane is used for section
CO_CUT    = false;

/* [Hidden] */

module __test__() {
  // customizer helper
  function axis(s) =
    assert(s=="X" || s=="-X" || s=="Y" || s=="-Y" || s=="Z" || s=="-Z")
    s == "X" ? FL_X : s=="-X" ? -FL_X : s=="Y" ? FL_Y : s=="-Y" ? -FL_Y : s=="Z" ? FL_Z : -FL_Z;
  screw = META_SCREW=="No632_pan_screw" ? No632_pan_screw
        : META_SCREW=="M2_cap_screw"    ? M2_cap_screw
        : META_SCREW=="M2_cs_cap_screw" ? M2_cs_cap_screw
        : META_SCREW=="M2_dome_screw"   ? M2_dome_screw
        : META_SCREW=="M2p5_cap_screw"  ? M2p5_cap_screw
        : META_SCREW=="M2p5_pan_screw"  ? M2p5_pan_screw
        : META_SCREW=="M3_cap_screw"    ? M3_cap_screw
        : META_SCREW=="M3_cs_cap_screw" ? M3_cs_cap_screw
        : META_SCREW=="M3_dome_screw"   ? M3_dome_screw
        : META_SCREW=="M3_grub_screw"   ? M3_grub_screw
        : META_SCREW=="M3_hex_screw"    ? M3_hex_screw
        : META_SCREW=="M3_low_cap_screw"? M3_low_cap_screw
        : META_SCREW=="M3_pan_screw"    ? M3_pan_screw
        : META_SCREW=="M4_cap_screw"    ? M4_cap_screw
        : META_SCREW=="M4_cs_cap_screw" ? M4_cs_cap_screw
        : META_SCREW=="M4_dome_screw"   ? M4_dome_screw
        : META_SCREW=="M4_grub_screw"   ? M4_grub_screw
        : META_SCREW=="M4_hex_screw"    ? M4_hex_screw
        : META_SCREW=="M4_pan_screw"    ? M4_pan_screw
        : META_SCREW=="M5_cap_screw"    ? M5_cap_screw
        : META_SCREW=="M5_cs_cap_screw" ? M5_cs_cap_screw
        : META_SCREW=="M5_dome_screw"   ? M5_dome_screw
        : META_SCREW=="M5_hex_screw"    ? M5_hex_screw
        : META_SCREW=="M5_pan_screw"    ? M5_pan_screw
        : META_SCREW=="M6_cap_screw"    ? M6_cap_screw
        : META_SCREW=="M6_cs_cap_screw" ? M6_cs_cap_screw
        : META_SCREW=="M6_hex_screw"    ? M6_hex_screw
        : META_SCREW=="M6_pan_screw"    ? M6_pan_screw
        : META_SCREW=="M8_cap_screw"    ? M8_cap_screw
        : META_SCREW=="M8_hex_screw"    ? M8_hex_screw
        : META_SCREW=="No2_screw"       ? No2_screw
        : META_SCREW=="No4_screw"       ? No4_screw
        : META_SCREW=="No6_cs_screw"    ? No6_cs_screw
        : META_SCREW=="No6_screw"       ? No6_screw
        : META_SCREW=="No8_screw"       ? No8_screw
        : undef;
  assert(screw!=undef);

  // module meta_screw_test() {
  //   gap = 1.5 * 2 * screw_head_radius(screw);
  //   translate(-X(gap))
  //     screw(screw,META_LEN);
  //   fl_color(FILAMENT)
  //     translate(X(gap))
  //       fl_metaScrew(screw,META_LEN);
  // }

  module rail_test() {
    cs    = screw_head_depth(screw);
    hh    = screw_head_height(screw);
    fl_trace("countersink",cs);
    size  = let(base=2*(screw_head_radius(screw)+PLANE_T)+RAIL_LEN) [base,base,cs ? PLANE_T : PLANE_T+hh];
    if (ADD)
      difference() {
        fl_color(FILAMENT) translate(Z(hh)) fl_cube(size=size,octant=-Z);
        translate(+Z(NIL)) fl_color() fl_rail(RAIL_LEN) fl_screw(FL_FOOTPRINT,screw,META_LEN);
      }
    if (ASSEMBLY)
      translate(+Z(NIL)) screw(screw,META_LEN);
  }

  module plane_align_test() {
    size  = [4,4,0.1];
    module plane(axis) {
      color("red")   fl_vector(axis.x);
      color("green") fl_vector(axis.y);
      // color("blue")  fl_vector(cross(axis.x,axis.y));
    }

    module shapes() {
      fl_color(FILAMENT) translate(size/2)
        fl_cylinder(r1=1,r2=0,h=1);
    }

    src  = [fl_versor(PLANE_SRC_AXIS_1),fl_versor(PLANE_SRC_AXIS_2)];
    fl_trace("source plane",src);
    src_R = fl_planeAlign(a=[X,Y],b=[PLANE_SRC_AXIS_1,PLANE_SRC_AXIS_2]);
    translate(-X(2*size.x)) {
      plane(max(size)*src);
      multmatrix(src_R) {
        %fl_cube(size=size,octant=+X+Y-Z);
        shapes();
      }
    }

    dst  = [fl_versor(PLANE_DST_AXIS_1),fl_versor(PLANE_DST_AXIS_2)];
    fl_trace("destination plane",dst);
    dst_R = fl_planeAlign(a=[PLANE_SRC_AXIS_1,PLANE_SRC_AXIS_2],b=[PLANE_DST_AXIS_1,PLANE_DST_AXIS_2]);
    translate(+X(size.x)) {
      plane(max(size)*dst);
      multmatrix(dst_R * src_R) {
        %fl_cube(size=size,octant=+X+Y-Z);
        shapes();
      }
    }
  }

  module cutout_test() {
    sz_cyl    = [2,3,7];
    sz_plane  = [20,20,PLANE_T];
    distance  = sz_cyl.z*3/2;
    co_axes   = let(axis=axis(CO_AXIS)) [
      axis,
      axis==+Z ? +X : axis==-Z ? -X: axis==+X ? -Z: axis==-X ? +Z: +X
    ];
    co_len    = 1.5 * distance; // cutout length

    module shapes() {
      difference() {
        union() {
          fl_prism(n=5,l1=sz_cyl.x,l2=sz_cyl.y,h=sz_cyl.z,octant=O);
          fl_cylinder(r1=sz_cyl.x/2,r2=sz_cyl.y/2,h=sz_cyl.z);
        }
        fl_cylinder(r=0.5,h=sz_cyl.z*2.5,octant=O);
      }
    }

    module co() {
      fl_cutout(len=co_len,z=co_axes[0],x=co_axes[1],trim=CO_TRIM,cut=CO_CUT,delta=CO_DELTA)
        children();
    }

    module plane() {
      fl_color(FILAMENT) translate(distance*co_axes[0])
        fl_cube(size=sz_plane,octant=+Z,direction=[co_axes[0],0]);
    }

    shapes();

    difference() {
      plane();
      co() shapes();
    }
    // if ($FL_DEBUG)
      #co() shapes();
  }

  // if (UTIL=="meta screw")
  //   meta_screw_test();
  if (UTIL=="rail")
    rail_test();
  else if (UTIL=="plane align")
    plane_align_test();
  else if (UTIL=="cutout")
    cutout_test();
}

__test__();