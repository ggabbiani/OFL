/*
 * 'Naive' SATA plug & socket definition.
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


include <../foundation/incs.scad>

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

use     <sata.scad>
