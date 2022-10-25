/*
 * Caddy test file.
 *
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
 * along with OFL.  If not, see <http://www.gnu.org/licenses/>.
 */

include <../../foundation/unsafe_defs.scad>
include <../../artifacts/caddy.scad>

$fn         = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]
// Default color for printable items (i.e. artifacts)
$fl_filament  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
$FL_ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
$FL_CUTOUT    = "OFF";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
$FL_FOOTPRINT = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a box representing the payload of the shape
$FL_PAYLOAD   = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Caddy] */
// wall thickness on X semi-axes (-X,+X)
T_x   = [2.5,2.5];  // [0:0.1:10]
// wall thickness on Y semi-axes (-Y,+Y)
T_y   = [2.5,2.5];  // [0:0.1:10]
// wall thickness on Z semi-axes (-Z,+Z)
T_z   = [2.5,2.5];  // [0:0.1:10]
FACES = ["+X","-X","-Z"];

// CUT OUT tolerance
CO_TOLERANCE  = 0.5;
// Internal tolerance (fl_JNgauge=0.15mm)
TOLERANCE     = 0.15;
// fillet radius
FILLET_R      = 0;  // [0:0.1:5]

/* [blob] */

BLOB_BBOX  = [[0,0,0],[30,20,10]];

/* [Hidden] */

module blob(
  verbs       = FL_ADD, // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  type,
  thick,                // walls thickness in the form:
                        // [["+X",«+X thick value»],["-X",«-X thick value»],["+Y",«+Y thick value»],["-Y",«-Y thick value»],["+Z",«+Z thick value»],["-Z",«-Z thick value»]].
                        // Passing a scalar means same thickness for all the six walls:
                        // [["+X",«thick»],["-X",«thick»],["+Y",«thick»],["-Y",«thick»],["+X",«thick»],["-X",«thick»]].
                        // NOTE: any missing semi-axis thickness is set to 0
                        // example:
                        // thick=[["+X",2.5],["-Z",5]]
                        // thick=2.5
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant,               // when undef native positioning is used
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  D     = direction ? fl_direction(proto=type,direction=direction)  : FL_I;
  M     = fl_octant(octant,bbox=bbox);

  module do_add() {}
  module do_bbox() {}
  module do_assembly() {}
  module do_layout() {}
  module do_drill() {}

  fl_manage(verbs,M,D,size)  {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) fl_cube(size=size);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_cube(size=size);

    } else if ($verb==FL_CUTOUT) {
      fl_trace("$modifier",$modifier);
      fl_modifier($modifier)
        translate([0,size.y/2,size.z/2]) fl_prism(h=thick.x[0],n=5,l=2,octant=-Z,direction=[+X,0]);

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout()
        children();

    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier);

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier);

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier);

    } else if ($verb==FL_DRILL) {
      fl_trace("$modifier",$modifier);
      fl_trace("thick",thick);
      fl_modifier($modifier)
        translate([size.x/2,size.y/2,0])
          fl_cylinder(h=thick.z[0],r=3,octant=-Z);
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
verbs=[
  if ($FL_ADD!="OFF")       FL_ADD,
  if ($FL_ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if ($FL_AXES!="OFF")      FL_AXES,
  if ($FL_BBOX!="OFF")      FL_BBOX,
  if ($FL_CUTOUT!="OFF")    FL_CUTOUT,
  if ($FL_DRILL!="OFF")     FL_DRILL,
  if ($FL_FOOTPRINT!="OFF") FL_FOOTPRINT,
  if ($FL_PAYLOAD!="OFF")   FL_PAYLOAD,
];
// list of normals to faces
faces = fl_3d_AxisList(FACES);
// the carried item
blob  = [
  fl_bb_corners(value=BLOB_BBOX)
];
// thickness list built from customizer values
T     = [T_x,T_y,T_z];
// 'NIL' list to be added to children thickness in order to avoid 'z' fighting problem during preview
T_NIL = [[NIL,NIL],[NIL,NIL],[NIL,NIL]];

fl_caddy(verbs,blob,thick=T,faces=faces,tolerance=TOLERANCE,fillet=FILLET_R,direction=direction,octant=octant)
  // the children is called with the following special variables set:
  // $cad_verbs ⇒ list of verbs to be executed
  // $cad_thick ⇒ thickness list for DRILL and CUTOUT
  blob($cad_verbs,blob,thick=$cad_thick+T_NIL,$FL_DRILL="ON",$FL_CUTOUT="ON",$FL_ADD="ON",$FL_ASSEMBLY="ON");
