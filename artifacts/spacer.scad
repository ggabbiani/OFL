/*
 * Spacers with optional screw and knurl nuts.
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
include <../foundation/tube.scad>
include <../foundation/hole.scad>

include <../vitamins/knurl_nuts.scad>

// namespace
FL_SPC_NS  = "spc";

FL_SPC_DICT = [
];

// constructor
function fl_Spacer(
    // thickness along Z axis
    h,
    // external radius
    r,
    // external diameter (mutually exclusive with «r»)
    d,
    screw,
    knut=false    
  ) = 
  // assert(!knut || screw)
  let(
    r     = assert((r && !d) || (!r && d)) r ? r : d/2,
    name  = str("Cylindric spacer"),
    bbox  = fl_bb_cylinder(h,r),
    knut  = knut && screw ? fl_knut_search(screw,h) : undef
  ) [
    fl_name(value=name),
    fl_bb_corners(value=bbox),
    fl_director(value=+Z),fl_rotor(value=+X),
    if (screw)  ["screw", screw],
    if (knut)   ["knurl nut", knut],
  ];

module fl_spacer(
  verbs       = FL_ADD, // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  type,
  material,
  // thickness in fixed form [[-X,+X],[-Y,+Y],[-Z,+Z]] or scalar shortcut
  thick=0,
  // FL_LAYOUT directions in floating semi-axis list
  lay_direction=[+Z,-Z],
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant,               // when undef native positioning is used
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  bbox    = fl_bb_corners(type);
  size    = bbox[1]-bbox[0];
  r       = assert(size.x==size.y) size.x/2;
  h       = size.z;
  knut    = fl_optional(type,"knurl nut");
  screw   = fl_optional(type,"screw");
  hole_r  = knut ? fl_knut_r(knut)-0.3 : screw ? screw_radius(screw) : undef;
  // thickness along ±Z only
  thick     = is_num(thick) ? [thick,thick] : assert(fl_tt_isAxisVList(thick)) thick.z; 

  D     = direction ? fl_direction(proto=type,direction=direction)  : I;
  M     = octant    ? fl_octant(octant=octant,bbox=bbox)            : I;

  module do_add() {
    fl_color(material)
      if (hole_r) 
        fl_tube(h=h,r=r,thick=r-hole_r); 
      else 
        fl_cylinder(h=h,r=r);
  }

  module do_mount() {
    t = thick[1];
    translate(+Z(h+t))
      fl_screw([FL_ADD,FL_ASSEMBLY],screw,thick=h+t,washer="nylon");
  }

  module do_assembly() {
    if (knut)
      translate(+Z(NIL)) fl_knut(type=knut);
  }

  module do_layout() {
    if (screw) {
      if (fl_3d_axisIsSet(+Z,lay_direction))
        context(+Z) translate($director*h) children();
      if (fl_3d_axisIsSet(-Z,lay_direction))
        context(-Z) children();
    }
  }
 
  module do_footprint() {
    fl_cylinder(h=h,r=r);
  }

  module do_drill() {
      do_layout()
        if ($thick) fl_cylinder(h=$thick,r=hole_r,octant=$director);
  }

  /**
  * Set context for children()
  *
  * $director - layout direction
  * $screw    - OPTIONAL screw
  * $thick    - thickness along $director
  * $h        - spacer height
  */
  module context(
    director
  ) {
    $director  = director;
    $screw      = screw;
    $thick      = director==+Z ? thick[1] : thick[0];
    $h          = h;
    children();
  }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_assembly();

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier) do_drill();

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout()
        children();

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier) do_mount();

    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) do_footprint();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
