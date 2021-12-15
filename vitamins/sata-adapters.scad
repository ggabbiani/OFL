/*
 * 'Naive' SATA adapter definition file.
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
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
 * along with OFL.  If not, see <http: //www.gnu.org/licenses/>.
 */

include <satas.scad>

FL_SADP_NS  = "sadp";

FL_SADP_ELUTENG = 
let(
  socket      = FL_SATA_POWERDATASOCKET,
  handle_size = [47,37,11.6],
  socket_size = fl_size(socket),
  size        = [handle_size.x,handle_size.y+socket_size.z,handle_size.z],
  Mpd         = fl_T(-fl_Y(FL_NIL)) * fl_Ry(180) * fl_Rx(-90) * fl_octant(socket,+FL_Z-FL_Y)
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

use <sata-adapter.scad>