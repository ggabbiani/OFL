/*
 * Created on 11/5/2021
 *
 * Copyright © 2021 Giampiero Gabbiani
 */

include <incs.scad>
use     <../vitamins/utils.scad>

$fn       = 50;           // [3:50]
$FL_TRACE    = false;
$FL_RENDER   = false;
$FL_DEBUG    = false;

/* [View] */

VIEW_CONNECTORS = false;
CONNECTORS_ONLY = false;
VIEW_SOCKET     = true;
VIEW_PLUG       = false;
VIEW_BALL       = true;

/* [Socket] */

// canonical view is solidal with the connector position and orientation
SOCKET_VIEW     = "natural"; // [natural,canonical,actual]
SOCKET_ALPHA    = 0; // [0:360]
SOCKET_BETA     = 0; // [0:360]
SOCKET_DISTANCE = 1; // [0:10]

/* [Plug] */
// canonical view is solidal with the connector position and orientation
PLUG_VIEW       = "natural"; // [natural,canonical,actual]
PLUG_DEBUG      = false;

/* [Hidden] */

if (VIEW_SOCKET && SOCKET_VIEW=="actual" && VIEW_BALL)
  %fl_sphere(r=SOCKET_DISTANCE);

verbs=[
  FL_ADD,
];

test_plug = [
  ["name",  "test plug" ],
  ["size",  [1.2,2,0.5] ],
  ["plugs", [
      conn_Plug(fprint="Test 220v AC ITA",ox=+FL_X,oy=+FL_Y,pos=[-0.4,-0.5,0])
    ]
  ]

];

test_socket=[
  ["name",    "test socket" ],
  ["size",    [2,0.5,1]     ],
  ["sockets", [
      conn_Socket(fprint="Test 220v AC ITA",ox=+FL_X,oy=-FL_Y,pos=[-0.7,0,0]),
    ]
  ]
];

if ($preview)
  __test__();

module __test__() {
  module fl_transform() {
    rotate(SOCKET_BETA,FL_X) rotate(SOCKET_ALPHA,FL_Y) translate(fl_X(SOCKET_DISTANCE)) children();
  }

  // "plug": 'a piece that fits into a hole in order to close it'
  //        Its canonical form implies an orientation of the piece coherent
  //        with its insertion movement along +FL_Z axis. 
  module plug(type,connectors=false,only=false) {
    positions=fl_get(type,"plugs");
    t=positions[0];

    size      = fl_get(type,"size");
    plug      = fl_get(type,"plugs")[0];
    ox        = fl_get(plug,"Orientation FL_X");
    oy        = fl_get(plug,"Orientation FL_Y");
    position  = fl_get(plug,"position");
    M         = plane_align(FL_X,FL_Y,ox,oy)
              * fl_T(position);
    if (!connectors || !only) {
      fl_color("DarkSlateGray") fl_cube(size=size,octant=-FL_Z);
      fl_color("gold") multmatrix(M) spine();
    }
    if (connectors)
      multmatrix(M) sym_plug();
  }

  // "socket": 'a part of the body into which another part fits'
  //        Its canonical form implies an orientation of the piece coherent
  //        with its fitting movement along -FL_Z axis. 
  module socket(type,connectors=false,only=false) {
    size      = fl_get(type,"size");
    socket    = fl_get(type,"sockets")[0];
    ox        = fl_get(socket,"Orientation FL_X");
    oy        = fl_get(socket,"Orientation FL_Y");
    position  = fl_get(socket,"position");
    M         = plane_align(FL_X,FL_Y,ox,oy)
              * fl_T(position);
    if (!connectors || !only) {
      difference() {
        fl_color("DarkSlateGray") fl_cube(size=size,octant=-FL_Z);
        translate(fl_Z(FL_NIL)) multmatrix(M) spine();
      }
    }
    if (connectors)
      multmatrix(M) sym_socket();
  }

