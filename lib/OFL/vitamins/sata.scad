/*!
 * 'Naive' SATA plug & socket definition.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../foundation/connect.scad>

use <../dxf.scad>
use <../foundation/algo-engine.scad>
use <../foundation/mngm-engine.scad>

/****************************************************************************
 * SATA namespace
 */

FL_SATA_NS  = "sata";

/****************************************************************************
 * public helpers
 */

function fl_sata_plug(type,value)   = fl_property(type,"sata/plug",value);
function fl_sata_sock(type,value)   = fl_property(type,"sata/socket",value);

/****************************************************************************
 * PRIVATE helpers
 */

function __fl_sata_Mpower__(type,default,value) = fl_property(type,"sata/__Mpower__",value,default);
function __fl_sata_Mdata__(type,default,value)  = fl_property(type,"sata/__Mdata__",value,default);

/****************************************************************************
 * SATA data commons
 */

// TODO: change to CONSTANT?
function fl_sata_dataCID() = "sata/data Connector ID (CID)";

/****************************************************************************
 * SATA power commons
 */

function fl_sata_powerCID() = "sata/power Connector ID (CID)";

/****************************************************************************
 * SATA power+data commons
 */

function fl_sata_powerDataCID()  = "sata/power-data Connector ID (CID)";

/****************************************************************************
 * SATA power+data socket
 */

FL_SATA_POWERDATASOCKET = let(
  side_prism_h  = 1.5,
  side_blk_sz   = [2,2,4],
  side_sz       = side_blk_sz + [0,0,side_prism_h],
  blk_sz        = [36.5,3.5,5],

  data_sz       = [10.7,2.3,blk_sz.z+2*FL_NIL],
  power_sz      = [20.9,2.3,data_sz.z],
  Mconn         = fl_T(fl_X((data_sz.x-power_sz.x)/2)),

  size          = blk_sz + [2*side_sz.x,0,side_blk_sz.z/8+side_prism_h],
  cid           = fl_sata_powerDataCID(),
  Mpoly         = fl_Ry(90) * fl_T(-fl_X(side_blk_sz.x/2)-fl_Z(side_blk_sz.y/2)),
  Mprism        = fl_Ry(45) * fl_T(fl_Y(side_prism_h/2)) * fl_Rx(-90),

  inter_d       = 2.41,
  Mdata         = fl_T(fl_X((data_sz.x-power_sz.x)/2)) * fl_T([-inter_d/2,data_sz.y/2,-data_sz.z/2]),
  dc            = conn_Socket(fl_sata_dataCID(),-FL_X,+FL_Y,Mdata*[0,0,data_sz.z,1]),
  Mpower        = fl_T(fl_X((data_sz.x-power_sz.x)/2)) * fl_T([inter_d/2,power_sz.y/2,-power_sz.z/2]),
  pc            = conn_Socket(fl_sata_powerCID(),-FL_X,+FL_Y,Mpower * [0,0,power_sz.z,1])
) fl_Object(
  bbox    = [-blk_sz/2,+blk_sz/2],
  engine  = "sata/composite socket",
  others  = [
  fl_conn_id(value=cid),
  fl_connectors(value=[pc,dc]),
  fl_cutout(value=[+Z]),
  ["points",          [[2, 0], [2, -4], [0, -2], [0, 0]]],
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
]);

