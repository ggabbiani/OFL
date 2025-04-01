# package vitamins/trimpot

## Dependencies

```mermaid
graph LR
    A1[vitamins/trimpot] --o|include| A2[foundation/unsafe_defs]
    A1 --o|use| A3[foundation/3d-engine]
    A1 --o|use| A4[foundation/bbox-engine]
    A1 --o|use| A5[foundation/mngm-engine]
    A1 --o|use| A6[foundation/type-engine]
    A1 --o|use| A7[foundation/util]
```

trimpot engine file

Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Variables

---

### variable FL_TRIM_DICT

__Default:__

    [FL_TRIM_POT10,]

---

### variable FL_TRIM_NS

__Default:__

    "trim"

---

### variable FL_TRIM_POT10

__Default:__

    let(sz=[9.5,10+1.5,4.8],bbox=[[-sz.x/2,-sz.y/2-1.5/2,0],[sz.x/2,sz.y/2-1.5/2,sz.z]])fl_Object(bbox,name="ten turn trimpot",engine=FL_TRIM_NS,others=[fl_cutout(value=[-Y]),])

## Modules

---

### module fl_trimpot

__Syntax:__

    fl_trimpot(verbs=FL_ADD,type,cut_thick,cut_tolerance=0,cut_drift=0,cut_dirs,direction,octant)

__Parameters:__

__verbs__  
supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT

__cut_thick__  
thickness for FL_CUTOUT

__cut_tolerance__  
tolerance used during FL_CUTOUT

__cut_drift__  
translation applied to cutout (default 0)

__cut_dirs__  
FL_CUTOUT direction list. Defaults to 'preferred' cutout direction

__direction__  
desired direction [director,rotation], native direction when undef ([+X+Y+Z])

__octant__  
when undef native positioning is used


