# package foundation/profile

## Dependencies

```mermaid
graph LR
    A1[foundation/profile] --o|include| A2[foundation/label]
```

Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Modules

---

### module fl_bentPlate

__Syntax:__

    fl_bentPlate(verbs=FL_ADD,type,radius,size,material,thick,octant,direction)

Engine for generating bent plates.

See also https://metalfabricationsvcs.com/products/bent-plate/


__Parameters:__

__verbs__  
supported verbs : FL_ADD,FL_AXES,FL_BBOX]

__type__  
"L" or "U"

__radius__  
fold internal radius (square if undef)

__size__  
dimensioni del profilato [w,h,d]. Uno scalare s indica [s,s,s]

__material__  
actually a color

__thick__  
sheet thickness

__octant__  
when undef native positioning (see [variable FL_O](core.md#variable-fl_o)) is used

__direction__  
desired direction [director,rotation], native direction when undef ([+X+Z])


---

### module fl_profile

__Syntax:__

    fl_profile(verbs=FL_ADD,type,radius,size,material,thick,direction,octant)

engine for generating profiles

__Parameters:__

__verbs__  
supported verbs : FL_ADD,FL_AXES,FL_BBOX]

__type__  
"E","L","T" and "U"

__radius__  
external radius (square if undef)

__material__  
actually a color

__direction__  
desired direction [director,rotation], native direction when undef ([+X+Z])

__octant__  
when undef native positioning (see [variable FL_O](core.md#variable-fl_o)) is used