FL_SATA_DATAPLUG  = let(
  dxf     = "vitamins/sata-data-plug.dxf",
  w       = __dxf_dim__(file=dxf, name="width", layer="sizes"),
  h       = __dxf_dim__(file=dxf, name="height",layer="sizes"),
  d       = __dxf_dim__(file=dxf, name="plug",  layer="extrusions"),
  size    = [w,h,d],
  cid     = fl_sata_dataCID(),
  d_short = __dxf_dim__(file=dxf, name="short", layer="extrusions"),
  d_long  = __dxf_dim__(file=dxf, name="long",  layer="extrusions"),
  c_w     = __dxf_dim__(file=dxf, name="c_width",  layer="sizes"),
  c_h     = __dxf_dim__(file=dxf, name="c_height",  layer="sizes")
) fl_Object(
  bbox    = [[0,-size.y,0],[size.x,0,size.z]],
  engine  = "sata/single plug",
  others  = [
  fl_dxf(value = dxf),
  fl_connectors(value=[conn_Plug(cid,+X,+Y,[0,0,0])]),
  fl_cutout(value=[+Z]),
  ["contact sizes", [
    ["short", [c_w,c_h,d_short]],
    ["long",  [c_w,c_h,d_long]]
  ]]
]);

FL_SATA_POWERPLUG = let(
  dxf     = "vitamins/sata-power-plug.dxf",
  w       = __dxf_dim__(file=dxf, name="width", layer="sizes"),
  h       = __dxf_dim__(file=dxf, name="height",layer="sizes"),
  d       = __dxf_dim__(file=dxf, name="plug",  layer="extrusions"),
  size    = [w,h,d],
  cid     = fl_sata_powerCID(),
  d_short = __dxf_dim__(file=dxf, name="short", layer="extrusions"),
  d_long  = __dxf_dim__(file=dxf, name="long",  layer="extrusions"),
  c_w     = __dxf_dim__(file=dxf, name="c_width",  layer="sizes"),
  c_h     = __dxf_dim__(file=dxf, name="c_height",  layer="sizes")
) fl_Object(
  bbox    = [[0,-size.y,0],[size.x,0,size.z]],
  engine  = "sata/single plug",
  others  = [
  fl_dxf(value = dxf),
  fl_connectors(value=[conn_Plug(cid,+X,+Y,[size.x,0,0])]),
  fl_cutout(value=[+Z]),
  ["contact sizes", [
    ["short", [c_w,c_h,d_short]],
    ["long",  [c_w,c_h,d_long]]
  ]]
]);

FL_SATA_POWERDATAPLUG = let(
  power   = FL_SATA_POWERPLUG,
  data    = FL_SATA_DATAPLUG,
  dxf     = "vitamins/sata-powerdata-plug.dxf",
  w       = __dxf_dim__(file=dxf, name="width", layer="sizes"),
  h       = __dxf_dim__(file=dxf, name="height",layer="sizes"),
  d       = __dxf_dim__(file=dxf, name="plug",  layer="extrusions"),
  thick   = __dxf_dim__(file=dxf, name="shell thick",layer="extrusions"),
  size    = [w,h,d+thick],
  sz_d    = fl_size(data),
  sz_p    = fl_size(power),
  cid     = fl_sata_powerDataCID(),

  // see dxf package documentation for the reason of the following conditionals
  Mpower  = let(
    p2d = version_num()>20210507
        ? __dxf_cross__(file=dxf, layer="power translation")
        : [-16.6953, 1.15039]
  ) T([p2d.x,p2d.y,thick]),
  Mdata   = let(
    p2d = version_num()>20210507
        ? __dxf_cross__(file=dxf, layer="data translation")
        : [6.28516, 1.15039]
  ) T([p2d.x,p2d.y,thick]),
  dc      = fl_conn_clone(fl_connectors(data)[0], M=Mdata *T(-Z(size.z/2))),
  pc      = fl_conn_clone(fl_connectors(power)[0],M=Mpower*T(-Z(size.z/2)))
) fl_Object(
  bbox    = [-size/2,+size/2],
  engine  = "sata/composite plug",
  others  = [
  fl_dxf(value = dxf),
  fl_connectors(value=[pc,dc]),
  fl_cutout(value=[+Z]),
  ["power plug",  power],
  ["data plug",   data],
  ["shell thick", thick],
  __fl_sata_Mpower__(value=Mpower),
  __fl_sata_Mdata__(value=Mdata),
]);

