/*
 * Screw wrappers test file for OpenSCAD Foundation Library vitamins
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/foundation/core.scad>
include <../../lib/OFL/vitamins/screw.scad>


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


/* [Supported verbs] */

// adds shapes to scene.
$FL_ADD       = "ON";   // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined auxiliary shapes (like predefined screws)
$FL_ASSEMBLY  = "ON";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
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


/* [Screw] */

SCREW       = "ALL";  // [ALL, No632_pan_screw,M2_cap_screw,M2_cs_cap_screw,M2_dome_screw,M2p5_cap_screw,M2p5_pan_screw,M3_cap_screw,M3_cs_cap_screw,M3_dome_screw,M3_grub_screw,M3_hex_screw,M3_low_cap_screw,M3_pan_screw,M4_cap_screw,M4_cs_cap_screw,M4_dome_screw,M4_grub_screw,M4_hex_screw,M4_pan_screw,M5_cap_screw,M5_cs_cap_screw,M5_dome_screw,M5_hex_screw,M5_pan_screw,M6_cap_screw,M6_cs_cap_screw,M6_hex_screw,M6_pan_screw,M8_cap_screw,M8_hex_screw,No2_screw,No4_screw,No6_cs_screw,No6_screw,No8_screw]
FIXED_LEN   = 0;
// thickness
T           = 10;     // [1:0.1:20]
WASHER      = "no";   // [no,default,penny,nylon]
XWASHER     = "no";   // [no,spring,star]
// add a default washer before the nut
NUT_WASHER  = false;
NUT         = "no";   // [no,default,nyloc]
HEAD_TYPE   = "ANY";  // [ANY, cap, pan, cs, hex, grub, cs cap, dome]


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// end of automatically generated code

verbs = fl_verbList([FL_ADD,FL_ASSEMBLY,FL_AXES,FL_BBOX,FL_DRILL,FL_FOOTPRINT]);
screw = fl_switch(SCREW,  cases=[
  ["No632_pan_screw" , No632_pan_screw  ],
  ["M2_cap_screw"    , M2_cap_screw     ],
  ["M2_cs_cap_screw" , M2_cs_cap_screw  ],
  ["M2_dome_screw"   , M2_dome_screw    ],
  ["M2p5_cap_screw"  , M2p5_cap_screw   ],
  ["M2p5_pan_screw"  , M2p5_pan_screw   ],
  ["M3_cap_screw"    , M3_cap_screw     ],
  ["M3_cs_cap_screw" , M3_cs_cap_screw  ],
  ["M3_dome_screw"   , M3_dome_screw    ],
  ["M3_grub_screw"   , M3_grub_screw    ],
  ["M3_hex_screw"    , M3_hex_screw     ],
  ["M3_low_cap_screw", M3_low_cap_screw ],
  ["M3_pan_screw"    , M3_pan_screw     ],
  ["M4_cap_screw"    , M4_cap_screw     ],
  ["M4_cs_cap_screw" , M4_cs_cap_screw  ],
  ["M4_dome_screw"   , M4_dome_screw    ],
  ["M4_grub_screw"   , M4_grub_screw    ],
  ["M4_hex_screw"    , M4_hex_screw     ],
  ["M4_pan_screw"    , M4_pan_screw     ],
  ["M5_cap_screw"    , M5_cap_screw     ],
  ["M5_cs_cap_screw" , M5_cs_cap_screw  ],
  ["M5_dome_screw"   , M5_dome_screw    ],
  ["M5_hex_screw"    , M5_hex_screw     ],
  ["M5_pan_screw"    , M5_pan_screw     ],
  ["M6_cap_screw"    , M6_cap_screw     ],
  ["M6_cs_cap_screw" , M6_cs_cap_screw  ],
  ["M6_hex_screw"    , M6_hex_screw     ],
  ["M6_pan_screw"    , M6_pan_screw     ],
  ["M8_cap_screw"    , M8_cap_screw     ],
  ["M8_hex_screw"    , M8_hex_screw     ],
  ["No2_screw"       , No2_screw        ],
  ["No4_screw"       , No4_screw        ],
  ["No6_cs_screw"    , No6_cs_screw     ],
  ["No6_screw"       , No6_screw        ],
  ["No8_screw"       , No8_screw        ]
]);

// enable nut washer only when nut is required
nut_washer  = NUT!="no" && NUT_WASHER;

h_filter  = fl_switch(HEAD_TYPE,[["cap",hs_cap], ["pan",hs_pan], ["cs",hs_cs], ["hex",hs_hex], ["grub",hs_grub], ["cs cap",hs_cs_cap], ["dome",hs_dome]]);
n_filter  = NUT!="no";

if (screw)
  fl_screw(verbs,screw,thick=T,washer=WASHER,nut=NUT,xwasher=XWASHER,nwasher=nut_washer,len=FIXED_LEN?FIXED_LEN:undef,octant=octant,direction=direction);
else {
  // ordered list of existing screw sizes
  sizes     = fl_list_sort(fl_list_unique([for(s=FL_SCREW_DICT) fl_screw_nominal(s)]));
  // filter items according to customizer input
  items     = fl_screw_search(head_type=h_filter,nut=n_filter,washer=WASHER);
  // build a dictionary organized by rows of screws with same nominal size
  dict      = fl_dict_organize(items,sizes,function(screw) fl_screw_nominal(screw));
  // for each not empty row calculates the offsets along Y axis
  y_coords  = let(
    y_offsets = [for(i=[0:len(dict)-1]) (i>0 && dict[i-1]) ? 20 : 0]
  ) fl_cumulativeSum(y_offsets);

  for(i=[0:len(dict)-1]) let(row=dict[i])
    if (row) { // no empty row
      wrappers  = [for(nop=row) Wrapper(nop)];
      // row movement along Y axis
      translate(Y(y_coords[i])) {
        translate(-X(12))
          label(str("⌀",fl_screw_nominal(row[0])),halign="center");
        // horizontal layout of row screws
        fl_layout(axis=+X,gap=3,types=wrappers)
          fl_screw(verbs,fl_screw($item),thick=T,washer=WASHER,nut=NUT,xwasher=XWASHER,nwasher=nut_washer,len=FIXED_LEN?FIXED_LEN:undef,octant=octant,direction=direction);
      }
    }
}

function Wrapper(nop) = let(
  length  = FIXED_LEN ? FIXED_LEN : fl_screw_l(nop,len=FIXED_LEN?FIXED_LEN:undef,thick=T,washer=WASHER,nut=NUT,xwasher=XWASHER,nwasher=nut_washer)
) [
  fl_screw(value=nop),
  fl_bb_corners(value=fl_bb_screw(nop,length)),
];

//! Draw text that always faces the camera
module label(str, scale = 0.25, valign = "baseline", halign = "left")
  color("black")
    rotate($vpr != [0, 0, 0] ? $vpr : [70, 0, 315])
      linear_extrude(NIL)
        scale(scale)
          text(str, valign = valign, halign = halign, font="Symbola:style=Regular");
