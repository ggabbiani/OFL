/*
 * fl_polymorph{} usage example, implementing an NopSCADlib IEC wrapper engine.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/iecs.scad>

include <../../lib/OFL/vitamins/screw.scad>

use <../../lib/OFL/foundation/polymorphic-engine.scad>

$fn           = 50;   // [3:100]
// When true, disables epsilon corrections
$FL_RENDER    = false;
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES    = -2;   // [-2:10]
$fl_debug     = false;
SHOW_LABELS   = false;
SHOW_SYMBOLS  = false;
$fl_filament  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
$FL_ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
$FL_CUTOUT    = "OFF";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
$FL_FOOTPRINT = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// mount shape through predefined screws
$FL_MOUNT      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a box representing the payload of the shape
$FL_PAYLOAD   = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// add symbols and labels usually for debugging
$FL_SYMBOLS   = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Polymorph] */

T             = 2.5;  // [0:0.1:5]

/* [Hidden] */

fl_status();
direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

verbs = fl_verbList([FL_ADD,FL_ASSEMBLY,FL_AXES,FL_BBOX,FL_CUTOUT,FL_DRILL,FL_FOOTPRINT,FL_LAYOUT,FL_MOUNT,FL_PAYLOAD,FL_SYMBOLS]);

module engine(thick) let(
  nop   = fl_nopSCADlib($this),
  screw = iec_screw(nop)
) if ($this_verb==FL_ADD)
    iec(nop);

  else if ($this_verb==FL_AXES)
    fl_doAxes($this_size,$this_direction);

  else if ($this_verb==FL_BBOX)
    fl_bb_add(corners=$this_bbox,$FL_ADD=$FL_BBOX);

  else if ($this_verb==FL_CUTOUT) {
    assert(is_num(thick))
    if (thick>=0)
      iec_holes(nop, h=thick+iec_flange_t(nop));

  } else if ($this_verb==FL_DRILL) {
    assert(is_num(thick))
    if (thick)
      iec_screw_positions(nop)
        fl_screw(FL_DRILL,screw,thick=thick);

  } else if ($this_verb==FL_LAYOUT) {
    translate(+Z(iec_flange_t(nop)))
      iec_screw_positions(nop) let(
        $iec_screw = screw
      ) children();

  } else if ($this_verb==FL_MOUNT)
    assert(is_num(thick)&&thick>=0)
    iec_assembly(nop, thick);
  else
    assert(false,str("***OFL ERROR***: unimplemented verb ",$this_verb));

iec = let(
  nop     = IEC_inlet,
  w       = iec_width(nop),
  h       = iec_flange_h(nop),
  spades  = iec_spades(nop)
) [
  fl_native(value=true),
  fl_bb_corners(value=[[-w/2,-h/2,-iec_depth(nop)-spades[0][1]],[+w/2,+h/2,+iec_flange_t(nop)+iec_bezel_t(nop)]]),
  fl_nopSCADlib(value=nop),
  fl_screw(value=iec_screw(nop)),
  fl_engine(value="iec"),
];

fl_polymorph(verbs,iec,direction=direction,octant=octant)
  engine(thick=T)
    fl_cylinder(h=10,r=screw_radius($iec_screw),octant=-Z);
