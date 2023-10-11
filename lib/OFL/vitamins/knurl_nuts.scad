/*!
 * Knurl nuts (aka 'inserts') definition module.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <NopSCADlib/utils/core/core.scad>
use <NopSCADlib/utils/annotation.scad>

include <../foundation/core.scad>
include <screw.scad>

use <../import.scad>
use <../foundation/3d-engine.scad>
use <../foundation/mngm-engine.scad>

//! namespace
FL_KNUT_NS  = "knut";

/*!
 * table with nominal size and suggested corresponding drill diameter taken from https://www.ruthex.de/cdn/shop/files/Tabelle_DE_600x.jpg
 *
 * | Metric ISO Thread | Inch UNC thread | hole ⌀ | min. hole length | min. hole wall |
 * | ----------------- | --------------- | ------ | ---------------- | -------------- |
 * | M2                | #2-56           | 3.6    |  5.0             | 1.3            |
 * | M2,5              |                 | 4.0    |  6.7             | 1.6            |
 * | M3                | #4-40           | 4.0    |  6.7             | 1.6            |
 * | M4                | #8-32           | 5.6    |  9.1             | 2.1            |
 * | M5                | #10-24          | 6.4    | 10.5             | 2.6            |
 * | M6                | ¼"-20           | 8.0    | 13.7             | 3.3            |
 * | M8                |                 | 9.6    | 13.7             | 4.5            |
 *
 */
FL_KNUT_NOMINAL_DRILL = [
  [2,   [3.6,  5.0, 1.3]],
  [2.5, [4.0,  6.7, 1.6]],
  [3,   [4.0,  6.7, 1.6]],
  [4,   [5.6,  9.1, 2.1]],
  [5,   [6.4, 10.5, 2.6]],
  [6,   [8.0, 13.7, 3.3]],
  [8,   [9.6, 13.7, 4.5]]
];

//*****************************************************************************
// Knurl nuts properties

//! Z axis length
function fl_knut_thick(type,value)  = fl_property(type,"knut/Z axis length",value);
//! suggested drill diameter for FL_DRILL
function fl_knut_drillD(type,value)  = fl_property(type,"knut/drill hole diameter",value);
//! tooth height
function fl_knut_tooth(type,value)  = fl_property(type,"knut/tooth height",value);
//! teeth number
function fl_knut_teeth(type,value)  = fl_property(type,"knut/teeth number",value);
//! external radius, the internal radius being: fl_knut_r()-fl_knut_tooth()
function fl_knut_r(type,value)      = fl_property(type,"knut/external radius",value);
//! rings array in the format '[[height1,position1],[height2,position2,..]]`
function fl_knut_rings(type,value)  = fl_property(type,"knut/rings array [[height1,position1],[height2,position2,..]]",value);

//*****************************************************************************
// Knurl nuts getters

//! nominal diameter of the mounting screw
function fl_knut_nominal(knut) = fl_screw_nominal(fl_screw(knut));

/*!
 * Constructor for double spiral knurl nuts.
 *
 * The diameter used during FL_DRILL is taken from variable
 * FL_KNUT_NOMINAL_DRILL
 */
function fl_knut_Spiral(
  //! internal thread
  screw,
  //! insert length
  length,
  //! external diameter
  diameter,
  //! stl geometry file from Ruthex
  stl_file
) = let(
  name  = assert(screw) str("Double spiral knurl nut ",screw[9][0],"x",length,"mm-⌀",diameter,"mm"),
  specs = fl_switch(fl_screw_nominal(screw), FL_KNUT_NOMINAL_DRILL)
)
assert(is_num(length),str("length=",length))
assert(is_num(diameter),str("diameter=",diameter))
[
  fl_name(value=name),
  fl_screw(value=screw),
  fl_knut_thick(value=length),
  fl_knut_r(value=diameter/2),
  fl_knut_drillD(value=assert(specs,str("Missing specs for '",name,"'")) specs[0]),
  fl_stl(value=stl_file),
  fl_tag(value="double spiral thread"),
  fl_vendor(value=
    [
      ["Amazon",  "https://www.amazon.it/dp/B08K1BVGN9"],
    ]
  ),
  fl_bb_corners(value=[
    [-diameter/2, -diameter/2,  -length], // negative corner
    [+diameter/2, +diameter/2,  0],       // positive corner
  ]),
];

