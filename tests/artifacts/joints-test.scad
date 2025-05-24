/*
 * Snap-fit joints test
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


include <../../lib/OFL/artifacts/joints.scad>


$fn            = 50;           // [3:100]
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER     = false;
// Default color for printable items (i.e. artifacts)
$fl_filament   = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
// When false polyRound() is disabled
$fl_polyround  = true;


/* [Debug] */

// -2⇒none, -1⇒all, [0..)⇒max depth allowed
$FL_TRACES        = -2;     // [-2:10]
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
// layout of predefined cutout shapes (+X,-X,+Y,-Y,+Z,-Z)
$FL_CUTOUT    = "OFF";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a footprint to scene, usually a simplified FL_ADD
$FL_FOOTPRINT = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


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


/* [Dimension Lines] */
VIEW_TYPE     = "other";    // [other,right,top,bottom,left,front,back]
DIM_MODE      = "full";     // [full,label,value,silent]
DIM_GAP       = 1;          // [1:.1:10]
DIM_W         = 0.05;       // [0.01:0.01:1]


/* [FACTORY] */

JOINT_SHAPE   = "rect";         // [rect,ring]
JOINT_TYPE    = "full scaled";  // [const,scaled thickness,scaled width,full scaled]
// "undef" or actual filet radius value (0 for 'no fillet')
JOINT_FILLET  = "undef";
ARM = 6;  // [0.1:0.1:10]
TOOTH = 2; // [0.1:0.1:5]
// thickness of arm at root
H0  = 2;  // [0.1:0.1:5]
// width of arm at root
B0  = 4; // [0.1:0.1:5]
UNDERCUT  = 1;  // [0.1:0.1:1]
// tooth angle
CANTILEVER_ANGLE  = 30; // [1:89]
// ring joint arc angle
ARM_THETA         = 90; // [1:360]
// ring joint external radius
ARM_R             = 4;

/* [CONTEXT] */

THICKNESS         = 2.5;  // [0:3]
TOLERANCE         = 0.1;  // [-0.5:0.1:0.5]
CUT_DRIFT         = 0;    // [0:5]
CUT_CLEARANCE     = 0;    // [-0.5:0.1:0.5]
CLIPPING_SECTION  = false;


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

$vpr  = fl_view(VIEW_TYPE);

verbs = fl_verbList([
  FL_ADD,
  FL_AXES,
  FL_BBOX,
  FL_CUTOUT,
  FL_FOOTPRINT,
]);

function fl_custom_num(value) =
  value=="undef" ? undef : is_num(value) ? value : assert(is_string(value),value) fl_atof(value);

fillet  = fl_custom_num(JOINT_FILLET);

$dim_mode   = DIM_MODE;
$dim_width  = DIM_W;

joint   =
  JOINT_SHAPE=="rect" ?
    fl_jnt_RectCantilever(
      alpha     = CANTILEVER_ANGLE,
      arm       = ARM,
      tooth     = TOOTH,
      h         = JOINT_TYPE=="scaled thickness" || JOINT_TYPE=="full scaled" ? [H0,H0/2] : H0,
      b         = JOINT_TYPE=="scaled width"     || JOINT_TYPE=="full scaled" ? [B0,B0/4] : B0,
      undercut  = UNDERCUT
    ) :
    JOINT_SHAPE=="ring" ?
      fl_jnt_RingCantilever(
        arm_l     = ARM,
        tooth_l   = TOOTH,
        h         = JOINT_TYPE=="scaled thickness" || JOINT_TYPE=="full scaled" ? [H0,H0/2] : H0,
        theta     = ARM_THETA,
        undercut  = UNDERCUT,
        alpha     = CANTILEVER_ANGLE,
        r         = ARM_R
      ) :
      undef;
bbox  = fl_bb_corners(joint);

fl_jnt_joint(verbs, joint, octant=octant, direction=direction,
  cut_drift     = CUT_DRIFT,
  cut_clearance = CUT_CLEARANCE,
  fillet        = fillet,
  $fl_tolerance = TOLERANCE,
  $fl_thickness = THICKNESS+NIL
);

let(
  SZ_joint    = bbox[1]-bbox[0],
  SZ_cutting  = [SZ_joint.x*2,SZ_joint.y*4,20],
  SZ_surface  = [SZ_joint.x*2,SZ_joint.y*4,6]
) if (CLIPPING_SECTION)
  fl_color()
    intersection() {
      fl_cube(size=SZ_cutting,octant=-X, $FL_ADD="ON");
      difference() {
        // translate(+Z(bbox[1].z+NIL))
          fl_cube(size=SZ_surface, $FL_ADD="ON");
        fl_jnt_joint(FL_CUTOUT, joint, octant=octant, direction=direction,
          cut_drift     = CUT_DRIFT,
          cut_clearance = CUT_CLEARANCE,
          $fl_tolerance = TOLERANCE,
          $fl_thickness = THICKNESS+NIL,
          $FL_CUTOUT="ON"
        );
      }
    }

