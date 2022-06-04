/*
 * Vitamins test template.
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
// include <../../foundation/incs.scad>
include <../../vitamins/usbs.scad>

include <NopSCADlib/global_defs.scad>
use     <NopSCADlib/utils/layout.scad>

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
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
$FL_CUTOUT    = "OFF";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
$FL_FOOTPRINT = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [USB] */

SHOW      = "ALL";  // [ALL,FL_USB_TYPE_Ax1,FL_USB_TYPE_Ax2,FL_USB_TYPE_B,FL_USB_TYPE_C,FL_USB_TYPE_uA]
// tolerance used during FL_CUTOUT and FL_FOOTPRINT
TOLERANCE = 0;      // [0:0.1:5]
// thickness for FL_CUTOUT
CO_T      = 2.5;
// translation applied to cutout
CO_DRIFT  = 0;      // [-5:0.05:5]
// tongue color
COLOR     = "white";  // [white, OrangeRed, DodgerBlue]

/* [Hidden] */

direction = DIR_NATIVE    ? undef         : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef         : OCTANT;
thick     = $FL_CUTOUT!="OFF" ? CO_T          : undef;
tolerance = $FL_CUTOUT!="OFF" || $FL_FOOTPRINT!="OFF" ? TOLERANCE : undef;
drift     = $FL_CUTOUT!="OFF" ? CO_DRIFT : undef;

verbs=[
  if ($FL_ADD!="OFF")       FL_ADD,
  if ($FL_AXES!="OFF")      FL_AXES,
  if ($FL_BBOX!="OFF")      FL_BBOX,
  if ($FL_CUTOUT!="OFF")    FL_CUTOUT,
  if ($FL_FOOTPRINT!="OFF") FL_FOOTPRINT,
];
// target object(s)
single  = SHOW=="FL_USB_TYPE_Ax1" ? FL_USB_TYPE_Ax1
        : SHOW=="FL_USB_TYPE_Ax2" ? FL_USB_TYPE_Ax2
        : SHOW=="FL_USB_TYPE_B"   ? FL_USB_TYPE_B
        : SHOW=="FL_USB_TYPE_C"   ? FL_USB_TYPE_C
        : SHOW=="FL_USB_TYPE_uA"  ? FL_USB_TYPE_uA
        : undef;

fl_trace("verbs",verbs);
fl_trace("single",single);
fl_trace("FL_USB_DICT",FL_USB_DICT);

if (single)
  fl_USB(verbs,single,direction=direction,octant=octant,cut_thick=thick,tolerance=tolerance,cut_drift=drift,tongue=COLOR);
else
  layout([for(socket=FL_USB_DICT) fl_width(socket)], 10)
    fl_USB(verbs,FL_USB_DICT[$i],direction=direction,octant=octant,cut_thick=thick,tolerance=tolerance,cut_drift=drift,tongue=COLOR);
