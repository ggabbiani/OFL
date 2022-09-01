# package vitamins/spdts


## Dependencies

```mermaid
graph LR
    A1[vitamins/spdts] --o|include| A2[foundation/3d]
```

## Variables


---

### variable FL_SODAL_SPDT

__Default:__

    let(len=40,d=19,head_d=22,head_h=+2)[fl_name(value="B077HJT92M"),fl_description(value="SODIAL(R) SPDT Button Switch 220V"),fl_bb_corners(value=[[-head_d/2,-head_d/2,-len+head_h],[+head_d/2,+head_d/2,head_h],]),["nominal diameter",d],["length",len],["head diameter",head_d],["head height",head_h],fl_director(value=+FL_Z),fl_rotor(value=+FL_X),fl_vendor(value=[["Amazon","https://www.amazon.it/gp/product/B077HJT92M/"],]),]

---

### variable FL_SPDT_DICT

__Default:__

    [FL_SODAL_SPDT]

## Functions


---

### function fl_spdt_d

__Syntax:__

    fl_spdt_d(type)

---

### function fl_spdt_headD

__Syntax:__

    fl_spdt_headD(type)

---

### function fl_spdt_headH

__Syntax:__

    fl_spdt_headH(type)

---

### function fl_spdt_l

__Syntax:__

    fl_spdt_l(type)

## Modules


---

### module fl_spdt

__Syntax:__

    fl_spdt(verbs=FL_ADD,type,direction,octant)

