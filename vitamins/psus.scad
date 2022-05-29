/*
 * PSU vitamin definitions.
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

include <../foundation/grid.scad>
include <../foundation/hole.scad>
include <../foundation/util.scad>
include <../foundation/unsafe_defs.scad>

include <screw.scad>
include <NopSCADlib/lib.scad>

// namespace for PCB engine
FL_PSU_NS  = "psu";

// ***** PSU MeanWell RS-25-5 25W 5V 5A ***************************************

FL_PSU_MeanWell_RS_25_5 = let(
    size  = [51,78,28],
    pcb_t = 1.6,
    // sheet metal thickness
    t     = 1,
    // TODO: terminal must become a stand-alone vitamin
    term_ways = 5,
    term_step = 7.62,
    term_esz  = [1.62,11,12],
    bbox      = [
      [-size.x/2, -term_esz.y,  0     ],  // negative corner
      [+size.x/2,  size.y,      size.z],  // positive corner
    ]
  ) [
    ["name",                "PSU MeanWell RS-25-5 25W 5V 5A"],
    fl_engine(value=FL_PSU_NS),
    fl_bb_corners(value=bbox),
    fl_screw(value=M3_cs_cap_screw),
    ["pcb thickness",       pcb_t],

    ["terminal screw",      M3_pan_screw  ],
    ["terminal ways",       term_ways     ],
    ["terminal step",       term_step     ],
    ["terminal edge size",  term_esz      ],

    ["grid diameter",       4.4],
    ["grid diagonal delta", 1.6],
    ["grid thickness",      t],
    ["grid surfaces",       [
      [-FL_X,[size.z, size.y, t]],
      [+FL_Z,[size.x, size.y, t]],
      [+FL_Y,[size.x, size.z, t]],
      [-FL_Y,[size.x, 9,      t]],
      [+FL_X,[size.z, size.y, t]],
      [-FL_Z,[size.x, size.y, t]],
    ]],
    fl_holes(value=[
      fl_Hole([25.5,8.75,14], 3,  +X, pcb_t),
      fl_Hole([25.5,75,14],   3,  +X, pcb_t),
      fl_Hole([0,12,0],       3,  -Z, pcb_t),
      fl_Hole([0,67,0],       3,  -Z, pcb_t),
      fl_Hole([-size.x/2+6.2,size.y,10],3,+Y,pcb_t),
    ]),
    fl_vendor(value=
      [
        ["Amazon",  "https://www.amazon.it/gp/product/B00MWQDAMU/"],
      ]
    ),
    fl_director(value=-FL_Y),fl_rotor(value=-FL_X),
  ];

FL_PSU_MeanWell_RS_15_5 = let(
    size      = [51,62.5,28],
    pcb_t     = 1.6,
    // sheet metal thickness
    t         = 1,
    // TODO: terminal must become a stand-alone vitamin
    term_ways = 5,
    term_step = 7.62,
    term_esz  = [1.62,11,12],
    bbox      = [
      [-size.x/2, -term_esz.y,  0     ],  // negative corner
      [+size.x/2,  size.y,      size.z],  // positive corner
    ]
  ) [
    ["name",                "PSU MeanWell RS-15-5 15W 5V 3A"],
    fl_engine(value=FL_PSU_NS),
    fl_bb_corners(value=bbox),
    fl_screw(value=M3_cs_cap_screw),
    ["pcb thickness",       pcb_t],

    ["terminal screw",      M3_pan_screw  ],
    ["terminal ways",       term_ways     ],
    ["terminal step",       term_step     ],
    ["terminal edge size",  term_esz      ],

    ["grid diameter",       4.4],
    ["grid diagonal delta", 1.6],
    ["grid thickness",      t],
    ["grid surfaces",       [
      [-FL_X,[size.z, size.y, t]],
      [+FL_Z,[size.x, size.y, t]],
      [+FL_Y,[size.x, size.z, t]],
      [-FL_Y,[size.x, 9,      t]],
      [+FL_X,[size.z, size.y, t]],
      [-FL_Z,[size.x, size.y, t]],
    ]],
    fl_holes(value=[
      fl_Hole([size.x/2,     11.9,   15.1  ],3,+X, pcb_t),
      fl_Hole([size.x/2,     size.x, 15.1  ],3,+X, pcb_t),
      fl_Hole([0,            8.75,   0     ],3,-Z, pcb_t),
      fl_Hole([0,            47.85,  0     ],3,-Z, pcb_t),
      fl_Hole([-size.x/2+6.2,  size.y, 10  ],3,+Y, pcb_t),
    ]),
    fl_vendor(value=
      [
        ["Amazon",  "https://www.amazon.it/gp/product/B00MWQD43U/"],
      ]
    ),
    fl_director(value=-FL_Y),fl_rotor(value=-FL_X),
  ];

FL_PSU_DICT = [
  FL_PSU_MeanWell_RS_25_5,
  FL_PSU_MeanWell_RS_15_5,
];

module fl_psu(
  // MANDATORY verb or list of verbs
  verbs,
  // MANDATORY
  type,
  // FL_DRILL thickness in fixed form [[-X,+X],[-Y,+Y],[-Z,+Z]] or scalar shortcut
  thick = 0,
  // FL_LAYOUT directions in floating semi-axis list form
  lay_direction=[+X,+Y,-Z],
  // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  // when undef native positioning is used
  octant
  ) {
  assert(verbs!=undef);
  assert(type!=undef);

  function terminal_size(type)     = let(
      term_ways   = fl_get(type,"terminal ways"),
      term_step   = fl_get(type,"terminal step"),
      term_esz    = fl_get(type,"terminal edge size")
    ) [
      term_step*term_ways+term_esz.x,
      term_esz.y,
      term_esz.z
    ];

  pcb_color   = "#FCD67E";
  pcb_t       = fl_get(type,"pcb thickness");
  holes       = fl_holes(type);

  screw       = fl_screw(type);
  screw_r     = screw_radius(screw);

  thick     = is_num(thick) ? [[thick,thick],[thick,thick],[thick,thick]]
            : assert(fl_tt_isAxisVList(thick)) thick;

  term_screw  = fl_get(type,"terminal screw");
  term_ways   = fl_get(type,"terminal ways");
  term_step   = fl_get(type,"terminal step");
  term_esz    = fl_get(type,"terminal edge size");
  term_size   = terminal_size(type);

  grid_d      = fl_get(type,"grid diameter");
  grid_t      = fl_get(type,"grid thickness");
  grid_faces  = fl_get(type,"grid surfaces");
  grid_shift  = grid_d + fl_get(type,"grid diagonal delta");

  bent_sheet  = fl_folding(faces=grid_faces);
  cbox        = fl_bb_corners(bent_sheet); // case box
  cbox_sz     = cbox[1]-cbox[0];
  bbox        = fl_bb_corners(type);
  bbox_sz     = bbox[1]-bbox[0];

  pcb_size    = [cbox_sz.x-2*grid_t,cbox_sz.y-grid_t,pcb_t];

  D           = direction ? fl_direction(type,direction=direction): I;
  M           = octant    ? fl_octant(octant=octant,bbox=bbox)    : I;

  fl_trace("grid shift",grid_shift);

  module terminal() {
    module flange() {
      r=0.5;
      s=[term_esz.z,term_esz.y,term_esz.x];
      // fl_color(grey20)
      translate(-fl_Y(s.y/2))
      translate(fl_Z(s.y))
      rotate(90,FL_Y)
      translate([r,r])
      minkowski() { // dimensione risultante = [12,11]
        cube([s.x-r*2,s.y-r*2,s.z/2]);
        cylinder(r=r,h=s.z/2);
      }
    }
    translate(-fl_X(term_size.x/2)) {
      for(i=[0:term_ways-1]) translate(i*fl_X(term_step)) {
      // for(i=[0:0]) translate(i*fl_X(term_step)) {
        // base
        fl_color(grey(20))
        let(size=[term_step+term_esz.x, term_esz.y, 8])
        translate([size.x/2,0, 5-size.z/2])
        cube(size=size, center=true);
        // gruppo vite
        translate([(term_step+term_esz.x)/2,0,5])
          fl_color("silver") {
            translate(fl_Z(0.75)) {
              translate(fl_Z(1))
                screw(term_screw,8);
              cube(size=[5.9, 5.9, 1.5], center=true);
            }
            translate(fl_Z(0.25))
            cube(size=[5, 8, 0.5], center=true);
          }
        // flangia laterale
        fl_color(grey(20)) flange();
      }
      // flangia laterale di chiusura
      fl_color(grey(20))
      translate(fl_X((term_ways)*term_step))
      flange();
    }
  }

  module do_add() {
    difference() {
      // case box as a bent sheet metal
      fl_bend(type=bent_sheet,octant=+Y+Z)
        linear_extrude(fl_bb_size($sheet).z)
          difference() {
            // 2d surface fitting the calculated $sheet size
            fl_bb_add(corners=fl_bb_corners($sheet),2d=true);
            // grid on face 4 (normal +Y) and part of face 1 (normal +Z)
            if (search($fid,[4,1]))
              fl_grid_layout(origin=[0,grid_d],r_step=grid_shift,bbox=[$C,$M] + [[grid_shift,-grid_shift],-[5,9]],clip=false)
                fl_circle(d=grid_d);
            // grid on face 0,1 (normal -X and +Z)
            if (search($fid,[0,1]))
              fl_grid_layout(origin=[2*grid_shift,1.5*grid_shift],r_step=grid_shift,bbox=[$A,$F] + [[1,5],-[5,3]],clip=false)
                fl_circle(d=grid_d);
          }
      // screw holes
      fl_holes(holes);
    }
    // pcb
    fl_color(pcb_color)
      translate([0,0,5.5-pcb_t/2])
        fl_cube(size=pcb_size, octant=+Y);
    // terminal
    translate([-((cbox_sz.x-2)-term_size.x)/2,-term_size.y/2+5.5,term_size.z/2+5.0])
      rotate(90,FL_X) terminal();
  }

  module do_bbox() {
    fl_bb_add(bbox);
  }

  module do_mount()  {
    do_layout() let(
        t   = fl_3d_axisValue($hole_n,thick),
        len = screw_longer_than(t+grid_t)
      ) translate((t+NIL)*$hole_n)
        fl_screw(type=screw,len=len,direction=[$hole_n,0]);
  }

  module do_drill()  {
    do_layout() let(
        t = fl_3d_axisValue($hole_n,thick)
      ) translate(-grid_t*$hole_n)
        fl_cylinder(d=$hole_d,h=t+grid_t+NIL,octant=+Z,direction=[$hole_n,0]);
  }

  module do_layout() {
    fl_lay_holes(holes,lay_direction)
      children();
  }

  fl_manage(verbs,M,D,cbox_sz) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_ASSEMBLY) {    // intentionally a no-op

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) do_bbox();

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier)  do_drill();

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout() {
        children();
      }

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier) do_mount();

    } else if ($verb==FL_CUTOUT) {  // intentionally a no-op

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
