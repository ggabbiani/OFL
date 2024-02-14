/*!
 * Heatsinks definition file.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <NopSCADlib/lib.scad>
include <NopSCADlib/vitamins/screws.scad>

include <../foundation/core.scad>

use <../foundation/3d-engine.scad>
use <../foundation/bbox-engine.scad>
use <../foundation/mngm-engine.scad>

//! namespace
FL_HS_NS  = "hs";

FL_HS_PIMORONI_TOP = let(
  Tbase = 1.5, Tfluting = 8.6, Tholders = 5.5,
  size  = [56,70,Tbase+Tfluting+Tholders]
) [
  fl_name(value="PIMORONI Raspberry Pi 4 Heatsink Case - top"),
  fl_bb_corners(value=[
    [-size.x/2, 0,      0       ],  // negative corner
    [+size.x/2, size.y, size.z  ],  // positive corner
  ]),
  fl_screw(value=M2p5_cap_screw),
  fl_dxf(value="vitamins/pimoroni.dxf"),
  fl_vendor(value=[
      ["Amazon", "https://www.amazon.it/gp/product/B082Y21GX5/"],
    ]
  ),
  fl_engine(value="Pimoroni"),
  fl_cutout(value=[+FL_Z]),

  // private/undocumented properties
  ["corner radius",     3         ],
  ["base thickness",    Tbase     ],
  ["fluting thickness", Tfluting  ],
  ["holders thickness", Tholders  ],
  ["part",              "top"     ],
];

FL_HS_PIMORONI_BOTTOM = let(
  Tbase = 2, Tfluting = 2.3, Tholders = 3,
  size  = [56,87,Tbase+Tfluting+Tholders]
) [
  fl_name(value="PIMORONI Raspberry Pi 4 Heatsink Case - bottom"),
  fl_bb_corners(value=[
    [-size.x/2, 0,      -size.z ],  // negative corner
    [+size.x/2, size.y, 0       ],  // positive corner
  ]),
  fl_screw(value=M2p5_cap_screw),
  fl_dxf(value="vitamins/pimoroni.dxf"),
  fl_vendor(value=[
      ["Amazon", "https://www.amazon.it/gp/product/B082Y21GX5/"],
    ]
  ),
  fl_engine(value="Pimoroni"),
  fl_cutout(value=[FL_Z]),

  // private/undocumented properties
  ["corner radius",     3         ],
  ["base thickness",    Tbase     ],
  ["fluting thickness", Tfluting  ],
  ["holders thickness", Tholders  ],
  ["part",              "bottom"  ],
];

FL_HS_KHADAS = let(
  Zs  =2, Zh =1, Zf=5.45,
  Zt  =2.2
) [
  fl_name(value="KHADAS VIM SBC Heatsink"),
  fl_bb_corners(value=[
    [0.5,   -49.57,   0         ],  // negative corner
    [81.49,  -0.49,   Zs+Zh+Zf  ],  // positive corner
  ]),
  fl_screw(value=M2_cap_screw),
  fl_dxf(value="vitamins/hs-khadas.dxf"),
  fl_engine(value="Khadas"),
  fl_cutout(value=[+FL_Z]),

  // private/undocumented properties
  fl_property(key="separator height", value=Zs),
  fl_property(key="heatsink height",  value=Zh),
  fl_property(key="fin height",       value=Zf),
  fl_property(key="tooth height",     value=Zt),
];

FL_HS_DICT  = [FL_HS_PIMORONI_TOP, FL_HS_PIMORONI_BOTTOM, FL_HS_KHADAS];

/*!
 * TODO: TO BE REMOVED
 */
function fl_pimoroni(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verb      = FL_ADD,
  type,
  //! FL_DRILL thickness in scalar form for -Z normal
  thick=0,
  //! either "mount" or "assembly"
  lay_what  = "mount",
  //! top part
  top       = true,
  //! bottom part
  bottom    = true,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant
) = let(
  bbox      = fl_bb_pimoroni(type,top=top,bottom=bottom),
  size      = fl_bb_size(type),
  corner_r  = fl_get(type,"corner radius"),
  bottom_p  = fl_get(type,"bottom part"),
  top_p     = fl_get(type,"top part"),
  rpi4      = FL_PCB_RPI4,
  pcb_t     = fl_pcb_thick(rpi4),
  screw     = fl_screw(type),
  dxf       = fl_dxf(type),

  bot_base_t    = fl_get(bottom_p,"layer 0 base thickness"),
  bot_fluting_t = fl_get(bottom_p,"layer 0 fluting thickness"),
  bot_holder_t  = fl_get(bottom_p,"layer 0 holders thickness"),
  top_base_t    = fl_get(top_p,"layer 1 base thickness"),
  top_fluting_t = fl_get(top_p,"layer 1 fluting thickness"),
  top_holder_t  = fl_get(top_p,"layer 1 holders thickness"),

  D         = direction ? fl_direction(direction) : FL_I,
  M         = fl_octant(octant,bbox=bbox),

  bottom_sz = function() [size.x,size.y,bot_base_t+bot_fluting_t+bot_holder_t]

) verb==FL_LAYOUT ? T(+Z(bottom_sz().z+pcb_t))
: undef;

/*!
 * common wrapper for different heat sink model engines.
 */
