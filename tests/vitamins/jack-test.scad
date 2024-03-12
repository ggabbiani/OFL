/*
 * NopSCADlib Jack wrapper test
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/NopSCADlib/global_defs.scad>
use     <../../lib/NopSCADlib/utils/layout.scad>

include <../../lib/OFL/vitamins/jacks.scad>


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

SHOW        = "ALL"; // [ALL,FL_JACK_BARREL,MCXJPHSTEM1]
// tolerance used during FL_CUTOUT
CO_TOLERANCE   = 0;  // [0:0.1:5]
// thickness for FL_CUTOUT
CO_T  = 2.5;
// translation applied to cutout
CO_DRIFT = 0; // [-5:0.05:5]


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// end of automatically generated code

thick     = $FL_CUTOUT!="OFF" ? CO_T          : undef;
tolerance = $FL_CUTOUT!="OFF" ? CO_TOLERANCE  : undef;
drift     = $FL_CUTOUT!="OFF" ? CO_DRIFT      : undef;

verbs=[
  if ($FL_ADD!="OFF")       FL_ADD,
  if ($FL_AXES!="OFF")      FL_AXES,
  if ($FL_BBOX!="OFF")      FL_BBOX,
  if ($FL_CUTOUT!="OFF")    FL_CUTOUT,
];
// target object(s)
single  = SHOW=="FL_JACK_BARREL"  ? FL_JACK_BARREL
        : SHOW=="MCXJPHSTEM1"     ? FL_JACK_MCXJPHSTEM1
        : undef;

fl_trace("verbs",verbs);
fl_trace("single",single);
fl_trace("FL_JACK_DICT",FL_JACK_DICT);

if (single)
  fl_jack(verbs,single,
    direction=direction,octant=octant,cut_thick=thick,cut_tolerance=tolerance,cut_drift=drift,debug=debug);
else
  layout([for(socket=FL_JACK_DICT) fl_width(socket)], 10)
    fl_jack(verbs,FL_JACK_DICT[$i],
      direction=direction,octant=octant,cut_thick=thick,cut_tolerance=tolerance,cut_drift=drift,debug=debug);
