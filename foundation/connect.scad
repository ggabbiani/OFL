/*
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

include <unsafe_defs.scad>
use     <3d.scad>
use     <symbol.scad>
use     <util.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = false;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

/* [View] */

VIEW_CONNECTORS = false;
CONNECTORS_ONLY = false;
VIEW_SOCKET     = true;
VIEW_PLUG       = true;
VIEW_BALL       = true;

/* [Socket] */

// canonical view is solidal with the connector position and orientation
SOCKET_VIEW     = "actual"; // [natural,canonical,actual]
SOCKET_ALPHA    = 120;      // [0:360]
SOCKET_BETA     = 30;       // [0:360]
SOCKET_DISTANCE = 6;        // [0:10]

/* [Plug] */

// canonical view is solidal with the connector position and orientation
PLUG_VIEW       = "actual"; // [natural,canonical,actual]

/* [Hidden] */

module __test__() {
  verbs=[
    FL_ADD,
  ];

  test_plug = [
    ["name",  "test plug" ],
    ["size",  [1.2,2,0.5] ],
    ["plugs", [
        conn_Plug(fprint="Test 220v AC ITA",ox=+X,oy=+Y,pos=[-0.4,-0.5,0])
      ]
    ]

  ];

  test_socket=[
    ["name",    "test socket" ],
    ["size",    [2,0.5,1]     ],
    ["sockets", [
        conn_Socket(fprint="Test 220v AC ITA",ox=+X,oy=-Y,pos=[-0.7,0,0]),
      ]
    ]
  ];

  module transform() {
    rotate(SOCKET_BETA,X) rotate(SOCKET_ALPHA,Y) translate(X(SOCKET_DISTANCE)) children();
  }

  // "plug": 'a piece that fits into a hole in order to close it'
  //        Its canonical form implies an orientation of the piece coherent
  //        with its insertion movement along +Z semi-axis. 
  module plug(type,connectors=false,only=false) {
    positions=fl_get(type,"plugs");
    t=positions[0];

    size      = fl_get(type,"size");
    plug      = fl_get(type,"plugs")[0];
    ox        = fl_conn_ox(plug);
    oy        = fl_conn_oy(plug);
    position  = fl_conn_pos(plug);
    M         = fl_planeAlign(X,Y,ox,oy)
              * T(position);
    if (!connectors || !only) {
      fl_color("DarkSlateGray") fl_cube(size=size,octant=-Z);
      fl_color("gold") multmatrix(M) spine();
    }
    if (connectors)
      multmatrix(M) fl_sym_plug();
  }

  // "socket": 'a part of the body into which another part fits'
  //        Its canonical form implies an orientation of the piece coherent
  //        with its fitting movement along -Z semi-axis. 
  module socket(type,connectors=false,only=false) {
    size      = fl_get(type,"size");
    socket    = fl_get(type,"sockets")[0];
    ox        = fl_conn_ox(socket);
    oy        = fl_conn_oy(socket);
    position  = fl_conn_pos(socket);
    M         = fl_planeAlign(X,Y,ox,oy)
              * T(position);
    if (!connectors || !only) {
      difference() {
        fl_color("DarkSlateGray") fl_cube(size=size,octant=-Z);
        fl_color("gold") translate(Z(FL_NIL)) multmatrix(M) spine();
      }
    }
    if (connectors)
      multmatrix(M) fl_sym_socket();
  }

  module spine() {
    inter = 1;
    r     = 0.1;
    h     = 0.8;
    // translate(-X(inter/2-r))
      for(i=[0,+1]) translate(i*X(inter-2*r))
        if (i==0) {
          fl_cube(size=[2*r,2*r,h],octant=+Z);
        } else {
          fl_cylinder(r=r,h=h-r);
          translate(Z(h-r)) fl_sphere(r=r,octant=FL_O);
        }
  }

  if (VIEW_SOCKET) {
    if (SOCKET_VIEW=="natural") 
      socket(test_socket,VIEW_CONNECTORS,CONNECTORS_ONLY);
    else if (SOCKET_VIEW=="canonical") 
      let(
        socket    = fl_get(test_socket,"sockets")[0],
        ox        = fl_conn_ox(socket),
        oy        = fl_conn_oy(socket),
        position  = fl_conn_pos(socket),
        M         = T(-position)
                  * fl_planeAlign(X,Y,ox,oy)
      ) {
      multmatrix(M) socket(test_socket,VIEW_CONNECTORS,CONNECTORS_ONLY);
    } else if (SOCKET_VIEW=="actual") 
      transform() socket(test_socket,VIEW_CONNECTORS,CONNECTORS_ONLY);
  }

  if (VIEW_PLUG) {
    if (PLUG_VIEW=="natural") 
      plug(test_plug,VIEW_CONNECTORS,CONNECTORS_ONLY);
    else if (PLUG_VIEW=="canonical") 
      let(
        plug      = fl_get(test_plug,"plugs")[0],
        ox        = fl_conn_ox(plug),
        oy        = fl_conn_oy(plug),
        position  = fl_conn_pos(plug),
        M         = T(-position)
                  * fl_planeAlign(X,Y,ox,oy)
      ) {
      multmatrix(M) plug(test_plug,VIEW_CONNECTORS,CONNECTORS_ONLY);
    } else if (PLUG_VIEW=="actual") let(
      plug      = fl_get(test_plug,"plugs")[0],
      socket    = fl_get(test_socket,"sockets")[0]
    ) transform() fl_connect(plug,socket) plug(test_plug,VIEW_CONNECTORS,CONNECTORS_ONLY);
  }

