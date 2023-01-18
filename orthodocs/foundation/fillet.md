# package foundation/fillet

## Dependencies

```mermaid
graph LR
    A1[foundation/fillet] --o|include| A2[foundation/3d]
```

Fillet primitives.

Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Functions

---

### function fl_bb_90DegFillet

__Syntax:__

```text
fl_bb_90DegFillet(r,n,child_bbox)
```

__Parameters:__

__r__  
fillet radius

__n__  
number of steps along Z axis

__child_bbox__  
bounding box of the object to apply the fillet to


## Modules

---

### module fl_90DegFillet

__Syntax:__

    fl_90DegFillet(verbs=FL_ADD,r,n,child_bbox,direction,octant)

90 Degree fillet taken from [OpenSCAD - Fillet With Internal Angles](https://forum.openscad.org/Fillet-With-Internal-Angles-td17201.html) */

__Parameters:__

__r__  
fillet radius

__n__  
number of steps along Z axis

__child_bbox__  
2D bounding box of the object to apply the fillet to

__direction__  
desired direction [director,rotation], [+Z,0°] native direction when undef

__octant__  
3d placement, children positioning when undef


---

### module fl_fillet

__Syntax:__

    fl_fillet(verbs=FL_ADD,r,h,rx,ry,direction,octant)

__Parameters:__

__verbs__  
FL_ADD, FL_AXES, FL_BBOX

__r__  
shortcut for «rx»/«ry»

__rx__  
ellipse's horizontal radius

__ry__  
ellipse's vertical radius

__direction__  
desired direction [director,rotation], [+Z,0°] native direction when undef [+Z,+X]

__octant__  
when undef native positioning is used (+Z)


---

### module fl_hFillet

__Syntax:__

    fl_hFillet(verbs=FL_ADD,r,h,rx,ry,direction,octant)

__Parameters:__

__verbs__  
FL_ADD, FL_AXES, FL_BBOX

__r__  
shortcut for «rx»/«ry»

__rx__  
ellipse's horizontal radius

__ry__  
ellipse's vertical radius

__direction__  
desired direction [director,rotation], [+Z,0°] native direction when undef [+Z,+X]

__octant__  
when undef native positioning is used (+Z)


---

### module fl_vFillet

__Syntax:__

    fl_vFillet(verbs=FL_ADD,r,h,rx,ry,direction,octant)

__Parameters:__

__verbs__  
FL_ADD, FL_AXES, FL_BBOX

__r__  
shortcut for «rx»/«ry»

__rx__  
ellipse's horizontal radius

__ry__  
ellipse's vertical radius

__direction__  
desired direction [director,rotation], [+Z,0°] native direction when undef [+Z,+X]

__octant__  
when undef native positioning is used (+Z)


