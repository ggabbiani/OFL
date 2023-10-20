# package artifacts/box

## Dependencies

```mermaid
graph LR
    A1[artifacts/box] --o|include| A2[artifacts/spacer]
    A1 --o|include| A3[vitamins/countersinks]
    A1 --o|include| A4[vitamins/knurl_nuts]
    A1 --o|include| A5[vitamins/screw]
    A1 --o|use| A6[foundation/fillet]
    A1 --o|use| A7[foundation/mngm-engine]
    A1 --o|use| A8[foundation/profile]
    A1 --o|use| A9[foundation/util]
```

Box artifact engine.

Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Modules

---

### module fl_box

__Syntax:__

    fl_box(verbs=FL_ADD,preset,xsize,isize,pload,thick,radius,parts,tolerance=0.3,material_upper,material_lower,fillet=true,lay_octant,direction,octant)

engine for generating boxes.

__children context__:

- $box_materials - list of used materials [«material_lower», «material_upper»]


__Parameters:__

__verbs__  
supported verbs: FL_ADD, FL_AXES, FL_ASSEMBLY, FL_BBOX, FL_LAYOUT, FL_MOUNT, FL_PAYLOAD

__preset__  
preset profiles (UNUSED)

__xsize__  
external dimensions

__isize__  
internal payload size

__pload__  
internal bounding box

__thick__  
sheet thickness

__radius__  
fold internal radius (square if undef)

__parts__  
"all","upper","lower"

__material_upper__  
upper side color

__material_lower__  
lower side color

__direction__  
desired direction [director,rotation], native direction when undef ([+X+Y+Z])

__octant__  
when undef native positioning is used


