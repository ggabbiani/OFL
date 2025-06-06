/*!
 * Knurl nuts (aka 'inserts') definition module.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../ext/NopSCADlib/utils/core/core.scad>
use <../../ext/NopSCADlib/utils/annotation.scad>

include <../foundation/core.scad>
include <screw.scad>

use <../import.scad>
use <../foundation/3d-engine.scad>
use <../foundation/mngm-engine.scad>

//! namespace
FL_KNUT_NS  = "knut";

/*!
 * table with nominal size and the corresponding suggested drill hole diameter,
 * length and wall (taken from https://www.ruthex.de/cdn/shop/files/Tabelle_DE_600x.jpg)
 *
 * | Metric ISO Thread | Inch UNC thread | hole ⌀ | min. hole length | min. hole wall |
 * | ----------------- | --------------- | ------ | ---------------- | -------------- |
 * | M2                | #2-56           | 3.2    |  5.0             | 1.3            |
 * | M2,5              |                 | 4.0    |  6.7             | 1.6            |
 * | M3                | #4-40           | 4.0    |  6.7             | 1.6            |
 * | M4                | #8-32           | 5.6    |  9.1             | 2.1            |
 * | M5                | #10-24          | 6.4    | 10.5             | 2.6            |
 * | M6                | ¼"-20           | 8.0    | 13.7             | 3.3            |
 * | M8                |                 | 9.6    | 13.7             | 4.5            |
 *
 * TODO: replace this variable with a function
 */
FL_KNUT_NOMINAL_DRILL = [
  [2,   [3.2,  5.0, 1.3]],
  [2.5, [4.0,  6.7, 1.6]],
  [3,   [4.0,  6.7, 1.6]],
  [4,   [5.6,  9.1, 2.1]],
  [5,   [6.4, 10.5, 2.6]],
  [6,   [8.0, 13.7, 3.3]],
  [8,   [9.6, 13.7, 4.5]]
];

//**** Knurl nuts properties **************************************************

//! diameter for FL_DRILL
function fl_knut_drillD(type,value)  = fl_property(type,"knut/drill hole diameter",value);
//! tooth height
function fl_knut_tooth(type,value)  = fl_property(type,"knut/tooth height",value);
//! teeth number
function fl_knut_teeth(type,value)  = fl_property(type,"knut/teeth number",value);
//! external radius, the internal radius being: fl_knut_r()-fl_knut_tooth()
function fl_knut_r(type,value)      = fl_property(type,"knut/external radius",value);
//! rings array in the format '[[height1,position1],[height2,position2,..]]`
function fl_knut_rings(type,value)  = fl_property(type,"knut/rings array [[height1,position1],[height2,position2,..]]",value);
//! thread type used ("linear" or "spiral")
function fl_knut_thread(type,value) = fl_property(type,"knut/thread type",value);

/*!
 * Constructor for double spiral knurl nuts.
 *
 * The diameter used during FL_DRILL is taken from variable
 * FL_KNUT_NOMINAL_DRILL
 */
function fl_knut_Spiral(
  //! internal thread ⌀
  nominal,
  //! insert length
  length,
  //! external diameter
  diameter,
  //! stl geometry file from Ruthex
  stl_file
) = assert(nominal) let(
  name  = str("Spiral M",nominal,"x",length,"mm"),
  specs = fl_switch(nominal, FL_KNUT_NOMINAL_DRILL),
  bbox  = [
    [-diameter/2, -diameter/2,  -length-NIL], // negative corner
    [+diameter/2, +diameter/2,  0-NIL],       // positive corner
  ]
)
assert(is_num(length),str("length=",length))
assert(is_num(diameter),str("diameter=",diameter))
fl_Object(bbox,
  name    = name,
  engine  = fl_Engine("spiral",FL_KNUT_NS),
  nominal = nominal,
  others  = [
    fl_knut_r(value=diameter/2),
    fl_knut_drillD(value=assert(specs,str("Missing specs for '",name,"'")) specs[0]),
    fl_stl(value=stl_file),
    fl_knut_thread(value="spiral"),
    fl_vendor(value=[
        ["Amazon",  "https://www.amazon.it/dp/B08K1BVGN9"],
      ]
    )
  ]
);

