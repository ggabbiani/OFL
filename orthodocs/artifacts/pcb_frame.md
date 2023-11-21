# package artifacts/pcb_frame

## Dependencies

```mermaid
graph LR
    A1[artifacts/pcb_frame] --o|include| A2[vitamins/pcbs]
```

PCB frame library: a PCB frame is a size driven adapter for PCBs, providing
them the necessary holes to be ficed in a box.

This file is part of the 'OpenSCAD Foundation Library' (OFL) project.

Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Functions

---

### function fl_pcb_Frame

__Syntax:__

```text
fl_pcb_Frame(pcb,d=2,faces=1.2,wall=1.5,overlap=[1,0.5],inclusion=5,countersink=false,layout="auto")
```

Constructor  for size-based pcb frame. It assumes the bare PCB bounding box
depth is from -«pcb thick» to 0.


__Parameters:__

__pcb__  
pcb object to be framed

__d__  
nominal screw ⌀

__faces__  
List of Z-axis thickness for top and bottom faces or a common scalar value
for both.

Positive value set thickness for the top face, negative for bottom while a
scalar can be used for both.

    faces = [+3,-1]

is interpreted as 3mm top, 1mm bottom

    faces = [-1]

is interpreted as 1mm bottom

    faces = 2

is interpreted as 2mm for top and bottom faces



__wall__  
distance between holes and external frame dimensions

__overlap__  
overlap in the form [wide,thin]: wide overlap is along major pcb dimension,
thin overlap is along the minor pcb one


__inclusion__  
inclusion is the size along major pcb dimension, laterally surrounding the pcb


__layout__  
Frame layout method:

    - "auto" (default) : auto detected based on PCB dimensions
    - "horizontal"     : holders are deployed horizontally from left to
                         right
    - "vertical"       : holders are deployed vertically from bottom to top



## Modules

---

### module fl_pcb_frame

__Syntax:__

    fl_pcb_frame(verbs=FL_ADD,this,tolerance=0.2,parts=true,thick=0,lay_direction=[+Z],cut_tolerance=0,cut_label,cut_direction,debug,direction,octant)

__Parameters:__

__verbs__  
supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT

__parts__  
PCB frame part visibility: defines which frame parts are shown.

The full form is [«left|bottom part»,«right|top part»], where each list
item is a boolean managing the visibility of the corresponding part.

Setting this parameter as a single boolean extends its value to both the parts.


__thick__  
see homonymous parameter for [fl_pcb{}](../vitamins/pcbs.md#module-fl_pcb)

__lay_direction__  
see homonymous parameter for [fl_pcb{}](../vitamins/pcbs.md#module-fl_pcb)

__cut_tolerance__  
see homonymous parameter for [fl_pcb{}](../vitamins/pcbs.md#module-fl_pcb)

__cut_label__  
see homonymous parameter for [fl_pcb{}](../vitamins/pcbs.md#module-fl_pcb)

__cut_direction__  
see homonymous parameter for [fl_pcb{}](../vitamins/pcbs.md#module-fl_pcb)

__debug__  
see constructor [fl_parm_Debug()](../foundation/core.md#function-fl_parm_debug)

__direction__  
desired direction [director,rotation], native direction when undef ([+X+Y+Z])

__octant__  
when undef native positioning is used


