/*!
 * utility toolkit for connecting objects
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <util.scad>

//*****************************************************************************
// Connection properties
function fl_conn_id(type,value)   = fl_property(type,"conn/id",value);
function fl_conn_ox(type,value)   = fl_property(type,"conn/orientation X",value);
function fl_conn_oy(type,value)   = fl_property(type,"conn/orientation Y",value);
function fl_conn_pos(type,value)  = fl_property(type,"conn/position",value);
function fl_conn_size(type,value) = fl_property(type,"conn/scalar size",value);
function fl_conn_type(type,value) = fl_property(type,"conn/type",value);
function fl_conn_ldir(type,value) = fl_property(type,"conn/label [direction,rotation]",value);
function fl_conn_loct(type,value) = fl_property(type,"conn/label octant",value);

/*!
 * constructors
 *
 * TODO: a more convenient way for positioning is the one used for holes.
 */
function conn_Plug(id,ox,oy,pos,size=2.54,octant,direction=[+FL_Z,0]) =
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
    fl_conn_ldir(value=direction),
    fl_conn_loct(value=octant),
  ];

function conn_Socket(id,ox,oy,pos,size=2.54,octant,direction=[+FL_Z,0]) =
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
    fl_conn_ldir(value=direction),
    fl_conn_loct(value=octant),
  ];

//! massive connection clone eventually transformed
function fl_conn_import(conns,M) = [for(c=conns) fl_conn_clone(c,M=M)];

//! returns a copy of the given connection with eventual rewriting of attributes
function fl_conn_clone(
  //! MANDATORY original connection to be cloned
  original,
  //! OPTIONAL new connection type ("socket" or "plug")
  type,
  //! OPTIONAL new connection id
  id,
  //! OPTIONAL new orientation X
  ox,
  //! OPTIONAL new orientation Y
  oy,
  //! OPTIONAL new position
  pos,
  //! OPTIONAL new size
  size,
  //! OPTIONAL label octant
  octant,
  //! OPTIONAL label [direction,rotation]
  direction,
  //! OPTIONAL transformation matrix for position transformation
  M=I
) =
  assert(original!=undef)
  assert(ox==undef  || len(ox)==3)
  assert(oy==undef  || len(oy)==3)
  assert(pos==undef || len(pos)==3)
  let(
    type      = type  ? type  : fl_conn_type(original),
    id        = id    ? id    : fl_conn_id(original),
    orig_ox_3 = fl_conn_ox(original),
    orig_oy_3 = fl_conn_oy(original),
    tran_ox_4 = fl_transform(M,orig_ox_3),
    tran_oy_4 = fl_transform(M,orig_oy_3),
    trans_O_4 = fl_transform(M,O),

    size      = size      ? size      : fl_conn_size(original),
    octant    = octant    ? octant    : fl_conn_loct(original),
    direction = direction ? direction : fl_conn_ldir(original),

    x_3   = ox!=undef     ? ox  :  fl_3(tran_ox_4) - fl_3(trans_O_4),
    y_3   = oy!=undef     ? oy  :  fl_3(tran_oy_4) - fl_3(trans_O_4),
    p_3   = pos!=undef    ? pos :  fl_transform(M,fl_conn_pos(original))
  )
  // echo(orig_ox_3=orig_ox_3)
  // echo(orig_oy_3=orig_oy_3)
  // echo(M=M)
  // echo(x_3=x_3)
  // echo(y_3=y_3)
  // FIXME: next statements run in error even if they shouldn't (OpenSCAD bug/regression?)
  // assert(norm(orig_ox_3)==1)
  // assert(norm(orig_oy_3)==1,orig_oy_3)
  // assert(norm(x_3)==1)
  // assert(norm(y_3)==1,y_3)
  assert(orig_ox_3*orig_oy_3==0,"Original orientation fl_axes are not orthogonal")
  assert(x_3*y_3==0,"Resulting orientation fl_axes are not orthogonal")
  type=="plug" ? conn_Plug(id,x_3,y_3,p_3,size,octant,direction) : conn_Socket(id,x_3,y_3,p_3,size,octant,direction);