//! Double spiral thread knurled nut M2x4mm
FL_KNUT_SPIRAL_M2x4p0     = fl_knut_Spiral(2,4.0,3.6,"vitamins/ruthex/m2x4p0.stl");
//! Double spiral thread knurled nut M2.5x5.7mm
FL_KNUT_SPIRAL_M2p5x5p7 = fl_knut_Spiral(2.5,5.7,4.6,"vitamins/ruthex/m2p5x5p7.stl");
//! Double spiral thread knurled nut M3x4mm
FL_KNUT_SPIRAL_M3x4p0   = fl_knut_Spiral(3,4.0,4.6,"vitamins/ruthex/m3x4p0.stl");
//! Double spiral thread knurled nut M3x5.7mm
FL_KNUT_SPIRAL_M3x5p7   = fl_knut_Spiral(3,5.7,4.6,"vitamins/ruthex/m3x5p7.stl");
//! Double spiral thread knurled nut M4x4mm
FL_KNUT_SPIRAL_M4x4p0   = fl_knut_Spiral(4,4.0,6.3,"vitamins/ruthex/m4x4p0.stl");
//! Double spiral thread knurled nut M4x8.1mm
FL_KNUT_SPIRAL_M4x8p1   = fl_knut_Spiral(4,8.1,6.3,"vitamins/ruthex/m4x8p1.stl");
//! Double spiral thread knurled nut M5x5.8mm
FL_KNUT_SPIRAL_M5x5p8   = fl_knut_Spiral(5,5.8,7.1,"vitamins/ruthex/m5x5p8.stl");
//! Double spiral thread knurled nut M5x9.5mm
FL_KNUT_SPIRAL_M5x9p5   = fl_knut_Spiral(5,9.5,7.1,"vitamins/ruthex/m5x9p5.stl");
//! Double spiral thread knurled nut M6x12.7mm
FL_KNUT_SPIRAL_M6x12p7  = fl_knut_Spiral(6,12.7,8.7,"vitamins/ruthex/m6x12p7.stl");
//! Double spiral thread knurled nut M8x12.7mm
FL_KNUT_SPIRAL_M8x12p7  = fl_knut_Spiral(8,12.7,10.1,"vitamins/ruthex/m8x12p7.stl");

function fl_knut_spiralDict() = [
  FL_KNUT_SPIRAL_M2x4p0,
  FL_KNUT_SPIRAL_M2p5x5p7,
  FL_KNUT_SPIRAL_M3x4p0,
  FL_KNUT_SPIRAL_M3x5p7,
  FL_KNUT_SPIRAL_M4x4p0,
  FL_KNUT_SPIRAL_M4x8p1,
  FL_KNUT_SPIRAL_M5x5p8,
  FL_KNUT_SPIRAL_M5x9p5,
  FL_KNUT_SPIRAL_M6x12p7,
  FL_KNUT_SPIRAL_M8x12p7
];

/*!
 * Constructor for Linear knurl nuts.
 *
 * The diameter used during FL_DRILL is equal to:
 *
 *     «external diameter» - 2 * «tooth» + 0.1mm
 */
