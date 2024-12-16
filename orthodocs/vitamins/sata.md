# package vitamins/sata

## Dependencies

```mermaid
graph LR
    A1[vitamins/sata] --o|include| A2[foundation/connect]
    A1 --o|use| A3[dxf]
    A1 --o|use| A4[foundation/algo-engine]
    A1 --o|use| A5[foundation/mngm-engine]
```

'Naive' SATA plug & socket definition.

Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Variables

---

### variable FL_SATA_DATAPLUG

__Default:__

    let(dxf="vitamins/sata-data-plug.dxf",w=__dxf_dim__(file=dxf,name="width",layer="sizes"),h=__dxf_dim__(file=dxf,name="height",layer="sizes"),d=__dxf_dim__(file=dxf,name="plug",layer="extrusions"),size=[w,h,d],cid=fl_sata_dataCID(),d_short=__dxf_dim__(file=dxf,name="short",layer="extrusions"),d_long=__dxf_dim__(file=dxf,name="long",layer="extrusions"),c_w=__dxf_dim__(file=dxf,name="c_width",layer="sizes"),c_h=__dxf_dim__(file=dxf,name="c_height",layer="sizes"))[fl_dxf(value=dxf),fl_connectors(value=[conn_Plug(cid,+X,+Y,[0,0,0.5])]),fl_bb_corners(value=[[0,-size.y,0],[size.x,0,size.z]]),fl_engine(value="sata/single plug"),["contact sizes",[["short",[c_w,c_h,d_short]],["long",[c_w,c_h,d_long]]]]]

---

### variable FL_SATA_DICT

__Default:__

    [FL_SATA_POWERPLUG,FL_SATA_DATAPLUG,FL_SATA_POWERDATASOCKET,FL_SATA_POWERDATAPLUG,]

---

### variable FL_SATA_NS

__Default:__

    "sata"

---

### variable FL_SATA_POWERDATAPLUG

__Default:__

    let(power=FL_SATA_POWERPLUG,data=FL_SATA_DATAPLUG,dxf="vitamins/sata-powerdata-plug.dxf",w=__dxf_dim__(file=dxf,name="width",layer="sizes"),h=__dxf_dim__(file=dxf,name="height",layer="sizes"),d=__dxf_dim__(file=dxf,name="plug",layer="extrusions"),thick=__dxf_dim__(file=dxf,name="shell thick",layer="extrusions"),size=[w,h,d+thick],sz_d=fl_size(data),sz_p=fl_size(power),cid=fl_sata_powerDataCID(),Mpower=let(p2d=version_num()>20210507?__dxf_cross__(file=dxf,layer="power translation"):[-16.6953,1.15039])T([p2d.x,p2d.y,thick]),Mdata=let(p2d=version_num()>20210507?__dxf_cross__(file=dxf,layer="data translation"):[6.28516,1.15039])T([p2d.x,p2d.y,thick]),dc=fl_conn_clone(fl_connectors(data)[0],M=Mdata*T(-Z(size.z/2))),pc=fl_conn_clone(fl_connectors(power)[0],M=Mpower*T(-Z(size.z/2))))[fl_dxf(value=dxf),fl_connectors(value=[pc,dc]),fl_bb_corners(value=[-size/2,+size/2]),fl_engine(value="sata/composite plug"),["power plug",power],["data plug",data],["shell thick",thick],__fl_sata_Mpower__(value=Mpower),__fl_sata_Mdata__(value=Mdata),]

---

### variable FL_SATA_POWERDATASOCKET