FL_SATA_DICT = [
  FL_SATA_POWERPLUG,
  FL_SATA_DATAPLUG,
  FL_SATA_POWERDATASOCKET,
  FL_SATA_POWERDATAPLUG,
];

/*!
 * SATA plug and socket module.
 *
 * Context variables:
 *
 * | Name           | Context   | Description                           |
 * | ------------   | -----     | ------------------------------------- |
 * | $dbg_Symbols   | Execution | when true connector symbols are shown |
 * | $fl_thickness  | Parameter | Used during FL_CUTOUT                 |
 * | $fl_tolerance  | Parameter | Used during FL_CUTOUT                 |
 */
module fl_sata(
  //! supported verbs: FL_ADD, FL_AXES, FL_BBOX, FL_CUTOUT, FL_FOOTPRINT
  verbs       = FL_ADD,
  type,
  //! FL_CUTOUT scalar drift
  cut_drift=0,
  /*!
   * Cutout direction list in floating semi-axis list (see also
   * fl_tt_isAxisList()).
   *
   * **NOTE:** defaults to fl_cutout() when undef (so all the preferred cutout
   * directions are included)
   *
   * Example 1:
   *
   *     cut_dirs=[+X,+Z]
   *
   * in this case the ethernet plug will perform a cutout along +X (since +Z is
   * not supported).
   *
   * Example 2:
   *
   *     cut_dirs=undef
   *
   * in this case the ethernet plug will perform a cutout along +X (the
   * supported cutout direction).
   *
   * Example 3:
   *
   *     cut_dirs=[]
   *
   * in this case the ethernet plug will not perform any cutout.
   *
   */
  cut_dirs,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction
) {
  thick       =
    is_undef($fl_thickness)       ? 0 :
    is_num($fl_thickness)         ? $fl_thickness :
    assert(is_list($fl_thickness))  $fl_thickness.z[1];
  cut_dirs    = is_undef(cut_dirs) ? fl_cutout(type) : cut_dirs;

  module singlePlug(
    verbs       = FL_ADD,
    type,
    direction,
    octant
  ) {
    assert(type!=undef);

    dxf         = fl_dxf(type);
    size        = fl_size(type);
    connection  = fl_connectors(type)[0];
    cont_sz     = fl_get(type,"contact sizes");
    bbox        = fl_bb_corners(type);

    module do_footprint()
      linear_extrude(size.z)
        __dxf__(dxf,layer="0");

    module do_add() {
      fl_color("DarkSlateGray")
        do_footprint();
      fl_color("gold") {
        linear_extrude(fl_get(cont_sz,"short").z)
          __dxf__(dxf,layer="short");
        linear_extrude(fl_get(cont_sz,"long").z)
          __dxf__(dxf,layer="long");
      }
      if (fl_dbg_symbols())
        fl_conn_add(connection,size=2,$FL_ADD="ON");
    }

    module do_cutout()
      fl_cutoutLoop(cut_dirs, fl_cutout(type))
        if ($co_preferred)
          fl_new_cutout($this_bbox,$co_current,drift=cut_drift)
            do_footprint();

    fl_vmanage(verbs,type,octant=octant,direction=direction)
      if ($this_verb==FL_ADD)
        do_add();
      else if ($this_verb==FL_BBOX)
        fl_bb_add(bbox,auto=true);
      else if ($this_verb==FL_CUTOUT)
        do_cutout();
      else if ($this_verb==FL_FOOTPRINT)
        do_footprint();
      else
        fl_error(["unimplemented verb",$this_verb]);
  }

  module compositePlug(
    verbs       = FL_ADD,
    type,
    direction,
    octant
  ) {
    assert(type!=undef);

    dxf         = fl_dxf(type);
    power_plug  = fl_get(type,"power plug");
    data_plug   = fl_get(type,"data plug");
    shell_thick = fl_get(type,"shell thick");
    data_sz     = fl_size(data_plug);
    power_sz    = fl_size(power_plug);
    size        = fl_size(type);
    conns       = fl_connectors(type);
    bbox        = fl_bb_corners(type);
    Md          = __fl_sata_Mdata__(type);
    Mp          = __fl_sata_Mpower__(type);

    module do_footprint() {
      translate(-Z(size.z/2))
        linear_extrude(size.z)
          __dxf__(dxf,layer="0");
    }

    module do_add() {
      translate(-Z(size.z/2)) {
        multmatrix(Md)
          // cloned connectors are added later, so we pass $dbg_Symbols=false
          singlePlug(type=data_plug,$dbg_Symbols=false);
        multmatrix(Mp)
          // cloned connectors are added later, so we pass $dbg_Symbols=false
          singlePlug(type=power_plug,$dbg_Symbols=false);
        fl_color("DarkSlateGray") {
          linear_extrude(shell_thick)
            __dxf__(dxf,layer="0");
          translate(Z(shell_thick))
            linear_extrude(power_sz.z)
              __dxf__(dxf,layer="1");
        }
      }
      // cloned connectors
      if (fl_dbg_symbols())
        for(c=conns)
          fl_conn_add(c,size=2,$FL_ADD="ON");
    }

    module do_cutout()
      fl_cutoutLoop(cut_dirs, fl_cutout(type))
        if ($co_preferred)
          fl_new_cutout($this_bbox,$co_current,drift=cut_drift)
            do_footprint();

    fl_vmanage(verbs,type,octant=octant,direction=direction)
      if ($this_verb==FL_ADD)
        fl_modifier($modifier)
          do_add();
      else if ($this_verb==FL_BBOX)
        fl_modifier($modifier)
          fl_bb_add(bbox,auto=true);
      else if ($this_verb==FL_CUTOUT)
        fl_modifier($modifier)
          do_cutout();
      else if ($this_verb==FL_FOOTPRINT)
        fl_modifier($modifier)
          do_footprint();
      else
        fl_error(["unimplemented verb",$this_verb]);
  }

  module compositeSocket(
    verbs     = FL_ADD,
    type,
    direction,
    octant
  ) {
    assert(type!=undef);

    connectors  = fl_dbg_symbols();
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

    conns       = fl_connectors(type);
    Mdata       = __fl_sata_Mdata__(type);
    Mpower      = __fl_sata_Mpower__(type);
    D           = direction ? fl_direction(direction)  : I;
    M           = fl_octant(octant,type=type);

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
        for(c=conns)
          fl_conn_add(c,size=2,$FL_ADD="ON");
    }

    module do_footprint()
      translate(fl_Z((size.z-block_sz.z)/2))
        fl_cube(size=size,octant=O);

    module do_cutout()
      fl_cutoutLoop(cut_dirs, fl_cutout(type))
        if ($co_preferred)
          fl_new_cutout($this_bbox,$co_current,drift=cut_drift)
            do_footprint();

    fl_vmanage(verbs,type,octant=octant,direction=direction)
      if ($this_verb==FL_ADD)
        fl_modifier($modifier)
          do_add();
      else if ($this_verb==FL_BBOX)
        fl_modifier($modifier)
          fl_bb_add(bbox,auto=true);
      else if ($this_verb==FL_CUTOUT)
        fl_modifier($modifier)
          do_cutout();
      else if ($this_verb==FL_FOOTPRINT)
        fl_modifier($modifier)
          do_footprint();
      else
        fl_error(["unimplemented verb",$this_verb]);
  }

  engine  = fl_engine(type);
  if      (engine=="sata/composite socket") compositeSocket (verbs,type,direction,octant);
  else if (engine=="sata/single plug"     ) singlePlug      (verbs,type,direction,octant);
  else if (engine=="sata/composite plug"  ) compositePlug   (verbs,type,direction,octant);
  else fl_error(["engine",engine,"not implemented"]);
}
