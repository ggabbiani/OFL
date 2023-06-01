/*!
 * 'Naive' SATA plug & socket definition.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../foundation/algo.scad>
include <../foundation/connect.scad>
include <../foundation/drawio.scad>
include <../foundation/mngm.scad>

FL_SATA_NS  = "sata";

/****************************************************************************
 * public helpers
 */

function fl_sata_instance(type,value)  = fl_property(type,"sata/connector instance (plug or socket)",value);
function fl_sata_type(type,value)   = fl_property(type,"sata/type",value);
function fl_sata_conns(type,value)  = fl_property(type,"sata/connectors",value);
function fl_sata_conn(type)         = fl_sata_conns(type)[0];

/****************************************************************************
 * PRIVATE helpers
 */

function __fl_sata_Mshell__(type,default,value) = fl_property(type,"sata/__Mshell__",value,default);
function __fl_sata_Mpower__(type,default,value) = fl_property(type,"sata/__Mpower__",value,default);
function __fl_sata_Mdata__(type,default,value)  = fl_property(type,"sata/__Mdata__",value,default);

/****************************************************************************
 * SATA data commons
 */

// TODO: change to CONSTANT?
function fl_sata_dataCID() = "sata/data Connector ID (CID)";

/****************************************************************************
 * data plug
 */

FL_SATA_DATAPLUG  = let(
  size      = [10.41,2.25,5.4],
  cid       = fl_sata_dataCID(),
  dio_pts   = [[0,0],[1,0],[1,1.1/size.y],[1.15/size.x,1.1/size.y],[1.15/size.x,1],[0,1],[0,0]],
  sz_short  = [0.84,        size.z-2*0.5,  0.1],
  sz_long   = [sz_short.x,  size.z-0.5,    0.1]
) [
  fl_sata_conns(value=[conn_Plug(cid,+FL_X,+FL_Y,[0,0,0.5])]),
  fl_bb_corners(value=[[0,-size.y,0],[size.x,0,size.z]]),
  fl_director(value=+FL_Z),fl_rotor(value=+FL_X),
  fl_sata_type(value="data plug"),
  ["points",      dio_polyCoords(dio_pts,size)],
  ["contacts",      7],
  ["contact step",  1.27],
  ["contact sizes", [
    ["short", sz_short],
    ["long",  sz_long],
  ]],
  ["contact pattern", [1,0,0]],
];

/****************************************************************************
 * SATA power commons
 */

function fl_sata_powerCID() = "sata/power Connector ID (CID)";

/****************************************************************************
 * SATA power plug
 */

FL_SATA_POWERPLUG = let(
  sz_d    = fl_size(FL_SATA_DATAPLUG),
  size    = [20.57,sz_d.y,sz_d.z],
  cid     = fl_sata_powerCID(),
  dio_pts = [
      [0,0],[1,0],[1,1],
      [1-1.15/size.x,1],
      [1-1.15/size.x,1.1/size.y],[0,1.1/size.y],[0,0]
    ],
  sz_short  = [0.84,        size.z-2*0.5,  0.1],
  sz_long   = [sz_short.x,  size.z-0.5,    0.1]
) [
  fl_sata_conns(value=[conn_Plug(cid,+FL_X,+FL_Y,[size.x,0,0.5])]),
  fl_bb_corners(value=[[0,-size.y,0],[size.x,0,size.z]]),
  fl_director(value=+FL_Z),fl_rotor(value=+FL_X),
  fl_sata_type(value="power plug"),
  ["points",        dio_polyCoords(dio_pts,size)],
  ["contacts",      15],
  ["contact step",  1.27],
  ["contact sizes", [
    ["short", sz_short],
    ["long",  sz_long],
  ]],
  ["contact pattern", [0,0,0,1,1,1]],
];

/****************************************************************************
 * SATA power+data commons
 */

function fl_sata_powerDataCID()  = "sata/power-data Connector ID (CID)";

/****************************************************************************
 * SATA power+data plug
 */

