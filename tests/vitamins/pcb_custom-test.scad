/*
 * HiLetgo SX1308 DC-DC Step up power module is built as a custom pcb.
 * See https://www.amazon.it/gp/product/B07ZYW68C4/ for the stepup specs
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
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
include <../../vitamins/pcbs.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

$FL_FILAMENT  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

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
// adds a box representing the payload of the shape
$FL_PAYLOAD   = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]

/* [Placement] */

PLACE_NATIVE  = true;
OCTANT        = [0,0,0];  // [-1:+1]

/* [Direction] */

DIR_NATIVE  = true;
// ARBITRARY direction vector
DIR_Z       = [0,0,1];  // [-1:0.1:+1]
// rotation around
DIR_R       = 0;        // [0:360]

/* [Custom PCB] */

// FL_DRILL and FL_CUTOUT thickness
T             = 2.5;

/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = PLACE_NATIVE  ? undef : OCTANT;
verbs=[
  if ($FL_ADD!="OFF")       FL_ADD,
  if ($FL_ASSEMBLY!="OFF")  FL_ASSEMBLY,
  if ($FL_AXES!="OFF")      FL_AXES,
  if ($FL_BBOX!="OFF")      FL_BBOX,
  if ($FL_CUTOUT!="OFF")    FL_CUTOUT,
  if ($FL_DRILL!="OFF")     FL_DRILL,
  if ($FL_FOOTPRINT!="OFF") FL_FOOTPRINT,
  if ($FL_LAYOUT!="OFF")    FL_LAYOUT,
  if ($FL_PAYLOAD!="OFF")   FL_PAYLOAD,
];

pcb = let(
    pcb_t = 1.6,
    sz    = [23,16,pcb_t],
    // holes positions
    holes = [for(x=[-sz.x/2+2.5,+sz.x/2-2.5],y=[-sz.y/2+2.5,+sz.y/2-2.5]) [x,y,0]],
    1PIN  = fl_phdr_new("1-pin",nop=2p54header),
    comps = [
      //["label", ["engine",   [position        ],  [[director],rotation],  type,           [engine specific parameters]]]
      ["TRIMPOT", [FL_TRIM_NS, [-5,-sz.y/2+0.5,0],  [+Y,0],                 FL_TRIM_POT10,  [["comp/octant",+X-Y+Z]]  ]],
      // create four component specifications, one for each hole position, labelled as "PIN-0", "PIN-1", "PIN-2", "PIN-3"
      for(i=[0:len(holes)-1]) let(label=str("PIN-",i))
        [label,   [FL_PHDR_NS, holes[i],            [+Z,0],                 1PIN]],
    ]
  ) fl_PCB(
    name  = "HiLetgo SX1308 DC-DC Step up power module",
    // bare (i.e. no payload) pcb's bounding box
    bare  = [[-sz.x/2,-sz.y/2,-sz.z],[+sz.x/2,+sz.y/2,0]],
    // pcb thickness
    thick = pcb_t,
    color  = "DarkCyan",
    holes = let(r=0.75,d=r*2,specs=[["hole/screw",M2_cap_screw]]) [for(i=[0:len(holes)-1]) [holes[i],+Z,d,0,specs]],
    components=comps
  );

fl_pcb(verbs,pcb,direction=direction,octant=octant,thick=T);
