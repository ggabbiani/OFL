/*
 * NopSCADlib pin header wrapper test file.
 *
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org)
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

include <../../vitamins/pin_headers.scad>

$fn         = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

$FL_FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

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

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Pin Header] */

// enable debug
DEBUG         = false;
SHOW          = "all"; // [all,custom,FL_PHDR_GPIOHDR,FL_PHDR_GPIOHDR_F,FL_PHDR_GPIOHDR_FL,FL_PHDR_GPIOHDR_F_SMT_LOW]
// ... guess what
COLOR         = "base";   // [base,red]
// tolerance used during FL_CUTOUT
CO_TOLERANCE  = 0.5;      // [0:0.1:5]
// thickness for FL_CUTOUT
CO_T          = 15;     // [0:0.1:20]

/* [Custom pin header] */

TYPE  = "female"; // [male,female]
// size in columns x rows
GEOMETRY          = [10,1]; // [1:20]

/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
thick     = $FL_CUTOUT!="OFF"||$FL_DRILL!="OFF" ? CO_T : undef;
tolerance = $FL_CUTOUT!="OFF" ? CO_TOLERANCE  : undef;
color     = COLOR=="base"?grey(20):COLOR;
type      = fl_dict_search(FL_PHDR_DICT,SHOW)[0];

verbs=[
  if ($FL_ADD!="OFF")       FL_ADD,
  if ($FL_AXES!="OFF")      FL_AXES,
  if ($FL_BBOX!="OFF")      FL_BBOX,
  if ($FL_CUTOUT!="OFF")    FL_CUTOUT,
  if ($FL_DRILL!="OFF")     FL_DRILL,
];

module wrapIt(type) {
  fl_pinHeader(verbs,type,color=color,cut_thick=thick,cut_tolerance=tolerance,debug=DEBUG,octant=octant,direction=direction);
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
