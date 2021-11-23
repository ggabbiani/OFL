/*
 * Magnets implementation.
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

include <../foundation/unsafe_defs.scad>
include <../foundation/defs.scad>

include <countersinks.scad>
include <magnets.scad>
use     <screw.scad>

use <../foundation/3d.scad>
use <../foundation/placement.scad>

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

      module M4_cs_magnet32x6() {
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
        if (name=="M4_cs_magnet32x6") 
          M4_cs_magnet32x6();
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

  multmatrix(D) {
    multmatrix(M) fl_parse(fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES)) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_add();
      } else if ($verb==FL_BBOX) {
        fl_trace("$FL_BBOX",$FL_BBOX);
        fl_modifier($FL_BBOX) translate(-Z(NIL)) fl_cube(size=size+Z(2*NIL),octant=+Z);
      } else if ($verb==FL_LAYOUT) {
        fl_modifier($FL_LAYOUT)
          do_layout() children();
      } else if ($verb==FL_FOOTPRINT) {
        fl_modifier($FL_FOOTPRINT) do_footprint();
      } else if ($verb==FL_ASSEMBLY) {
        fl_modifier($FL_ASSEMBLY) 
          do_layout() fl_screw(type=screw,thick=screw_thick);
      } else if ($verb==FL_DRILL) {
        fl_modifier($FL_DRILL) 
          do_layout() fl_screw(FL_DRILL,screw,thick=screw_thick);
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (fl_list_has(verbs,FL_AXES))
      fl_modifier($FL_AXES) fl_axes(size=size);
  }
}
