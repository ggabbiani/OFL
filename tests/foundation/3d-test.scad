/*
 * 3D foundation primitives tests.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../foundation/3d.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$fl_debug   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// Default color for printable items (i.e. artifacts)
$fl_filament  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES  = -2;     // [-2:10]

/* [Supported verbs] */

// adds shapes to scene.
ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [+1,+1,+1];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [3ds] */

SHAPE   = "cube";     // ["cube", "cylinder", "prism", "sphere"]
// Size for cube and sphere, bottom/top diameter and height for cylinder, bottom/top edge length and height for prism
SIZE    = [1,2,3];

/* [Prism] */

// Number of edges
N     = 3; // [3:10]

/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
verbs=[
  if (ADD!="OFF")   FL_ADD,
  if (AXES!="OFF")  FL_AXES,
  if (BBOX!="OFF")  FL_BBOX,
];
fl_trace("PLACE_NATIVE",PLACE_NATIVE);
fl_trace("octant",octant);

fl_color()
  if      (SHAPE == "cube"    )  fl_cube(verbs,size=SIZE,octant=octant,direction=direction,$FL_ADD=ADD,$FL_AXES=AXES,$FL_BBOX=BBOX);
  else if (SHAPE == "sphere"  )  fl_sphere(verbs,d=SIZE,octant=octant,direction=direction,$FL_ADD=ADD,$FL_AXES=AXES,$FL_BBOX=BBOX);
  else if (SHAPE == "cylinder")  fl_cylinder(verbs,d1=SIZE.x,d2=SIZE.y,h=SIZE.z,octant=octant,direction=direction,$FL_ADD=ADD,$FL_AXES=AXES,$FL_BBOX=BBOX);
  else if (SHAPE == "prism"   )  fl_prism(verbs,n=N,l1=SIZE.x,l2=SIZE.y,h=SIZE.z,octant=octant,direction=direction,$FL_ADD=ADD,$FL_AXES=AXES,$FL_BBOX=BBOX);
