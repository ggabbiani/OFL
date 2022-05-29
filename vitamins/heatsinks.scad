/*
 * Heatsinks definition file.
 *
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
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

use     <../dxf.scad>
include <pcbs.scad>

include <NopSCADlib/lib.scad>
include <NopSCADlib/vitamins/screws.scad>

// namespace
FL_HS_NS  = "hs";

FL_HS_PIMORONI = let(
  size  = [56,87,25.5]
) [
  fl_name(value="PIMORONI Heatsink Case"),
  fl_description(value="PIMORONI Aluminium Heatsink Case for Raspberry Pi 4"),
  fl_bb_corners(value=[
    [-size.x/2, 0,      0       ],  // negative corner
    [+size.x/2, size.y, size.z  ],  // positive corner
  ]),
  fl_screw(value=M2p5_cap_screw),
  fl_director(value=+FL_Z),fl_rotor(value=+FL_X),
  fl_dxf(value="vitamins/pimoroni.dxf"),
  ["corner radius",      3],
  ["bottom part", [
    ["layer 0 base thickness",    2   ],
    ["layer 0 fluting thickness", 2.3 ],
    ["layer 0 holders thickness", 3   ],
  ]],
  ["top part", [
    ["layer 1 base thickness",    1.5   ],
    ["layer 1 fluting thickness", 8.6   ],
    ["layer 1 holders thickness", 5.5   ],
  ]],
  fl_vendor(value=[
      ["Amazon", "https://www.amazon.it/gp/product/B082Y21GX5/"],
    ]
  ),
];

FL_HS_DICT  = [FL_HS_PIMORONI];

/**
 * calculates Pimoroni's bounding box
 */
function fl_bb_pimoroni(
  type,
  // top part
  top       = true,
  // bottom part
  bottom    = true,
) = let(
  bb    = fl_bb_corners(type),
  pcb_bb  = fl_bb_corners(FL_PCB_RPI4),
  pcb_t  = fl_pcb_thick(FL_PCB_RPI4),
  bot_p = fl_get(type,"bottom part"),
  bot_t = fl_get(bot_p,"layer 0 base thickness") + fl_get(bot_p,"layer 0 fluting thickness") + fl_get(bot_p,"layer 0 holders thickness"),
  top_p = fl_get(type,"top part"),
  top_t = fl_get(top_p,"layer 1 base thickness") + fl_get(top_p,"layer 1 fluting thickness") + fl_get(top_p,"layer 1 holders thickness")
) [
  [bb[0].x,bb[0].y,bottom ? bb[0].z : bot_t+pcb_bb[0].z+pcb_t],
  [bb[1].x,bb[1].y-(bottom ? 0 : 2),bb[1].z-0*(top    ? 0 : top_t)]
];

function fl_pimoroni(
  // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verb      = FL_ADD,
  type,
  // FL_DRILL thickness in scalar form for -Z normal
  thick=0,
  // either "mount" or "assembly"
  lay_what  = "mount",
  // top part
  top       = true,
  // bottom part
  bottom    = true,
  // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  // when undef native positioning is used
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
  dxf       = fl_get(type,"DXF model"),

  bot_base_t    = fl_get(bottom_p,"layer 0 base thickness"),
  bot_fluting_t = fl_get(bottom_p,"layer 0 fluting thickness"),
  bot_holder_t  = fl_get(bottom_p,"layer 0 holders thickness"),
  top_base_t    = fl_get(top_p,"layer 1 base thickness"),
  top_fluting_t = fl_get(top_p,"layer 1 fluting thickness"),
  top_holder_t  = fl_get(top_p,"layer 1 holders thickness"),

  D         = direction ? fl_direction(proto=type,direction=direction)  : I,
  M         = octant    ? fl_octant(octant=octant,bbox=bbox)            : I,

  bottom_sz = function() [size.x,size.y,bot_base_t+bot_fluting_t+bot_holder_t]

) verb==FL_LAYOUT ? T(+Z(bottom_sz().z+pcb_t))
: undef;

/**
 * FL_LAYOUT,FL_ASSEMBLY children context:
 *  $hs_radius  - corner radius
 *  $hs_normal  - layout normal (always -Z);
 *  $hs_screw   - mount screw;
 */
