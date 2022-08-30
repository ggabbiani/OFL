# package vitamins/hds


__Includes:__

    foundation/hole
    vitamins/sata
    vitamins/screw

## Variables


---

### variable FL_HD_DICT

__Default:__

    [FL_HD_EVO860]

---

### variable FL_HD_EVO860

__Default:__

    let(size=[70,100,6.7],plug=FL_SATA_POWERDATAPLUG,cid=fl_sata_powerDataCID(),screw=M3_cs_cap_screw,screw_r=screw_radius(screw),Mpd=let(w=size.x,l=fl_size(plug).x,d=7)fl_T(fl_X((l-w+2*d)/2)-fl_Z(FL_NIL))*fl_Rx(90)*fl_octant(+Y-Z,type=plug),conns=fl_sata_conns(plug),pc=fl_conn_clone(conns[0],M=Mpd),dc=fl_conn_clone(conns[1],M=Mpd))[fl_name(value="Samsung V-NAND SSD 860 EVO"),fl_engine(value=FL_HD_NS),fl_bb_corners(value=[[-size.x/2,0,0],[+size.x/2,+size.y,+size.z],]),fl_director(value=+FL_Z),fl_rotor(value=+FL_X),["offset",[0,-size.y/2,-size.z/2]],["corner radius",3],fl_screw(value=screw),fl_sata_instance(value=plug),fl_connectors(value=[pc,dc]),fl_holes(value=[fl_Hole([size.x/2-3.5,13.5,0],3,-Z,2.5+screw_r),fl_Hole([size.x/2-3.5,90,0],3,-Z,2.5+screw_r),fl_Hole([-size.x/2+3.5,13.5,0],3,-Z,2.5+screw_r),fl_Hole([-size.x/2+3.5,90,0],3,-Z,2.5+screw_r),fl_Hole([size.x/2,13.5,2.5],3,+X,3.5+screw_r),fl_Hole([size.x/2,90,2.5],3,+X,3.5+screw_r),fl_Hole([-size.x/2,13.5,2.5],3,-X,3.5+screw_r),fl_Hole([-size.x/2,90,2.5],3,-X,3.5+screw_r),]),["Mpd",Mpd],]

---

### variable FL_HD_NS

__Default:__

    "hd"

## Modules


---

### module fl_hd

__Syntax:__

    fl_hd(verbs,type,thick,lay_direction=[-X,+X,-Z],dri_tolerance=fl_JNgauge,dri_rails=[[0,0],[0,0],[0,0]],add_connectors=false,direction,octant)

