/*
 * Knurl nuts (aka 'inserts') definition module.
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

include <../foundation/3d.scad>
include <screw.scad>

include <NopSCADlib/lib.scad>;

//*****************************************************************************
// Knurl nuts properties
// when invoked by «type» parameter act as getters
// when invodec by «value» parameter act as property constructors
function fl_knut_thick(type,value)  = fl_property(type,"knut/Z axis length",value);
function fl_knut_tooth(type,value)  = fl_property(type,"knut/tooth height",value);
function fl_knut_teeth(type,value)  = fl_property(type,"knut/teeth number",value);
function fl_knut_r(type,value)      = fl_property(type,"knut/external radius",value);
function fl_knut_rings(type,value)  = fl_property(type,"knut/rings array [[height1,position1],[height2,position2,..]]",value);

//*****************************************************************************
// key values

/**
 * contructor
 */
function fl_Knut(screw,length,diameter,tooth,rings) = let(
  rlen  = len(rings),
  delta = length/(rlen-1),
  name  = str("knurl nut ",screw[9][0]," screw, ",length,"mm length, ",diameter,"mm ext. diameter")
)
assert(screw!=undef,"screw is undef")
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
    [for(i=[0:len(rings)-1]) [rings[i],(i<(rlen-1)/2?rings[i]/2:(i==(rlen-1)/2?0:-rings[i]/2))+i*delta-rings[i]/2]]
  ),
  fl_bb_corners(value=[
    [-diameter/2, -diameter/2,  0],       // negative corner
    [+diameter/2, +diameter/2,  length],  // positive corner
  ]),
  fl_director(value=FL_Z),
  fl_rotor(value=FL_X),
];

FL_KNUT_M2x4x3p5   = fl_Knut(M2_cap_screw,4,3.5,0.6, [1.15,  1.15      ]);
FL_KNUT_M2x6x3p5   = fl_Knut(M2_cap_screw,6,3.5,0.6, [1.5,   1.5       ]);
FL_KNUT_M2x8x3p5   = fl_Knut(M2_cap_screw,8,3.5,0.5, [1.3,   1.4,  1.3 ]);
FL_KNUT_M2x10x3p5  = fl_Knut(M2_cap_screw,10,3.5,0.5,[1.9,   2.0,  1.9 ]);

FL_KNUT_M3x4x5     = fl_Knut(M3_cap_screw,4,5,0.5,   [1.2,   1.2       ]);
FL_KNUT_M3x6x5     = fl_Knut(M3_cap_screw,6,5,0.5,   [1.5,   1.5       ]);
FL_KNUT_M3x8x5     = fl_Knut(M3_cap_screw,8,5,0.5,   [1.9,   1.9       ]);
FL_KNUT_M3x10x5    = fl_Knut(M3_cap_screw,10,5,0.5,  [1.6,   1.5,   1.6]);

FL_KNUT_M4x4x6     = fl_Knut(M4_cap_screw,4,6,0.5,   [1.3,   1.3       ]);
FL_KNUT_M4x6x6     = fl_Knut(M4_cap_screw,6,6,0.5,   [1.7,   1.7       ]);
FL_KNUT_M4x8x6     = fl_Knut(M4_cap_screw,8,6,0.5,   [2.3,   2.3       ]);
FL_KNUT_M4x10x6    = fl_Knut(M4_cap_screw,10,6,0.5,  [1.9,   1.7,   1.9]);

FL_KNUT_M5x6x7     = fl_Knut(M5_cap_screw,6,7.0,0.5, [1.9,   1.9       ]);
FL_KNUT_M5x8x7     = fl_Knut(M5_cap_screw,8,7.0,0.5, [2.4,   2.4       ]);
FL_KNUT_M5x10x7    = fl_Knut(M5_cap_screw,10,7.0,0.8,[1.7,   1.5,  1.7 ]);

FL_KNUT_DICT = [
  [FL_KNUT_M2x4x3p5, FL_KNUT_M2x6x3p5,  FL_KNUT_M2x8x3p5,  FL_KNUT_M2x10x3p5],
  [FL_KNUT_M3x4x5,   FL_KNUT_M3x6x5,    FL_KNUT_M3x8x5,    FL_KNUT_M3x10x5  ],
  [FL_KNUT_M4x4x6,   FL_KNUT_M4x6x6,    FL_KNUT_M4x8x6,    FL_KNUT_M4x10x6  ],
  [FL_KNUT_M5x6x7,   FL_KNUT_M5x8x7,    FL_KNUT_M5x10x7                     ],
];

FL_KNUT_DICT_1 = [
  FL_KNUT_M2x4x3p5, FL_KNUT_M2x6x3p5,  FL_KNUT_M2x8x3p5,  FL_KNUT_M2x10x3p5,
  FL_KNUT_M3x4x5,   FL_KNUT_M3x6x5,    FL_KNUT_M3x8x5,    FL_KNUT_M3x10x5  ,
  FL_KNUT_M4x4x6,   FL_KNUT_M4x6x6,    FL_KNUT_M4x8x6,    FL_KNUT_M4x10x6  ,
  FL_KNUT_M5x6x7,   FL_KNUT_M5x8x7,    FL_KNUT_M5x10x7                     ,
];

// return a knurl nut fitting the passed «screw» and «t»
// returns undef when not knurl nut is found
function fl_knut_search(
    // screw to fit into
    screw,
    // Z axis knurl nut thickness
    t
  ) = 
  assert(screw)
  assert(t)
  let(
    r         = screw_radius(screw),
    row       = let(i=search(r*2,[2,3,4,5])[0]) i!=undef ? FL_KNUT_DICT[i] : undef,
    max_thick = function(list,current=[-1,undef]) 
      assert(list!=[]) 
      let(
        len   = len(list),
        first = list[0],
        max   = first[0]>current[0] ? first : current
      ) len==1 ? max : max_thick([for(i=[1:len-1]) list[i]],max),
    list = row ? [
      for(i=[0:len(row)-1]) 
        let(thick = fl_knut_thick(row[i])) if (thick<=t) [thick,i]
      ] : undef
  ) row && list ? row[max_thick(list)[1]] : undef;

module fl_knut(
  verbs=FL_ADD,
  type,
  direction,            // desired direction [director,rotation], native direction when undef ([+Z])
  octant,               // when undef native positioning is used
) {
  assert(verbs!=undef);

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

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) do_bbox();
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