module fl_heatsink(
  //! supported verbs: FL_ADD, FL_AXES, FL_BBOX, FL_FOOTPRINT
  verbs       = FL_ADD,
  type,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant,
  // see constructor fl_parm_Debug()
  debug
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  bbox    = fl_bb_corners(type);
  size    = fl_bb_size(type);
  engine  = fl_engine(type);
  D       = direction ? fl_direction(direction)  : FL_I;
  M       = fl_octant(octant,bbox=bbox);

  module pimoroni(verb,type,direction,octant) {
    dxf       = fl_dxf(type);
    // private properties
    corner_r  = fl_get(type,"corner radius");
    base_t    = fl_property(type,"base thickness");
    fluting_t = fl_property(type,"fluting thickness");
    holder_t  = fl_property(type,"holders thickness");
    part      = fl_property(type,"part");

    D         = direction ? fl_direction(direction) : FL_I;
    M         = fl_octant(octant,bbox=bbox);

    module do_add(fprint) {

      module bottom(fprint) {
        translate(Z(bbox[0].z))
        difference() {
          union() {
            // metal block
            translate(bbox[0]+[corner_r,corner_r])
              minkowski() {
                fl_cube(size=[size.x-2*corner_r, size.y-2*corner_r, (fprint?holder_t:0)+base_t],octant=O0);
                fl_cylinder(r1=0, r2=corner_r, h=fluting_t);
              }
            if (!fprint) // add holders
              translate(+Z(base_t+fluting_t))
                linear_extrude(holder_t)
                  __dxf__(file=dxf,layer="0 holders");
          }
          if (!fprint) {
            // subtracts holes
            translate(-Z(NIL))
              linear_extrude(base_t+fluting_t+2xNIL)
                __dxf__(file=dxf,layer="0 holes");
            // subtracts fluting
            translate(-Z(NIL))
              linear_extrude(fluting_t)
                __dxf__(file=dxf,layer="0 fluting");
          }
        }
      }

      module top(fprint) {
        difference() {
          union() {
            if (!fprint) // add holders
              linear_extrude(holder_t)
                fl_importDxf(file=dxf,layer="0 holders");
            translate(+Z(fprint?0:holder_t)) {
              // metal block
              intersection() {
                translate(bbox[0]+[corner_r,corner_r])
                  minkowski() {
                    fl_cube(size=[size.x-2*corner_r, size.y-2*corner_r,(fprint?holder_t:0)+base_t+fluting_t-2.3],octant=O0);
                    fl_cylinder(r2=0, r1=corner_r, h=2.3);
                  }
                linear_extrude((fprint?holder_t:0)+base_t+fluting_t)
                  fl_importDxf(file=dxf,layer="1");
              }
            }
          }
          if (!fprint) {
            // subtracts fluting
            translate(+Z(holder_t)) {
              resize(newsize=[0,70+NIL,0])
                translate(Z(base_t+NIL))
                  linear_extrude(fluting_t)
                    __dxf__(file=dxf,layer="1 fluting");
            }
            // subtracts GPIO and VIDEO bus
            translate(+Z(holder_t-NIL)) {
              linear_extrude(base_t+fluting_t+2xNIL)
                offset(1)
                  fl_importDxf(dxf,"gpio");
              linear_extrude(base_t+3*NIL)
                offset(0.5)
                  fl_importDxf(dxf,"video");
              translate(+Z(base_t))
                linear_extrude(fluting_t+2xNIL)
                  offset(0.5)
                    fl_importDxf(dxf,"video2");
            }
          }
        }
      }

      if (part=="top")
        top(fprint);
      else
        bottom(fprint);
    }

    if (verb==FL_ADD) {
      fl_trace("$FL_ADD",$FL_ADD);
      do_add(false);

    } else if (verb==FL_FOOTPRINT) {
      fl_trace("$FL_FOOTPRINT",$FL_FOOTPRINT);
      do_add(true);

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }

  module khadas(verb,type,direction,octant,) {
    dxf   = fl_dxf(type);
    // private properties
    Zs  = fl_property(type,"separator height");
    Zh  = fl_property(type,"heatsink height");
    Zf  = fl_property(type,"fin height");
    Zt  = fl_property(type,"tooth height");

    D     = direction ? fl_direction(direction)  : FL_I;
    M     = fl_octant(octant,bbox=bbox);

    module do_add(fprint) {
      fl_color(fl_grey(30)) {
        if (!fprint)
          linear_extrude(Zs)
            fl_importDxf(file=dxf,layer="separators");
        translate(+Z(fprint?0:Zs)) {
          linear_extrude((fprint?Zs:0)+Zh)
            difference() {
              fl_importDxf(file=dxf,layer="heatsink");
              if (!fprint)
                fl_importDxf(file=dxf,layer="holes");
            }
          translate(+Z(Zh)) {
            if (!fprint) {
              linear_extrude(Zf)
                fl_importDxf(file=dxf,layer="fins");
              linear_extrude(Zt)
                fl_importDxf(file=dxf,layer="tooth");
            } else {
              translate([4.5,-7.17])
                fl_cube(size=[35,35,Zf+Zt],octant=+X-Y+Z);
            }
          }
        }
      }
    }

    if (verb==FL_ADD) {
      do_add(false);

    } else if (verb==FL_FOOTPRINT) {
      do_add(true);

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }

  module wrap(verb) {
    if (engine=="Khadas")
      khadas(verb, type, direction, octant)
        children();
    else if (engine=="Pimoroni")
      pimoroni(verb, type, direction, octant)
        children();
  }

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier)
        wrap($verb);

    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction,debug);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) wrap($verb);

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
