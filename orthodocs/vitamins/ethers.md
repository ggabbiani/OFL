# package vitamins/ethers

## Dependencies

```mermaid
graph LR
    A1[vitamins/ethers] --o|include| A2[foundation/3d]
```

Ethernet.

Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Variables

---

### variable FL_ETHER_DICT

__Default:__

    [FL_ETHER_RJ45,]

---

### variable FL_ETHER_NS

__Default:__

    "ether"

ethernet namespace

---

### variable FL_ETHER_RJ45

__Default:__

    let(bbox=let(l=21,w=16,h=13.5)[[-l/2,-w/2,0],[+l/2,+w/2,h]])[fl_name(value="RJ45"),fl_bb_corners(value=bbox),fl_director(value=+FL_X),fl_rotor(value=-FL_Z),]

## Modules

---

### module fl_ether

__Syntax:__

    fl_ether(verbs=FL_ADD,type,cut_thick,cut_tolerance=0,cut_drift=0,direction,octant)

__Parameters:__

__verbs__  
supported verbs: FL_ADD,FL_AXES,FL_BBOX,FL_CUTOUT

__cut_thick__  
thickness for FL_CUTOUT

__cut_tolerance__  
tolerance used during FL_CUTOUT

__cut_drift__  
translation applied to cutout (default 0)

__direction__  
desired direction [director,rotation], native direction when undef ([+X+Y+Z])

__octant__  
when undef native positioning is used


