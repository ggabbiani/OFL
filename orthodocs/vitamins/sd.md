# package vitamins/sd

## Dependencies

```mermaid
graph LR
    A1[vitamins/sd] --o|use| A2[foundation/3d-engine]
    A1 --o|use| A3[foundation/bbox-engine]
    A1 --o|use| A4[foundation/mngm-engine]
    A1 --o|use| A5[foundation/util]
```

Secure Digital flash memory card for OpenSCAD Foundation Library.

Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Variables

---

### variable FL_SD_DICT

__Default:__

    [FL_SD_MOLEX_uSD_SOCKET]

sd dictionary

---

### variable FL_SD_MOLEX_uSD_SOCKET

__Default:__

    let(size=[13,11.5,1.28])[fl_bb_corners(value=[[-size.x/2,-size.y/2,0],[+size.x/2,+size.y/2,+size.z]]),fl_cutout(value=[-FL_Y]),]

---

### variable FL_SD_NS

__Default:__

    "sd"

sd namespace

## Modules

---

### module fl_sd_usocket

__Syntax:__

    fl_sd_usocket(verbs=FL_ADD,type,cut_thick,cut_tolerance=0,direction,octant)

micro SD socket


__Parameters:__

__verbs__  
supported verbs: FL_ADD, FL_BBOX, FL_CUTOUT

__type__  
Secure Digital flash memory card socket type

__cut_thick__  
thickness for FL_CUTOUT

__cut_tolerance__  
tolerance used during FL_CUTOUT

__direction__  
desired direction [director,rotation], native direction when undef ([+X+Y+Z])

__octant__  
when undef native positioning is used


