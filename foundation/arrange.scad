/*
 * Created on Thu Jul 08 2021.
 *
 * Copyright © 2021 Giampiero Gabbiani.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL).
 *
 * OFL is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * OFL is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with OFL.  If not, see <http: //www.gnu.org/licenses/>.
 */

include <defs.scad>

$fn         = 50;           // [3:50]
$FL_TRACE   = false;
$FL_RENDER  = false;
$FL_DEBUG   = false;

BBOX        = false;

/* [Layout] */

GAP           = 5;
AXIS          = "+X"; // [+X, -X, +Y, -Y, +Z, -Z]

/* [Hidden] */

module __test__() {
  psu= [
    ["name", "PSU MeanWell RS-25-5 25W 5V 5A"],
    ["bounding corners",   [
      [-51/2, -11,   0],  // negative corner
      [+51/2,  78,  28],  // positive corner
    ]],
  ];

  hd = [
    ["name",  "Samsung V-NAND SSD 860 EVO"],
    ["bounding corners",   [
      [-69/2,-(13+3),0],  // negative corner
      [69/2,100,6.7],     // positive corner
    ]],
  ];

  rpi = [
    ["name",                "RPI4-MODBP-8GB"],
    ["bounding corners",   [
      [-56/2-2.5,  -3, -1.5],     // negative corner
      [+56/2,     85,  -1.5+16],  // positive corner
    ]],
  ];

  types   = [hd,hd,rpi];
  type    = types[0];
  axis    = AXIS=="+X" ? +FL_X : AXIS=="-X" ? -FL_X : AXIS=="+Y" ? +FL_Y : AXIS=="-Y" ? -FL_Y : AXIS=="+Z" ? +FL_Z : -FL_Z;
  trans   = ((AXIS=="+X"||AXIS=="-X") ? bb_corners(type)[0].x 
          : AXIS=="+Y" ? +bb_corners(type)[0].y 
          : AXIS=="-Y" ? -bb_corners(type)[1].y 
          : AXIS=="+Z" ? +bb_corners(type)[0].z 
          : AXIS=="-Z" ? -bb_corners(type)[1].z
          : assert(false,"Unmanaged layout axis")
          ) * axis;
  // center  = lay_bb_center(axis,GAP,types);

  color("red") translate(trans)
    if      (axis==+FL_X||axis==-FL_X) fl_vector(lay_bb_size(axis,GAP,types).x*axis);
    else if (axis==+FL_Y||axis==-FL_Y) fl_vector(lay_bb_size(axis,GAP,types).y*axis);
    else if (axis==+FL_Z||axis==-FL_Z) fl_vector(lay_bb_size(axis,GAP,types).z*axis);

  arrange(axis,GAP,types,draw=BBOX) { 
    // let(type=psu) translate(bb_center(type)) %cube(size=bb_size(type), center=true);
    let(type=hd ) translate(bb_center(type)) %cube(size=bb_size(type), center=true);
    let(type=hd ) translate(bb_center(type)) %cube(size=bb_size(type), center=true);
    let(type=rpi) translate(bb_center(type)) %cube(size=bb_size(type), center=true);
  }

  fl_trace("axis",     axis);
  fl_trace("corners",  lay_bb_corners(axis,GAP,types));
  fl_trace("size",     lay_bb_size(axis,GAP,types) );

  fl_trace("Originals", [bb_corners(hd)]);
  fl_trace("Aligned", lay_align_many(undef,[hd]));
}

//**** Bounding Box ***********************************************************

function bb_corners(type) = fl_get(type,"bounding corners");

function bb_new(negative=[0,0,0],size=[0,0,0],positive) = [["bounding corners", [negative,positive==undef?negative+size:positive]]];

// bounding box size from bounding corners
function bb_size(type) = 
  assert(type!=undef)
  let(corner=bb_corners(type)) 
  assert(corner!=undef)
  corner[1]-corner[0];

