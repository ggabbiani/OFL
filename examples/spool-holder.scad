include <../lib/OFL/foundation/hole.scad>
include <../lib/OFL/foundation/limits.scad>
include <../lib/OFL/vitamins/screw.scad>
include <../lib/OFL/artifacts/t-nut.scad>
include <../lib/OFL/artifacts/t-profiles.scad>

use <../lib/OFL/dxf.scad>

$fn         = 50;           // [3:100]

// max spooler width
MAX_SPOOLER_W = 80;
// T-slotted profile length
TSP_length   = 463;
TOLERANCE = true;
PARTS="side";     // [all,side,central,stopper]
MODE="assembly";  // [assembly,print me!]
SIDE_T  = 5;
FILAMENT_CENTRAL  = "DodgerBlue"; // [ignore,DodgerBlue,Blue,OrangeRed,SteelBlue]
FILAMENT_SIDE  = "SteelBlue";     // [ignore,DodgerBlue,Blue,OrangeRed,SteelBlue]

$fl_debug       = false;
SHOW_LABELS     = false;
SHOW_SYMBOLS    = false;

/* [Hidden] */

debug = fl_parm_Debug(labels=SHOW_LABELS,symbols=SHOW_SYMBOLS);

PLEXI_SZ  = [463,605,2.5];

// custom cross-section in NopSCADlib format
//                                            1   2     3      4   5     6     7    8    9   10   11
//                                            W   H     d1     d2  sq    cw   cwi   t    st  f    recess
TSP_section = fl_tsp_CrossSection([ "custom", 20, 20,  -5,    -3,   8,   6.2, 10.5, 2,   2,  1,   false ]);
tsp         = fl_tsp_TProfile(TSP_section,TSP_length);

tolerance   = TOLERANCE ? fl_techLimit(FL_LIMIT_CLEARANCE)/2 : 0;

NUT_wall    = fl_tsp_tabT(tsp)+2*tolerance;
NUT_base    = 1.0-tolerance/2;
NUT_cone    = 2.0-tolerance/2;
NUT_T       = [NUT_wall,NUT_base,NUT_cone];
NUT_opening = fl_tsp_chW(tsp)-2*tolerance;

screw       = M2_cap_screw;
scr_d       = 2*screw_radius(screw);
scr_head_d  = 2*screw_head_radius(screw);
scr_head_h  = screw_head_height(screw);
screw_side  = M4_cap_screw;
scr_side_d  = 2*screw_radius(screw_side);

// heuristic value: it works with M2 brass inserts
knut_hole_d = 2.8;

// T-slotted profile nominal size
TSP_nominal = fl_tsp_nominalSize(TSP_section);

// central block wall thickness (≥ insert hole ⌀ + 2*1.6mm)
BLK_wall = knut_hole_d + 2*1.6;
// central block size
BLK_size   = [
  NUT_opening/2+BLK_wall+tolerance+TSP_nominal/2,
  2*(tolerance+BLK_wall)+TSP_nominal,
  MAX_SPOOLER_W
];
echo(BLK_size=BLK_size);

nut = fl_TNut(NUT_opening,[fl_tsp_intChW(tsp),BLK_size.z],NUT_T);

// 1 T-slotted profile and 3 T-slotted nuts
module profile(verb="show",depth,tnuts=false) {
  fl_tProfile([FL_ADD,FL_LAYOUT],type=tsp,lay_surface=[-X,+Y,-Y],octant=+X,$FL_ADD=MODE=="assembly"?"ON":"OFF")
    translate(-(NUT_wall-tolerance)*$tsp_surface)
      if (tnuts)
        fl_tnut([FL_ADD],type=nut,octant=[undef,undef,0],direction=[+Z, fl_switch($tsp_surface,[[+Y,0],[-Y,180],[-X,90]])]);
}

module body(depth) {
  translate(-Z(depth/2))
    linear_extrude(depth)
      difference() {
        // + actual body cross-section
        let(thick = BLK_wall)
          translate(-X(thick+tolerance))
            fl_square(size=BLK_size,corners=fl_tsp_filletR(TSP_section)*4,quadrant=[1,0]);
        // - enlarged profile footprint cross-section
        translate(+X(TSP_nominal/2))
          fl_square(size=TSP_nominal+2*tolerance,corners=fl_tsp_filletR(TSP_section));
      }
}

// full length body with holes
module central(verb="show") {

  function holes() = let(
    depth = BLK_wall+fl_size(nut).y,
    d     = knut_hole_d,
    len_third = MAX_SPOOLER_W/3/2,
    holes = concat(
      // holes on -X surface
      [
        for(z=[-len_third,+len_third])
          let(normal=-X)
            fl_Hole([-(BLK_wall+tolerance),0,z],d=d,normal=normal,depth=depth,screw=screw)
      ],
      // holes on -Y surface
      [
        for(z=[-len_third,+len_third])
          let(normal=-Y)
            fl_Hole([BLK_size.y/2-BLK_wall-tolerance,-BLK_size.y/2,z],d=d,normal=normal,depth=depth,screw=screw)
      ],
      // holes on +Y surface
      [
        for(z=[-len_third,+len_third])
          let(normal=+Y)
            fl_Hole([BLK_size.y/2-BLK_wall-tolerance,+BLK_size.y/2,z],d=d,normal=normal,depth=depth,screw=screw)
      ]
    )
  ) holes;

