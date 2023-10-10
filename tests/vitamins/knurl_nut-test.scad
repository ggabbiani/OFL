/*
 * Knurl nut (aka brass inserts) test file
 *
 * NOTE: this file is generated automatically from 'template-3d.scad', any
 * change will be lost.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/vitamins/knurl_nuts.scad>


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
$FL_ASSEMBLY  = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds local reference axes
$FL_AXES      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// adds a bounding box containing the object
$FL_BBOX      = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
// layout of predefined drill shapes (like holes with predefined screw diameter)
$FL_DRILL     = "OFF";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]


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


/* [Knurl nut] */

SHOW        = "ALL"; // [ALL, Linear M2x4mm,Linear M2x6mm,Linear M2x8mm,Linear M2x10mm,Linear M3x4mm,Linear M3x6mm,Linear M3x8mm,Linear M3x10mm,Linear M4x4mm,Linear M4x6mm,Linear M4x8mm,Linear M4x10mm,Linear M5x6mm,Linear M5x8mm,Linear M5x10mm,Spiral M2x4mm,Spiral M2p5x5.7mm,Spiral M3x5.7mm,Spiral M4x8.1mm,Spiral M5x9.5mm,Spiral M6x12.7mm,Spiral M8x12.7mm]
PRODUCT_TAG = "ANY";  // [ANY,linear thread,double spiral thread]


/* [Hidden] */

direction = DIR_NATIVE    ? undef : [DIR_Z,DIR_R];
octant    = fl_parm_Octant(X_PLACE,Y_PLACE,Z_PLACE);
debug     = fl_parm_Debug(SHOW_LABELS,SHOW_SYMBOLS);

fl_status();

// end of automatically generated code

obj   = fl_switch(SHOW,cases=[
  ["Linear M2x4mm",     FL_KNUT_LINEAR_M2x4     ],
  ["Linear M2x6mm",     FL_KNUT_LINEAR_M2x6     ],
  ["Linear M2x8mm",     FL_KNUT_LINEAR_M2x8     ],
  ["Linear M2x10mm",    FL_KNUT_LINEAR_M2x10    ],
  ["Linear M3x4mm",     FL_KNUT_LINEAR_M3x4     ],
  ["Linear M3x6mm",     FL_KNUT_LINEAR_M3x6     ],
  ["Linear M3x8mm",     FL_KNUT_LINEAR_M3x8     ],
  ["Linear M3x10mm",    FL_KNUT_LINEAR_M3x10    ],
  ["Linear M4x4mm",     FL_KNUT_LINEAR_M4x4     ],
  ["Linear M4x6mm",     FL_KNUT_LINEAR_M4x6     ],
  ["Linear M4x8mm",     FL_KNUT_LINEAR_M4x8     ],
  ["Linear M4x10mm",    FL_KNUT_LINEAR_M4x10    ],
  ["Linear M5x6mm",     FL_KNUT_LINEAR_M5x6     ],
  ["Linear M5x8mm",     FL_KNUT_LINEAR_M5x8     ],
  ["Linear M5x10mm",    FL_KNUT_LINEAR_M5x10    ],
  ["Spiral M2x4mm",     FL_KNUT_SPIRAL_M2x4     ],
  ["Spiral M2p5x5.7mm", FL_KNUT_SPIRAL_M2p5x5p7 ],
  ["Spiral M3x5.7mm",   FL_KNUT_SPIRAL_M3x5p7   ],
  ["Spiral M4x8.1mm",   FL_KNUT_SPIRAL_M4x8p1   ],
  ["Spiral M5x9.5mm",   FL_KNUT_SPIRAL_M5x9p5   ],
  ["Spiral M6x12.7mm",  FL_KNUT_SPIRAL_M6x12p7  ],
  ["Spiral M8x12.7mm",  FL_KNUT_SPIRAL_M8x12p7  ]
]);
verbs = fl_verbList([FL_ADD,FL_ASSEMBLY,FL_AXES,FL_BBOX,FL_DRILL]);

if (obj)
  fl_knut(verbs,obj,octant=octant,direction=direction);
else {
  // filter items by the product tag
  items = PRODUCT_TAG=="ANY" ? FL_KNUT_DICT : fl_knut_search(tag=PRODUCT_TAG,best=false);
  // build a dictionary with rows constituted by items with equal internal thread
  dict  = fl_dict_organize(items,[2:0.5:8],function(nut) fl_knut_nominal(nut));
  y_offsets = [for(i=[0:len(dict)-1]) i && dict[i] ? 12 : 0];
  y_coords  = cumulativeSum(y_offsets);
  for(i=[0:len(dict)-1]) let(row=dict[i],l=len(row))
    if (row) { // ignore empty rows
      translate(Y(y_coords[i])) {
          label(str("M",fl_knut_nominal(row[0])),halign="center");
        fl_layout(axis=+X,gap=3,types=row)
          // echo(fl_name($item))
            fl_knut(verbs,$item,octant=octant,direction=direction);
      }
    }
}

//! returns a vector in which each item is the sum of the previous ones
function cumulativeSum(v) = [
  for (i = [0 : len(v) - 1])
    fl_accum([for(j=[0:i]) v[j]])
];