// bounding box translation
function bb_center(type) = let(corner=bb_corners(type),size=bb_size(type)) corner[0]+size/2;

// converte un bounding box in formato canonico (due bounding corners) nei suoi quattro vertici
// a,b,c,d sul piano individuato dal negative corner
// A,B,C,D sul piano individuato dal positive corner
function bb_vertices(bbcorners) = let(
  a   = bbcorners[0]
  ,C  = bbcorners[1]
  ,b  = [C.x,a.y,C.z]
  ,c  = [C.x,a.y,C.z]
  ,d  = [a.x,a.y,C.z]
  ,A  = [a.x,C.y,a.z]
  ,B  = [C.x,C.y,a.z]
  ,D  = [a.x,C.y,C.z]
) [a,b,c,d,A,B,C,D];

// Trasforma un bounding box in forma canonica (bounding corners) 
function bb_transform(M,bbcorners) = let(
  vertices  = [for(v=bb_vertices(bbcorners)) fl_transform(M,v)]
  ,Xs       = [for(v=vertices) v.x]
  ,Ys       = [for(v=vertices) v.y]
  ,Zs       = [for(v=vertices) v.z]
) [[min(Xs),min(Ys),min(Zs)],[max(Xs),max(Ys),max(Zs)]];

//**** layout *****************************************************************
// function lay_bb_sizes(types) = let() [for(t=types) bb_size(t)];

function lay_align_many(axis,types) = [
  for(t=types) let(c=bb_corners(t)) [[c[0].x,0,c[0].z],[c[1].x,c[1].y-c[0].y,c[1].z]]
];

/**
 * creates a group with the resulting bounding box corners of a layout
 */
function lay_group(axis,gap,types) = [["bounding corners", lay_bb_corners(axis,gap,types)]];

/**
 * returns the bounding box corners of a layout
 */
function lay_bb_corners(axis,gap,types) = let(
  n     = len(types),
  type  = types[0],
  M     = [
    max([for(t=types) bb_corners(t)[1].x]),
    max([for(t=types) bb_corners(t)[1].y]),
    max([for(t=types) bb_corners(t)[1].z])
  ],
  m     = [
    min([for(t=types) bb_corners(t)[0].x]),
    min([for(t=types) bb_corners(t)[0].y]),
    min([for(t=types) bb_corners(t)[0].z])
  ]
) (axis==+FL_X) ? [
    [bb_corners(type)[0].x,m.y,m.z],  // negative
    [bb_corners(type)[1].x+(n>1?fl_accum([for(t=fl_sub(types,1,n)) bb_size(t).x]):0)+(n-1)*gap,M.y,M.z] // positive
  ]
: (axis==-FL_X) ? [
    [bb_corners(type)[0].x-(n>1?fl_accum([for(t=fl_sub(types,1,n)) bb_size(t).x]):0)-(n-1)*gap,m.y,m.z],  // negative
    [bb_corners(type)[1].x,M.y,M.z] // positive
  ]
: (axis==+FL_Y) ? [
    [m.x,bb_corners(type)[0].y,m.z],  // negative
    [M.x,bb_corners(type)[1].y+(n>1?fl_accum([for(t=fl_sub(types,1,n)) bb_size(t).y]):0)+(n-1)*gap,M.z] // positive
  ]
: (axis==-FL_Y) ? [
    [m.x,bb_corners(type)[0].y-(n>1?fl_accum([for(t=fl_sub(types,1,n)) bb_size(t).y]):0)-(n-1)*gap,m.z],// negative
    [M.x,bb_corners(type)[1].y,M.z] // positive
  ]
: (axis==+FL_Z) ? [
    [m.x,m.y,bb_corners(type)[0].z,],// negative corner
    [M.x,M.y,bb_corners(type)[1].z+(n>1?fl_accum([for(t=fl_sub(types,1,n)) bb_size(t).z]):0)+(n-1)*gap,]// positive corner
  ]