function fl_knut_Linear(
  //! internal thread ⌀
  nominal,
  //! insert length
  length,
  //! external diameter
  diameter,
  //! tooth height
  tooth,
  //! ring specification as a list of ring lengths
  rings
) = assert(nominal) let(
  rlen  = len(rings),
  delta = length/(rlen-1),
  name  = str("Linear M",nominal,"x",length,"mm"),
  bbox  = [
    [-diameter/2, -diameter/2,  -length-NIL], // negative corner
    [+diameter/2, +diameter/2,  0-NIL],       // positive corner
  ]
)
assert(is_num(length),str("length=",length))
assert(is_num(diameter),str("diameter=",diameter))
assert(is_num(tooth),str("tooth=",tooth))
fl_Object(bbox,
  name    = name,
  engine  = fl_Engine("linear",FL_KNUT_NS),
  nominal = nominal,
  others = [
    fl_knut_drillD(value=diameter-2*tooth+0.2),
    fl_knut_r(value=diameter/2),
    fl_knut_tooth(value=tooth),
    fl_knut_teeth(value=30),
    fl_knut_rings(value=
      [for(i=[0:rlen-1]) [rings[i],(i<(rlen-1)/2 ? -rings[i]/2 : (i==(rlen-1)/2 ? 0 : rings[i]/2))-i*delta-rings[i]/2]]
    ),
    fl_knut_thread(value="linear"),
    fl_vendor(value=
      [
        ["Amazon",  "https://www.amazon.it/gp/product/B07QR6GVFJ"],
      ]
    ),
  ]);

//! Linear thread knurled nut M2x4mm
FL_KNUT_LINEAR_M2x4     = fl_knut_Linear(2,4,3.5,0.6, [1.15,  1.15      ]);
//! Linear thread knurled nut M2x6mm
FL_KNUT_LINEAR_M2x6     = fl_knut_Linear(2,6,3.5,0.6, [1.5,   1.5       ]);
//! Linear thread knurled nut M2x8mm
FL_KNUT_LINEAR_M2x8     = fl_knut_Linear(2,8,3.5,0.5, [1.3,   1.4,  1.3 ]);
//! Linear thread knurled nut M2x10mm
FL_KNUT_LINEAR_M2x10    = fl_knut_Linear(2,10,3.5,0.5,[1.9,   2.0,  1.9 ]);
//! Linear thread knurled nut M2.5x3.5mm
FL_KNUT_LINEAR_M2p5x4   = fl_knut_Linear(2.5,4,3.5,0.4,[1.15,  1.15 ]);
//! Linear thread knurled nut M2x6mm
FL_KNUT_LINEAR_M2p5x6   = fl_knut_Linear(2.5,6,3.5,0.4, [1.5,   1.5       ]);
//! Linear thread knurled nut M2x8mm
FL_KNUT_LINEAR_M2p5x8   = fl_knut_Linear(2.5,8,3.5,0.4, [1.3,   1.4,  1.3 ]);
//! Linear thread knurled nut M2x10mm
FL_KNUT_LINEAR_M2p5x10  = fl_knut_Linear(2.5,10,3.5,0.4,[1.9,   2.0,  1.9 ]);
//! Linear thread knurled nut M3x4mm
FL_KNUT_LINEAR_M3x4     = fl_knut_Linear(3,4,5,0.5,   [1.2,   1.2       ]);
//! Linear thread knurled nut M3x6mm
FL_KNUT_LINEAR_M3x6     = fl_knut_Linear(3,6,5,0.5,   [1.5,   1.5       ]);
//! Linear thread knurled nut M3x8mm
FL_KNUT_LINEAR_M3x8     = fl_knut_Linear(3,8,5,0.5,   [1.9,   1.9       ]);
//! Linear thread knurled nut M3x10mm
FL_KNUT_LINEAR_M3x10    = fl_knut_Linear(3,10,5,0.5,  [1.6,   1.5,   1.6]);
//! Linear thread knurled nut M4x4mm
FL_KNUT_LINEAR_M4x4     = fl_knut_Linear(4,4,6,0.5,   [1.3,   1.3       ]);
//! Linear thread knurled nut M4x6mm
FL_KNUT_LINEAR_M4x6     = fl_knut_Linear(4,6,6,0.5,   [1.7,   1.7       ]);
//! Linear thread knurled nut M4x8mm
FL_KNUT_LINEAR_M4x8     = fl_knut_Linear(4,8,6,0.5,   [2.3,   2.3       ]);
//! Linear thread knurled nut M4x10mm
FL_KNUT_LINEAR_M4x10    = fl_knut_Linear(4,10,6,0.5,  [1.9,   1.7,   1.9]);
//! Linear thread knurled nut M5x6mm
FL_KNUT_LINEAR_M5x6     = fl_knut_Linear(5,6,7.0,0.5, [1.9,   1.9       ]);
//! Linear thread knurled nut M5x8mm
FL_KNUT_LINEAR_M5x8     = fl_knut_Linear(5,8,7.0,0.5, [2.4,   2.4       ]);
//! Linear thread knurled nut M5x10mm
FL_KNUT_LINEAR_M5x10    = fl_knut_Linear(5,10,7.0,0.8,[1.7,   1.5,  1.7 ]);

