/*
 * Vitamins test template.
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
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
include <../../foundation/incs.scad>
include <../../vitamins/incs.scad>

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
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
CUTOUT    = "OFF";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [HDMI] */

SHOW        = "ALL"; // [ALL,FL_HDMI_TYPE_A,FL_HDMI_TYPE_C,FL_HDMI_TYPE_D]
// tolerance used during FL_CUTOUT
CO_TOLERANCE   = 0;  // [0:0.1:5]
// thickness for FL_CUTOUT
CO_LEN  = 2.5;
// translation applied to cutout
CO_DRIFT = 0; // [-5:0.05:5]

/* [Hidden] */

module __test__() {
  direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
  octant    = PLACE_NATIVE  ? undef : OCTANT;
  cutout    = CUTOUT!="OFF" ? CO_LEN : undef;
  tolerance = CUTOUT!="OFF" ? CO_TOLERANCE : undef;
  drift     = CUTOUT!="OFF" ? CO_DRIFT : undef;

  verbs=[
    if (ADD!="OFF")       FL_ADD,
    if (AXES!="OFF")      FL_AXES,
    if (BBOX!="OFF")      FL_BBOX,
    if (CUTOUT!="OFF")    FL_CUTOUT,
  ];
  // target object(s)
  single  = SHOW=="FL_HDMI_TYPE_A"  ? FL_HDMI_TYPE_A 
          : SHOW=="FL_HDMI_TYPE_C"  ? FL_HDMI_TYPE_C 
          : SHOW=="FL_HDMI_TYPE_D"  ? FL_HDMI_TYPE_D
          : undef;

  fl_trace("verbs",verbs);
  // $FL_ADD=ADD;$FL_ASSEMBLY=ASSEMBLY;$FL_AXES=AXES;$FL_BBOX=BBOX;$FL_CUTOUT=CUTOUT;$FL_DRILL=DRILL;$FL_FOOTPRINT=FPRINT;$FL_LAYOUT=LAYOUT;$FL_PAYLOAD=PLOAD;
  if (single)
    fl_hdmi(
      verbs,single,direction=direction,octant=octant,cut_thick=cutout,cut_tolerance=tolerance,co_drift=drift,
      $FL_ADD=ADD,$FL_AXES=AXES,$FL_BBOX=BBOX,$FL_CUTOUT=CUTOUT
    );
  else
    layout([for(socket=FL_HDMI_DICT) fl_width(socket)], 10)
      fl_hdmi(
        verbs,FL_HDMI_DICT[$i],direction=direction,octant=octant,cut_thick=cutout,cut_tolerance=tolerance,co_drift=drift,
        $FL_ADD=ADD,$FL_AXES=AXES,$FL_BBOX=BBOX,$FL_CUTOUT=CUTOUT
      );
}

__test__();