  if (VIEW_SOCKET && SOCKET_VIEW=="actual" && VIEW_BALL)
    %fl_sphere(r=SOCKET_DISTANCE);
}

// contructors
function conn_Plug(fprint,ox,oy,pos) = 
  assert(is_string(fprint))
  assert(is_list(ox))
  assert(is_list(oy))
  assert(ox*oy==0,str("ox=",ox,",oy=",oy))
  assert(is_list(pos))
  [
    fl_conn_typeKV("plug"),
    fl_conn_fprintKV(fprint),
    fl_conn_oxKV(ox),
    fl_conn_oyKV(oy),
    fl_conn_posKV(pos),
  ];

function conn_Socket(fprint,ox,oy,pos) = 
  assert(is_string(fprint))
  assert(is_list(ox))
  assert(is_list(oy))
  assert(ox*oy==0,str("ox=",ox,",oy=",oy))
  assert(is_list(pos))
  [
    fl_conn_typeKV("socket"),
    fl_conn_fprintKV(fprint),
    fl_conn_oxKV(ox),
    fl_conn_oyKV(oy),
    fl_conn_posKV(pos),
  ];

//*****************************************************************************
// key values
function fl_conn_typeKV(value)   = fl_kv("conn/type",value);
function fl_conn_fprintKV(value) = fl_kv("conn/footprint",value);
function fl_conn_oxKV(value)     = fl_kv("conn/orientation X",value);
function fl_conn_oyKV(value)     = fl_kv("conn/orientation Y",value);
function fl_conn_posKV(value)    = fl_kv("conn/position",value);

//*****************************************************************************
// getters
function fl_conn_type(type)    = fl_get(type,fl_conn_typeKV());
function fl_conn_fprint(type)  = fl_get(type,fl_conn_fprintKV());
function fl_conn_ox(type)      = fl_get(type,fl_conn_oxKV());
function fl_conn_oy(type)      = fl_get(type,fl_conn_oyKV());
function fl_conn_pos(type)     = fl_get(type,fl_conn_posKV());

// massive connection clone eventually transformed
function fl_conn_import(conns,M) = [for(c=conns) fl_conn_clone(c,M=M)];

// returns a copy of the given connection with eventual rewriting of attributes
function fl_conn_clone(
  original  // MANDATORY original connection to be cloned
  ,type     // OPTIONAL new connection type ("socket" or "plug")
  ,fprint   // OPTIONAL new connection fingerprint
  ,ox       // OPTIONAL new orientation X
  ,oy       // OPTIONAL new orientation Y
  ,pos      // OPTIONAL new position
  ,M=I      // OPTIONAL tarnsformation matrix for position transformation
) = 
  assert(original!=undef) 
  assert(ox==undef  || len(ox)==3)
  assert(oy==undef  || len(oy)==3)
  assert(pos==undef || len(pos)==3)
  let(
    t         = type==undef   ? fl_conn_type(original) : type,
    f         = fprint==undef ? fl_conn_fprint(original) : fprint,
    orig_ox_3 = fl_conn_ox(original),
    orig_oy_3 = fl_conn_oy(original),
    tran_ox_4 = fl_transform(M,orig_ox_3),
    tran_oy_4 = fl_transform(M,orig_oy_3),
    trans_O_4 = fl_transform(M,O),

    x_3   = ox!=undef     ? ox  :  fl_3(tran_ox_4) - fl_3(trans_O_4),
    y_3   = oy!=undef     ? oy  :  fl_3(tran_oy_4) - fl_3(trans_O_4),
    p_3   = pos!=undef    ? pos :  fl_transform(M,fl_conn_pos(original))

    // x_3   = ox!=undef     ? ox  : M==undef ? orig_ox_3 : fl_3(tran_ox_4) - fl_3(trans_O_4),
    // y_3   = oy!=undef     ? oy  : M==undef ? orig_oy_3 : fl_3(tran_oy_4) - fl_3(trans_O_4),
    // p_3   = pos!=undef    ? pos : M==undef ? fl_conn_pos(original) : fl_3(M * fl_4(fl_conn_pos(original)))
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
module fl_connect(
  son     // socket or plug data for the children shape to be jointed
  ,parent // plug or socket data for the fixed part
  ) {
  son_type      = fl_conn_type(son);
  son_footprint = fl_conn_fprint(son);
  son_ox        = fl_conn_ox(son);
  son_oy        = fl_conn_oy(son);
  son_pos       = fl_conn_pos(son);

  par_type      = fl_conn_type(parent);
  par_footprint = fl_conn_fprint(parent);
  par_ox        = fl_conn_ox(parent);
  par_oy        = fl_conn_oy(parent);
  par_pos       = fl_conn_pos(parent);

  M           = T(+par_pos)
              * fl_planeAlign(son_ox,son_oy,par_ox,par_oy)
              * T(-son_pos);

  assert(son_type!=par_type);
  assert(son_footprint==par_footprint,str("Trying to connect '",son_footprint,"'' with '",par_footprint,"'."));

  multmatrix(M) children();
}

// Adds proper connection symbol (plug or socket) to the scene
module fl_conn_add(connector,size) {
  assert(connector!=undef);
  M = T(fl_conn_pos(connector))
    * fl_planeAlign(X,Y,fl_conn_ox(connector),fl_conn_oy(connector));
  multmatrix(M)
    fl_symbol(size=size,symbol=fl_conn_type(connector));
}

__test__();