function fl_knut_linearDict() = [
  FL_KNUT_LINEAR_M2x4,
  FL_KNUT_LINEAR_M2x6,
  FL_KNUT_LINEAR_M2x8,
  FL_KNUT_LINEAR_M2x10,
  FL_KNUT_LINEAR_M2p5x4,
  FL_KNUT_LINEAR_M2p5x6,
  FL_KNUT_LINEAR_M2p5x8,
  FL_KNUT_LINEAR_M2p5x10,
  FL_KNUT_LINEAR_M3x4,
  FL_KNUT_LINEAR_M3x6,
  FL_KNUT_LINEAR_M3x8,
  FL_KNUT_LINEAR_M3x10,
  FL_KNUT_LINEAR_M4x4,
  FL_KNUT_LINEAR_M4x6,
  FL_KNUT_LINEAR_M4x8,
  FL_KNUT_LINEAR_M4x10,
  FL_KNUT_LINEAR_M5x6,
  FL_KNUT_LINEAR_M5x8,
  FL_KNUT_LINEAR_M5x10
];

/*!
 * full knurl nuts dictionary
 */
function fl_knut_dict() = concat(fl_knut_spiralDict(),fl_knut_linearDict());

//! in a list of knurl nuts find out the __shortest__ one
FL_KNUT_SHORTEST  = function(nuts) fl_list_min(nuts,function(item) fl_thick(item));
//! in a list of knurl nuts find out the __longest__ one
FL_KNUT_LONGEST   = function(nuts) fl_list_max(nuts,function(item) fl_thick(item));
//! in a list of knurl nuts find out the __first__ one
FL_KNUT_FIRST     = function(nuts) assert(len(nuts)) nuts[0];

/*!
 * Returns a list of knurl nuts fitting requirements (empty list if none was
 * found) or a sigle best matching knurl nut when the `best` function literal
 * is provided.
 *
 * The default behavior is to return the **first** matching knurl nut.
 */
function fl_knut_selectBest(
  inventory = fl_knut_dict(),
  //! nominal ⌀ in mm
  nominal,
  //! selector by thread type ("linear" or "spiral")
  thread,
  //! length less than this value
  less_than,
  //! length greater than this value
  greater_than,
  //! length equal to this value
  equal_to,
  /*!
   * Function literal restricting the selection to a **unique** best matching knurl
   * nut or to «undef» in the selection result is empty.
   * By default the parameter is take-first operation, when implemented it must have
   * the following signature:
   *
   *     function(matches)
   */
  best = FL_KNUT_FIRST
) = fl_knut_select(
  inventory     = inventory,
  nominal       = nominal,
  thread        = thread,
  less_than     = less_than,
  greater_than  = greater_than,
  equal_to      = equal_to,
  best          = best
);

/*!
 * Returns a list of knurl nuts fitting requirements (empty list if none was
 * found) or a sigle best matching knurl nut when the `best` function literal
 * is provided.
 */
