/*
 * T-slot structural framing tests.
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


include <../../lib/OFL/artifacts/t-nut.scad>
include <../../lib/OFL/artifacts/t-profiles.scad>


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
// adds a footprint to scene, usually a simplified FL_ADD
$FL_FOOTPRINT = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of user passed accessories (like alternative screws)
$FL_LAYOUT    = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

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



/* [T Profile] */

PROFILE     = "E1515"; // [E1515,E2020,E2020t,E2040,E2060,E2080,E3030,E3060,E4040,E4040t,E4080]
LENGTH      = 50;
CORNER_HOLE = false;
TOLERANCE   = 0.1;  // [0:0.1:1]


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

verbs = fl_verbList([FL_ADD,FL_AXES,FL_BBOX,FL_FOOTPRINT,FL_LAYOUT]);

xsec  = fl_switch(PROFILE,[
  ["E1515"  ,FL_TSP_E1515   ],
  ["E2020"  ,FL_TSP_E2020   ],
  ["E2020t" ,FL_TSP_E2020t  ],
  ["E2040"  ,FL_TSP_E2040   ],
  ["E2060"  ,FL_TSP_E2060   ],
  ["E2080"  ,FL_TSP_E2080   ],
  ["E3030"  ,FL_TSP_E3030   ],
  ["E3060"  ,FL_TSP_E3060   ],
  ["E4040"  ,FL_TSP_E4040   ],
  ["E4040t" ,FL_TSP_E4040t  ],
  ["E4080"  ,FL_TSP_E4080   ]
]);

profile = fl_tsp_TProfile(xsec,LENGTH,CORNER_HOLE);

fl_tProfile(verbs,profile,lay_surface=[+X],direction=direction,octant=octant,$fl_tolerance=TOLERANCE)
  echo($tsp_size=$tsp_size,$tsp_tabT=$tsp_tabT)
  translate(-X($tsp_tabT))
    fl_tnut(type=FL_TNUT_M5_CS,octant=[undef,undef,0],direction=[Z,-90],$FL_ADD=$FL_LAYOUT);