FL_SATA_POWERDATAPLUG  = let(
  power   = FL_SATA_POWERPLUG,
  data    = FL_SATA_DATAPLUG,
  sz_d    = fl_size(data),
  sz_p    = fl_size(power),
  sz_pd   = sz_d + fl_X(2.41 + sz_p.x), // without shell
  size    = [42.2,5.6,sz_pd.z],         // with shell
  cid     = fl_sata_powerDataCID(),
  Mshell  = fl_T(-fl_Y(.5)),
  Mpower  = Mshell * fl_T(-fl_X(sz_pd.x/2)) * fl_T(fl_Y(sz_pd.y/2)) * fl_T(-fl_Z(sz_pd.z/2)),
  Mdata   = Mpower * fl_T(fl_X(sz_p.x+2.41)),
  dc      = fl_conn_clone(fl_sata_conn(data),M=Mdata),
  pc      = fl_conn_clone(fl_sata_conn(power),M=Mpower)
) [
  fl_sata_conns(value=[pc,dc]),
  fl_bb_corners(value=[-size/2,+size/2]),
  fl_director(value=+FL_Z),fl_rotor(value=+FL_X),
  fl_sata_type(value="power data plug"),
  ["power plug",  power],
  ["data plug",   data],
  __fl_sata_Mshell__(value=Mshell),
  __fl_sata_Mpower__(value=Mpower),
  __fl_sata_Mdata__(value=Mdata),
];

/****************************************************************************
 * SATA power+data socket
 */

FL_SATA_POWERDATASOCKET = let(
  side_prism_h  = 1.5,
  side_blk_sz   = [2,2,4], // in OpenSCAD orientation i.e. with y,z inverted compared to Draw.io
  side_sz       = side_blk_sz + [0,0,side_prism_h],
  blk_sz        = [36.5,3.5,5],

  data_sz       = [10.7,2.3,blk_sz.z+2*FL_NIL],
  power_sz      = [20.9,2.3,data_sz.z],
  Mconn         = fl_T(fl_X((data_sz.x-power_sz.x)/2)),

  size          = blk_sz + [2*side_sz.x,0,side_blk_sz.z/8+side_prism_h],
  cid           = fl_sata_powerDataCID(),
  dio_pts       = [[1,0],[1,1],[0,0.5],[0,0]],
  Mpoly         = fl_Ry(90) * fl_T(-fl_X(side_blk_sz.x/2)-fl_Z(side_blk_sz.y/2)),
  Mprism        = fl_Ry(45) * fl_T(fl_Y(side_prism_h/2)) * fl_Rx(-90),

  inter_d       = 2.41,
  Mdata         = fl_T(fl_X((data_sz.x-power_sz.x)/2)) * fl_T([-inter_d/2,data_sz.y/2,-data_sz.z/2]),
  dc            = conn_Socket(fl_sata_dataCID(),-FL_X,+FL_Y,Mdata*[0,0,data_sz.z,1]),
  Mpower        = fl_T(fl_X((data_sz.x-power_sz.x)/2)) * fl_T([inter_d/2,power_sz.y/2,-power_sz.z/2]),
  pc            = conn_Socket(fl_sata_powerCID(),-FL_X,+FL_Y,Mpower * [0,0,power_sz.z,1])
) [
  fl_conn_id(value=cid),
  fl_sata_conns(value=[pc,dc]),
  fl_bb_corners(value=[-blk_sz/2,+blk_sz/2]),
  fl_director(value=+FL_Z),fl_rotor(value=+FL_X),
  fl_sata_type(value="power data socket"),
  ["points",      dio_polyCoords(dio_pts,[side_blk_sz.x,side_blk_sz.z,side_blk_sz.y])],
  ["block size",      blk_sz],
  ["side block size", side_blk_sz],
  ["prism l1,l2,h",   [side_blk_sz.x,0.5,side_prism_h]],

  ["data plug size",  data_sz],
  ["power plug size", power_sz],

  ["Mpoly",           Mpoly],
  ["Mprism",          Mprism],
  ["plug inter distance",    inter_d],
  __fl_sata_Mdata__(value=Mdata),
  __fl_sata_Mpower__(value=Mpower),
];

