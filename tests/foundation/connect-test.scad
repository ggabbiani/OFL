/*
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org)
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

include <../../foundation/connect.scad>

$fn         = 50;           // [3:100]
// Debug statements are turned on
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, trace messages are turned on
$fl_traces   = false;

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
        conn_Plug(id="Test 220v AC ITA",ox=+X,oy=+Y,pos=[-0.4,-0.5,0])
      ]
    ]

  ];

  test_socket=[
    ["name",    "test socket" ],
    ["size",    [2,0.5,1]     ],
    ["sockets", [
        conn_Socket(id="Test 220v AC ITA",ox=+X,oy=-Y,pos=[-0.7,0,0]),
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

__test__();
