/*
 * Caddy test file.
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org).
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
include <../foundation/incs.scad>
include <../vitamins/incs.scad>
use     <../caddy.scad>

$fn         = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
TRACE       = false;

$FL_FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Supported verbs] */

// adds shapes to scene.
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
CUTOUT    = "OFF";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
FPRINT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a box representing the payload of the shape
PLOAD     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

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

// converts a list of strings into a list of their represented axes
// TODO: insert the function in OFL defs?
function s2axes(slist) = 
  [for(s=slist)
    assert(s=="+X"||s=="-X"||s=="+Y"||s=="-Y"||s=="+Z"||s=="-Z",str("Invalid value '",s,"'"))
    (s=="+X") ? +FL_X : (s=="-X") ? -FL_X : (s=="+Y") ? +FL_Y : (s=="-Y") ? -FL_Y : (s=="+Z") ? +FL_Z : -FL_Z];

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

  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  D     = direction ? fl_direction(proto=type,direction=direction)  : FL_I;
  M     = octant    ? fl_octant(octant=octant,bbox=bbox)            : FL_I;

  dr_thick  = thick ? thick : dr_thick;
  co_thick  = thick ? thick : co_thick;

  module do_add() {}
  module do_bbox() {}
  module do_assembly() {}
  module do_layout() {}
  module do_drill() {}

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) fl_cube(size=size);

      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_cube(size=size);

      } else if ($verb==FL_CUTOUT) {
        fl_modifier($FL_CUTOUT) 
          translate([0,size.y/2,size.z/2]) fl_prism(h=thick.x[0],n=5,l=2,octant=-Z,direction=[+X,0]);

      } else if ($verb==FL_LAYOUT) {
        fl_modifier($FL_LAYOUT) do_layout()

          children();
      } else if ($verb==FL_FOOTPRINT) {

        fl_modifier($FL_FOOTPRINT);
      } else if ($verb==FL_ASSEMBLY) {

        fl_modifier($FL_ASSEMBLY);
      } else if ($verb==FL_DRILL) {
        fl_trace("thick",thick);
        fl_modifier($FL_DRILL)
          translate([size.x/2,size.y/2,0]) 
            fl_cylinder(h=thick.z[0],r=3,octant=-Z);
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=size);
  }
}

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
verbs=[
  if (ADD!="OFF")       FL_ADD,
  if (ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if (AXES!="OFF")      FL_AXES,
  if (BBOX!="OFF")      FL_BBOX,
  if (CUTOUT!="OFF")    FL_CUTOUT,
  if (DRILL!="OFF")     FL_DRILL,
  if (FPRINT!="OFF")    FL_FOOTPRINT,
  if (LAYOUT!="OFF")    FL_LAYOUT,
  if (PLOAD!="OFF")     FL_PAYLOAD,
];
// list of normals to faces
faces = s2axes(FACES);
// the carried item
blob  = [
  fl_bb_corners(value=BLOB_BBOX)
];
// thickness list built from customizer values
T     = [T_x,T_y,T_z];
// 'NIL' list to be added to children thickness in order to avoid 'z' fighting problem during preview
T_NIL = [[NIL,NIL],[NIL,NIL],[NIL,NIL]];

fl_caddy(verbs,blob,thick=T,faces=faces,tolerance=TOLERANCE,fillet=FILLET_R,direction=direction,octant=octant,
  $FL_TRACE=TRACE,
  $FL_ADD=ADD,$FL_ASSEMBLY=ASSEMBLY,$FL_AXES=AXES,$FL_BBOX=BBOX,$FL_CUTOUT=CUTOUT,$FL_DRILL=DRILL,$FL_FOOTPRINT=FPRINT,$FL_LAYOUT=LAYOUT,$FL_PAYLOAD=PLOAD)
  // the children is called with the following special variables set:
  // $verbs ⇒ list of verbs to be executed
  // $thick ⇒ thickness list for DRILL and CUTOUT
  blob($verbs,blob,thick=$thick+T_NIL,
      $FL_TRACE=TRACE,
      $FL_DRILL="ON",$FL_CUTOUT="ON");
