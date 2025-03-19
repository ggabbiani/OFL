/*
 * Foundation test template.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../lib/OFL/artifacts/din_rails.scad>
// include <../../lib/OFL/artifacts/joints.scad>
include <../../lib/OFL/vitamins/ethers.scad>
include <../../lib/OFL/vitamins/jacks.scad>

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
$FL_CUTOUT    = "DEBUG";// [OFF,ON,ONLY,DEBUG,TRANSPARENT]
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

/* [Object selection] */

// ... please take a decision!
CLASS  = "jack";  // [jack,DIN,ether,snapfit joint]

/* [cutout] */

// list of cutout directions or "preferred" for preferred directions only
CUTOUT_DIRS  = ["preferred"];
// space added/subtracted to the bounding box before carving
CUTOUT_DRIFT  = 0;        // [-5:0.1:5]
// overall thickness to be carved out
$fl_thickness = 2.5;      // [0:0.1:5]
// tolerance added/subtracted to the object section boundaries
$fl_tolerance = 0;        // [0:0.1:2]

/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
verbs     = fl_verbList([FL_ADD,FL_ASSEMBLY,FL_AXES,FL_BBOX,FL_CUTOUT,FL_DRILL,FL_FOOTPRINT,FL_LAYOUT,FL_MOUNT,FL_PAYLOAD]);
co_dirs   = CUTOUT_DIRS==["preferred"] ? undef : fl_3d_AxisList(CUTOUT_DIRS);

/*!
 * True if the «type» engine is a sub domain of «engine».
 *
 * Example: if «type» has the fl_engine() attribute set to "jack/barrel", the
 * following code
 *
 *     fl_typeIsEngine(type,"jack")
 *
 * will return true.
 */
function fl_typeIsEngine(type,engine) = fl_substr(fl_engine(type),len=len(engine))==engine;

function all(inventory,builder) = let(
) [for(i=[0:len(inventory)-1]) builder ? builder(i) : inventory[i]];

module proxy(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  // cutout axes list
  co_dirs,
  // cutout drift (scalar)
  co_drift,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction
) let(
    gap     = 2*$fl_thickness
) if (CLASS=="jack") let(
    all = all(FL_JACK_DICT)
  ) fl_layout(axis=+X,gap=gap,types=all,$FL_LAYOUT="ON")
    fl_jack(verbs,all[$i],co_drift,co_dirs,octant,direction);

  else if (CLASS=="DIN") let(
    all = all(FL_DIN_RAIL_INVENTORY,function(i) FL_DIN_RAIL_INVENTORY[i](fl_bb_size(FL_DIN_TS_INVENTORY[i]).x*2))
  ) fl_layout(axis=+X,gap=2*$fl_thickness,types=all,$FL_LAYOUT="ON")
    fl_DIN_rail(verbs,all[$i],cut_direction=co_dirs,cut_drift=co_drift,octant=octant,direction=direction);

  else if (CLASS=="ether") let(
    all = all(FL_ETHER_DICT)
  ) fl_layout(axis=+X,gap=gap,types=all,$FL_LAYOUT="ON")
    fl_ether(verbs, all[$i], cut_drift=co_drift, cut_direction=co_dirs, octant=octant, direction=direction);

  else if (CLASS=="snapfit joint") let(
  )
  ;

  else
    fl_error(["Unsupported class engine",CLASS]);

proxy(verbs, co_dirs, CUTOUT_DRIFT, octant=octant, direction=direction);