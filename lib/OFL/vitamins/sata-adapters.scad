/*!
 * 'Naive' SATA adapter definition file.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <sata.scad>
use <../foundation/mngm-engine.scad>

FL_SADP_NS  = "sadp";

FL_SADP_ELUTENG =
let(
  socket      = FL_SATA_POWERDATASOCKET,
  handle_size = [47,37,11.6],
  socket_size = fl_size(socket),
  size        = [handle_size.x,handle_size.y+socket_size.z,handle_size.z],
  Mpd         = T(-Y(FL_NIL)) * Ry(180) * Rx(-90) * fl_octant(+Z-Y,type=socket)
)
[
  fl_name(value="ELUTENG USB 3.0 TO SATA ADAPTER"),
  fl_bb_corners(value=[[-size.x/2,-handle_size.y,-size.z/2],[size.x/2,socket_size.z,+size.z/2]]),
  fl_vendor(value=[["Amazon", "https://www.amazon.it/gp/product/B06XCV1W97/"]]),
  ["handle size", handle_size],
  ["Mpd",         Mpd],
  ["connectors",  fl_conn_import(fl_connectors(socket),Mpd)],
  ["SATA socket", socket],
];

FL_SADP_DICT = [
  FL_SADP_ELUTENG,
];

module sata_adapter(
  verbs,
  type,
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
  locators    = fl_dbg_symbols();
  bbox        = fl_bb_corners(type);

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
    multmatrix(Mpd) fl_sata(type=sock);
    if (locators)
      for(c=connectors) fl_conn_add(c,2);
  }

  fl_vloop(verbs,bbox,octant,direction) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier)
        fl_bb_add(bbox,auto=true);
    } else {
      fl_error(["unimplemented verb",$this_verb]);
    }
  }
}