  holes = holes();
  if (verb=="show")     {
    // fl_axes(50);
    body(BLK_size.z);
  } else if (verb=="drill") {
    fl_holes(holes);
    fl_lay_holes(holes)
      translate(NIL*$hole_n)
        fl_cylinder(h=scr_head_h,d=scr_head_d+tolerance,direction=[-$hole_n,0]);
  } else if (verb=="debug") {
    fl_hole_debug(holes,debug=debug);
  } else {
    assert(false,verb);
  }
}

// holding arm
module n_holding_arm(depth) {
  translate(-Z(depth/2))
      linear_extrude(depth) {
        hull() {
          let(thick = BLK_wall,corner=fl_tsp_filletR(TSP_section)*4)
            translate(-X(tolerance))
              fl_square(size=[thick+tolerance,BLK_size.y],quadrant=[-1,0]);
          translate(-X(140))
            fl_circle(r=6);
        }
      }
}

module holding_arm(depth) {
  rotate(180,Z)
    translate(-Z(depth/2))
      linear_extrude(depth)
        import("spool-holder-arm.dxf",layer="0");
}

// side part: body cross-section + holding arm
module side(verb="show",normal) {
  depth = SIDE_T;
  holes=let(d=scr_d) [
    fl_Hole([-140,0,0]+SIDE_T/2*normal,d=scr_side_d,normal=normal,depth=depth,screw=screw_side),
    fl_Hole([-BLK_wall/2,0,0]+SIDE_T/2*normal,d=d,normal=normal,depth=depth,screw=screw),
    fl_Hole([BLK_size.x/2-BLK_wall,(BLK_size.y-BLK_wall)/2,0]+SIDE_T/2*normal,d=d,normal=normal,depth=depth,screw=screw),
    fl_Hole([BLK_size.x/2-BLK_wall,-(BLK_size.y-BLK_wall)/2,0]+SIDE_T/2*normal,d=d,normal=normal,depth=depth,screw=screw)
  ];
  if (verb=="show") {
  // fl_axes(size = 10, reverse = false);
    body(SIDE_T);
    holding_arm(SIDE_T);
  } else if (verb=="drill") {
    fl_holes(holes,tolerance=2*tolerance);
    fl_lay_holes(holes) {
      // inserts hole
      translate(-(SIDE_T-NIL)*$hole_n)
        fl_cylinder(h=2*SIDE_T,d=knut_hole_d,direction=[-$hole_n,0]);
    }
  } else if (verb=="debug") {
    fl_hole_debug(holes, screw=screw, debug=debug);
  } else {
    assert(false,verb);
  }
}

module filamentStopper() {
  fl_tube(r=6,h=2,thick=3.9,direction=[+X,0],octant=-Z);
}

rotate(90,Y) {
  difference() {
    union() {
      if (PARTS=="central"||PARTS=="all")
        fl_color(FILAMENT_CENTRAL)
          central();
      // one or two sides
      fl_color(FILAMENT_SIDE)
        if (PARTS=="side")
          side(normal=+Z);
        else if (PARTS=="all") {
          translate(Z(-(BLK_size.z+SIDE_T)/2)) side(normal=-Z);
          translate(Z(+(BLK_size.z+SIDE_T)/2)) side(normal=+Z);
        }
      // T-slotted nuts and profile
      profile(depth=BLK_size.z,tnuts=PARTS=="central"||PARTS=="all");
    }
    // - holes
    if (PARTS=="central"||PARTS=="all")
      central("drill");
    if (PARTS=="side")
      side("drill",normal=+Z);
    else {
      translate(Z(-(BLK_size.z+SIDE_T)/2)) side("drill",normal=-Z);
      translate(Z(+(BLK_size.z+SIDE_T)/2)) side("drill",normal=+Z);
    }
  }
  // symbols
  if (PARTS=="central"||PARTS=="all")
    central("debug");
  if (PARTS=="side")
    side("debug",normal=+Z);
  else if (PARTS=="all") {
    translate(Z(-(BLK_size.z+SIDE_T)/2)) side("debug",normal=-Z);
    translate(Z(+(BLK_size.z+SIDE_T)/2)) side("debug",normal=+Z);
  }
  if (PARTS=="stopper" || PARTS=="all")
    fl_color() translate(X(TSP_nominal)+Y(17+BLK_size.y))
      for(z=[0,PLEXI_SZ.z+2]) translate(X(z)) filamentStopper();

  // T-slotted nuts and profile
  profile(depth=BLK_size.z);

  if (MODE=="assembly")
    translate(+X(TSP_nominal)-Y(300)) let(
      direction = [-X,0],
      octant    = -Z+Y
    ) fl_color("Goldenrod",0.15)
        fl_cube([FL_ADD],size=PLEXI_SZ,direction=direction,octant=octant);
}