//! Double spiral thread knurled nut M2x4mm
FL_KNUT_SPIRAL_M2x4     = fl_knut_Spiral(M2_cap_screw,4,3.6,"vitamins/ruthex/rx-m2x4.stl");
//! Double spiral thread knurled nut M2.5x5.7mm
FL_KNUT_SPIRAL_M2p5x5p7 = fl_knut_Spiral(M2p5_cap_screw,5.7,4.6,"vitamins/ruthex/rx-m2p5x5p7.stl");
//! Double spiral thread knurled nut M3x5.7mm
FL_KNUT_SPIRAL_M3x5p7   = fl_knut_Spiral(M3_cap_screw,5.7,4.6,"vitamins/ruthex/rx-m3x5p7.stl");
//! Double spiral thread knurled nut M4x8.1mm
FL_KNUT_SPIRAL_M4x8p1   = fl_knut_Spiral(M4_cap_screw,8.1,6.3,"vitamins/ruthex/rx-m4x8p1.stl");
//! Double spiral thread knurled nut M5x9.5mm
FL_KNUT_SPIRAL_M5x9p5   = fl_knut_Spiral(M5_cap_screw,9.5,8.5,"vitamins/ruthex/rx-m5x9p5.stl");
//! Double spiral thread knurled nut M6x12.7mm
FL_KNUT_SPIRAL_M6x12p7  = fl_knut_Spiral(M6_cap_screw,12.7,8.7,"vitamins/ruthex/rx-m6x12p7.stl");
//! Double spiral thread knurled nut M8x12.7mm
FL_KNUT_SPIRAL_M8x12p7  = fl_knut_Spiral(M8_cap_screw,12.7,10.1,"vitamins/ruthex/rx-m8x12p7.stl");

/*!
 * Constructor for Linear knurl nuts.
 *
 * The diameter used during FL_DRILL is equal to:
 *
 *     «external diameter» - 2 * «tooth» + 0.1mm
 */
function fl_knut_Linear(
  //! internal thread
  screw,
  //! insert length
  length,
  //! external diameter
  diameter,
  //! tooth height
  tooth,
  //! ring specification as a list of ring lengths
  rings
) = let(
  rlen  = len(rings),
  delta = length/(rlen-1),
  name  = assert(screw) str("Linear knurl nut ",screw[9][0],"x",length,"mm-⌀",diameter,"mm")
)
assert(screw!=undef,"screw cannot be undef")
assert(is_num(length),str("length=",length))
assert(is_num(diameter),str("diameter=",diameter))
assert(is_num(tooth),str("tooth=",tooth))
[
  fl_name(value=name),
  fl_screw(value=screw),
  fl_knut_thick(value=length),
  fl_knut_r(value=diameter/2),
  fl_knut_tooth(value=tooth),
  fl_knut_teeth(value=100),
  fl_knut_rings(value=
    [for(i=[0:rlen-1]) [rings[i],(i<(rlen-1)/2 ? -rings[i]/2 : (i==(rlen-1)/2 ? 0 : rings[i]/2))-i*delta-rings[i]/2]]
  ),
  fl_bb_corners(value=[
    [-diameter/2, -diameter/2,  -length], // negative corner
    [+diameter/2, +diameter/2,  0],       // positive corner
  ]),
  fl_tag(value="linear thread"),
  fl_vendor(value=
    [
      ["Amazon",  "https://www.amazon.it/gp/product/B07QR6GVFJ"],
    ]
  ),
];

