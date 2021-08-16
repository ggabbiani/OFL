include <NopSCADlib/lib.scad>;

function knut_init(screw,length,diameter,tooth,rings)=let(rlen=len(rings),delta=length/(rlen-1)) [
  ["screw",             screw],
  ["FL_Z axis length",     length],
  ["external radius",   diameter/2],
  ["tooth height",      tooth],
  ["teeth number",      100],
  ["rings array [[height1,position1],[height2,position2,..]]", [for(i=[0:len(rings)-1]) [rings[i],(i<(rlen-1)/2?rings[i]/2:(i==(rlen-1)/2?0:-rings[i]/2))+i*delta-rings[i]/2]] ],
  ["bounding corners",   [
    [-diameter/2, -diameter/2,  0],       // negative corner
    [+diameter/2, +diameter/2,  length],  // positive corner
  ]],
];

KnurlNut_M2x4x3p5   = knut_init(M2_cap_screw,4,3.5,0.6, [1.15,  1.15      ]);
KnurlNut_M2x6x3p5   = knut_init(M2_cap_screw,6,3.5,0.6, [1.5,   1.5       ]);
KnurlNut_M2x8x3p5   = knut_init(M2_cap_screw,8,3.5,0.5, [1.3,   1.4,  1.3 ]);
KnurlNut_M2x10x3p5  = knut_init(M2_cap_screw,10,3.5,0.5,[1.9,   2.0,  1.9 ]);

KnurlNut_M3x4x5     = knut_init(M3_cap_screw,4,5,0.5,   [1.2,   1.2       ]);
KnurlNut_M3x6x5     = knut_init(M3_cap_screw,6,5,0.5,   [1.5,   1.5       ]);
KnurlNut_M3x8x5     = knut_init(M3_cap_screw,8,5,0.5,   [1.9,   1.9       ]);
KnurlNut_M3x10x5    = knut_init(M3_cap_screw,10,5,0.5,  [1.6,   1.5,   1.6]);

KnurlNut_M4x4x6     = knut_init(M4_cap_screw,4,6,0.5,   [1.3,   1.3       ]);
KnurlNut_M4x6x6     = knut_init(M4_cap_screw,6,6,0.5,   [1.7,   1.7       ]);
KnurlNut_M4x8x6     = knut_init(M4_cap_screw,8,6,0.5,   [2.3,   2.3       ]);
KnurlNut_M4x10x6    = knut_init(M4_cap_screw,10,6,0.5,  [1.9,   1.7,   1.9]);

KnurlNut_M5x6x7     = knut_init(M5_cap_screw,6,7.0,0.5, [1.9,   1.9       ]);
KnurlNut_M5x8x7     = knut_init(M5_cap_screw,8,7.0,0.5, [2.4,   2.4       ]);
KnurlNut_M5x10x7    = knut_init(M5_cap_screw,10,7.0,0.8,[1.7,   1.5,  1.7 ]);

KnurlNuts = [
  [KnurlNut_M2x4x3p5, KnurlNut_M2x6x3p5,  KnurlNut_M2x8x3p5,  KnurlNut_M2x10x3p5],
  [KnurlNut_M3x4x5,   KnurlNut_M3x6x5,    KnurlNut_M3x8x5,    KnurlNut_M3x10x5  ],
  [KnurlNut_M4x4x6,   KnurlNut_M4x6x6,    KnurlNut_M4x8x6,    KnurlNut_M4x10x6  ],
  [KnurlNut_M5x6x7,   KnurlNut_M5x8x7,    KnurlNut_M5x10x7                      ],
];

use <knurl_nut.scad>