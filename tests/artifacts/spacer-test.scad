/*
 * Spacers test file
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


include <../../lib/OFL/artifacts/spacer.scad>
include <../../lib/OFL/vitamins/countersinks.scad>


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
// layout of predefined auxiliary shapes (like predefined screws)
$FL_ASSEMBLY  = "ON";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
$FL_FOOTPRINT = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// mount shape through predefined screws
$FL_MOUNT     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


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



/* [FACTORY] */

// height
H_MIN     = 9;  // [0:0.1:15]
// minimum external ⌀
D_MIN     = 12;  // [0:0.1:20]
// nominal screw size
SCREW_SIZE  = "4";       // [no screw,2,2.5,3,4,5,6,8]
KNUT_TYPE   = "spiral";  // [none, linear, spiral]
// no fillet if zero
FILLET  = 1;  // [0:0.1:5]

ANCHOR_X_POS  = false;
ANCHOR_X_NEG  = false;
ANCHOR_Y_POS  = false;
ANCHOR_Y_NEG  = false;
ANCHOR_Z_NEG  = true;

/* [TEST] */

// thickness on +Z axis
THICK_POSITIVE = 1.6;      // [0:0.1:10]
// thickness on -Z axis
THICK_NEGATIVE = 2.5;      // [0:0.1:10]


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

anchor  = [
  if (ANCHOR_X_POS) +X,
  if (ANCHOR_X_NEG) -X,
  if (ANCHOR_Y_POS) +Y,
  if (ANCHOR_Y_NEG) -Y,
  if (ANCHOR_Z_NEG) -Z,
];

verbs = fl_verbList([
  FL_ADD,
  FL_ASSEMBLY,
  FL_AXES,
  FL_BBOX,
  FL_DRILL,
  FL_FOOTPRINT,
  FL_LAYOUT,
  FL_MOUNT,
]);
thickness = let(t= [
  if (THICK_NEGATIVE) -THICK_NEGATIVE,
  if (THICK_POSITIVE) +THICK_POSITIVE
]) t ? t : undef;

scr_inventory = screw_lists[0]; // cap screws from NopSCADlib
scr_size      = SCREW_SIZE!="no screw" ? fl_atof(SCREW_SIZE) : undef;
screw         = scr_size ? fl_list_filter(scr_inventory,fl_screw_byNominal(scr_size))[0] : undef;
knut          = KNUT_TYPE!="none" ? assert(scr_size,"***TEST ERROR***: specify a screw size for knut") fl_knut_shortest(fl_knut_find(thread=KNUT_TYPE,nominal=scr_size)) : undef;
assert(KNUT_TYPE=="none"||knut,str("***TEST ERROR***: no M",SCREW_SIZE," ",KNUT_TYPE," knurl nut found in inventory"));
cs            = let(d=knut?fl_nominal(knut):screw?fl_screw_nominal(screw):undef)
                d ? fl_cs_search(d=d)[0] : undef;

spacer = fl_Spacer(h_min=H_MIN,d_min=D_MIN,screw_size=scr_size,knut=knut);
fl_spacer(verbs,spacer,thick=thickness,anchor=anchor,fillet=FILLET,octant=octant,direction=direction)
  if ($spc_verb==FL_LAYOUT)
    /*
     * CHILDREN LAYOUT: by default spacers layout children on the top of the ±Z
     * surfaces.
     */
    translate($spc_director*($spc_thick))
      if ($spc_thick)
        let(l=1.5*fl_spc_d(spacer))
          fl_cube(size=[l,l,$spc_thick],octant=-$spc_director,$FL_ADD=$FL_LAYOUT);
  else if ($spc_verb==FL_MOUNT) // SCREW MOUNT
    let(
      htyp    = screw_head_type(screw),
      washer  = (htyp==hs_cs||htyp==hs_cs_cap) ? "no" : "nylon"
    ) fl_screw(FL_DRAW,screw,$fl_thickness=$spc_thickness,washer=washer,$FL_ADD=$FL_MOUNT,$FL_ASSEMBLY=$FL_MOUNT);

