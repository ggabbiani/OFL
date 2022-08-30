# package vitamins/sata-adapters


__Includes:__

    vitamins/sata

## Variables


---

### variable FL_SADP_DICT

__Default:__

    [FL_SADP_ELUTENG,]

---

### variable FL_SADP_ELUTENG

__Default:__

    let(socket=FL_SATA_POWERDATASOCKET,handle_size=[47,37,11.6],socket_size=fl_size(socket),size=[handle_size.x,handle_size.y+socket_size.z,handle_size.z],Mpd=fl_T(-fl_Y(FL_NIL))*fl_Ry(180)*fl_Rx(-90)*fl_octant(+Z-Y,type=socket))[fl_name(value="ELUTENG USB 3.0 TO SATA ADAPTER"),fl_bb_corners(value=[[-size.x/2,-handle_size.y,-size.z/2],[size.x/2,socket_size.z,+size.z/2]]),fl_director(value=+FL_Y),fl_rotor(value=+FL_X),fl_vendor(value=[["Amazon","https://www.amazon.it/gp/product/B007UOXRY0/"]]),["handle size",handle_size],["Mpd",Mpd],["connectors",fl_conn_import(fl_sata_conns(socket),Mpd)],["SATA socket",socket],]

---

### variable FL_SADP_NS

__Default:__

    "sadp"

## Modules


---

### module sata_adapter

__Syntax:__

    sata_adapter(verbs,type,locators=false,direction,octant)

