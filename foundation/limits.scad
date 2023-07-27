/*!
 * Recommended settings for 3d printing properties
 * (limits taken from [Knowledge base | Hubs](https://www.hubs.com/knowledge-base/))
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <3d-engine.scad>
include <defs.scad>

// available 3d printing technologies
FL_TECH_SLS   = "Selective Laser sintering";
FL_TECH_FDM   = "Fused deposition modeling";
FL_TECH_SLA   = "Stereo lithography";
FL_TECH_MJ    = "Material jetting";
FL_TECH_BJ    = "Binder jetting";
FL_TECH_DMLS  = "Direct metal Laser sintering";

FL_TECHNOLOGIES = [
  FL_TECH_SLS,
  FL_TECH_FDM,
  FL_TECH_SLA,
  FL_TECH_MJ,
  FL_TECH_BJ,
  FL_TECH_DMLS,
];

// 3d printing property names

/*!
 * ![Supported walls](../../docs/pics/foundation/256x256/fig_Supported_walls.png)
 *
 * The minimum width of walls connected to the rest of the print on at least
 * two sides (mm).
 */
FL_LIMIT_SWALLS     = "Supported walls";
/*!
 * ![Unsupported walls](../../docs/pics/foundation/256x256/fig_Unsupported_walls.png)
 *
 * Unsupported walls are connected to the rest of the print on less than two
 * sides (mm).
 */
FL_LIMIT_UWALLS     = "Unsupported walls";
/*!
 * ![Support & overhangs](../../docs/pics/foundation/256x256/fig_Support_and_overhangs.png)
 *
 * Maximum angle a wall can be printed at without requiring support (degree).
 */
FL_LIMIT_OVERHANGS  = "Support & overhangs";
//! Features on the model that are raised or recessed below the model surface [mm,mm]
FL_LIMIT_DETAILS    = "Embossed & engraved details";
//! The span a technology can print without the need for support
FL_LIMIT_HBRIDGES   = "Horizontal Bridges";
//! Minimum diameter a technology can successfully print a hole
FL_LIMIT_HOLES      = "Holes";
//! The recommended clearance between two moving or connecting parts
FL_LIMIT_CLEARANCE  = "Connecting/moving parts";
//! The minimum diameter of escape holes to allow for the removal of build material
FL_LIMIT_ESCAPE     = "Escape holes";
//! Recommended minimum size of a feature to ensure it will not fail to print
FL_LIMIT_FEATURES   = "Minimum features";
//! Minimum diameter a pin can be printed at
FL_LIMIT_PIN        = "Pin diameter";
//! Expected tolerance (diameter accuracy) of a specific technology [mm,%]
FL_LIMIT_TOLERANCE  = "Tolerance";

//! this is the printing technology used
$fl_print_tech  = FL_TECH_FDM;

__FL_LIMITS__  = [
  [FL_TECH_FDM, [
    [FL_LIMIT_SWALLS,     0.8],
    [FL_LIMIT_UWALLS,     0.8],
    [FL_LIMIT_OVERHANGS,  45],
    [FL_LIMIT_DETAILS,    [0.6,2.00]],
    [FL_LIMIT_HBRIDGES,   10],
    [FL_LIMIT_HOLES,      2],
    [FL_LIMIT_CLEARANCE,  0.5],
    [FL_LIMIT_FEATURES,   2],
    [FL_LIMIT_PIN,        3],
    [FL_LIMIT_TOLERANCE,  [[-0.5,+0.5],[-0.5,+0.5]]],
    ]
  ],
  [FL_TECH_SLS, [
    [FL_LIMIT_SWALLS,     0.5],
    [FL_LIMIT_UWALLS,     1.0],
    [FL_LIMIT_OVERHANGS,  0],   // always required
    [FL_LIMIT_DETAILS,    0.4], // wide & high
    [FL_LIMIT_HOLES,      0.5],
    [FL_LIMIT_CLEARANCE,  0.5],
    [FL_LIMIT_ESCAPE,     4],
    [FL_LIMIT_FEATURES,   0.2],
    [FL_LIMIT_PIN,        0.5],
    [FL_LIMIT_TOLERANCE,  [[-0.5,+0.5],[-0.15,+0.15]]],
    ]
  ],
];

/*!
 * returns the corresponding recommended value for the «property» name of the
 * current $fl_technology.
 */
function fl_techLimit(name) = let(
  technology  = fl_property(__FL_LIMITS__,$fl_print_tech)
) fl_optProperty(technology,name);

module __fig_Supported_walls__() {
  T=1.5;
  l=10;
  $fl_technology=FL_TECH_FDM;
  fl_cube(size=[l,l,T], octant=+X+Z);
  fl_cube(size=[T,l,l], octant=+X+Z);
  #translate([T,0,T])
    fl_cube(size=[l-T,fl_techLimit(FL_LIMIT_SWALLS),l-T],octant=+X+Z);
}

module __fig_Unsupported_walls__() {
  T=1.5;
  l=10;
  $fl_technology=FL_TECH_FDM;
  fl_cube(size=[l,l,T], octant=+X+Z);
  #translate([0,0,T])
    fl_cube(size=[l,fl_techLimit(FL_LIMIT_SWALLS),l-T],octant=+X+Z);
}

module __fig_Support_and_overhangs__() {
  T=1.5;
  l=10;
  size=[10,10];
  alpha=90-fl_techLimit(FL_LIMIT_OVERHANGS);
  $fl_technology=FL_TECH_FDM;
  fl_color("DodgerBlue")
    translate(-fl_Y(T))
    fl_linear_extrude([-Y,0],T*10) {
      difference() {
        fl_square(size=size,quadrant=+X+Y);
        fl_ellipticSector(e=1.5*size, angles = [0,alpha], quadrant = +X+Y);
      }
    }
    fl_color("red")
    fl_linear_extrude([-Y,0],T)
    let(
      beta=alpha/2,
      e=sqrt(2)*(size+[T,T])
    ) {
    translate(fl_ellipseXY(e-[T,T]/2,angle=90-beta))
    rotate(-beta,FL_Z)
    polygon([[0,-T],[T,0],[0,+T]]);
      fl_ellipticArc(e=e,angles=[90,90-alpha],thick=T,$fn=100);
    }
}

// __fig_Support_and_overhangs__();