/*!
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
  //! child to be moved, either a connector or a list [child object,connector number]
  son,
  //! fixed parent, either a connector or a list [parent object,connector number]
  parent,
  //! parent octant
  octant,
  //! parent direction
  direction
  ) = let(
    son_c = len(son)==2     ? fl_connectors(son[0])[son[1]]       : son,
    par_c = len(parent)==2  ? fl_connectors(parent[0])[parent[1]] : parent,

    son_ox        = fl_conn_ox(son_c),
    son_oy        = fl_conn_oy(son_c),
    son_pos       = fl_conn_pos(son_c),

    par_ox        = fl_conn_ox(par_c),
    par_oy        = fl_conn_oy(par_c),
    par_pos       = fl_conn_pos(par_c),

    M_dir         = direction ? fl_direction(direction) : I,
    T_oct         = let(
      M_oct = len(parent)==2 && octant ? fl_octant(octant,parent[0]) : I
    ) T([M_oct.x[3],M_oct.y[3],M_oct.z[3]])
  ) M_dir * T_oct * T(+par_pos) * fl_planeAlign(son_ox,son_oy,par_ox,par_oy) * T(-son_pos);

/*!
 * See function fl_connect() for docs.
 *
 * Context variables:
 *
 * | Name         | Context   | Description |
 * | ---          | ---       | ---         |
 * | $con_child   | Children  | OPTIONAL child object (undef when direct connector is passed)   |
 * | $con_parent  | Children  | OPTIONAL parent object (undef when direct connector is passed)  |
 */
module fl_connect(
  //! child to be moved, can be either a connector or a list [object,connector number]
  son,
  //! fixed parent, can be either a connector or a list [object,connector number]
  parent,
  //! parent octant
  octant,
  //! parent direction
  direction
  ) {
  son_c       = len(son)==2 ? fl_connectors(son[0])[son[1]] : son;
  par_c       = len(parent)==2 ? fl_connectors(parent[0])[parent[1]] : parent;

  son_type    = fl_conn_type(son_c);
  son_fprint  = fl_conn_id(son_c);

  par_type    = fl_conn_type(par_c);
  par_fprint  = fl_conn_id(par_c);

  M           = fl_connect(son,parent,octant,direction);

  assert(son_type!=par_type,str("son:",son_type,",parent:",par_type));
  assert(son_fprint==par_fprint,str("Trying to connect '",son_fprint,"'' with '",par_fprint,"'."));
  let(
    $con_child  = len(son)==2 ?     son[0]    : undef,
    $con_parent = len(parent)==2 ?  parent[0] : undef
  ) multmatrix(M) children();
}

//! Adds proper connection symbol (plug or socket) to the scene
module fl_conn_add(connector,size,label) {
  assert(connector!=undef);
  fl_conn_Context(connector)
    multmatrix(T($conn_pos)*fl_planeAlign(X,Y,$conn_ox,$conn_oy))
      fl_symbol(size=size,symbol=$conn_type);
}

/*!
 * Prepares context for children() connectors
 *
 * - $conn_i    : OPTIONAL connection number
 * - $conn_ox   : X axis
 * - $conn_oy   : Y axis
 * - $conn_label: OPTIONAL string label
 * - $conn_ldir : [direction,rotation]
 * - $conn_loct : label octant
 * - $conn_pos  : position
 * - $conn_size : OPTIONAL connector size
 * - $conn_type : connector type
 */
module fl_conn_Context(
  connector,
  //! OPTIONAL connection number
  ordinal
) {
  $conn_i     = ordinal;
  $conn_pos   = fl_conn_pos(connector);
  $conn_ox    = fl_conn_ox(connector);
  $conn_oy    = fl_conn_oy(connector);
  $conn_type  = fl_conn_type(connector);
  $conn_size  = fl_optional(connector,fl_conn_size()[0]);
  $conn_label = is_num(ordinal) ? str("C",ordinal) : undef;
  $conn_ldir  = fl_conn_ldir(connector);
  $conn_loct  = fl_conn_loct(connector);

  children();
}

/*!
 * Layouts children along a list of connectors.
 *
 * See fl_conn_Context{} for context variables passed to children().
 */
module fl_lay_connectors(
  //! list of connectors
  conns
) for(i=[0:len(conns)-1])
    fl_conn_Context(conns[i],i)
      multmatrix(T($conn_pos)*fl_planeAlign(FL_X,FL_Y,$conn_ox,$conn_oy))
        children();

/*!
 * Layouts connector symbols.
 */
module fl_conn_debug(
  //! list of connectors
  conns
) {
  fl_lay_connectors(conns) union() {
    if (fl_dbg_symbols())
      fl_symbol(FL_ADD,size=$conn_size,symbol=$conn_type,$FL_ADD="ON");
    if (fl_dbg_labels())
      echo($conn_label=$conn_label,$conn_loct=$conn_loct,$conn_ldir=$conn_ldir)
      // multmatrix(T(0.6*$conn_size*[sign($conn_loct.x),sign($conn_loct.y),sign($conn_loct.z)]))
        fl_label(FL_ADD,$conn_label,size=0.6*$conn_size,thick=0.1,octant=$conn_loct,direction=$conn_ldir,extra=$conn_size,$FL_ADD="ON",$FL_AXES="ON");
  }
}