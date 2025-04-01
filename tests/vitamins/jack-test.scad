/*
 * NopSCADlib Jack wrapper test
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


include <../../lib/ext/NopSCADlib/global_defs.scad>
use     <../../lib/ext/NopSCADlib/utils/layout.scad>

include <../../lib/OFL/vitamins/jacks.scad>


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



/* [Jack] */

SHOW          = "ALL";  // [ALL,FL_JACK_BARREL,MCXJPHSTEM1]
// tolerance used during FL_CUTOUT
CO_TOLERANCE  = 0;        // [0:0.1:5]
// thickness for FL_CUTOUT
CO_T          = 2.5;      // [0:0.1:5]
// translation applied to cutout
CO_DRIFT      = 0;        // [-5:0.05:5]
// list of cutout directions like -x,+x,±x,-y,+y,±y,-z,+z,±z, "undef" or "empty"
CUT_DIRS      = ["undef"]; // [undef,empty,-x,+x,±x,-y,+y,±y,-z,+z,±z]

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

$fl_thickness = $FL_CUTOUT!="OFF" ? CO_T          : undef;
$fl_tolerance = $FL_CUTOUT!="OFF" ? CO_TOLERANCE  : undef;
drift         = $FL_CUTOUT!="OFF" ? CO_DRIFT      : undef;
verbs         = fl_verbList([FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT]);
cut_dirs      = CUT_DIRS==["undef"] ? undef : CUT_DIRS==["empty"] ? [] : fl_3d_AxisList(CUT_DIRS);

// target object(s)
single  = SHOW=="FL_JACK_BARREL"  ? FL_JACK_BARREL
        : SHOW=="MCXJPHSTEM1"     ? FL_JACK_MCXJPHSTEM1
        : undef;

if (single)
  fl_jack(verbs,single,cut_drift=drift,co_dirs=cut_dirs,octant=octant,direction=direction);
else
  layout([for(socket=FL_JACK_DICT) fl_width(socket)], 10)
    fl_jack(verbs,FL_JACK_DICT[$i],cut_drift=drift,co_dirs=cut_dirs,octant=octant,direction=direction);
