/*
 * NopSCADlib pin header wrapper test file
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


include <../../lib/OFL/vitamins/pin_headers.scad>


$fn            = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER     = false;
// Default color for printable items (i.e. artifacts)
$fl_filament   = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]


/* [Debug] */

// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES        = -2;     // [-2:10]
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
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


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



/* [Pin Header] */

SHOW          = "all"; // [all,custom,FL_PHDR_GPIOHDR,FL_PHDR_GPIOHDR_F,FL_PHDR_GPIOHDR_FL,FL_PHDR_GPIOHDR_F_SMT_LOW]
// ... guess what
PIN_COLOR     = "base";   // [base,red]
// tolerance used during FL_CUTOUT
CO_TOLERANCE  = 0.5;      // [0:0.1:5]
// thickness for FL_CUTOUT
CO_T          = 15;     // [0:0.1:20]
// list of cutout directions like -x,+x,±x,-y,+y,±y,-z,+z,±z, "undef" or "empty"
CUTOUT_DIRS   = ["undef"]; // [undef,empty,-x,+x,±x,-y,+y,±y,-z,+z,±z]

/* [Custom pin header] */

TYPE  = "female"; // [male,female]
// size in columns x rows
GEOMETRY          = [10,1]; // [1:20]


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

thick     = $FL_CUTOUT!="OFF"||$FL_DRILL!="OFF" ? CO_T : undef;
tolerance = $FL_CUTOUT!="OFF" ? CO_TOLERANCE  : undef;
color     = PIN_COLOR=="base"?grey(20):PIN_COLOR;
type      = fl_dict_search(FL_PHDR_DICT,SHOW)[0];
verbs     = fl_verbList([FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT,FL_DRILL]);
dirs      = CUTOUT_DIRS==["undef"] ? undef : CUTOUT_DIRS==["empty"] ? [] : fl_3d_AxisList(CUTOUT_DIRS);

module wrapIt(type) {
  fl_pinHeader(verbs,type,color=color,cut_thick=thick,cut_tolerance=tolerance,cut_dirs=dirs,octant=octant,direction=direction);
}

// one predefined
if (type)
  wrapIt(type);

// all predefined
else if (SHOW=="all")
  layout([for(type=FL_PHDR_DICT) fl_width(type)], 10)
    let(t=FL_PHDR_DICT[$i])
      wrapIt(t);

// custom
else
  let(
    type  = fl_PinHeader("test header",nop=2p54header,geometry=GEOMETRY,engine=TYPE)
  )   wrapIt(type);