: (axis==-FL_Z) ? [
    [m.x,m.y,bb_corners(type)[0].z-(n>1?fl_accum([for(t=fl_sub(types,1,n)) bb_size(t).z]):0)-(n-1)*gap,],// negative
    [M.x,M.y,bb_corners(type)[1].z,]// positive
  ]
: assert(false,"Unmanaged layout axis");

function lay_bb_size(axis,gap,types) = let(c = lay_bb_corners(axis,gap,types)) c[1]-c[0];

module arrange(axis,gap,types,draw=false) {  
  fl_trace("$children",$children);
  fl_trace("len(types)",len(types));
  assert($children>=len(types),str("$children (",$children,") != len(types) (",len(types),")"));
  
  // $FL_TRACE=true;
  // fl_align on +FL_X axis
  module xp(types) {
    fl_trace("$children",$children);
    fl_trace("len(types)",len(types));
    assert($children>=len(types));

    type    = types[0];
    corners = bb_corners(type);
    n       = len(types);

    translate(fl_X(-corners[0].x)) {
      /* let(center=bb_center(type)) translate([0,-center.y,-center.z]) */ children(0);
      if (n>1) {
        others = fl_sub(types,1,n);
        translate(fl_X(corners[1].x+gap))
          xp(others)
            // for(i=[1:n-1]) children(i);
            {
            children(1);
            if (len(types)>2) children(2);
            if (len(types)>3) children(3);
            if (len(types)>4) children(4);
            if (len(types)>5) children(5);
            if (len(types)>6) children(6);
            if (len(types)>7) children(7);
            if (len(types)>8) children(8);
            if (len(types)>9) children(9);
            if (len(types)>10) children(10);
            if (len(types)>11) children(11);
            if (len(types)>12) children(12);
            if (len(types)>13) children(13);
            if (len(types)>14) children(14);
            if (len(types)>15) children(15);
            if (len(types)>16) children(16);
            if (len(types)>17) children(17);
            if (len(types)>18) children(18);
            if (len(types)>19) children(19);
            if (len(types)>20) children(20);
          }
      }
    }
  }

  // fl_align on -FL_X axis
  module xn(types) {
    type    = types[0];
    corners = bb_corners(type);
    n       = len(types);

    translate(-fl_X(corners[1].x)) {
      /* let(center=bb_center(type)) translate([0,-center.y,-center.z]) */ children(0);
      if (n>1) {
        others = fl_sub(types,1,n);
        translate(fl_X(corners[0].x-gap))
          xn(others) {
            children(1);
            if (len(types)>2) children(2);
            if (len(types)>3) children(3);
            if (len(types)>4) children(4);
            if (len(types)>5) children(5);
            if (len(types)>6) children(6);
            if (len(types)>7) children(7);
            if (len(types)>8) children(8);
            if (len(types)>9) children(9);
            if (len(types)>10) children(10);
            if (len(types)>11) children(11);
            if (len(types)>12) children(12);
            if (len(types)>13) children(13);
            if (len(types)>14) children(14);
            if (len(types)>15) children(15);
            if (len(types)>16) children(16);
            if (len(types)>17) children(17);
            if (len(types)>18) children(18);
            if (len(types)>19) children(19);
            if (len(types)>20) children(20);
          }
      }
    }
  }

  // fl_align on +FL_Y axis
  module yp(types) {
    type    = types[0];
    corners = bb_corners(type);
    n       = len(types);

    translate(-fl_Y(corners[0].y)) {
      /* let(center=bb_center(type)) translate([-center.x,0,-center.z]) */ children(0);
      if (len(types)>1) {
        others = [for(t=[1:len(types)-1]) types[t]];
        translate(fl_Y(corners[1].y+gap))
          yp(others) {
            children(1);
            if (len(types)>2) children(2);
            if (len(types)>3) children(3);
            if (len(types)>4) children(4);
            if (len(types)>5) children(5);
            if (len(types)>6) children(6);
            if (len(types)>7) children(7);
            if (len(types)>8) children(8);
            if (len(types)>9) children(9);
            if (len(types)>10) children(10);
            if (len(types)>11) children(11);
            if (len(types)>12) children(12);
            if (len(types)>13) children(13);
            if (len(types)>14) children(14);
            if (len(types)>15) children(15);
            if (len(types)>16) children(16);
            if (len(types)>17) children(17);
            if (len(types)>18) children(18);
            if (len(types)>19) children(19);
            if (len(types)>20) children(20);
          }
      }
    }
  }

