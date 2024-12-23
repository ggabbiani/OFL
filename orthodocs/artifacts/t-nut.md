# package artifacts/t-nut

## Dependencies

```mermaid
graph LR
    A1[artifacts/t-nut] --o|include| A2[foundation/dimensions]
    A1 --o|include| A3[foundation/unsafe_defs]
    A1 --o|include| A4[vitamins/countersinks]
    A1 --o|include| A5[vitamins/screw]
    A1 --o|use| A6[foundation/3d-engine]
    A1 --o|use| A7[foundation/bbox-engine]
    A1 --o|use| A8[foundation/hole]
    A1 --o|use| A9[foundation/mngm-engine]
```

T-slot nut engine for OpenSCAD Foundation Library.

T-slot nuts are used with
[T-slot structural framing](https://en.wikipedia.org/wiki/T-slot_structural_framing)
to build a variety of industrial structures and machines.

T-slot nut are not to be confused with [T-nuts](https://en.wikipedia.org/wiki/T-nut).

Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Variables

---

### variable FL_TNUT_DICT

__Default:__

    [FL_TNUT_M3_CS,FL_TNUT_M4_CS,FL_TNUT_M5_CS,FL_TNUT_M6_CS]

---

### variable FL_TNUT_M3_CS

__Default:__

    fl_TNut(opening=6,size=[10,20],thickness=[1,1,2],screw=M3_cs_cap_screw)

---

### variable FL_TNUT_M3_SM

__Default:__

    fl_TNut(opening=6,size=[10,20],thickness=[2,1,2],screw=M3_cs_cap_screw)

---

### variable FL_TNUT_M4_CS

__Default:__

    fl_TNut(opening=6,size=[10,20],thickness=[1,1.7,2],screw=M4_cs_cap_screw)

---

### variable FL_TNUT_M5_CS

__Default:__

    fl_TNut(opening=6,size=[10,20],thickness=[1,2.2,1.5],screw=M5_cs_cap_screw)

---

### variable FL_TNUT_M6_CS

__Default:__

    fl_TNut(opening=8,size=[18.6,20],thickness=[1.9,1.3,5.3],screw=M6_cs_cap_screw)

---

### variable FL_TNUT_NS

__Default:__

    "tnut"

namespace

## Functions

---

### function fl_TNut

__Syntax:__

```text
fl_TNut(opening,size,thickness,screw,knut=false,holes)
```

Constructor returning a T-slot nut.

__TOP VIEW__:

![Front view](800x600/fig_tnut_top_view.png)

__RIGHT VIEW__:

![Right view](800x600/fig_tnut_right_view.png)


__Parameters:__

__opening__  
the opening of the T-slot

__size__  
2d size in the form [width (X size), length (Z size)], the height (Y size)
being calculated from «thickness».

The resulting bounding box is: `[width, ∑ thickness, length]`


__thickness__  
section heights passed as `[wall,base,cone]` thicknesses


__screw__  
an optional screw determining a hole

__knut__  
eventual knurl nut

__holes__  
list of user defined holes usually positioned on the 'opening' side


---

### function fl_tnut_nominal

__Syntax:__

```text
fl_tnut_nominal(tnut)
```

nominal size for a knurl nut is the nominal size of the screw

---

### function fl_tnut_search

__Syntax:__

```text
fl_tnut_search(screw,d,best=function(matches)matches[0])
```

Search into dictionary for the best matching T-slot nut (default behavior)
or all the matching T-lot nuts depending on the «best_match» parameter.


__Parameters:__

__screw__  
screw to fit into

__d__  
nominal diameter


---

### function fl_tnut_thickness

__Syntax:__

```text
fl_tnut_thickness(type,value)
```

## Modules

---

### module fl_tnut

__Syntax:__

    fl_tnut(verbs=FL_ADD,type,tolerance=0,countersink=false,dri_thick,octant,direction)

T-slot nut engine.

See [fl_hole_Context{}](../foundation/hole.md#module-fl_hole_context) for context variables passed to children() during
FL_LAYOUT.



__Parameters:__

__verbs__  
supported verbs: `FL_ADD, FL_AXES, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT, FL_MOUNT`

__tolerance__  
tolerances added to [nut, hole, countersink] dimensions

tolerance=x means [x,x,x]


__dri_thick__  
scalar thickness for FL_DRILL

__octant__  
when undef native positioning is used

__direction__  
desired direction [director,rotation], native direction when undef ([+Z,0])