__Default:__

    let(side_prism_h=1.5,side_blk_sz=[2,2,4],side_sz=side_blk_sz+[0,0,side_prism_h],blk_sz=[36.5,3.5,5],data_sz=[10.7,2.3,blk_sz.z+2*FL_NIL],power_sz=[20.9,2.3,data_sz.z],Mconn=fl_T(fl_X((data_sz.x-power_sz.x)/2)),size=blk_sz+[2*side_sz.x,0,side_blk_sz.z/8+side_prism_h],cid=fl_sata_powerDataCID(),Mpoly=fl_Ry(90)*fl_T(-fl_X(side_blk_sz.x/2)-fl_Z(side_blk_sz.y/2)),Mprism=fl_Ry(45)*fl_T(fl_Y(side_prism_h/2))*fl_Rx(-90),inter_d=2.41,Mdata=fl_T(fl_X((data_sz.x-power_sz.x)/2))*fl_T([-inter_d/2,data_sz.y/2,-data_sz.z/2]),dc=conn_Socket(fl_sata_dataCID(),-FL_X,+FL_Y,Mdata*[0,0,data_sz.z,1]),Mpower=fl_T(fl_X((data_sz.x-power_sz.x)/2))*fl_T([inter_d/2,power_sz.y/2,-power_sz.z/2]),pc=conn_Socket(fl_sata_powerCID(),-FL_X,+FL_Y,Mpower*[0,0,power_sz.z,1]))[fl_conn_id(value=cid),fl_connectors(value=[pc,dc]),fl_bb_corners(value=[-blk_sz/2,+blk_sz/2]),fl_engine(value="sata/power+data socket"),["points",[[2,0],[2,-4],[0,-2],[0,0]]],["block size",blk_sz],["side block size",side_blk_sz],["prism l1,l2,h",[side_blk_sz.x,0.5,side_prism_h]],["data plug size",data_sz],["power plug size",power_sz],["Mpoly",Mpoly],["Mprism",Mprism],["plug inter distance",inter_d],__fl_sata_Mdata__(value=Mdata),__fl_sata_Mpower__(value=Mpower),]

---

### variable FL_SATA_POWERPLUG

__Default:__

    let(dxf="vitamins/sata-power-plug.dxf",w=__dxf_dim__(file=dxf,name="width",layer="sizes"),h=__dxf_dim__(file=dxf,name="height",layer="sizes"),d=__dxf_dim__(file=dxf,name="plug",layer="extrusions"),size=[w,h,d],cid=fl_sata_powerCID(),d_short=__dxf_dim__(file=dxf,name="short",layer="extrusions"),d_long=__dxf_dim__(file=dxf,name="long",layer="extrusions"),c_w=__dxf_dim__(file=dxf,name="c_width",layer="sizes"),c_h=__dxf_dim__(file=dxf,name="c_height",layer="sizes"))[fl_dxf(value=dxf),fl_connectors(value=[conn_Plug(cid,+X,+Y,[size.x,0,0.5])]),fl_bb_corners(value=[[0,-size.y,0],[size.x,0,size.z]]),fl_engine(value="sata/single plug"),["contact sizes",[["short",[c_w,c_h,d_short]],["long",[c_w,c_h,d_long]]]]]

## Functions

---

### function fl_sata_dataCID

__Syntax:__

```text
fl_sata_dataCID()
```

---

### function fl_sata_plug

__Syntax:__

```text
fl_sata_plug(type,value)
```

---

### function fl_sata_powerCID

__Syntax:__

```text
fl_sata_powerCID()
```

---

### function fl_sata_powerDataCID

__Syntax:__

```text
fl_sata_powerDataCID()
```

---

### function fl_sata_sock

__Syntax:__

```text
fl_sata_sock(type,value)
```

## Modules

---

### module fl_sata

__Syntax:__

    fl_sata(verbs=FL_ADD,type,shell=true,direction,octant)

SATA plug and socket module.

Implemented debug context:

| Name         | Description                            |
| ------------ | -------------------------------------- |
| $dbg_Symbols | when true connector symbols are shown  |


__Parameters:__

__verbs__  
supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT

__direction__  
desired direction [director,rotation], native direction when undef ([+X+Y+Z])

__octant__  
when undef native positioning is used


