# package foundation/grid

## Dependencies

```mermaid
graph LR
    A1[foundation/grid] --o|include| A2[foundation/3d-engine]
```

Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Functions

---

### function fl_grid_hex

__Syntax:__

```text
fl_grid_hex(origin=[0,0],r_step,bbox)
```

__Parameters:__

__origin__  
bounding box relative grid origin

__r_step__  
scalar radial step

__bbox__  
used for clipping the out of region points


---

### function fl_grid_quad

__Syntax:__

```text
fl_grid_quad(origin=[0,0],step,bbox,generator=function(point,bbox)[point])
```

__Parameters:__

__origin__  
bounding box relative grid origin

__step__  
2d deltas

__bbox__  
used for clipping the out of region points

__generator__  
generator (default generator just returns its center resulting in a quad grid ... hence the name)


## Modules

---

### module fl_grid_layout

__Syntax:__

    fl_grid_layout(origin=[0,0],step,r_step,bbox,clip=true)

__Parameters:__

__origin__  
grid origin relative to bounding box

__step__  
2d deltas for quad grid

__r_step__  
scalar radial step for hex grid

__bbox__  
used for clipping the out of region points


