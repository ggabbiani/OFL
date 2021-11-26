/*
 * 'Naive' SATA plug & socket implementation.
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

include <../foundation/unsafe_defs.scad>
include <../foundation/incs.scad>

/****************************************************************************
 * SATA data commons
 */

// TODO: change to CONSTANT?
function fl_sata_dataCID() = "sata/data connector footprint";

/****************************************************************************
 * SATA data plug
 */

module fl_sata_dataPlug(
  verbs       = FL_ADD, // FL_ADD, FL_AXES, FL_BBOX, FL_FOOTPRINT
  type,
  connectors  = false,  
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant                // when undef native positioning is used
) {
  assert(type!=undef);
  fl_trace("verbs",verbs);

  axes        = fl_list_has(verbs,FL_AXES);
  verbs       = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);
  size        = fl_size(type);
  points      = fl_get(type,"points");
  connection  = fl_sata_conns(type)[0];
  cts         = fl_get(type,"contacts");
  cont_step   = fl_get(type,"contact step");
  cont_sz     = fl_get(type,"contact sizes");
  pattern     = fl_get(type,"contact pattern");
  bbox        = fl_bb_corners(type);
  D           = direction ? fl_direction(proto=type,direction=direction)  : I;
  M           = octant    ? fl_octant(type,octant=octant)                 : I;

  module do_footprint() {
    linear_extrude(size.z) polygon(points);
  }

  module do_add() {
    fl_color("DarkSlateGray") do_footprint();
    fl_color("gold") 
      translate(-Y(1.1)+X(1.15+(size.x-1.15-cont_step*6-cont_sz[0][1].x)/2)) rotate(-90,X) 
        fl_algo_pattern(cts,pattern,cont_sz,[cont_step,0,0],align=-Y,octant=+X);
    if (connectors)
      fl_conn_add(connection,size=2);
  }

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_add();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_bb_add(bbox);
      } else if ($verb==FL_FOOTPRINT) {
        fl_modifier($FL_FOOTPRINT) do_footprint();
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=size);
  }
}

/****************************************************************************
 * SATA power commons
 */

function fl_sata_powerCID() = "sata/power connector footprint";

/****************************************************************************
 * SATA power plug
 */

module fl_sata_powerPlug(
  verbs       = FL_ADD, // FL_ADD, FL_AXES, FL_BBOX, FL_FOOTPRINT
  type,
  connectors  = false,  
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant                // when undef native positioning is used
) {
  assert(type!=undef);
  axes        = fl_list_has(verbs,FL_AXES);
  verbs       = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);
  bbox        = fl_bb_corners(type);
  size        = fl_size(type);
  points      = fl_get(type,"points");
  cts         = fl_get(type,"contacts");
  cont_step   = fl_get(type,"contact step");
  cont_sz     = fl_get(type,"contact sizes");
  pattern     = fl_get(type,"contact pattern");
  connection  = fl_sata_conns(type)[0];
  D           = direction ? fl_direction(type,direction=direction)  : I;
  M           = octant    ? fl_octant(type,octant=octant)           : I;

  fl_trace("connection",connection);
  fl_trace("bounding box",bbox);

  module do_footprint() {
    linear_extrude(size.z) polygon(points);
  }

  module do_add() {
    // plug part
    fl_color("DarkSlateGray") do_footprint();
    fl_color("gold") 
      translate(-fl_Y(1.1)+fl_X((size.x-1.15-cont_step*14-cont_sz[0][1].x)/2)) rotate(-90,FL_X)
        fl_algo_pattern(cts,pattern,cont_sz,[cont_step,0,0],align=-FL_Y,octant=+FL_X);
    if (connectors)
      fl_conn_add(connection,size=2);
  }

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_add();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_bb_add(bbox);
      } else if ($verb==FL_FOOTPRINT) {
        fl_modifier($FL_FOOTPRINT) do_footprint();
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=size);
  }

}

/****************************************************************************
 * SATA power+data commons
 */

function fl_sata_powerDataCID()  = "sata/power-data connector footprint";

/****************************************************************************
 * SATA power+data plug
 */

