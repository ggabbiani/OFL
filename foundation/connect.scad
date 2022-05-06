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

include <symbol.scad>
include <util.scad>

//*****************************************************************************
// Connection properties
function fl_conn_id(type,value)   = fl_property(type,"conn/id",value);
function fl_conn_ox(type,value)   = fl_property(type,"conn/orientation X",value);
function fl_conn_oy(type,value)   = fl_property(type,"conn/orientation Y",value);
function fl_conn_pos(type,value)  = fl_property(type,"conn/position",value);
function fl_conn_size(type,value) = fl_property(type,"conn/size",value);
function fl_conn_type(type,value) = fl_property(type,"conn/type",value);

// contructors
function conn_Plug(id,ox,oy,pos,size=2.54) =
  assert(is_string(id))
  assert(is_list(ox))
  assert(is_list(oy))
  assert(ox*oy==0,str("ox=",ox,",oy=",oy))
  assert(is_list(pos))
  assert(is_num(size))
  [
    fl_conn_type(value="plug"),
    fl_conn_id(value=id),
    fl_conn_ox(value=ox),
    fl_conn_oy(value=oy),
    fl_conn_pos(value=pos),
    fl_conn_size(value=size),
  ];

function conn_Socket(id,ox,oy,pos,size=2.54) =
  assert(is_string(id))
  assert(is_list(ox))
  assert(is_list(oy))
  assert(ox*oy==0,str("ox=",ox,",oy=",oy))
  assert(is_list(pos))
  assert(is_num(size))
  [
    fl_conn_type(value="socket"),
    fl_conn_id(value=id),
    fl_conn_ox(value=ox),
    fl_conn_oy(value=oy),
    fl_conn_pos(value=pos),
    fl_conn_size(value=size),
  ];

// massive connection clone eventually transformed
function fl_conn_import(conns,M) = [for(c=conns) fl_conn_clone(c,M=M)];

