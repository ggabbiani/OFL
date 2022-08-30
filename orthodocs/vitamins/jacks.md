# package vitamins/jacks


__Includes:__

    foundation/3d
    foundation/connect
    foundation/label
    foundation/tube
    foundation/util

## Variables


---

### variable FL_JACK_BARREL

__Default:__

    let(l=12,w=7,h=6,ch=2.5,bbox=[[-l/2,-w/2,0],[+l/2+ch,+w/2,h]])[fl_bb_corners(value=bbox),fl_director(value=+FL_X),fl_rotor(value=+FL_Y),fl_engine(value="fl_jack_barrelEngine"),]

---

### variable FL_JACK_DICT

__Default:__

    [FL_JACK_BARREL,FL_JACK_MCXJPHSTEM1,]

---

### variable FL_JACK_MCXJPHSTEM1

__Default:__

    let(name="50Ω MCX EDGE MOUNT JACK PCB CONNECTOR",w=6.7,l=9.3,h=5,sz=[w,l,h],axis=[0,0,0.4],bbox=[[-w/2,0,-h/2+axis.z],[+w/2,l,+h/2+axis.z]],d_ext=6.7,head=6.25,tail=sz.y-head,jack=sz.y-2)[fl_name(value=name),fl_bb_corners(value=bbox),fl_director(value=-Y),fl_rotor(value=+X),fl_engine(value="fl_jack_mcxjphstem1Engine"),fl_connectors(value=[conn_Socket("antenna",+X,-Z,[0,0,axis.z],size=3.45,octant=-X-Y,direction=[-Z,180])]),["axis of symmetry",axis],["external diameter",d_ext],["head",head],["tail",tail],["jack length",jack]]

---

### variable FL_JACK_NS

__Default:__

    "jack"

## Modules


---

### module fl_jack

__Syntax:__

    fl_jack(verbs=FL_ADD,type,cut_thick,cut_tolerance=0,cut_drift=0,debug,direction,octant)

---

### module fl_jack_barrelEngine

__Syntax:__

    fl_jack_barrelEngine(verbs=FL_ADD,type,cut_thick,cut_tolerance=0,cut_drift=0,debug,direction,octant)

---

### module fl_jack_mcxjphstem1Engine

__Syntax:__

    fl_jack_mcxjphstem1Engine(verbs=FL_ADD,type,cut_thick,cut_tolerance=0,cut_drift=0,debug,direction,octant)

