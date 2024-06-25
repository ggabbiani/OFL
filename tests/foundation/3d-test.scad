/*
 * 3D foundation primitives tests.
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


include <../../lib/OFL/foundation/core.scad>
use <../../lib/OFL/foundation/3d-engine.scad>


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
SHOW_DIMENSIONS = false;


/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD   = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


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



/* [3ds] */

SHAPE   = "cube";     // [cube, cylinder, prism, sphere, pyramid]
// Size for cube and sphere, bottom/top diameter and height for cylinder, bottom/top edge length and height for prism
SIZE    = [1,2,3];

/* [Prism] */

// Number of edges
N     = 3; // [3:10]


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS,dimensions=SHOW_DIMENSIONS);

fl_status();

// end of automatically generated code

verbs = fl_verbList([FL_ADD,FL_AXES,FL_BBOX]);

fl_trace("octant",octant);

if      (SHAPE == "cube"    )  fl_cube(verbs,size=SIZE,debug=debug,octant=octant,direction=direction);
else if (SHAPE == "sphere"  )  fl_sphere(verbs,d=SIZE,debug=debug,octant=octant,direction=direction);
else if (SHAPE == "cylinder")  fl_cylinder(verbs,d1=SIZE.x,d2=SIZE.y,h=SIZE.z,debug=debug,octant=octant,direction=direction);
else if (SHAPE == "prism"   )  fl_prism(verbs,n=N,l1=SIZE.x,l2=SIZE.y,h=SIZE.z,debug=debug,octant=octant,direction=direction);
else if (SHAPE == "pyramid" )  fl_pyramid(verbs,[[-1,-1],[+1,-1],[+1,+1],[-1,+1]], [0,0,2],debug=debug,octant=octant,direction=direction);