// returns a copy of the given connection with eventual rewriting of attributes
function fl_conn_clone(
  original  // MANDATORY original connection to be cloned
  ,type     // OPTIONAL new connection type ("socket" or "plug")
  ,id       // OPTIONAL new connection id
  ,ox       // OPTIONAL new orientation X
  ,oy       // OPTIONAL new orientation Y
  ,pos      // OPTIONAL new position
  ,M=I      // OPTIONAL transformation matrix for position transformation
) =
  assert(original!=undef)
  assert(ox==undef  || len(ox)==3)
  assert(oy==undef  || len(oy)==3)
  assert(pos==undef || len(pos)==3)
  let(
    type      = type==undef   ? fl_conn_type(original) : type,
    id        = id==undef ? fl_conn_id(original) : id,
    orig_ox_3 = fl_conn_ox(original),
    orig_oy_3 = fl_conn_oy(original),
    orig_size = fl_conn_size(original),
    tran_ox_4 = fl_transform(M,orig_ox_3),
    tran_oy_4 = fl_transform(M,orig_oy_3),
    trans_O_4 = fl_transform(M,O),

    x_3   = ox!=undef     ? ox  :  fl_3(tran_ox_4) - fl_3(trans_O_4),
    y_3   = oy!=undef     ? oy  :  fl_3(tran_oy_4) - fl_3(trans_O_4),
    p_3   = pos!=undef    ? pos :  fl_transform(M,fl_conn_pos(original))
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
  type=="plug" ? conn_Plug(id,x_3,y_3,p_3,orig_size) : conn_Socket(id,x_3,y_3,p_3,orig_size);

/**
 * Returns the transformation matrix moving child shape to its parent
 * coherently with their respective connection geometries.
 * Child can be thought as a mobile socket/plug jointing a fixed plug/socket
 * (the parent).
 *
 * The transformations applied to children are:
 *
 * 1. move children connector to origin
 * 2. align children axes to parent connector axes
 * 3. move children connector to parent connector position
 *
 * TODO: symbol orientation is managed by passing x and y plane while
 * calculating z consequently. It should be managed through the couple
 * [director,rotor] instead.
 */
function fl_connect(
  // child to be moved, either a connector or a list [child object,connector number]
  son,
  // fixed parent, either a connector or a list [parent object,connector number]
  parent
  ) = let(
    son_c = len(son)==2     ? fl_connectors(son[0])[son[1]]       : son,
    par_c = len(parent)==2  ? fl_connectors(parent[0])[parent[1]] : parent,

    son_ox        = fl_conn_ox(son_c),
    son_oy        = fl_conn_oy(son_c),
    son_pos       = fl_conn_pos(son_c),

    par_ox        = fl_conn_ox(par_c),
    par_oy        = fl_conn_oy(par_c),
    par_pos       = fl_conn_pos(par_c)
  ) T(+par_pos) * fl_planeAlign(son_ox,son_oy,par_ox,par_oy) * T(-son_pos);

/**
 * See function fl_connect() for docs.
 *
 * Children context:
 * $con_child   - OPTIONAL child object (undef when direct connector is passed)
 * $con_parent  - OPTIONAL parent object (undef when direct connector is passed)
 */
module fl_connect(
  // child to be moved, can be either a connector or a list [object,connector number]
  son,
  // fixed parent, can be either a connector or a list [object,connector number]
  parent
  ) {
  son_c       = len(son)==2 ? fl_connectors(son[0])[son[1]] : son;
  par_c       = len(parent)==2 ? fl_connectors(parent[0])[parent[1]] : parent;

  son_type    = fl_conn_type(son_c);
  son_fprint  = fl_conn_id(son_c);

  par_type    = fl_conn_type(par_c);
  par_fprint  = fl_conn_id(par_c);

  M           = fl_connect(son,parent);

  assert(son_type!=par_type,str("son:",son_type,",parent:",par_type));
  assert(son_fprint==par_fprint,str("Trying to connect '",son_fprint,"'' with '",par_fprint,"'."));
  let(
    $con_child  = len(son)==2 ?     son[0]    : undef,
    $con_parent = len(parent)==2 ?  parent[0] : undef
  ) multmatrix(M) children();
}

// Adds proper connection symbol (plug or socket) to the scene
module fl_conn_add(connector,size,label) {
  assert(connector!=undef);
  fl_conn_Context(connector)
    multmatrix(T($conn_pos)*fl_planeAlign(X,Y,$conn_ox,$conn_oy))
      fl_symbol(size=size,symbol=$conn_type);
}

/**
 * Prepares context for children() connectors
 *
 * $conn_i      - OPTIONAL connection number
 * $conn_ox     - X axis
 * $conn_oy     - Y axis
 * $conn_label  - OPTIONAL string label
 * $conn_pos    - position
 * $conn_size   - OPTIONAL connector size
 * $conn_type   - connector type
 */
module fl_conn_Context(
  connector,
  // OPTIONAL connection number
  ordinal
) {
  $conn_i     = ordinal;
  $conn_pos   = fl_conn_pos(connector);
  $conn_ox    = fl_conn_ox(connector);
  $conn_oy    = fl_conn_oy(connector);
  $conn_type  = fl_conn_type(connector);
  $conn_size  = fl_optional(connector,fl_conn_size()[0]);
  $conn_label = is_num(ordinal) ? str("C",ordinal) : undef;

  children();
}

/**
 * Layouts children along a list of connectors.
 * See fl_conn_Context() for context variables passed to children().
 */
module fl_lay_connectors(
  // list of connectors
  conns
) for(i=[0:len(conns)-1])
    fl_conn_Context(conns[i],i)
      multmatrix(T($conn_pos)*fl_planeAlign(X,Y,$conn_ox,$conn_oy))
        children();

/**
 * Layouts connector symbols
 */
module fl_conn_debug(
  // list of connectors
  conns
) fl_lay_connectors(conns)
    fl_symbol(size=2.54,symbol=$conn_type);
