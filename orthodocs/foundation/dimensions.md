# package foundation/dimensions

## Dependencies

```mermaid
graph LR
    A1[foundation/dimensions] --o|include| A2[foundation/unsafe_defs]
    A1 --o|use| A3[foundation/3d-engine]
    A1 --o|use| A4[foundation/bbox-engine]
    A1 --o|use| A5[foundation/polymorphic-engine]
```

Dimension line library.

This file is part of the 'OpenSCAD Foundation Library' (OFL) project.

Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Variables

---

### variable $DIM_GAP

__Default:__

    1

gap between dimension lines

---

### variable FL_DIM_INVENTORY

__Default:__

    []

package inventory as a list of pre-defined and ready-to-use 'objects'

---

### variable FL_DIM_NS

__Default:__

    "dim"

prefix used for namespacing

## Functions

---

### function fl_Dimension

__Syntax:__

```text
fl_Dimension(value,label,spread=+X,line_width,object,view="top")
```

Constructor for dimension lines.

This geometry is meant to be used on a 'top view' projection, with Z axis as normal.


__Parameters:__

__value__  
mandatory value

__label__  
mandatory label string

__spread__  
Spread direction in the orthogonal view of the dimension lines.


__line_width__  
dimension line thickness

__object__  
The object to which the dimension line is attached.

__view__  
one of the following:
- "right"
- "top"
- "bottom"
- "left"



---

### function fl_dim_label

__Syntax:__

```text
fl_dim_label(type,value)
```

---

### function fl_dim_value

__Syntax:__

```text
fl_dim_value(type,value)
```

## Modules

---

### module fl_dimension

__Syntax:__

    fl_dimension(verbs=FL_ADD,geometry,align=[0,0,0],octant,direction,debug)

Children context:

- $dim_align   : current alignment
- $dim_label   : current dimension line label
- $dim_spread  : spread vector
- $dim_value   : current value
- $dim_view    : dimension line bounded view
- $dim_width   : current line width
- $dim_level   : current dimension line stacking level (always positive)


__Parameters:__

__verbs__  
supported verbs: FL_ADD

__align__  
By default the dimension line is centered on the «spread» parameter.


__octant__  
when undef native positioning is used

__direction__  
desired direction [director,rotation], native direction when undef ([+X+Y+Z])

__debug__  
see constructor [fl_parm_Debug()](core.md#function-fl_parm_debug)


