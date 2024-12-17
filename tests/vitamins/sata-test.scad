/*
 * Test for 'naive' SATA plug & socket
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/vitamins/hds.scad>
include <../../lib/OFL/vitamins/sata.scad>
include <../../lib/OFL/foundation/unsafe_defs.scad>


$fn            = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER     = false;
// Default color for printable items (i.e. artifacts)
$fl_filament   = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]


/* [Debug] */

// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]
DEBUG_ASSERTIONS  = false;
DEBUG_COMPONENTS  = ["none"];
DEBUG_COLOR       = false;
DEBUG_DIMENSIONS  = false;
DEBUG_LABELS      = false;
DEBUG_SYMBOLS     = false;


/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
$FL_CUTOUT    = "OFF";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
$FL_FOOTPRINT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


/* [3D Placement] */

X_PLACE = "undef";  // [undef,-1,0,+1]
Y_PLACE = "undef";  // [undef,-1,0,+1]
Z_PLACE = "undef";  // [undef,-1,0,+1]


/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [-360:360]



/* [Sata] */
PART        = "data plug"; // [data plug,power plug,power data plug,power data socket]
// connect composite plug or socket
CONNECT     = "none"; // [none, counter type, hd]


/* [Hidden] */


$dbg_Assert     = DEBUG_ASSERTIONS;
$dbg_Dimensions = DEBUG_DIMENSIONS;
$dbg_Color      = DEBUG_COLOR;
$dbg_Components = DEBUG_COMPONENTS[0]=="none" ? undef : DEBUG_COMPONENTS;
$dbg_Labels     = DEBUG_LABELS;
$dbg_Symbols    = DEBUG_SYMBOLS;


direction       = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant          = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);

fl_status();

// end of automatically generated code

verbs = fl_verbList([FL_ADD,FL_AXES,FL_BBOX,FL_FOOTPRINT]);
type  = PART=="data plug"       ? FL_SATA_DATAPLUG
      : PART=="power plug"      ? FL_SATA_POWERPLUG
      : PART=="power data plug" ? FL_SATA_POWERDATAPLUG
      : FL_SATA_POWERDATASOCKET;
counter_type =
  PART=="power data plug"   ? FL_SATA_POWERDATASOCKET :
  PART=="power data socket" ? FL_SATA_POWERDATAPLUG   :
  undef;
connected_device  =
  CONNECT=="counter type" ? counter_type :
  CONNECT=="hd" && PART=="power data socket" ? FL_HD_EVO860 :
  undef;

fl_sata(verbs,type,octant=octant,direction=direction);
if (connected_device)
  fl_connect(son=[connected_device,0], parent=[type,0], octant=octant, direction=direction)
    if (fl_engine($con_child)==FL_HD_NS)
      fl_hd(type=$con_child,$FL_ADD="ON");
    else
      fl_sata(type=$con_child,$FL_ADD="ON");
