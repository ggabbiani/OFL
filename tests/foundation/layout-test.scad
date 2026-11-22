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

//**** TEST_INCLUDES ***********************************************************
include <../../lib/OFL/vitamins/hds.scad>
include <../../lib/OFL/vitamins/pcbs.scad>
include <../../lib/OFL/vitamins/psus.scad>

use <../../lib/OFL/foundation/3d-engine.scad>

//**** TAB_PARAMETERS **********************************************************
// number of segments
$fn            = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_EPS
$FL_RENDER     = false;
// Default color for printable items (i.e. artifacts)
$fl_filament   = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// When false polyRound() is disabled
$fl_polyround  = true;

//**** TAB_Debug ***************************************************************
/* [Debug] */

// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES        = -2;     // [-2:10]
DEBUG_ASSERTIONS  = false;
DEBUG_COMPONENTS  = ["none"];
DEBUG_COLOR       = false;
DEBUG_DIMENSIONS  = false;
DEBUG_LABELS      = false;
DEBUG_SYMBOLS     = false;

//**** TAB_Verbs ***************************************************************
/* [Supported verbs] */

// adds local reference axes
$FL_AXES      = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

//**** TAB_Placement ***********************************************************
/* [3D Placement] */

X_PLACE = "undef";  // [undef,-1,0,+1]
Y_PLACE = "undef";  // [undef,-1,0,+1]
Z_PLACE = "undef";  // [undef,-1,0,+1]

//**** TAB_Direction ***********************************************************
/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [-360:360]

//**** TAB_Dimensions **********************************************************


//**** TAB_TEST ****************************************************************
/* [Layout] */

GAP     = 5;
AXIS    = "+X";   // [+X, -X, +Y, -Y, +Z, -Z]
RENDER  = "ADD"; // [DRAW, ADD, BBOX]
ALIGN   = [0,0,0];  // [-1:+1]
// when true the layout is passed as an object built by fl_Layout()
CONSTRUCTOR = false;
// when true (and CONSTRUCTOR is true) the layout object is built with axis -X
// and no gap, the explicit «axis» and «gap» parameters override them
OVERRIDE    = false;

/* [Hidden] */

//**** TEST_PROLOGUE ***********************************************************
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
verbs   = fl_verbList([FL_AXES,FL_BBOX,FL_LAYOUT]);
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

if (CONSTRUCTOR) {
  layout = OVERRIDE
    ? fl_Layout(axis=-axis,gap=0,types=types)
    : fl_Layout(axis=axis,gap=GAP,types=types);
  assert(OVERRIDE||fl_bb_corners(layout)==lay_bb_corners(axis,GAP,types),fl_bb_corners(layout));
  echo(str("layout: ",fl_name(layout)));
  if (OVERRIDE)
    fl_layout(verbs,layout,axis=axis,gap=GAP,align=ALIGN,octant=octant,direction=direction)
      object($item);
  else
    fl_layout(verbs,layout,align=ALIGN,octant=octant,direction=direction)
      object($item);
} else
  fl_layout(verbs,axis=axis,gap=GAP,types=types,align=ALIGN,octant=octant,direction=direction)
    object($item);
