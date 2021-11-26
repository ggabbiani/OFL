/*
 * 'Naive' SATA adapter implementation file.
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

include <sata-adapters.scad>

module sata_adapter(
  verbs,
  type,
  locators=false,
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant                // when undef native positioning is used
) {
  assert(verbs!=undef);
  axes        = fl_list_has(verbs,FL_AXES);
  verbs       = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);
  handle_size = fl_get(type,"handle size");
  sock        = fl_get(type,"SATA socket");
  sock_size   = fl_size(sock);
  size        = fl_size(type);
  Mpd         = fl_get(type,"Mpd");
  connectors  = fl_connectors(type);
  D           = direction ? fl_direction(type,direction=direction)  : FL_I;
  M           = octant    ? fl_octant(type,octant=octant)           : FL_I;

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
    %translate(fl_Y(sock_size.z))
      fl_cube(size=size,octant=-FL_Y);
  }
  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_add();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) do_bbox();
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=size/2);
  }

}
