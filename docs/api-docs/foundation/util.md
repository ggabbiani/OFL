# package foundation/util

## Dependencies

```mermaid
graph LR
    A1[foundation/util] --o|include| A2[foundation/3d-engine]
```

Miscellaneous utilities.

This file is part of the 'OpenSCAD Foundation Library' (OFL) project.

Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Functions

---

### function fl_bend_faceSet

__Syntax:__

```text
fl_bend_faceSet(type,value)
```

---

### function fl_bend_sheet

__Syntax:__

```text
fl_bend_sheet(type,value)
```

---

### function fl_folding

__Syntax:__

```text
fl_folding(faces,material="silver")
```

folding objects contain bending information.

«faces» is used for mapping each surface sizings and calculating the total
size of the sheet.

The folding object is then created with the overall sheet bounding box.



## Modules

---

### module fl_bend

__Syntax:__

    fl_bend(verbs=FL_ADD,type,flat=false,octant,direction,octant)

3d surface bending on rectangular cuboid faces.

Children context:

```

                       N           M
                        +=========+                  ✛ ⇐ upper corner
                        |         |                     (at sizing x,y)
                        |   [4]   |
                D      C|   +Y    |F      H          L
                +=======+=========+=======+==========+
                |       |         |       |          |
                |  [0]  |   [1]   |  [2]  |    [3]   |
                |  -X   |   +Z    |  +X   |    -Z    |
                +=======+=========+=======+==========+
                A      B|         |E      G          I
                        |   [5]   |
                        |   -Y    |
lower corner ⇒ ✛       +=========+
(at origin)            O           P
```

- $sheet : an object containing the calculated bounding corners of the sheet
- $A..$N : 3d values of the corresponding points in the above picture
- $size  : list of six surface sizings in the order shown in the picture
- $fid   : current face id



__Parameters:__

__verbs__  
supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT

__type__  
bend type as constructed from function [fl_folding()](#function-fl_folding)

__flat__  
when true children 3d surface is not bent

__octant__  
when undef native positioning is used

__direction__  
desired direction [director,rotation], native direction when undef ([+X+Y+Z])

__octant__  
when undef native positioning is used


---

### module fl_cutout

__Syntax:__

    fl_cutout(len,z=Z,x=X,trim=[0,0,0],cut=false,debug=false,delta=0)

cutout implementation.

**TODO**: the interface is ugly, a different implementation based on
fl_direction_extrude() is available (see fl_new_cutout()).


__Parameters:__

__len__  
cutout length

__z__  
axis to use as Z (detects the cutout plane on Z==0)

__x__  
axis to use as X

__trim__  
translation applied BEFORE projection() useful for trimming when cut=true

__cut__  
when true only the cutout plane is used for section

__debug__  
echo of children() when true

__delta__  
specifies the distance of the new outline from the original outline


---

### module fl_rail

__Syntax:__

    fl_rail(length)

use children() for making a rail

__Parameters:__

__length__  
when undef or 0 rail degenerates into children(0)


