# package foundation/bbox-engine

## Dependencies

```mermaid
graph LR
    A1[foundation/bbox-engine] --o|include| A2[foundation/core]
```

BoundingBox toolkit

Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Functions

---

### function fl_bb_calc

__Syntax:__

```text
fl_bb_calc(bbs)
```

Calculates a cubic bounding block from a bounding blocks list


__Parameters:__

__bbs__  
list of bounding blocks to be included in the new one


---

### function fl_bb_center

__Syntax:__

```text
fl_bb_center(type)
```

bounding box translation

---

### function fl_bb_corners

__Syntax:__

```text
fl_bb_corners(type,value)
```

invoked by «type» parameter acts as getter for the bounding box property

invoked by «value» parameter acts as property constructor


---

### function fl_bb_new

__Syntax:__

```text
fl_bb_new(negative=[0,0,0],size=[0,0,0],positive)
```

constructor for a new type with bounding box corners set as property

---

### function fl_bb_polyhedron

__Syntax:__

```text
fl_bb_polyhedron(points)
```

Calculates a cubic bounding block from a 3d point set.
See also 2d counter-part function [fl_bb_polygon()](2d-engine.md#function-fl_bb_polygon).


---

### function fl_bb_size

__Syntax:__

```text
fl_bb_size(type)
```

computes size from the bounding corners retrieved from «type».

---

### function fl_bb_transform

__Syntax:__

```text
fl_bb_transform(M,corners)
```

Applies a transformation matrix «M» to a bounding box

---

### function fl_bb_vertices

__Syntax:__

```text
fl_bb_vertices(corners)
```

Converts a bounding box in canonic form into four vertices:

a,b,c,d on plane y==corners[0].y

A,B,C,D on plane y==corners[1].y