  module spine() {
    inter = 1;
    r     = 0.1;
    h     = 0.8;
    // translate(-fl_X(inter/2-r))
      for(i=[0,+1]) translate(i*fl_X(inter-2*r))
        if (i==0) {
          fl_cube(size=[2*r,2*r,h],octant=+FL_Z);
        } else {
          fl_cylinder(r=r,h=h-r);
          translate(fl_Z(h-r)) fl_sphere(r=r,octant=FL_O);
        }
  }

  if (VIEW_SOCKET) {
    if (SOCKET_VIEW=="natural") 
      socket(test_socket,VIEW_CONNECTORS,CONNECTORS_ONLY);
    else if (SOCKET_VIEW=="canonical") 
      let(
        socket    = fl_get(test_socket,"sockets")[0],
        ox        = fl_get(socket,"Orientation FL_X"),
        oy        = fl_get(socket,"Orientation FL_Y"),
        position  = fl_get(socket,"position"),
        M         = fl_T(-position)
                  * plane_align(FL_X,FL_Y,ox,oy)
      ) {
      multmatrix(M) socket(test_socket,VIEW_CONNECTORS,CONNECTORS_ONLY);
    } else if (SOCKET_VIEW=="actual") 
      fl_transform() socket(test_socket,VIEW_CONNECTORS,CONNECTORS_ONLY);
  }

  if (VIEW_PLUG) {
    if (PLUG_VIEW=="natural") 
      plug(test_plug,VIEW_CONNECTORS,CONNECTORS_ONLY);
    else if (PLUG_VIEW=="canonical") 
      let(
        plug      = fl_get(test_plug,"plugs")[0],
        ox        = fl_get(plug,"Orientation FL_X"),
        oy        = fl_get(plug,"Orientation FL_Y"),
        position  = fl_get(plug,"position"),
        M         = fl_T(-position)
                  * plane_align(FL_X,FL_Y,ox,oy)
      ) {
      multmatrix(M) plug(test_plug,VIEW_CONNECTORS,CONNECTORS_ONLY);
    } else if (PLUG_VIEW=="actual") let(
      plug      = fl_get(test_plug,"plugs")[0],
      p_ox      = fl_get(plug,"Orientation FL_X"),
      p_oy      = fl_get(plug,"Orientation FL_Y"),
      p_pos     = fl_get(plug,"position"),

      socket    = fl_get(test_socket,"sockets")[0],
      s_ox      = fl_get(socket,"Orientation FL_X"),
      s_oy      = fl_get(socket,"Orientation FL_Y"),
      s_pos     = fl_get(socket,"position"),

      M         = plane_align(FL_X,FL_Y,s_ox,s_oy)
                * fl_T(+s_pos)
                * fl_T(-p_pos)
                * plane_align(FL_X,FL_Y,p_ox,p_oy)
    ) fl_transform() connect(plug,socket) plug(test_plug,VIEW_CONNECTORS,CONNECTORS_ONLY);
  }
}

// contructors
function conn_Plug(fprint,ox,oy,pos) = 
  assert(is_string(fprint))
  assert(is_list(ox))
  assert(is_list(oy))
  assert(ox*oy==0,str("ox=",ox,",oy=",oy))
  assert(is_list(pos))
  [
    ["type",          "plug"    ],
    ["footprint",     fprint    ],
    ["Orientation FL_X", ox        ],
    ["Orientation FL_Y", oy        ],
    ["position",      pos       ],
  ];

function conn_Socket(fprint,ox,oy,pos) = 
  assert(is_string(fprint))
  assert(is_list(ox))
  assert(is_list(oy))
  assert(ox*oy==0)
  assert(is_list(pos))
  [
    ["type",          "socket"  ],
    ["footprint",     fprint    ],
    ["Orientation FL_X", ox        ],
    ["Orientation FL_Y", oy        ],
    ["position",      pos       ],
  ];

// getters
function conn_type(type)    = fl_get(type,"type");
function conn_fprint(type)  = fl_get(type,"footprint");
function conn_ox(type)      = fl_get(type,"Orientation FL_X");
function conn_oy(type)      = fl_get(type,"Orientation FL_Y");
function conn_pos(type)     = fl_get(type,"position");

