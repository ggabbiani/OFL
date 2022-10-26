# package vitamins/screw

## Dependencies

```mermaid
graph LR
    A1[vitamins/screw] --o|include| A2[foundation/3d]
    A1 --o|include| A3[foundation/unsafe_defs]
```

Screw implementation file for OpenSCAD Foundation Library.



*Published under __GNU General Public License v3__*

## Functions

---

### function fl_bb_screw

__Syntax:__

```text
fl_bb_screw(type,length)
```

bounding box

---

### function fl_screw_l

__Syntax:__

```text
fl_screw_l(type,len,thick=0,washer="no",nut="no",xwasher="no",nwasher=false)
```

return the overall length of a screw (according to parameters)

__Parameters:__

__washer__  
screw washer : "no","default","penny","nylon"

__nut__  
screw nut    : "no","default","nyloc"

__xwasher__  
extra washer : "no","spring","star"

__nwasher__  
nut washer


---

### function fl_screw_lens

__Syntax:__

```text
fl_screw_lens(type,len,thick=0,washer="no",nut="no",xwasher="no",nwasher=false)
```

return a list with layered thickness (according to parameters):
 0 overall screw length
 1 passed thickness
 2 washer thickness
 3 extra washer (spring or star) thickness
 4 nut washer thickness
 5 nut thickness

Note: if one layer is "off", the corresponding thickness will be 0


__Parameters:__

__washer__  
screw washer : "no","default","penny","nylon"

__nut__  
screw nut    : "no","default","nyloc"

__xwasher__  
extra washer : "no","spring","star"

__nwasher__  
nut washer


---

### function fl_screw_size

__Syntax:__

```text
fl_screw_size(type,length)
```

## Modules

---

### module fl_screw

__Syntax:__

    fl_screw(verbs=FL_ADD,type,len,thick=0,washer="no",nut="no",xwasher="no",nwasher=false,direction,octant)

