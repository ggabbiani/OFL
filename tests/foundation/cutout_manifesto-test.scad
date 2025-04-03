/*
 * All OFL objects implementing the FL_CUTOUT verb are triggered with same
 * cutout parameters to compare the behavior implemented. This test is also
 * important to verify that the cutout parameters used are consistent in the
 * different modules.
 *
 * For the detailed description of the behavior expected when triggering
 * FL_CUTOUT verb and the cutout parameters used see the variable FL_CUTOUT
 * documentation.
 *
 * Standard parameters for FL_CUTOUT:
 *
 * | name           | default         | type      |
 * | ---            | ---             | ---       |
 * | cut_drift      | 0               | parameter |
 * | cut_dirs       | fl_cutout(type) | parameter |
 * | $fl_thickness  | 0               | context   |
 * | $fl_tolerance  | 0               | context   |
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../lib/OFL/artifacts/din_rails.scad>
include <../../lib/OFL/vitamins/ethers.scad>
include <../../lib/OFL/vitamins/jacks.scad>
include <../../lib/OFL/vitamins/heatsinks.scad>
include <../../lib/OFL/vitamins/hdmi.scad>
include <../../lib/OFL/vitamins/hds.scad>
include <../../lib/OFL/vitamins/pin_headers.scad>
include <../../lib/OFL/vitamins/sata.scad>
include <../../lib/OFL/vitamins/sd.scad>
include <../../lib/OFL/vitamins/switch.scad>
include <../../lib/OFL/vitamins/trimpot.scad>
include <../../lib/OFL/vitamins/usbs.scad>

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

/* [cutout] */

CLASS         = "jack";  // [hd,hdmi,heatsinks,jack,DIN,ether,pin header,SATA,SD,snapfit joint,switch,trimpot,USB]
// list of cutout directions like -x,+x,±x,-y,+y,±y,-z,+z,±z, "undef" or "empty"
CUTOUT_DIRS   = ["undef"]; // [undef,empty,-x,+x,±x,-y,+y,±y,-z,+z,±z]
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
dirs      = CUTOUT_DIRS==["undef"] ? undef : CUTOUT_DIRS==["empty"] ? [] : fl_3d_AxisList(CUTOUT_DIRS);
gap       = 2*$fl_thickness;

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

if (CLASS=="jack") let(
  all = all(FL_JACK_DICT)
) fl_layout(axis=+X,gap=gap,types=all,$FL_LAYOUT="ON")
  fl_jack(verbs,$item,cut_drift=CUTOUT_DRIFT,cut_dirs=dirs,octant=octant,direction=direction);

else if (CLASS=="DIN") let(
  all = all(FL_DIN_RAIL_INVENTORY,function(i) FL_DIN_RAIL_INVENTORY[i](fl_bb_size(FL_DIN_TS_INVENTORY[i]).x*2))
) fl_layout(axis=+X,gap=gap,types=all,$FL_LAYOUT="ON")
  fl_DIN_rail(verbs,$item,cut_dirs=dirs,cut_drift=CUTOUT_DRIFT,octant=octant,direction=direction);

else if (CLASS=="ether") let(
  all = all(FL_ETHER_DICT)
) fl_layout(axis=+X,gap=gap,types=all,$FL_LAYOUT="ON")
  fl_ether(verbs, $item, cut_dirs=dirs, cut_drift=CUTOUT_DRIFT, octant=octant, direction=direction);

else if (CLASS=="hdmi") let(
  all = all(FL_HDMI_DICT)
) fl_layout(axis=+X,gap=gap,types=all,$FL_LAYOUT="ON")
  fl_hdmi(verbs,$item,cut_drift=CUTOUT_DRIFT,cut_dirs=dirs,octant=octant,direction=direction);

else if (CLASS=="hd") let(
  all = all(FL_HD_DICT)
) fl_layout(axis=+X,gap=gap,types=all,$FL_LAYOUT="ON")
  fl_hd(verbs,$item,cut_drift=CUTOUT_DRIFT,cut_dirs=dirs,direction=direction,octant=octant);

else if (CLASS=="heatsinks") let(
  all = all(FL_HS_DICT)
) fl_layout(axis=+X,gap=gap,types=all,$FL_LAYOUT="ON")
  fl_heatsink(verbs,$item,cut_drift=CUTOUT_DRIFT,cut_dirs=dirs,octant=octant,direction=direction);

else if (CLASS=="pin header") let(
  all = all(FL_PHDR_DICT)
) fl_layout(axis=+X,gap=gap,types=all,$FL_LAYOUT="ON")
  fl_pinHeader(verbs,$item,cut_thick=$fl_thickness,cut_tolerance=$fl_tolerance,cut_dirs=dirs, octant=octant, direction=direction);

else if (CLASS=="SATA") let(
  all = all(FL_SATA_DICT)
) fl_layout(axis=+X,gap=gap,types=all,$FL_LAYOUT="ON")
  fl_sata(verbs,$item, cut_drift=CUTOUT_DRIFT, cut_dirs=dirs, octant=octant, direction=direction);

else if (CLASS=="SD") let(
  all = all(FL_SD_DICT)
) fl_layout(axis=+X,gap=gap,types=all,$FL_LAYOUT="ON")
  fl_sd_usocket(verbs,$item,cut_drift=CUTOUT_DRIFT,cut_thick=$fl_thickness,cut_tolerance=$fl_tolerance,cut_dirs=dirs,direction=direction,octant=octant);

else if (CLASS=="switch") let(
  all = all(FL_SWT_DICT)
) fl_layout(axis=+X,gap=gap,types=all,$FL_LAYOUT="ON")
  fl_switch(verbs,$item,cut_thick=$fl_thickness,cut_tolerance=$fl_tolerance,cut_drift=CUTOUT_DRIFT,cut_dirs=dirs,direction=direction,octant=octant);

else if (CLASS=="trimpot") let(
  all = all(FL_TRIM_DICT)
) fl_layout(axis=+X,gap=gap,types=all,$FL_LAYOUT="ON")
  fl_trimpot(verbs,$item,cut_thick=$fl_thickness,cut_tolerance=$fl_tolerance,cut_drift=CUTOUT_DRIFT,cut_dirs=dirs,direction=direction,octant=octant);

else if (CLASS=="USB") let(
  all = all(FL_USB_DICT)
) fl_layout(axis=+X,gap=gap,types=all,$FL_LAYOUT="ON")
  fl_USB(verbs,$item,cut_thick=$fl_thickness,cut_tolerance=$fl_tolerance,cut_drift=CUTOUT_DRIFT,cut_dirs=dirs,direction=direction,octant=octant);

else
  fl_error(["Unsupported class engine",CLASS]);