module fl_sata_powerDataPlug(
  verbs       = FL_ADD,
  type,
  connectors = false,
  shell      = true,
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant                // when undef native positioning is used
) {
  assert(type!=undef);
  axes        = fl_list_has(verbs,FL_AXES);
  verbs       = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  power_plug  = fl_get(type,"power plug");
  data_plug   = fl_get(type,"data plug");
  data_sz     = fl_size(data_plug);
  power_sz    = fl_size(power_plug);
  size        = fl_size(type);
  conns       = fl_sata_conns(type);
  bbox        = fl_bb_corners(type);
  Md          = __fl_sata_Mdata__(type);
  Mp          = __fl_sata_Mpower__(type);
  Ms          = __fl_sata_Mshell__(type);
  D           = direction ? fl_direction(type,direction=direction)  : I;
  M           = octant    ? fl_octant(type,octant=octant)           : I;

  // power data shell
  module shell() {
    dio_int = [[0.06,0],[0.94,0],[0.94,0.38],[1,0.38],[1,0.86],[0.94,0.86],[0.94,1],[0.06,1],[0.06,0.86],[0,0.86],[0,0.38],[0.06,0.38],[0.06,0]];
    dio_ext = [[0.02,0],[0.98,0],[1,0.18],[1,1],[0,1],[0,0.18],[0.02,0]];

    translate(-fl_Z(size.z/2))
    fl_color("DarkSlateGray") linear_extrude(size.z)
      difference() {
        translate(fl_Y(0.5)) dio_polyCoords(points=dio_ext,size=[size.x,size.y],quadrant=FL_O);
        dio_polyCoords(points=dio_int,size=[41.1,4.7],quadrant=O);
      }
  }

  module do_add() {
    multmatrix(Md) fl_sata_dataPlug(type=data_plug);
    multmatrix(Mp) fl_sata_powerPlug(type=power_plug);
    if (connectors) 
      for(c=conns) fl_conn_add(c,size=2);
    if (shell) 
      multmatrix(Ms) shell();
  }

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_add();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_bb_add(bbox);
      } else if ($verb==FL_FOOTPRINT) {
        fl_modifier($FL_FOOTPRINT) fl_bb_add(bbox);
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes([size.x/2,size.y,size.z]);
  }
}

/****************************************************************************
 * SATA power+data socket
 */

module sata_PowerDataSocket(
  verbs     = FL_ADD,
  type,
  connectors = false,
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant                // when undef native positioning is used
) {
  assert(type!=undef);
  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  size        = fl_size(type);
  points      = fl_get(type,"points");
  prism       = fl_get(type,"prism l1,l2,h");
  Mpoly       = fl_get(type,"Mpoly");
  Mprism      = fl_get(type,"Mprism");
  sideblk_sz  = fl_get(type,"side block size");
  block_sz    = fl_get(type,"block size");
  inter_d     = fl_get(type,"plug inter distance");
  bbox        = fl_bb_corners(type);

  data_sz     = fl_get(type,"data plug size");
  power_sz    = fl_get(type,"power plug size");
  
  conns       = fl_sata_conns(type);
  Mdata       = __fl_sata_Mdata__(type);
  Mpower      = __fl_sata_Mpower__(type);
  D           = direction ? fl_direction(type,direction=direction)  : I;
  M           = octant    ? fl_octant(type,octant=octant)           : I;

  module side_plug() {
    multmatrix(Mpoly)
      linear_extrude(sideblk_sz.y)
        polygon(points);
    multmatrix(Mprism)
      fl_prism(n=4,h=prism.z,l1=prism[0],l2=prism[1],octant=O);
  }

  module data_hole() {
    size    = data_sz;
    points  = [[-size.x,0],[0,0],[0,-size.y],[-1.5,-size.y],[-1.5,-1.25],[-size.x,-1.25],[-size.x,0]];
    linear_extrude(size.z)
      polygon(points);
  }

  module power_hole() {
    size    = power_sz;
    points  = [[0,0],[size.x,0],[size.x,-1.25],[1.5,-1.25],[1.5,-size.y],[0,-size.y],[0,0]];
    linear_extrude(size.z)
      polygon(points);
  }

  module do_add() {
    fl_color("DodgerBlue") difference() {
      union() { // main body
        fl_cube(size=block_sz,octant=FL_O);
        for (i=[-1,1])   
          translate(i*fl_X((block_sz.x+sideblk_sz.x)/2)+fl_Z(sideblk_sz.z*3/4))
          rotate(-90,FL_X)
            rotate(fl_Y(i*3*90)) 
            rotate(180,FL_X)
              side_plug();
      }
      multmatrix(Mpower)  power_hole();
      multmatrix(Mdata)   data_hole();
    }
    if (connectors) // adds connectors 
      for(c=conns) fl_conn_add(c,size=2);
  }

  module do_footprint() {
    translate(fl_Z((size.z-block_sz.z)/2)) fl_cube(size=size,octant=O);
  }

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_add();
      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) do_footprint();
      } else if ($verb==FL_FOOTPRINT) {
        fl_modifier($FL_FOOTPRINT) do_footprint();
      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes([size.x/2,size.y,size.z]);
  }
}

module fl_sata(
  verbs       = FL_ADD, // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  type,
  connectors  = false,  
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant                // when undef native positioning is used
) {
  if      (fl_sata_engine(type)=="data plug")         fl_sata_dataPlug(verbs,type,connectors,direction,octant);
  else if (fl_sata_engine(type)=="power plug")        fl_sata_powerPlug(verbs,type,connectors,direction,octant);
  else if (fl_sata_engine(type)=="power data plug")   fl_sata_powerDataPlug(verbs,type,connectors,direction,octant);
  else if (fl_sata_engine(type)=="power data socket") fl_sata_powerDataSocket(verbs,type,connectors,direction,octant);
}