  // fl_align on -FL_Y axis
  module yn(types) {
    type    = types[0];
    corners = bb_corners(type);
    n       = len(types);

    translate(-fl_Y(corners[1].y)) {
      /* let(center=bb_center(type)) translate([-center.x,0,-center.z]) */ children(0);
      if (len(types)>1) {
        others = [for(t=[1:len(types)-1]) types[t]];
        translate(fl_Y(corners[0].y-gap))
          yn(others) {
            children(1);
            if (len(types)>2) children(2);
            if (len(types)>3) children(3);
            if (len(types)>4) children(4);
            if (len(types)>5) children(5);
            if (len(types)>6) children(6);
            if (len(types)>7) children(7);
            if (len(types)>8) children(8);
            if (len(types)>9) children(9);
            if (len(types)>10) children(10);
            if (len(types)>11) children(11);
            if (len(types)>12) children(12);
            if (len(types)>13) children(13);
            if (len(types)>14) children(14);
            if (len(types)>15) children(15);
            if (len(types)>16) children(16);
            if (len(types)>17) children(17);
            if (len(types)>18) children(18);
            if (len(types)>19) children(19);
            if (len(types)>20) children(20);
          }
      }
    }
  }

  // fl_align on +FL_Z axis
  module zp(types) {
    type    = types[0];
    corners = bb_corners(type);
    n       = len(types);
    // fl_trace("type",type);
    // fl_trace("corners",corners);

    translate(-fl_Z(corners[0].z)) {
      /* let(center=bb_center(type)) translate([-center.x,-center.y,0]) */ children(0);
      if (len(types)>1) {
        others = [for(t=[1:len(types)-1]) types[t]];
        // fl_trace("corners[1].z",corners[1].z);
        // fl_trace("FL_Z delta",corners[1].z+gap);
        translate(fl_Z(corners[1].z+gap))
          zp(others) {
            children(1);
            if (len(types)>2) children(2);
            if (len(types)>3) children(3);
            if (len(types)>4) children(4);
            if (len(types)>5) children(5);
            if (len(types)>6) children(6);
            if (len(types)>7) children(7);
            if (len(types)>8) children(8);
            if (len(types)>9) children(9);
            if (len(types)>10) children(10);
            if (len(types)>11) children(11);
            if (len(types)>12) children(12);
            if (len(types)>13) children(13);
            if (len(types)>14) children(14);
            if (len(types)>15) children(15);
            if (len(types)>16) children(16);
            if (len(types)>17) children(17);
            if (len(types)>18) children(18);
            if (len(types)>19) children(19);
            if (len(types)>20) children(20);
          }
      }
    }
  }

  // fl_align on -FL_Z axis
  module zn(types) {
    type    = types[0];
    corners = bb_corners(type);
    n       = len(types);

    translate(-fl_Z(corners[1].z)) {
      /* let(center=bb_center(type)) translate([-center.x,-center.y,0]) */ children(0);
      if (len(types)>1) {
        others = [for(t=[1:len(types)-1]) types[t]];
        remaining_names = [for(t=others) fl_name(t)];
        translate(fl_Z(corners[0].z-gap))
          zn(others) {
            children(1);
            if (len(types)>2) children(2);
            if (len(types)>3) children(3);
            if (len(types)>4) children(4);
            if (len(types)>5) children(5);
            if (len(types)>6) children(6);
            if (len(types)>7) children(7);
            if (len(types)>8) children(8);
            if (len(types)>9) children(9);
            if (len(types)>10) children(10);
            if (len(types)>11) children(11);
            if (len(types)>12) children(12);
            if (len(types)>13) children(13);
            if (len(types)>14) children(14);
            if (len(types)>15) children(15);
            if (len(types)>16) children(16);
            if (len(types)>17) children(17);
            if (len(types)>18) children(18);
            if (len(types)>19) children(19);
            if (len(types)>20) children(20);
          }
      }
    }
  }