FL_SATA_DICT = [
  FL_SATA_POWERPLUG,
  FL_SATA_DATAPLUG,
  FL_SATA_POWERDATASOCKET,
  FL_SATA_POWERDATAPLUG,
];

/****************************************************************************
 * SATA data plug
 */

module fl_sata_dataPlug(
  //! FL_ADD, FL_AXES, FL_BBOX, FL_FOOTPRINT
  verbs       = FL_ADD,
  type,
  connectors  = false,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant
) {
  assert(type!=undef);
  fl_trace("verbs",verbs);

  size        = fl_size(type);
  points      = fl_get(type,"points");
  connection  = fl_sata_conns(type)[0];
  cts         = fl_get(type,"contacts");
  cont_step   = fl_get(type,"contact step");
  cont_sz     = fl_get(type,"contact sizes");
  pattern     = fl_get(type,"contact pattern");
  bbox        = fl_bb_corners(type);
  D           = direction ? fl_direction(proto=type,direction=direction)  : I;
  M           = fl_octant(octant,type=type);

  fl_trace("type",type);

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

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);
    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) do_footprint();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

/****************************************************************************
 * SATA power plug
 */

module fl_sata_powerPlug(
  //! FL_ADD, FL_AXES, FL_BBOX, FL_FOOTPRINT
  verbs       = FL_ADD,
  type,
  connectors  = false,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant
) {
  assert(type!=undef);

  bbox        = fl_bb_corners(type);
  size        = fl_size(type);
  points      = fl_get(type,"points");
  cts         = fl_get(type,"contacts");
  cont_step   = fl_get(type,"contact step");
  cont_sz     = fl_get(type,"contact sizes");
  pattern     = fl_get(type,"contact pattern");
  connection  = fl_sata_conns(type)[0];
  D           = direction ? fl_direction(type,direction=direction)  : I;
  M           = fl_octant(octant,type=type);

  fl_trace("type",type);
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

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);
    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) do_footprint();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

/****************************************************************************
 * SATA power+data plug
 */

module fl_sata_powerDataPlug(
  verbs       = FL_ADD,
  type,
  connectors  =false,
  // FIXME: really useful?
  shell       =true,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant
) {
  assert(type!=undef);

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
  M           = fl_octant(octant,type=type);

  dio_int = [[0.06,0],[0.94,0],[0.94,0.38],[1,0.38],[1,0.86],[0.94,0.86],[0.94,1],[0.06,1],[0.06,0.86],[0,0.86],[0,0.38],[0.06,0.38],[0.06,0]];
  dio_ext = [[0.02,0],[0.98,0],[1,0.18],[1,1],[0,1],[0,0.18],[0.02,0]];

  fl_trace("type",type);

  module do_footprint() {
    translate(-fl_Z(size.z/2))
    fl_cutout(size.z,delta=fl_JNgauge)
      linear_extrude(size.z)
        dio_polyCoords(points=dio_ext,size=[size.x,size.y],quadrant=FL_O);
  }

  // power data shell
  module shell() {
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

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) do_footprint();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

/****************************************************************************
 * SATA power+data socket
 */

module sata_PowerDataSocket(
  verbs     = FL_ADD,
  type,
  connectors = false,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant
) {
  assert(type!=undef);

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
  M           = fl_octant(octant,type=type);

  fl_trace("type",type);

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

  fl_manage(verbs) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) do_footprint();
    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) do_footprint();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

module fl_sata(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  type,
  connectors  = false,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant
) {
  if      (fl_sata_type(type)=="data plug")         fl_sata_dataPlug(verbs,type,connectors,direction,octant);
  else if (fl_sata_type(type)=="power plug")        fl_sata_powerPlug(verbs,type,connectors,direction,octant);
  else if (fl_sata_type(type)=="power data plug")   fl_sata_powerDataPlug(verbs,type,connectors,direction,octant);
  else if (fl_sata_type(type)=="power data socket") fl_sata_powerDataSocket(verbs,type,connectors,direction,octant);
}