//! Linear thread knurled nut M2x4mm
FL_KNUT_LINEAR_M2x4  = fl_knut_Linear(M2_cap_screw,4,3.5,0.6, [1.15,  1.15      ]);
//! Linear thread knurled nut M2x6mm
FL_KNUT_LINEAR_M2x6  = fl_knut_Linear(M2_cap_screw,6,3.5,0.6, [1.5,   1.5       ]);
//! Linear thread knurled nut M2x8mm
FL_KNUT_LINEAR_M2x8  = fl_knut_Linear(M2_cap_screw,8,3.5,0.5, [1.3,   1.4,  1.3 ]);
//! Linear thread knurled nut M2x10mm
FL_KNUT_LINEAR_M2x10 = fl_knut_Linear(M2_cap_screw,10,3.5,0.5,[1.9,   2.0,  1.9 ]);
//! Linear thread knurled nut M3x4mm
FL_KNUT_LINEAR_M3x4  = fl_knut_Linear(M3_cap_screw,4,5,0.5,   [1.2,   1.2       ]);
//! Linear thread knurled nut M3x6mm
FL_KNUT_LINEAR_M3x6  = fl_knut_Linear(M3_cap_screw,6,5,0.5,   [1.5,   1.5       ]);
//! Linear thread knurled nut M3x8mm
FL_KNUT_LINEAR_M3x8  = fl_knut_Linear(M3_cap_screw,8,5,0.5,   [1.9,   1.9       ]);
//! Linear thread knurled nut M3x10mm
FL_KNUT_LINEAR_M3x10 = fl_knut_Linear(M3_cap_screw,10,5,0.5,  [1.6,   1.5,   1.6]);
//! Linear thread knurled nut M4x4mm
FL_KNUT_LINEAR_M4x4  = fl_knut_Linear(M4_cap_screw,4,6,0.5,   [1.3,   1.3       ]);
//! Linear thread knurled nut M4x6mm
FL_KNUT_LINEAR_M4x6  = fl_knut_Linear(M4_cap_screw,6,6,0.5,   [1.7,   1.7       ]);
//! Linear thread knurled nut M4x8mm
FL_KNUT_LINEAR_M4x8  = fl_knut_Linear(M4_cap_screw,8,6,0.5,   [2.3,   2.3       ]);
//! Linear thread knurled nut M4x10mm
FL_KNUT_LINEAR_M4x10 = fl_knut_Linear(M4_cap_screw,10,6,0.5,  [1.9,   1.7,   1.9]);
//! Linear thread knurled nut M5x6mm
FL_KNUT_LINEAR_M5x6  = fl_knut_Linear(M5_cap_screw,6,7.0,0.5, [1.9,   1.9       ]);
//! Linear thread knurled nut M5x8mm
FL_KNUT_LINEAR_M5x8  = fl_knut_Linear(M5_cap_screw,8,7.0,0.5, [2.4,   2.4       ]);
//! Linear thread knurled nut M5x10mm
FL_KNUT_LINEAR_M5x10 = fl_knut_Linear(M5_cap_screw,10,7.0,0.8,[1.7,   1.5,  1.7 ]);

/*!
 * Dictionary sorted by increasing internal thread
 */
FL_KNUT_DICT = [
  FL_KNUT_LINEAR_M2x4,    FL_KNUT_LINEAR_M2x6,      FL_KNUT_LINEAR_M2x8,    FL_KNUT_LINEAR_M2x10,
  FL_KNUT_LINEAR_M3x4,    FL_KNUT_LINEAR_M3x6,      FL_KNUT_LINEAR_M3x8,    FL_KNUT_LINEAR_M3x10,
  FL_KNUT_LINEAR_M4x4,    FL_KNUT_LINEAR_M4x6,      FL_KNUT_LINEAR_M4x8,    FL_KNUT_LINEAR_M4x10,
  FL_KNUT_LINEAR_M5x6,    FL_KNUT_LINEAR_M5x8,      FL_KNUT_LINEAR_M5x10,
  FL_KNUT_SPIRAL_M2x4,    FL_KNUT_SPIRAL_M2p5x5p7,  FL_KNUT_SPIRAL_M3x5p7,  FL_KNUT_SPIRAL_M4x8p1,
  FL_KNUT_SPIRAL_M5x9p5,  FL_KNUT_SPIRAL_M6x12p7,   FL_KNUT_SPIRAL_M8x12p7
];