  if        (axis==+FL_X) translate(+bb_corners(types[0])[0].x*axis) xp(types) {
    // for_intersection(i=[0:len(types)-1])
    //   children(i);
    if (len(types)>0) children(0);
    if (len(types)>1) children(1);
    if (len(types)>2) children(2);
    if (len(types)>3) children(3);
    if (len(types)>4) children(4);
    if (len(types)>5) children(5);
    if (len(types)>6) children(6);
    if (len(types)>7) children(7);
    if (len(types)>8) children(8);
    if (len(types)>9) children(9);
    if (len(types)>10) children(10);
    if (len(types)>11) children(11);
    if (len(types)>12) children(12);
    if (len(types)>13) children(13);
    if (len(types)>14) children(14);
    if (len(types)>15) children(15);
    if (len(types)>16) children(16);
    if (len(types)>17) children(17);
    if (len(types)>18) children(18);
    if (len(types)>19) children(19);
    if (len(types)>20) children(20);
  } else if (axis==-FL_X) translate(+bb_corners(types[0])[0].x*axis) xn(types) {
    if (len(types)>0) children(0);
    if (len(types)>1) children(1);
    if (len(types)>2) children(2);
    if (len(types)>3) children(3);
    if (len(types)>4) children(4);
    if (len(types)>5) children(5);
    if (len(types)>6) children(6);
    if (len(types)>7) children(7);
    if (len(types)>8) children(8);
    if (len(types)>9) children(9);
    if (len(types)>10) children(10);
    if (len(types)>11) children(11);
    if (len(types)>12) children(12);
    if (len(types)>13) children(13);
    if (len(types)>14) children(14);
    if (len(types)>15) children(15);
    if (len(types)>16) children(16);
    if (len(types)>17) children(17);
    if (len(types)>18) children(18);
    if (len(types)>19) children(19);
    if (len(types)>20) children(20);
  } else if (axis==+FL_Y) translate(+bb_corners(types[0])[0].y*axis) yp(types) {
    if (len(types)>0) children(0);
    if (len(types)>1) children(1);
    if (len(types)>2) children(2);
    if (len(types)>3) children(3);
    if (len(types)>4) children(4);
    if (len(types)>5) children(5);
    if (len(types)>6) children(6);
    if (len(types)>7) children(7);
    if (len(types)>8) children(8);
    if (len(types)>9) children(9);
    if (len(types)>10) children(10);
    if (len(types)>11) children(11);
    if (len(types)>12) children(12);
    if (len(types)>13) children(13);
    if (len(types)>14) children(14);
    if (len(types)>15) children(15);
    if (len(types)>16) children(16);
    if (len(types)>17) children(17);
    if (len(types)>18) children(18);
    if (len(types)>19) children(19);
    if (len(types)>20) children(20);
  } else if (axis==-FL_Y) translate(-bb_corners(types[0])[1].y*axis) yn(types) {
    if (len(types)>0) children(0);
    if (len(types)>1) children(1);
    if (len(types)>2) children(2);
    if (len(types)>3) children(3);
    if (len(types)>4) children(4);
    if (len(types)>5) children(5);
    if (len(types)>6) children(6);
    if (len(types)>7) children(7);
    if (len(types)>8) children(8);
    if (len(types)>9) children(9);
    if (len(types)>10) children(10);
    if (len(types)>11) children(11);
    if (len(types)>12) children(12);
    if (len(types)>13) children(13);
    if (len(types)>14) children(14);
    if (len(types)>15) children(15);
    if (len(types)>16) children(16);
    if (len(types)>17) children(17);
    if (len(types)>18) children(18);
    if (len(types)>19) children(19);
    if (len(types)>20) children(20);
  } else if (axis==+FL_Z) translate(+bb_corners(types[0])[0].z*axis) zp(types) {
    if (len(types)>0) children(0);
    if (len(types)>1) children(1);
    if (len(types)>2) children(2);
    if (len(types)>3) children(3);
    if (len(types)>4) children(4);
    if (len(types)>5) children(5);
    if (len(types)>6) children(6);
    if (len(types)>7) children(7);
    if (len(types)>8) children(8);
    if (len(types)>9) children(9);
    if (len(types)>10) children(10);
    if (len(types)>11) children(11);
    if (len(types)>12) children(12);
    if (len(types)>13) children(13);
    if (len(types)>14) children(14);
    if (len(types)>15) children(15);
    if (len(types)>16) children(16);
    if (len(types)>17) children(17);
    if (len(types)>18) children(18);
    if (len(types)>19) children(19);
    if (len(types)>20) children(20);
  } else if (axis==-FL_Z) translate(-bb_corners(types[0])[1].z*axis) zn(types) {
    if (len(types)>0) children(0);
    if (len(types)>1) children(1);
    if (len(types)>2) children(2);
    if (len(types)>3) children(3);
    if (len(types)>4) children(4);
    if (len(types)>5) children(5);
    if (len(types)>6) children(6);
    if (len(types)>7) children(7);
    if (len(types)>8) children(8);
    if (len(types)>9) children(9);
    if (len(types)>10) children(10);
    if (len(types)>11) children(11);
    if (len(types)>12) children(12);
    if (len(types)>13) children(13);
    if (len(types)>14) children(14);
    if (len(types)>15) children(15);
    if (len(types)>16) children(16);
    if (len(types)>17) children(17);
    if (len(types)>18) children(18);
    if (len(types)>19) children(19);
    if (len(types)>20) children(20);
  } else assert(false,str("Wrong axis '",axis,"'."));