function fl_knut_select(
  inventory = fl_knut_dict(),
  //! nominal ⌀ in mm
  nominal,
  //! selector by thread type ("linear" or "spiral")
  thread,
  //! length less than this value
  less_than,
  //! length greater than this value
  greater_than,
  //! length equal to this value
  equal_to,
  /*!
   * Function literal restricting the selection to a **unique** best matching knurl
   * nut or to «undef» in the selection result is empty.
   * By default the parameter is a no-operation, when implemented it must have
   * the following signature:
   *
   *     function(matches)
   */
  best
) =
assert(is_undef(thread) || thread=="linear" || thread=="spiral",thread)
let(
  best = is_undef(best) ? function(matches) matches : best,
  // nominal «value» filter factory
  byNominal = function(value) let(
    nominal = is_num(value) ? value : assert(is_string(value),value) fl_atof(value)
  ) function (item) fl_nominal(item)==nominal,

  // length filter factory
  byLength  = function(
    less,
    greater,
    equal
  ) function (item) let(
      l = fl_thick(item)
    ) (
          (!less          || l<less)
      &&  (!greater       || l>greater)
      &&  (!equal         || l==equal)
    ),
  // thread type ("linear" or "spiral") filter factory
  byThread  = function(value) function(knut) fl_knut_thread(knut)==value,

  filters = [
    if (!is_undef(nominal))
      byNominal(nominal),
    if (!is_undef(thread))
      byThread(thread),
    if (!is_undef(less_than) || !is_undef(greater_than) || !is_undef(equal_to))
      byLength(less_than,greater_than,equal_to)
  ]
) best(fl_list_filter(inventory,filters));

//! filter the passed inventory with «knut» feasible screws
function fl_knut_screws(
  //! knurl nut to search for a screw
  knut,
  //! inventory of NopSCADlib screws
  nops
) = fl_list_filter(nops,fl_screw_byNominal(fl_nominal(knut)));

/*!
 * Search into dictionary for the best matching knut (default behavior) or all
 * the matching knurl nuts.
 *
 * This function is **DEPRECATED** and is going to be removed: use
 * function fl_knut_select() instead.
 */
function fl_knut_search(
  //! screw to fit into: ignored if undef
  screw,
  //! max knurl nut thickness (along Z axis): ignored if undef
  thick,
  //! nominal diameter: ignored if undef/zero
  d,
  //! thread type: ignored if undef
  thread,
  /*!
   * Lambda calculating the 'score' for determining the 'best' match.
   *
   * The default returns the longest knurl nut.
   */
  best=FL_KNUT_LONGEST
) = let(
  nominal = d ? d : screw ? assert(!fl_native(screw),screw) 2*screw_radius(screw) : undef,
  result  = [
    for(nut=fl_knut_dict())
      if ( (is_undef(thick)   || fl_thick(nut)<=thick)
        && (is_undef(nominal) || nominal==fl_nominal(nut))
        && (is_undef(thread)  || thread==fl_knut_thread(nut))
      ) nut
  ]
) best ? best(result) : result;

/*!
 * knurl nuts engine
 *
 * Children context for FL_ASSEMBLY and FL_DRILL:
 *
 *     $knut_director   - layout direction
 *     $knut_thick      - Z-axis thickness vector
 *     $knut_thickness  - overall thickness (insert length + ∑dri_thick),
 *     $knut_length     - insert length
 *     $knut_nominal    - nominal ⌀
 *     $knut_obj        - OFL insert object
 *     $knut_verb       - verb currently triggering children (FL_ASSEMBLY or
 *                        FL_LAYOUT)
 *
 * **NOTE:** FL_ASSEMBLY expects a child screw to be passed
 */
