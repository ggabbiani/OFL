/*
 * High-level management engine for OFL types.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <core.scad>

use <3d-engine.scad>
use <bbox-engine.scad>
use <mngm-engine.scad>

/*!
 * This module manages OFL types leveraging children implementation of the
 * actual engine while decoupling standard OFL parameters manipulation from
   other engine specific ones.
   Essentially it uses children module in place of not yet implemented module
   literals, simplifying the new type module writing.

   A typical use of this high-level management module is the following:

       // this engine is called one for every verb passed to fl_polymorph{}
       module engine(thick) let(
         ...
       ) if ($this_verb==FL_ADD)
         ...;

         else if ($this_verb==FL_AXES)
           fl_doAxes($this_size,$this_direction);

         else if ($this_verb==FL_BBOX)
         ...;

         else if ($this_verb==FL_CUTOUT)
         ...;

         else if ($this_verb==FL_DRILL)
         ...;

         else if ($this_verb==FL_LAYOUT)
         ...;

         else if ($this_verb==FL_MOUNT)
         ...;

         else
           assert(false,str("***OFL ERROR***: unimplemented verb ",$this_verb));

       // this is the actual object definition as a list of [key,values] items
       object = let(
         ...
       ) [
         fl_native(value=true),
         ...
       ];

       fl_polymorph(verbs,object,direction=direction,octant=octant)
         engine(thick=T)
           // child passed to engine for further manipulation (ex. during FL_LAYOUT)
           fl_cylinder(h=10,r=screw_radius($iec_screw),octant=-Z);
 *
 * Children context:
 *
 * - $this
 * - $this_verb       : current verb passed to children
 * - $this_size       : object 3d dimensions
 * - $this_bbox       : bounding box corners in [low,high] format
 * - $this_direction  : orientation in [director,rotation] format
 * - $this_octant     : positioning octant
 * - $this_debug      : debug parameters
 */
module fl_polymorph(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  this,
  //! see constructor fl_parm_Debug()
  debug,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant,
) assert(is_list(verbs)||is_string(verbs),verbs) let(
  bbox  = fl_bb_corners(this),
  size  = fl_bb_size(this),
  D     = direction ? fl_direction(direction)  : FL_I,
  M     = fl_octant(octant,bbox=bbox)
) fl_manage(verbs,M,D)
    fl_modifier($modifier) let(
      $this_verb      = $verb,
      $this           = this,
      $this_size      = size,
      $this_bbox      = bbox,
      $this_direction = direction,
      $this_octant    = octant,
      $this_debug     = debug
    ) children();