  %if (draw) {
    c       = fl_get(types[0],"bounding corners");
    sz      = lay_bb_size(axis,gap,types);
    M     = [
      max([for(t=types) bb_corners(t)[1].x]),
      max([for(t=types) bb_corners(t)[1].y]),
      max([for(t=types) bb_corners(t)[1].z])
    ];
    m     = [
      min([for(t=types) bb_corners(t)[0].x]),
      min([for(t=types) bb_corners(t)[0].y]),
      min([for(t=types) bb_corners(t)[0].z])
    ];
    
    fl_trace("M",M);
    fl_trace("m",m);
    fl_trace("sz",sz);
    fl_trace("axis",axis);
    fl_trace("bounding corners list",[for(t=types) bb_corners(t)]);

    if      (axis==+FL_X) translate([c[0].x+sz.x/2,m.y+sz.y/2,M.z-sz.z/2]) cube(size=sz,center=true);
    else if (axis==-FL_X) translate([c[1].x-sz.x/2,M.y-sz.y/2,M.z-sz.z/2]) cube(size=sz,center=true);
    else if (axis==+FL_Y) translate([M.x-sz.x/2,c[0].y+sz.y/2,M.z-sz.z/2]) cube(size=sz,center=true);
    else if (axis==-FL_Y) translate([M.x-sz.x/2,c[1].y-sz.y/2,M.z-sz.z/2]) cube(size=sz,center=true);
    else if (axis==+FL_Z) translate([M.x-sz.x/2,M.y-sz.y/2,c[0].z+sz.z/2]) cube(size=sz,center=true);
    else if (axis==-FL_Z) translate([M.x-sz.x/2,M.y-sz.y/2,c[1].z-sz.z/2]) cube(size=sz,center=true);
  }
}

__test__();
