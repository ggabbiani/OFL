# package vitamins/trimpot

## Dependencies

```mermaid
graph LR
    A1[vitamins/trimpot] --o|include| A2[foundation/3d]
    A1 --o|include| A3[foundation/bbox]
    A1 --o|include| A4[foundation/unsafe_defs]
    A1 --o|include| A5[foundation/util]
```

trimpot engine file

Copyright © 2022 Giampiero Gabbiani (giampiero@gabbiani.org)

This file is part of the 'Raspberry Pi4' (RPI4) project.

RPI4 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

RPI4 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with RPI4.  If not, see <http: //www.gnu.org/licenses/>.


## Variables

---

### variable FL_TRIM_NS

__Default:__

    "trim"

namespace

---

### variable FL_TRIM_POT10

__Default:__

    let(sz=[9.5,10+1.5,4.8])[fl_name(value="ten turn trimpot"),fl_bb_corners(value=[[-sz.x/2,-sz.y/2-1.5/2,0],[sz.x/2,sz.y/2-1.5/2,sz.z]]),fl_director(value=+Z),fl_rotor(value=+X),]

## Modules

---

### module fl_trimpot

__Syntax:__

    fl_trimpot(verbs=FL_ADD,type,cut_thick,cut_tolerance=0,cut_drift=0,direction,octant)

__Parameters:__

__verbs__  
supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT

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