//! in a list of knurl nuts find out the shortest one
FL_KNUT_SHORTEST  = function(nuts) fl_min(nuts,function(item) fl_knut_thick(item));
//! in a list of knurl nuts find out the longest one
FL_KNUT_LONGEST   = function(nuts) fl_max(nuts,function(item) fl_knut_thick(item));

/*!
 * Search into dictionary for the best matching knut (default behavior) or all
 * the matching knuts.
 */
function fl_knut_search(
  //! screw to fit into
  screw,
  //! max knurl nut thickness (Z axis size)
  thick,
  //! nominal diameter
  d,
  //! product tag
  tag,
  best=FL_KNUT_LONGEST
) = let(
  nominal = d ? d : screw ? fl_screw_nominal(screw) : undef,
  result  = [
    for(nut=FL_KNUT_DICT)
      if ( (is_undef(thick)   || fl_knut_thick(nut)<=thick)
        && (is_undef(nominal) || nominal==fl_knut_nominal(nut))
        && (is_undef(tag)     || tag==fl_optProperty(nut,fl_tag()[0]))
      ) nut
  ]
) best ? best(result) : result;

module fl_knut(
  //! supported verbs: `FL_ADD, FL_AXES, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_LAYOUT`
  verbs=FL_ADD,
  type,
  /*!
   * Overall thickness during FL_DRILL operations.
   * Should be at least equal to the knurl nut thickness.
   */
  dri_thick,
  //! desired direction [director,rotation], native direction when undef ([+Z])
  direction,
  //! when undef native positioning is used
  octant,
) {
  assert(type!=undef);

  r       = fl_knut_r(type);
  l       = fl_knut_thick(type);
  dri_thick = dri_thick ? dri_thick : l;
  screw   = fl_screw(type);
  screw_r = screw_radius(screw);
  screw_l = screw_shorter_than(l);
  nominal = fl_knut_nominal(type);
  stl     = fl_optProperty(type,fl_stl()[0]);
  tooth_h = stl ? undef : fl_knut_tooth(type);
  drill_d = tooth_h ? 2*r-2*tooth_h+0.1 : fl_switch(nominal, FL_KNUT_NOMINAL_DRILL)[0];

  rings   = stl ? undef : fl_knut_rings(type);
  teeth   = stl ? undef : fl_knut_teeth(type);

  bbox    = fl_bb_corners(type);
  size    = fl_bb_size(type);
  D       = direction ? fl_direction(direction)  : I;
  M       = fl_octant(octant,bbox=bbox);

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
    fl_color("gold") {
      if (stl)
        __import__(stl);
      else {
        for(ring=rings)
          translate([0, 0, ring[1]])
            toothed_nut(r=screw_r,R=r,thick=ring[0],n=teeth);
        fl_tube(r=r-tooth_h, h=l, thick=r-tooth_h-screw_r, octant=-Z);
      }
    }
  }

  module do_layout()    {
    translate(Z(bbox[1].z)) children();
  }
  module do_drill() {
    // echo(d1=2*r,d2=2*(r-tooth_h),d3=2*(r-tooth_h)+0.1)
    fl_trace("drill ⌀",drill_d);
    do_layout() {
      fl_cylinder(d=drill_d, h=l,octant=-Z,$FL_ADD=$FL_DRILL);
      if (dri_thick>l)
        translate(-Z(l))
          fl_cylinder(d=nominal, h=dri_thick-l,octant=-Z,$FL_ADD=$FL_DRILL);
    }
  }

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();
    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction);
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);
    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_layout() fl_screw(type=screw,len=screw_l);
    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout() children();
    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier) do_drill();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