module fl_pimoroni(
  // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  type,
  // FL_DRILL thickness in scalar form for -Z normal
  thick=0,
  // either "mount" or "assembly"
  lay_what  = "mount",
  // top part
  top       = true,
  // bottom part
  bottom    = true,
  // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  // when undef native positioning is used
  octant
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(is_undef(lay_what)||lay_what=="mount"||lay_what=="assembly");

  bbox      = fl_bb_pimoroni(type,top=top,bottom=bottom);
  size      = fl_bb_size(type);
  corner_r  = fl_get(type,"corner radius");
  bottom_p  = fl_get(type,"bottom part");
  top_p     = fl_get(type,"top part");
  rpi4      = FL_PCB_RPI4;
  pcb_t     = fl_pcb_thick(rpi4);
  screw     = fl_screw(type);
  dxf       = fl_get(type,"DXF model");

  bot_base_t    = fl_get(bottom_p,"layer 0 base thickness");
  bot_fluting_t = fl_get(bottom_p,"layer 0 fluting thickness");
  bot_holder_t  = fl_get(bottom_p,"layer 0 holders thickness");
  top_base_t    = fl_get(top_p,"layer 1 base thickness");
  top_fluting_t = fl_get(top_p,"layer 1 fluting thickness");
  top_holder_t  = fl_get(top_p,"layer 1 holders thickness");

  D         = direction ? fl_direction(proto=type,direction=direction)  : I;
  M         = octant    ? fl_octant(octant=octant,bbox=bbox)            : I;

  function bottom_sz() = [size.x,size.y,bot_base_t+bot_fluting_t+bot_holder_t];

  module do_add() {

    module bottom() {
      difference() {
        union() {
          // metal block
          translate(bbox[0]+[corner_r,corner_r])
            minkowski() {
              fl_cube(size=[size.x-2*corner_r, size.y-2*corner_r, bot_base_t]);
              fl_cylinder(r1=0, r2=corner_r, h=bot_fluting_t);
            }
          // add holders
          translate(+Z(bot_base_t+bot_fluting_t))
            linear_extrude(bot_holder_t)
              __dxf__(file=dxf,layer="0 holders");
        }
        // subtracts holes
        translate(-Z(NIL))
          linear_extrude(bot_base_t+bot_fluting_t+NIL2)
            __dxf__(file=dxf,layer="0 holes");
        // subtracts fluting
        translate(-Z(NIL))
          linear_extrude(bot_fluting_t)
            __dxf__(file=dxf,layer="0 fluting");
      }
      // let(
      //   sz  = bottom_sz(),
      //   bb  = [[-sz.x/2,0,0],[+sz.x/2,sz.y,sz.z]]
      // ) #fl_bb_add(bb);
    }

    module top() {
      bottom_sz = bottom_sz();
      translate(+Z(bottom_sz.z+pcb_t)) {
        difference() {
          union() {
            // add holders
            linear_extrude(top_holder_t)
              __dxf__(file=dxf,layer="0 holders");
            translate(+Z(top_holder_t)) {
              // metal block
              intersection() {
                translate(bbox[0]+[corner_r,corner_r])
                  minkowski() {
                    fl_cube(size=[size.x-2*corner_r, size.y-2*corner_r, top_base_t+top_fluting_t-2.3]);
                    fl_cylinder(r2=0, r1=corner_r, h=2.3);
                  }
                linear_extrude(top_base_t+top_fluting_t)
                  __dxf__(file=dxf,layer="1");
              }
            }
          }
          // subtracts fluting
          translate(+Z(top_holder_t)) {
            resize(newsize=[0,70+NIL,0])
              translate(Z(top_base_t+NIL))
                linear_extrude(top_fluting_t)
                  __dxf__(file=dxf,layer="1 fluting");
          }
          // subtracts GPIO
          fl_pcb([FL_ADD,FL_CUTOUT],rpi4,cut_label="GPIO",thick=5,cut_tolerance=2);
        }
      }
      // let(
      //   sz  = [size.x,size.y,top_base_t+top_fluting_t+top_holder_t],
      //   bb  = [[-sz.x/2,0,bottom_sz.z+pcb_t],[+sz.x/2,sz.y,bottom_sz.z+pcb_t+sz.z]]
      // ) #fl_bb_add(bb);
    }

    if (bottom)
      bottom();
    if (top)
      top();
  }

  module do_assembly() {
    t = bot_base_t+bot_holder_t;
    translate(+Z(bottom_sz().z+pcb_t))
      fl_pcb(FL_DRAW,rpi4,thick=t,lay_direction=[]);
  }

  module context() {
    $hs_radius  = corner_r;
    $hs_normal  = -Z;
    $hs_screw   = screw;
    children();
  }

  module do_layout() {
    fl_trace("$FL_LAYOUT",$FL_LAYOUT);
    translate(+Z(bottom_sz().z+pcb_t))
      if (lay_what=="mount")
        fl_pcb(FL_LAYOUT,rpi4,thick=bot_base_t+bot_holder_t)
          translate(-Z(pcb_t+(bottom?bot_base_t+bot_holder_t:0)))
            context()
              children();
      else
        children();
  }

  module do_drill() {
    do_layout($FL_LAYOUT=$FL_DRILL)
      fl_cylinder(h=thick+bot_fluting_t,r=screw_radius(screw),octant=$hs_normal);
  }

  module do_mount() {
    do_layout() fl_color("DarkSlateGray")
      fl_screw(type=M2p5_cap_screw,len=10,direction=[$hs_normal,0]);
  }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout()
        children();

    } else if ($verb==FL_FOOTPRINT) {
      fl_trace("$FL_FOOTPRINT",$FL_FOOTPRINT);
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_assembly();

    } else if ($verb==FL_DRILL) {
      fl_trace("$FL_DRILL",$FL_DRILL);
      fl_modifier($modifier) do_drill();

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier) do_mount();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
