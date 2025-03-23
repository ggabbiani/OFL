# package vitamins/ethers

## Dependencies

```mermaid
graph LR
    A1[vitamins/ethers] --o|include| A2[foundation/unsafe_defs]
    A1 --o|use| A3[foundation/2d-engine]
    A1 --o|use| A4[foundation/3d-engine]
    A1 --o|use| A5[foundation/bbox-engine]
    A1 --o|use| A6[foundation/mngm-engine]
    A1 --o|use| A7[foundation/util]
```

Ethernet.

Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Variables

---

### variable FL_ETHER_DICT

__Default:__

    [FL_ETHER_RJ45,FL_ETHER_RJ45_SM]

---

### variable FL_ETHER_FRAME_T

__Default:__

    1.5

part of a surface mount ethernet socket length is reserved for the external frame

---

### variable FL_ETHER_NS

__Default:__

    "ether"

ethernet namespace

---

### variable FL_ETHER_PLUG_L

__Default:__

    8.5

value of the internally inserted part of an RJ45 plug

---

### variable FL_ETHER_RJ45

__Default:__

    let(l=21,w=16,h=13.5)[fl_name(value="RJ45"),fl_bb_corners(value=[[-l/2,-w/2,0],[+l/2,+w/2,h]]),fl_cutout(value=[+X]),fl_engine(value=str(FL_ETHER_NS,"/NopSCADlib")),]

---

### variable FL_ETHER_RJ45_SM

__Default:__

    let(l=12.6,w=17.4,h=11.5)[fl_name(value="RJ45 SLIM"),fl_bb_corners(value=[[-l+FL_ETHER_FRAME_T,-w/2,-FL_ETHER_Z_OFFSET],+[FL_ETHER_FRAME_T,w/2,h-FL_ETHER_Z_OFFSET]]),fl_cutout(value=[+X]),fl_dxf(value="vitamins/ether-slim.dxf"),fl_engine(value=str(FL_ETHER_NS,"/native")),]

---

### variable FL_ETHER_Z_OFFSET

__Default:__

    5

a surface mount ethernet socket is partially embedded on PCB

## Functions

---

### function fl_ether_Zoffset

__Syntax:__

```text
fl_ether_Zoffset(type,value)
```

## Modules

---

### module fl_ether

__Syntax:__

    fl_ether(verbs=FL_ADD,type,cut_drift=0,cut_dirs,octant,direction)

Ethernet engine.

Context variables:

| Name             | Context   | Description                                           |
| ---------------- | --------- | ----------------------------------------------------- |
| $fl_thickness    | Parameter | Used during FL_CUTOUT (see also [fl_parm_thickness()](../foundation/core.md#function-fl_parm_thickness))  |
| $fl_tolerance    | Parameter | Used during FL_CUTOUT (see [fl_parm_tolerance()](../foundation/core.md#function-fl_parm_tolerance))       |


__Parameters:__

__verbs__  
supported verbs: FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT

__cut_drift__  
translation applied to cutout (default 0)

__cut_dirs__  
Cutout direction list in floating semi-axis list (see also [fl_tt_isAxisList()](../foundation/traits-engine.md#function-fl_tt_isaxislist)).

Example:

    cut_dirs=[+X,+Z]

in this case the ethernet plug will perform a cutout along +X and +Z.



__octant__  
when undef native positioning is used

__direction__  
desired direction [director,rotation], native direction when undef ([+X+Y+Z])


