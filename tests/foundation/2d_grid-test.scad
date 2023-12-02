/*
 * 2d grid test
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/foundation/unsafe_defs.scad>
use <../../lib/OFL/foundation/2d-engine.scad>
use <../../lib/OFL/foundation/3d-engine.scad>
use <../../lib/OFL/foundation/grid.scad>


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





/* [TEST] */
GRID_SIZE   = [100,100];
GRID_TYPE   = "quad";   // [quad,hex]
GRID_CLIP   = false;
// draw the grid clipping bounding box
GRID_BBOX   = false;
BORDER      = [1,1];    // [0:0.05:20]
TRIM_ORIGIN = [0,0];      // [-10:0.1:+10]
QUAD_STEP   = [6,6];  // [0:0.01:+10]
// radius of the polygon circumcircle used for creating 6 holes for each grid point
HEX_STEP    = 6;    // [0:0.1:10]

// hole vertex number
HOLE_VERTICES = 50; // [3:1:50]
// hole diameter
HOLE_D        = 4.4;
// drill shape rotation about +Z
ROTATION    = 0;    // [0:360]


/* [Hidden] */

fl_status();

// end of automatically generated code

sheet_metal = [[0,0],GRID_SIZE];
// the grid bounding box is equal to the sheet metal one reduced by border size
grid_bbox   = sheet_metal+[BORDER,-BORDER];

if (GRID_BBOX)
  translate(Z(NIL)) #fl_bb_add(grid_bbox,2d=true);

fl_color("silver")
  linear_extrude(0.5)
    difference() {
      // sheet metal
      fl_bb_add(sheet_metal,2d=true);
      // grid holes
      fl_grid_layout(
        origin  = TRIM_ORIGIN,
        step    = GRID_TYPE=="quad" ? QUAD_STEP : undef,
        r_step  = GRID_TYPE=="hex" ? HEX_STEP : undef,
        bbox    = grid_bbox,
        clip    = GRID_CLIP
      ) // hole shape
        rotate(ROTATION,+Z) fl_circle(d=HOLE_D,$fn=HOLE_VERTICES);
    }