module fl_knut(
  /*!
   * supported verbs: `FL_ADD, FL_AXES, FL_ASSEMBLY, FL_BBOX, FL_DRILL,
   * FL_LAYOUT`
   *
   * - `FL_ASSEMBLY`: The implementation of the `FL_ASSEMBLY` verb involves
   *   using screws as child modules, which is typically done when executing the
   *   `FL_MOUNT` verb elsewhere in OFL. In this case, however, a different choice
   *   was made since in reality the inserts are fixed by casting the support
   *   frame and therefore the screws are considered as accessory components
   *   (which excludes, among other things, the implementation of the verb
   *   `FL_MOUNT`). During assembly, the positive part of the «dri_thick»
   *   parameter is used to translate the screws along Z+ semi-axis.
   *   The context variable $knut_thickness can be used for the screw length.
   */
  verbs=FL_ADD,
  type,
  /*!
   * List of Z-axis thickness for FL_DRILL operations or scalar value.
   *
   * A positive value is for drill along +Z semi-axis.
   * A negative value is for drill along -Z semi-axis.
   * A scalar value is applied to both Z semi-axes.
   *
   * Example 1:
   *
   *     dri_thick = [+3,-1]
   *
   * is interpreted as drill of 3mm along +Z and 1mm along -Z
   *
   * Example 2:
   *
   *     dri_thick = [-1]
   *
   * is interpreted as drill of 1mm along -Z
   *
   * Example 3:
   *
   *     dri_thick = 2
   *
   * is interpreted as a drill of 2mm along +Z and -Z axes
   *
   */
  dri_thick=0,
  //! desired direction [director,rotation], native direction when undef ([+Z])
  direction,
  //! when undef native positioning is used
  octant,
) {
  assert(type!=undef);
  assert(is_num(dri_thick)||is_list(dri_thick));

  dri_thick = fl_parm_SignedPair(dri_thick);
  r       = fl_knut_r(type);
  l       = fl_thick(type);
  thickness = abs(dri_thick[0])+dri_thick[1]+l;
  // screw   = fl_screw(type);
  // screw_r = screw_radius(screw);
  // screw_l = screw_shorter_than(l);
  nominal = fl_nominal(type);
  screw_r = nominal/2;
  stl     = fl_optProperty(type,fl_stl()[0]);
  tooth_h = stl ? undef : fl_knut_tooth(type);
  drill_d = fl_knut_drillD(type);

  rings   = stl ? undef : fl_knut_rings(type);
  teeth   = stl ? undef : fl_knut_teeth(type);

  bbox    = fl_bb_corners(type);
  size    = fl_bb_size(type);

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

  module context(director)
    let(
      $knut_director  = director,
      $knut_thickness = thickness,
      $knut_thick     = director==+Z ? dri_thick[1] : director==-Z ? -dri_thick[0] : undef,
      $knut_nominal   = nominal,
      $knut_obj       = type,
      $knut_verb      = $verb,
      $knut_length    = l
    ) children();

  module do_layout()    {
    // echo($FL_LAYOUT=$FL_LAYOUT);
    context(+Z)
        children();
    context(-Z)
      translate(-Z*size.z)
        children();
  }

  module do_drill() {
    fl_trace("drill ⌀",drill_d);
    // -Z semi-axis
    let(
      z = -dri_thick[0]
    ) if (z)
        translate(-Z(l))
          fl_cylinder(d=nominal,h=z,octant=-Z,$FL_ADD=$FL_DRILL);
    // +Z semi-axis
    let(
      z = dri_thick[1]
    ) if (z)
        fl_cylinder(d=nominal,h=z,octant=+Z,$FL_ADD=$FL_DRILL);
    // knurl nut carving
    translate(-Z(NIL))
      fl_cylinder(d=drill_d, h=l,octant=-Z,$FL_ADD=$FL_DRILL);
  }

  fl_vloop(verbs,bbox,octant,direction) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier)
        context(+Z)
          translate(+Z(dri_thick[1]))
            children();

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout() children();

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier) do_drill();

    } else {
      fl_error(["unimplemented verb",$this_verb]);
    }
  }
}
