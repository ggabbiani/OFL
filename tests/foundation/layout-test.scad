/*
 * Layout test
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
include <../../lib/OFL/vitamins/pcbs.scad>
include <../../lib/OFL/vitamins/psus.scad>

use <../../lib/OFL/foundation/3d-engine.scad>


$fn            = 50;           // [3:100]
// When true, debug statements are turned on
$fl_debug      = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER     = false;
// Default color for printable items (i.e. artifacts)
$fl_filament   = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES     = -2;     // [-2:10]
SHOW_LABELS     = false;
SHOW_SYMBOLS    = false;
SHOW_DIMENSIONS = false;


/* [Supported verbs] */

// adds local reference axes
$FL_AXES      = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


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



/* [Layout] */

GAP     = 5;
AXIS    = "+X";   // [+X, -X, +Y, -Y, +Z, -Z]
RENDER  = "ADD"; // [DRAW, ADD, BBOX]
ALIGN   = [0,0,0];  // [-1:+1]


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS,dimensions=SHOW_DIMENSIONS);

fl_status();

// end of automatically generated code

verbs=[
  if ($FL_AXES!="OFF")    FL_AXES,
  if ($FL_BBOX!="OFF")    FL_BBOX,
  if ($FL_LAYOUT!="OFF")  FL_LAYOUT,
];

types   = [FL_PCB_RPI4,FL_HD_EVO860,FL_HD_EVO860,FL_PSU_MeanWell_RS_25_5];
axis    = fl_3d_AxisList([AXIS])[0];
overbs  = [
  if (RENDER=="DRAW"||RENDER=="ADD") FL_ADD,
  if (RENDER=="DRAW"||RENDER=="ASSEMBLY") FL_ASSEMBLY,
  if (RENDER=="BBOX") FL_BBOX,
];

module object(object) {
  engine        = fl_engine(object);
  octant        = undef;
  $FL_ADD       = "ON";
  $FL_ASSEMBLY  = "ON";
  $FL_BBOX      = "DEBUG";
  if (engine==FL_PCB_NS)
    fl_pcb(overbs,object,octant=octant);
  else if (engine==FL_HD_NS)
    fl_hd(overbs,object,octant=octant);
  else if (engine==FL_PSU_NS)
    fl_psu(overbs,object,octant=octant);
  else
    assert(false,str("Engine ",engine," UNKNOWN."));
}

fl_trace("verbs",verbs);
fl_layout(verbs,axis,GAP,types,align=ALIGN,octant=octant,direction=direction)
  object($item);