// massive connection clone eventually transformed
function conn_import(conns,M) = [for(c=conns) conn_clone(c,M=M)];

// returns a copy of the given connection with eventual rewriting of attributes
function conn_clone(
  original  // MANDATORY original connection to be cloned
  ,type     // OPTIONAL new connection type ("socket" or "plug")
  ,fprint   // OPTIONAL new connection fingerprint
  ,ox       // OPTIONAL new orientation FL_X
  ,oy       // OPTIONAL new orientation FL_Y
  ,pos      // OPTIONAL new position
  ,M        // OPTIONAL tarnsformation matrix for position transformation
) = 
  assert(original!=undef) 
  assert(ox==undef  || len(ox)==3)
  assert(oy==undef  || len(oy)==3)
  assert(pos==undef || len(pos)==3)
  let(
    t         = type==undef   ? conn_type(original) : type,
    f         = fprint==undef ? conn_fprint(original) : fprint,
    orig_ox_3 = conn_ox(original),
    orig_oy_3 = conn_oy(original),
    tran_ox_4 = M * fl_4(orig_ox_3),
    tran_oy_4 = M * fl_4(orig_oy_3),
    trans_O_4 = M * [0,0,0,1],

    x_3   = ox!=undef     ? ox  : M==undef ? orig_ox_3 : fl_3(tran_ox_4) - fl_3(trans_O_4),
    y_3   = oy!=undef     ? oy  : M==undef ? orig_oy_3 : fl_3(tran_oy_4) - fl_3(trans_O_4),
    p_3   = pos!=undef    ? pos : M==undef ? conn_pos(original) : fl_3(M * fl_4(conn_pos(original)))
  )
  // echo(orig_ox_3=orig_ox_3)
  // echo(orig_oy_3=orig_oy_3)
  // echo(M=M)
  // echo(x_3=x_3)
  // echo(y_3=y_3)
  assert(norm(orig_ox_3)==1)
  assert(norm(orig_oy_3)==1)
  assert(norm(x_3)==1)
  assert(norm(y_3)==1)
  assert(orig_ox_3*orig_oy_3==0,"Original orientation fl_axes are not orthogonal")
  assert(x_3*y_3==0,"Resulting orientation fl_axes are not orthogonal")
  t=="plug" ? conn_Plug(f,x_3,y_3,p_3) : conn_Socket(f,x_3,y_3,p_3);

// Transforms a child shape to its parent form coherently with 
// their respective connection geometries.
// Child can be thought as a mobile socket or plug 
// jointing a fixed plug or socket.
module connect(
  son     // socket or plug data for the children shape to be jointed
  ,parent // plug or socket data for the fixed part
  ) {
  son_type      = conn_type(son);
  son_footprint = conn_fprint(son);
  son_ox        = conn_ox(son);
  son_oy        = conn_oy(son);
  son_pos       = conn_pos(son);

  par_type      = conn_type(parent);
  par_footprint = conn_fprint(parent);
  par_ox        = conn_ox(parent);
  par_oy        = conn_oy(parent);
  par_pos       = conn_pos(parent);

  // M           = plane_align(FL_X,FL_Y,par_ox,par_oy)
  //             * fl_T(+par_pos)
  //             * fl_T(-son_pos)
  //             * plane_align(son_ox,son_oy,FL_X,FL_Y);

  M           = fl_T(+par_pos)
              * plane_align(son_ox,son_oy,par_ox,par_oy)
              * fl_T(-son_pos);

  assert(son_type!=par_type);
  assert(son_footprint==par_footprint,str("Trying to connect '",son_footprint,"'' with '",par_footprint,"'."));

  multmatrix(M) children();
}

// Adds proper connection symbol (plug or socket) to the scene
module conn_add(connector,size) {
  assert(connector!=undef);
  M = fl_T(conn_pos(connector))
    * plane_align(FL_X,FL_Y,conn_ox(connector),conn_oy(connector));
  multmatrix(M)
    if (conn_type(connector)=="plug") sym_plug(size=size); else sym_socket(size=size);
}
