/*
 * Foundation test template.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../lib/OFL/foundation/3d-engine.scad>

$fn         = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// Default color for printable items (i.e. artifacts)
$fl_filament  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]

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
$FL_CUTOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
$FL_FOOTPRINT = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// mount shape through predefined screws
$FL_MOUNT     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
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

/* [Test] */

$hole_syms   = true;

/* [Bounding box] */

BB_NEGATIVE = [-1,-1,-0.5]; // [-1:0.1:1]
BB_POSITIVE = [1,1,0];      // [-1:0.1:1]

/* [cutout] */

CUTOUT_AXIS   = [0,0,1];  // [-1:0.1:+1]
CUTOUT_DRIFT  = 0;  // [-2:0.1:2]
$fl_thickness = 0.1;  // [0:0.1:2]
$fl_tolerance = 0;  // [0:0.1:2]

/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
verbs     = fl_verbList([FL_ADD,FL_ASSEMBLY,FL_AXES,FL_BBOX,FL_CUTOUT,FL_DRILL,FL_FOOTPRINT,FL_LAYOUT,FL_MOUNT,FL_PAYLOAD]);
bbox      = [BB_NEGATIVE,BB_POSITIVE];

test      = fl_Object(bbox=bbox, name="Cut-out test object", engine="cutout-test");

module cutout_test(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  this,
  // cutout axis
  co_axis,
  // cutout drift (scalar)
  co_drift,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction
) {

  // run with an execution context set by fl_vmanage{}
  module engine() let(
    // start of engine specific internal variables
    dummy_var = "whatever you need"
  ) if ($this_verb==FL_ADD) {
    fl_bb_add(corners=$this_bbox,auto=false);

  } else if ($this_verb==FL_BBOX)
    // ... this should be enough
    fl_bb_add(corners=$this_bbox,$FL_ADD=$FL_BBOX);

  else if ($this_verb==FL_CUTOUT) {
    fl_new_cutout(bbox,co_axis,co_drift)
      fl_bb_add(corners=$this_bbox,auto=false,$FL_ADD=$FL_CUTOUT);

  } else if ($this_verb==FL_DRILL) {
    // your code ...

  } else if ($this_verb==FL_LAYOUT) {
    // your code ...

  } else if ($this_verb==FL_MOUNT) {
    // your code ...

  } else
    fl_error(["unimplemented verb",$this_verb]);

  // fl_vmanage() manages standard parameters and prepares the execution
  // context for the engine.
  fl_vmanage(verbs,this,octant=octant,direction=direction)
    engine()
      children();
}

cutout_test(verbs, test, co_axis=CUTOUT_AXIS, co_drift=CUTOUT_DRIFT, octant=octant, direction=direction);