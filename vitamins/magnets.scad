/*
 * Magnets definitions.
 *
 * Created  : on Mon Aug 30 2021.
 * Copyright: © 2021 Giampiero Gabbiani.
 * Email    : giampiero@gabbiani.org
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

include <countersinks.scad>
include <screw.scad>

include <NopSCADlib/core.scad>

// namespace for pin headers engine
// TODO: extend namespace definition to other modules
FL_MAG_NS  = "mag";

//*****************************************************************************
// magnet properties
// when invoked by «type» parameter act as getters
// when invoked by «value» parameter act as property constructors
function fl_mag_d(type,value)       = fl_property(type,"mag/diameter",value);
function fl_mag_csH(type,value)     = fl_property(type,"mag/counter sink height",value);
function fl_mag_cs(type,value)      = fl_property(type,"mag/counter sink type",value);
function fl_mag_engine(type,value)  = fl_property(type,"mag/__internal engine type__",value);

//*****************************************************************************
// constructor
function fl_Magnet(name,description,d,thick,size,cs,csh,screw,vendors) =
  assert(thick!=undef || size!=undef)
  let(
    engine  = d!=undef ? "cyl" : "quad",
    bbox    = engine=="cyl"
              ? assert(size==undef) assert(thick!=undef) fl_bb_cylinder(d=d,h=thick)
              : assert(size!=undef) [[-size.x/2,-size.y/2,0],[size.x/2,size.y/2,size.z]]
  ) [
    fl_name(value=name),
    fl_description(value=description),
    fl_mag_engine(value=engine),
    fl_director(value=+FL_Z), fl_rotor(value=+FL_X),
    if (engine=="cyl") fl_mag_d(value=d),
    fl_mag_cs(value=cs),
    if (cs!=undef) fl_mag_csH(value=csh),
    fl_material(value=grey(80)),
    fl_screw(value=screw),
    fl_bb_corners(value=bbox),
    fl_vendor(value=vendors),
  ];

FL_MAG_M3_CS_D10x2 = fl_Magnet(
  name        = "mag_M3_cs_d10x2",
  description = "M3 countersink magnet d10x2mm 1.2kg",
  d           = 10, thick = 2,
  cs          = FL_CS_M3, csh = 2,
  screw       = M3_cs_cap_screw,
  vendors     = [
      ["Amazon", "https://www.amazon.it/gp/product/B007UOXRY0/"],
    ]
);

FL_MAG_D10x5  = fl_Magnet(
  name        = "mag_d10x5",
  description = "magnet d10x5mm",
  d           = 10, thick = 5,
  vendors     = [
      ["Amazon", "https://www.amazon.it/gp/product/B017W7J0TA/"],
    ]
);

FL_MAG_M3_CS_D10x5 = fl_Magnet(
  name        = "mag_M3_cs_d10x5",
  description = "M3 countersink magnet d10x5mm 2.0kg",
  d           = 10, thick = 5,
  cs          = FL_CS_M3, csh = 3,
  screw       = M3_cs_cap_screw,
  vendors     = [
      ["Amazon", "https://www.amazon.it/gp/product/B001TOJESK/"],
    ]
);

FL_MAG_M4_CS_D32x6  = fl_Magnet(
  name        = "mag_M4_cs_d32x6",
  description = "M4 countersink magnet d32x6mm 29.0kg",
  d           = 32, // actual: 31.89 31.89 31.92 31.88 31.88 31.81 31.88 31.88  ⇒ average: 31.88mm ±0.04mm
  thick       = 6,
  cs          = FL_CS_M3, csh = 2,
  screw       = M3_cs_cap_screw,
  vendors     = [
      ["Amazon", "https://www.amazon.it/gp/product/B07RQL2ZSS/"],
    ]
);

FL_MAG_RECT_10x5x1  = fl_Magnet(
  name        = "mag_rect_10x5x1",
  description = "rectangular magnet 10x5x1mm",
  size        = [10,5,1],
  vendors     = [
      ["Amazon", "https://www.amazon.it/gp/product/B06XQNG59T/"],
    ]
);

FL_MAG_RECT_10x5x2  = fl_Magnet(
  name        = "mag_rect_10x5x2",
  description = "rectangular magnet 10x5x2mm",
  size        = [10,5,2],
  vendors     = [
      ["Amazon", "https://www.amazon.it/gp/product/B075PBJ31D/"],
    ]
);

FL_MAG_DICT = [
  FL_MAG_M3_CS_D10x2,
  FL_MAG_D10x5,
  FL_MAG_M3_CS_D10x5,
  FL_MAG_M4_CS_D32x6,
  FL_MAG_RECT_10x5x1,
  FL_MAG_RECT_10x5x2,
];

module fl_magnet(
  verbs       = FL_ADD, // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  type,                 // magnet object
  fp_gross    = 0,      // quantity to add to the footprint dimensions
  thick       = 0,      // thickness for screws
  direction,            // desired direction [director,rotation], native direction when undef
  octant                // when undef native positioning is used (+Z)
) {
  assert(verbs!=undef);
  assert(type!=undef);

  engine        = fl_mag_engine(type);
  cs            = fl_mag_cs(type);
  color         = fl_material(type);
  h             = fl_thick(type);
  screw         = fl_screw(type);
  screw_len     = screw!=undef  ? screw_longer_than(h)   : undef;
  screw_d       = screw!=undef  ? 2*screw_radius(screw)  : undef;
  h_cs          = cs!=undef     ? fl_mag_csH(type)       : undef;
  cs_offset     = h_cs!=undef   ? h-h_cs : undef;
  screw_offset  = screw!=undef  ? h-(h_cs-screw_socket_af(screw)) : undef;
  bbox          = fl_bb_corners(type);
  size          = bbox[1]-bbox[0];
  name          = fl_name(type);
  D             = direction!=undef ? fl_direction(proto=type,direction=direction) : I;
  M             = octant!=undef ? fl_octant(octant=octant,bbox=bbox) : I;
  Mscrew        = T(+Z(h));
  screw_thick   = h + thick;

  fl_trace("direction:",direction);
  fl_trace("D:",D);
  fl_trace("Bounding Box:",bbox);

  module do_add() {
    module cyl_engine() {
      d = fl_mag_d(type);

      module mag_M4_cs_d32x6() {
        // d=32;
        fl_trace("size",size);
        shell_r=size.z/2;
        cyl_h=size.z/2;
        shell_t=2;
        little=0.2;
        difference() {
          union() {
            translate([0,0,shell_r])
              rotate_extrude(convexity = 10)
                translate([d/2-shell_r, 0, 0])
                  circle(r = shell_r);
            translate(+Z(cyl_h)) fl_cylinder(h=cyl_h,d=d);
            fl_cylinder(h=cyl_h,d=d-2*shell_r);
          }
          translate(+Z(cyl_h+NIL)) fl_cylinder(h=cyl_h,d=d-2*shell_t);
        }
        translate(+Z(cyl_h)) fl_cylinder(h=cyl_h,d=d-2*shell_t-2*little);
      }

      fl_trace("FL_ADD",$FL_ADD);
      fl_trace("name",name);
      fl_color(color) difference() {
        if (name=="mag_M4_cs_d32x6")
          mag_M4_cs_d32x6();
        else
          fl_cylinder(d=d, h=h, octant=+Z);
        if (cs!=undef)
            translate(+Z(h+NIL)) fl_countersink(FL_ADD,type=cs);
        if (screw!=undef)
          do_layout() fl_screw(FL_DRILL,screw,thick=h+NIL);
      }
    }

    module quad_engine() {
      fl_color("silver") fl_cube(size=size,octant=+Z);
    }

    if (engine=="cyl") cyl_engine();
    else if (engine=="quad") quad_engine();
    else assert(false,str("Unknown engine '",engine,"'."));
  }

  module do_footprint() {
    translate(-Z(fp_gross))
      if (engine=="cyl") let(d = fl_mag_d(type)) fl_cylinder(d=d+2*fp_gross, h=h+2*fp_gross,octant=+Z);
      else if (engine=="quad") fl_cube(size=size+fp_gross*[2,2,2],octant=+Z);
  }

  module do_layout() {
    if (screw!=undef)
      multmatrix(Mscrew) children();
  }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) translate(-Z(NIL)) fl_cube(size=size+Z(2*NIL),octant=+Z);
    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier)
        do_layout() children();
    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) do_footprint();
    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier)
        do_layout() fl_screw(type=screw,thick=screw_thick);
    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier)
        do_layout() fl_screw(FL_DRILL,screw,thick=screw_thick);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
