/*!
 * 'Naive' SATA adapter definition file.
 *
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
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
 * along with OFL.  If not, see <http://www.gnu.org/licenses/>.
 */

include <sata.scad>

FL_SADP_NS  = "sadp";

FL_SADP_ELUTENG =
let(
  socket      = FL_SATA_POWERDATASOCKET,
  handle_size = [47,37,11.6],
  socket_size = fl_size(socket),
  size        = [handle_size.x,handle_size.y+socket_size.z,handle_size.z],
  Mpd         = fl_T(-fl_Y(FL_NIL)) * fl_Ry(180) * fl_Rx(-90) * fl_octant(+Z-Y,type=socket)
)
[
  fl_name(value="ELUTENG USB 3.0 TO SATA ADAPTER"),
  fl_bb_corners(value=[[-size.x/2,-handle_size.y,-size.z/2],[size.x/2,socket_size.z,+size.z/2]]),
  fl_director(value=+FL_Y),fl_rotor(value=+FL_X),
  fl_vendor(value=[["Amazon", "https://www.amazon.it/gp/product/B007UOXRY0/"]]),
  ["handle size", handle_size],
  ["Mpd",         Mpd],
  ["connectors",  fl_conn_import(fl_sata_conns(socket),Mpd)],
  ["SATA socket", socket],
];

FL_SADP_DICT = [
  FL_SADP_ELUTENG,
];

module sata_adapter(
  verbs,
  type,
  locators=false,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant
) {
  assert(verbs!=undef);

  handle_size = fl_get(type,"handle size");
  sock        = fl_get(type,"SATA socket");
  sock_size   = fl_size(sock);
  size        = fl_size(type);
  Mpd         = fl_get(type,"Mpd");
  connectors  = fl_connectors(type);
  D           = direction ? fl_direction(type,direction=direction)  : FL_I;
  M           = fl_octant(octant,type=type);

  module sata_handle() {
    // transformation matrix for converting from Draw.io coord-system to OpenSCAD
    M       = [[1,0],[0,-1],]*[[-1,0],[0,1],];
    points  = [[0,0],[1,0],[1,0.53],
    [0.73,0.53],
    [0.68,1],[0.32,1],
    [0.27,0.53],
    [0,0.53],[0,0]];
    fl_color("DarkSlateGray")
    translate(fl_X(handle_size.x/2)-fl_Z(handle_size.z/2))
    linear_extrude(handle_size.z)
      multmatrix(M)
        resize(handle_size)
          polygon(points);
  }

  module do_add() {
    sata_handle();
    multmatrix(Mpd) sata_PowerDataSocket(type=sock);
    if (locators)
      for(c=connectors) fl_conn_add(c,2);
  }

  module do_bbox() {
    translate(fl_Y(sock_size.z))
      fl_cube(size=size,octant=-FL_Y);
  }
  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) do_bbox();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
