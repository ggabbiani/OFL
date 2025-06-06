# package foundation/3d-engine

## Dependencies

```mermaid
graph LR
    A1[foundation/3d-engine] --o|include| A2[foundation/2d-engine]
    A1 --o|use| A3[dxf]
    A1 --o|use| A4[foundation/traits-engine]
    A1 --o|use| A5[foundation/type-engine]
```

3d primitives

Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Functions

---

### function fl_3d_AxisList

__Syntax:__

```text
fl_3d_AxisList(axes)
```

Build a floating semi-axis list from literal semi-axis list.

example:

    list = fl_3d_AxisList(axes=["-x","±Z"]);

is equivalent to:

    list =
    [
     [-1, 0,  0],  // -X semi-axis
     [ 0, 0, -1],  // -Z semi-axis
     [ 0, 0, +1],  // +Z semi-axis
    ];

:memo: **NOTE:** the negative ('-') or positive ('+') sign must always be set.


__Parameters:__

__axes__  
semi-axis literals list (es.["-x","±Z"])


---

### function fl_3d_AxisVList

__Syntax:__

```text
fl_3d_AxisVList(kvs,axes)
```

Constructor for a full semi-axis value list. The returned value can be built
from a list of pairs ("string", value) or from a list of semi-axes name
strings

| parameter | result                                                                     |
| --------- | ------                                                                     |
| kvs       | full semi-axis value list initialized from the passed axis/value pair list |
| values    | full boolean semi-axis value list from semi-axis literal                   |

See also function [fl_tt_isAxisVList()](traits-engine.md#function-fl_tt_isaxisvlist)

example 1:

    thick = fl_3d_AxisVList(kvs=[["-x",3],["±Z",4]]);

is equivalent to:

    thick =
    [
     [3,0],  // -x and +x value pair
     [0,0],  // -y and +y value pair
     [4,4]   // -z and +z value pair
    ];

example 2:

    values = fl_3d_AxisVList(axes=["-x","±Z"]);

is equivalent to:

    values =
    [
     [true,  false], // -x and +x boolean
     [false, false], // -y and +y boolean
     [true,  true]   // -z and +z boolean
    ];


__Parameters:__

__kvs__  
semi-axis key/value list (es. [["-x",3],["±Z",4]])

__axes__  
semi-axis list (es.["-x","±Z"])


---

### function fl_3d_abs

__Syntax:__

```text
fl_3d_abs(a)
```

Transforms a vector inside the +X+Y+Z octant


---

### function fl_3d_axisIsSet

__Syntax:__

```text
fl_3d_axisIsSet(axis,list)
```

Wether «axis» is present in floating semi-axis «list».

TODO: this is a recursive solution that could be more quickly solved by a
mere call to the OpenSCAD builtin search() function like in the example
below:

    function fl_3d_axisIsSet(axis,list) = search([axis],list)!=[[]]

TODO: eventually replace it with [fl_isInAxisList()](#function-fl_isinaxislist)


---

### function fl_3d_axisValue

__Syntax:__

```text
fl_3d_axisValue(axis,values)
```

returns the «axis» value from a full semi-axis value list

__Parameters:__

__axis__  
axis to retrieve corresponding value

__values__  
full semi-axis value list (see also function [fl_tt_isAxisVList()](traits-engine.md#function-fl_tt_isaxisvlist))


---

### function fl_3d_max

__Syntax:__

```text
fl_3d_max(a,b)
```

Builds a max vector


---

### function fl_3d_medianValue

__Syntax:__

```text
fl_3d_medianValue(list,axis,pre_ordered=false)
```

calculates the median VALUE of a 2d/3d point list


---

### function fl_3d_min

__Syntax:__

```text
fl_3d_min(a,b)
```

Builds a minor vector


---

### function fl_3d_orthoPlane

__Syntax:__

```text
fl_3d_orthoPlane(axis)
```

Cartesian plane from axis


---

### function fl_3d_planarProjection

__Syntax:__

```text
fl_3d_planarProjection(vector,plane)
```

Projection of «vector» onto a cartesian «plane»


__Parameters:__

__vector__  
3D vector

__plane__  
cartesian plane by vector with ([-1,+1,0]==[1,1,0]==XY)


---

### function fl_3d_sign

__Syntax:__

```text
fl_3d_sign(axis)
```

returns the sign of a semi-axis (-1,+1)

---

### function fl_3d_vectorialProjection

__Syntax:__

```text
fl_3d_vectorialProjection(vector,axis)
```

Projection of «vector» onto a cartesian «axis»


__Parameters:__

__vector__  
3D vector

__axis__  
cartesian axis ([-1,0,0]==[1,0,0]==X)


---

### function fl_Cube

__Syntax:__

```text
fl_Cube(size=[1,1,1])
```

---

### function fl_Cylinder

__Syntax:__

```text
fl_Cylinder(h,r,r1,r2,d,d1,d2)
```

__Parameters:__

__h__  
height of the cylinder or cone

__r__  
radius of cylinder. r1 = r2 = r.

__r1__  
radius, bottom of cone.

__r2__  
radius, top of cone.

__d__  
diameter of cylinder. r1 = r2 = d / 2.

__d1__  
diameter, bottom of cone. r1 = d1 / 2.

__d2__  
diameter, top of cone. r2 = d2 / 2.


---

### function fl_Prism

__Syntax:__

```text
fl_Prism(n,l,l1,l2,h)
```

__Parameters:__

__n__  
edge number

__l__  
edge length

__l1__  
edge length, bottom

__l2__  
edge length, top

__h__  
height of the prism


---

### function fl_Pyramid

__Syntax:__

```text
fl_Pyramid(base,apex)
```

__Parameters:__

__base__  
2d point list defining the polygonal base on plane XY

__apex__  
3d point defining the apex


---

### function fl_Sphere

__Syntax:__

```text
fl_Sphere(r=[1,1,1],d)
```

---

### function fl_bb_accum

__Syntax:__

```text
fl_bb_accum(axis,gap=0,bbcs)
```

Accumulates a list of bounding boxes along a direction.

Recursive algorithm, at each call a bounding box is extracted from «bbcs»
and decomposed into axial and planar components. The last bounding box in
the list ended up the recursion and is returned as result.
If there are still bounding boxes left, a new call is made and its
result, decomposed into the axial and planar components, used to produce a
new bounding box as follows:

- for planar component, the new negative and positive corners are calculated
  with the minimum dimensions between the current one and the result of the
  recursive call;
- for the axial component when «axis» is positive:
  - negative corner is equal to the current corner;
  - positive corner is equal to the current positive corner PLUS the gap and
    the axial dimension of the result;
  - when «axis» is negative:
    - negative corner is equal to the current one MINUS the gap and the
      axial dimension of the result
    - the positive corner is equal to the current corner.


__Parameters:__

__axis__  
layout direction

__gap__  
gap to be inserted between bounding boxes along axis

__bbcs__  
bounding box corners


---

### function fl_bb_cube

__Syntax:__

```text
fl_bb_cube(size=[1,1,1])
```

---

### function fl_bb_cylinder

__Syntax:__

```text
fl_bb_cylinder(h,r,r1,r2,d,d1,d2)
```

__Parameters:__

__h__  
height of the cylinder or cone

__r__  
radius of cylinder. r1 = r2 = r.

__r1__  
radius, bottom of cone.

__r2__  
radius, top of cone.

__d__  
diameter of cylinder. r1 = r2 = d / 2.

__d1__  
diameter, bottom of cone. r1 = d1 / 2.

__d2__  
diameter, top of cone. r2 = d2 / 2.


---

### function fl_bb_prism

__Syntax:__

```text
fl_bb_prism(n,l,l1,l2,h)
```

__Parameters:__

__n__  
edge number

__l__  
edge length

__l1__  
edge length, bottom

__l2__  
edge length, top

__h__  
height of the prism


---

### function fl_bb_pyramid

__Syntax:__

```text
fl_bb_pyramid(base,apex)
```

---

### function fl_bb_sphere

__Syntax:__

```text
fl_bb_sphere(r=[1,1,1],d)
```

---

### function fl_bb_torus

__Syntax:__

```text
fl_bb_torus(r,d,e,R)
```

__Parameters:__

__r__  
radius of the circular tube.

__d__  
diameter of the circular tube.

__e__  
elliptic tube [a,b] form

__R__  
distance from the center of the tube to the center of the torus


---

### function fl_centroid

__Syntax:__

```text
fl_centroid(pts)
```

Calculates the [geometric center](https://en.wikipedia.org/wiki/Centroid) of
the passed points.


__Parameters:__

__pts__  
Point list defining a polygon/polyhedron with each element p | p∈ℝ^n^


---

### function fl_cube_size

__Syntax:__

```text
fl_cube_size(type,value)
```

---

### function fl_cyl_botRadius

__Syntax:__

```text
fl_cyl_botRadius(type,value)
```

---

### function fl_cyl_h

__Syntax:__

```text
fl_cyl_h(type,value)
```

---

### function fl_cyl_topRadius

__Syntax:__

```text
fl_cyl_topRadius(type,value)
```

---

### function fl_cylinder_defaults

__Syntax:__

```text
fl_cylinder_defaults(h,r,r1,r2,d,d1,d2)
```

cylinder defaults for positioning (fl_bb_cornersKV).


__Parameters:__

__h__  
height of the cylinder or cone

__r__  
radius of cylinder. r1 = r2 = r.

__r1__  
radius, bottom of cone.

__r2__  
radius, top of cone.

__d__  
diameter of cylinder. r1 = r2 = d / 2.

__d1__  
diameter, bottom of cone. r1 = d1 / 2.

__d2__  
diameter, top of cone. r2 = d2 / 2.


---

### function fl_direction

__Syntax:__

```text
fl_direction(direction,default=I)
```

Return the direction matrix transforming native coordinates along new
direction.

Native coordinate system is represented by two vectors: +Z and +X. +Y axis
is the cross product between +Z and +X. So with two vector (+Z,+X) we can
represent the native coordinate system +X,+Y,+Z.

New direction is expected in [Axis–angle representation](https://en.wikipedia.org/wiki/Axis%E2%80%93angle_representation)
in the format

    [axis,rotation angle]



__Parameters:__

__direction__  
desired direction in axis-angle representation [axis,rotation]

__default__  
returned matrix when «direction» is undef


---

### function fl_isInAxisList

__Syntax:__

```text
fl_isInAxisList(axis,list)
```

True when «axis» is contained in the floating semi-axis «list», false
otherwise.

TODO: let the function name follow the order of parameters (i.e. rename as
fl_isAxisInList(axis,list))



---

### function fl_octant

__Syntax:__

```text
fl_octant(octant,type,bbox,default=FL_I)
```

Calculates the translation matrix needed for moving a shape in the provided
3d octant.


__Parameters:__

__octant__  
3d octant vector, each component can assume one out of four values
modifying the corresponding x,y or z position in the following manner:

- undef: translation invariant (no translation)
- -1: object on negative semi-axis
- 0: object midpoint on origin
- +1: object on positive semi-axis

Example 1:

    octant=[undef,undef,undef]

no translation in any dimension

Example 2:

    octant=[0,0,0]

object center [midpoint x, midpoint y, midpoint z] on origin

Example 3:

    octant=[+1,undef,-1]

 object on X positive semi-space, no Y translated, on negative Z semi-space


__type__  
type with embedded "bounding corners" property (see [fl_bb_corners()](bbox-engine.md#function-fl_bb_corners))

__bbox__  
explicit bounding box corners: overrides «type» settings

__default__  
returned matrix when «octant» is undef


---

### function fl_planeAlign

__Syntax:__

```text
fl_planeAlign(ax,ay,bx,by,a,b)
```

From [Rotation matrix from plane A to B](https://math.stackexchange.com/questions/1876615/rotation-matrix-from-plane-a-to-b)

Returns the rotation matrix R aligning the plane A(ax,ay),to plane B(bx,by)
When ax and bx are orthogonal to ay and by respectively calculation are simplified.


---

### function fl_prism_defaults

__Syntax:__

```text
fl_prism_defaults(n,l,l1,l2,h)
```

prism defaults for positioning (fl_bb_cornersKV).


__Parameters:__

__n__  
edge number

__l__  
edge length

__l1__  
edge length, bottom

__l2__  
edge length, top

__h__  
height of the prism


---

### function fl_prsm_botEdgeL

__Syntax:__

```text
fl_prsm_botEdgeL(type,value)
```

---

### function fl_prsm_h

__Syntax:__

```text
fl_prsm_h(type,value)
```

---

### function fl_prsm_n

__Syntax:__

```text
fl_prsm_n(type,value)
```

---

### function fl_prsm_topEdgeL

__Syntax:__

```text
fl_prsm_topEdgeL(type,value)
```

---

### function fl_pyr_apex

__Syntax:__

```text
fl_pyr_apex(type,value)
```

---

### function fl_pyr_base

__Syntax:__

```text
fl_pyr_base(type,value)
```

---

### function fl_sphere_defaults

__Syntax:__

```text
fl_sphere_defaults(r=[1,1,1],d)
```

sphere defaults for positioning (fl_bb_cornersKV).


---

### function lay_bb_corners

__Syntax:__

```text
lay_bb_corners(axis,gap=0,types)
```

returns the bounding box corners of a layout.

See also [fl_bb_accum()](#function-fl_bb_accum).


__Parameters:__

__axis__  
layout direction

__gap__  
gap to be inserted between bounding boxes along axis

__types__  
list of types


---

### function lay_bb_size

__Syntax:__

```text
lay_bb_size(axis,gap,types)
```

calculates the overall bounding box size of a layout


---

### function lay_group

__Syntax:__

```text
lay_group(axis,gap,types)
```

creates a group with the resulting bounding box corners of a layout


## Modules

---

### module fl_3d_polyhedronLabels

__Syntax:__

    fl_3d_polyhedronLabels(poly,size,label="P")

---

### module fl_3d_polyhedronSymbols

__Syntax:__

    fl_3d_polyhedronSymbols(poly,size,color="black")

---

### module fl_bb_add

__Syntax:__

    fl_bb_add(corners,2d=false,auto=true)

add a bounding box shape to the scene


__Parameters:__

__corners__  
Bounding box corners in [Low,High] format.
see also [fl_tt_isBoundingBox()](traits-engine.md#function-fl_tt_isboundingbox)


__2d__  
2d switch

__auto__  
when true, z-fight correction is applied


---

### module fl_cube

__Syntax:__

    fl_cube(verbs=FL_ADD,type,size,octant,direction)

Cube replacement: if not specified otherwise, the cube has its midpoint centered at origin O

![default positioning](256x256/fig_3d_cube_defaults.png)


__Parameters:__

__verbs__  
FL_ADD,FL_AXES,FL_BBOX

__octant__  
when undef, native positioning is used with cube midpoint centered at origin O

__direction__  
desired direction [director,rotation] or native direction if undef


---

### module fl_cutoutLoop

__Syntax:__

    fl_cutoutLoop(list,preferred)

Cutout helper: loops over passed axes initializing a children context as
follow:

| Name           | Context   | Description                                 |
| -------------- | --------- | ------------------------------------------- |
| $co_current    | Children  | Current axis                                |
| $co_preferred  | Children  | true if $co_current axis is a preferred one |

This facility is meant to be used with fl_new_cutout() like in the following
example:

```
fl_cutoutLoop(cut_dirs, fl_cutout($this))
  if ($co_preferred) {
    fl_new_cutout($this_bbox,$co_current,drift=cut_drift,$fl_thickness=...,$fl_tolerance=..)
      do_footprint();
  }
```


---

### module fl_cylinder

__Syntax:__

    fl_cylinder(verbs=FL_ADD,type,h,r,r1,r2,d,d1,d2,octant,direction)

Cylinder replacement.

![default positioning](256x256/fig_3d_cylinder_defaults.png)


__Parameters:__

__verbs__  
FL_ADD,FL_AXES,FL_BBOX

__type__  
optional type as returned by [fl_Cylinder()](#function-fl_cylinder).

:memo: **NOTE:** «type» attributes are always overridden by the following
parameters (if any).


__h__  
height of the cylinder or cone

__r__  
radius of cylinder. r1 = r2 = r.

__r1__  
radius, bottom of cone.

__r2__  
radius, top of cone.

__d__  
diameter of cylinder. r1 = r2 = d / 2.

__d1__  
diameter, bottom of cone. r1 = d1 / 2.

__d2__  
diameter, top of cone. r2 = d2 / 2.

__octant__  
when undef native positioning is used

__direction__  
desired direction [director,rotation], native direction when undef ([+X+Y+Z])


---

### module fl_direct

__Syntax:__

    fl_direct(direction)

Applies a direction matrix to its children.
See also [fl_direction()](#function-fl_direction) function comments.


__Parameters:__

__direction__  
desired direction in axis-angle representation [axis,rotation]


---

### module fl_direction_extrude

__Syntax:__

    fl_direction_extrude(direction,length,convexity=10,r,delta,chamfer,trim)

Extrusion along arbitrary direction.

Children are projected on the plane orthogonal to «direction» then extruded
by «length» along «direction».

See also the corresponding test: tests/foundation/extrusion-test.scad


__Parameters:__

__direction__  
direction in [axis,angle] representation

__r__  
offset() radius

__delta__  
offset() delta (ignored when r!=0)

__chamfer__  
offset() chamfer (ignored when r!=0)

__trim__  
Translation list applied BEFORE projection().

:memo: **NOTE:** trimming modify projection() behavior, enabling its «cut»
parameter to true.



---

### module fl_doAxes

__Syntax:__

    fl_doAxes(size,direction)

---

### module fl_fillet_extrude

__Syntax:__

    fl_fillet_extrude(height=100,r1=0,r2=0)

linear_extrude{} with optional fillet radius on each end.

Positive radii will expand outward towards their end, negative will shrink
inward towards their end

Limitations:

- individual children of fillet_extrude should be convex
- only straight extrudes with no twist or scaling supported
- fillets only for 90 degrees between Z axis and top/bottom surface


__Parameters:__

__height__  
total extrusion length including radii

__r1__  
bottom radius

__r2__  
top radius


---

### module fl_frame

__Syntax:__

    fl_frame(verbs=FL_ADD,size=[1,1,1],corners=[0,0,0,0],thick,octant,direction)

3d extension of [fl_2d_frame{}](2d-engine.md#module-fl_2d_frame).


__Parameters:__

__verbs__  
supported verbs: FL_ADD, FL_AXES, FL_BBOX

__size__  
outer size

__corners__  
List of four radiuses, one for each base quadrant's corners.
Each zero means that the corresponding corner is squared.
Defaults to a 'perfect' rectangle with four squared corners.
One scalar value R means corners=[R,R,R,R]


__thick__  
subtracted to size defines the internal size

__octant__  
when undef, native positioning is used with cube midpoint centered at origin O

__direction__  
desired direction [director,rotation] or native direction if undef


---

### module fl_importDxf

__Syntax:__

    fl_importDxf(file,layer,direction)

DXF files import with direction and rotation. By default DXF files are
imported in the XY plane with no rotation. The «direction» parameter
specifies a normal to the actual import plane and a rotation about it.


__Parameters:__

__direction__  
direction in [axis,angle] representation


---

### module fl_layout

__Syntax:__

    fl_layout(verbs=FL_LAYOUT,axis,gap=0,types,align=0,direction,octant)

Layout of types along a direction.

There are basically two methods of invocation call:

- with as many children as the length of types: in this case each children will
  be called explicitly in turn with children($i)
- with one child only called repetitively through children(0) with $i equal to the
  current execution number.

Called children can use the following special variables:

    $i      - current item index
    $first  - true when $i==0
    $last   - true when $i==len(types)-1
    $item   - equal to types[$i]
    $len    - equal to len(types)
    $size   - equal to bounding box size of $item

TODO: add namespace to children context variables.


__Parameters:__

__verbs__  
supported verbs: FL_AXES, FL_BBOX, FL_LAYOUT

__axis__  
layout direction vector

__gap__  
gap inserted along «axis»

__types__  
list of types to be arranged

__align__  
Internal type alignment into the resulting bounding box surfaces.

Is managed through a vector whose x,y,z components can assume -1,0 or +1 values.

[-1,0,+1] means aligned to the -X and +Z surfaces, centered on y axis.

Passing a scalar means [scalar,scalar,scalar]


__direction__  
desired direction in [vector,rotation] form, native direction when undef ([+X+Y+Z])

__octant__  
when undef native positioning is used


---

### module fl_linear_extrude

__Syntax:__

    fl_linear_extrude(direction,length,convexity=10)

Z-Axis extrusion is oriented along arbitrary axis/rotation


__Parameters:__

__direction__  
direction in [axis,angle] representation


---

### module fl_lookAtMe

__Syntax:__

    fl_lookAtMe()

rotates children to face camera

---

### module fl_new_cutout

__Syntax:__

    fl_new_cutout(bbox,director,drift=0,trim)

Cutout along arbitrary direction of children shapes.

Context variables:

| Name             | Context   | Description                                     |
| ---------------- | --------- | ----------------------------------------------- |
| $fl_thickness    | Parameter | multi-verb parameter (see [fl_parm_thickness()](core.md#function-fl_parm_thickness))  |
| $fl_tolerance    | Parameter | multi-verb parameter (see [fl_parm_tolerance()](core.md#function-fl_parm_tolerance))  |


__Parameters:__

__bbox__  
bounding box delimiting children shape(s)

__director__  
direction vector (3d vector format)

__drift__  
Scalar or function literal (with signature `drift()`) returning a scalar
value, adding space from children boundaries (if negative this value is
actually subtracted).



__trim__  
3d translation or function literal (signature `trim()`) returning a 3d
translation that is applied BEFORE projection().

:memo: **NOTE:** trimming modify the OpenSCAD projection module behavior, enabling
its «cut» parameter.



---

### module fl_place

__Syntax:__

    fl_place(type,octant,quadrant,bbox)

__Parameters:__

__octant__  
3d octant

__quadrant__  
2d quadrant

__bbox__  
bounding box corners


---

### module fl_placeIf

__Syntax:__

    fl_placeIf(condition,type,octant,quadrant,bbox)

__Parameters:__

__condition__  
when true placement is ignored

__octant__  
3d octant

__quadrant__  
2d quadrant

__bbox__  
bounding box corners


---

### module fl_planeAlign

__Syntax:__

    fl_planeAlign(ax,ay,bx,by,ech=false)

---

### module fl_prism

__Syntax:__

    fl_prism(verbs=FL_ADD,type,n,l,l1,l2,h,octant,direction)

Right prism.

![default positioning](256x256/fig_3d_prism_defaults.png)


__Parameters:__

__verbs__  
FL_ADD,FL_AXES,FL_BBOX

__n__  
edge number

__l__  
edge length

__l1__  
edge length, bottom

__l2__  
edge length, top

__h__  
height

__octant__  
when undef native positioning is used

__direction__  
desired direction [director,rotation], native direction when undef ([+X+Y+Z])


---

### module fl_pyramid

__Syntax:__

    fl_pyramid(verbs=FL_ADD,type,base,apex,octant,direction)

Right pyramid.

![default positioning](256x256/fig_3d_pyramid_defaults.png)


__Parameters:__

__verbs__  
FL_ADD,FL_AXES,FL_BBOX

__octant__  
when undef native positioning is used

__direction__  
desired direction [director,rotation], native direction when undef ([+X+Y+Z])


---

### module fl_sphere

__Syntax:__

    fl_sphere(verbs=FL_ADD,type,r,d,octant,direction)

Sphere replacement.

![default positioning](256x256/fig_3d_sphere_defaults.png)


__Parameters:__

__verbs__  
FL_ADD,FL_AXES,FL_BBOX

__octant__  
when undef default positioning is used

__direction__  
desired direction [director,rotation], default direction if undef


---

### module fl_sym_direction

__Syntax:__

    fl_sym_direction(verbs=FL_ADD,direction,size=0.5)

display the direction change from a native coordinate system and a new
direction specification in [direction,rotation] format.

:memo: **NOTE:** the native coordinate system (ncs) is now meant to be the standard
+X+Y+Z (with direction set by +Z)


__Parameters:__

__verbs__  
supported verbs: FL_ADD

__direction__  
direction in [Axis–angle representation](https://en.wikipedia.org/wiki/Axis%E2%80%93angle_representation)
in the format

    [axis,rotation angle]


__size__  
default size given as a scalar


---

### module fl_sym_hole

__Syntax:__

    fl_sym_hole(verbs=FL_ADD)

this symbol uses as input a complete node context.

The symbol is oriented according to the hole normal.


__Parameters:__

__verbs__  
supported verbs: FL_ADD


---

### module fl_sym_plug

__Syntax:__

    fl_sym_plug(verbs=[FL_ADD,FL_AXES],type=undef,size=0.5)

---

### module fl_sym_point

__Syntax:__

    fl_sym_point(verbs=FL_ADD,point=FL_O,size,color="black")

Point symbol.


__Parameters:__

__verbs__  
supported verbs: FL_ADD

__size__  
synonymous of point diameter


---

### module fl_sym_socket

__Syntax:__

    fl_sym_socket(verbs=[FL_ADD,FL_AXES],type=undef,size=0.5)

---

### module fl_symbol

__Syntax:__

    fl_symbol(verbs=FL_ADD,type=undef,size=0.5,symbol)

provides the symbol required in its 'canonical' form:
- "plug": 'a piece that fits into a hole in order to close it'
         Its canonical form implies an orientation of the piece coherent
         with its insertion movement along +Z axis.
- "socket": 'a part of the body into which another part fits'
         Its canonical form implies an orientation of the piece coherent
         with its fitting movement along -Z axis.

[variable FL_LAYOUT](core.md#variable-fl_layout) is used for proper label orientation

Children context:

- $sym_ldir: [axis,angle]
- $sym_size: size in 3d format


__Parameters:__

__verbs__  
supported verbs: FL_ADD, FL_LAYOUT

__size__  
default size given as a scalar

__symbol__  
currently "plug" or "socket"


---

### module fl_torus

__Syntax:__

    fl_torus(verbs=FL_ADD,r,d,e,R,direction,octant)

«e» and «R» are mutually exclusive parameters


__Parameters:__

__verbs__  
supported verbs: FL_ADD, FL_AXES, FL_BBOX

__r__  
radius of the circular tube.

__d__  
diameter of the circular tube.

__e__  
elliptic tube [a,b] form

__R__  
distance from the center of the tube to the center of the torus

__direction__  
desired direction [director,rotation], native direction when undef ([+X+Y+Z])

__octant__  
when undef native positioning is used


---

### module fl_tube

__Syntax:__

    fl_tube(verbs=FL_ADD,base,r,d,h,thick,direction,octant)

__Parameters:__

__verbs__  
supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT

__base__  
base ellipse in [a,b] form

__r__  
«base» alternative radius for circular tubes

__d__  
«base» alternative diameter for circular tubes

__h__  
pipe height

__thick__  
tube thickness

__direction__  
desired direction [director,rotation], native direction when undef ([+X+Y+Z])

__octant__  
when undef native positioning is used


---

### module fl_vloop

__Syntax:__

    fl_vloop(verbs,bbox,octant,direction)

Low-level verb-driven OFL API management.

Three-dimensional steps:

1. verb looping
2. octant translation («octant» parameter)
3. orientation along a given direction / angle («direction» parameter)

**1. Verb looping:**

Each passed verb triggers in turn the children modules with an execution
context describing:

- the verb actually triggered;
- the OpenSCAD character modifier descriptor (see also [OpenSCAD User Manual/Modifier
  Characters](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Modifier_Characters))

Verb list like `[FL_ADD, FL_DRILL]` will loop children modules two times,
once for the FL_ADD implementation and once for the FL_DRILL.

The only exception to this is the FL_AXES verb, that needs to be executed
outside the canonical transformation pipeline (without applying «octant» translations).
FL_AXES implementation - when passed in the verb list - is provided
automatically by the library.

So a verb list like `[FL_ADD, FL_AXES, FL_DRILL]` will trigger the children
modules twice: once for FL_ADD and once for FL_DRILL. OFL will trigger an
internal FL_AXES implementation.

**2. Octant translation**

A coordinate system divides three-dimensional spaces in eight
[octants](https://en.wikipedia.org/wiki/Octant_(solid_geometry)).

Using the bounding-box information provided by the «bbox» parameter, we can
fit the shapes defined by children modules exactly in one octant.

**3. Orientation**

OFL can also orient shapes defined by children modules along arbitrary axis
and additionally rotate around it.

Context variables:

| Name       | Context   | Description
| ---------- | --------- | ---------------------
|            | Children  | see [fl_generic_vloop{}](mngm-engine.md#module-fl_generic_vloop) context variables


__Parameters:__

__verbs__  
verb list

__bbox__  
mandatory bounding box

__octant__  
when undef native positioning is used

__direction__  
desired direction [director,rotation], native direction when undef


---

### module fl_vmanage

__Syntax:__

    fl_vmanage(verbs,this,octant,direction)

High-level (OFL 'objects' only) verb-driven OFL API management.

It does pretty much the same things like [fl_vloop{}](#module-fl_vloop) but with a different
interface and enriching the children context with new context variables.

**Usage:**

    // An OFL object is a list of [key,values] items
    object = fl_Object(...);

    ...

    // this engine is called once for every verb passed to module fl_vmanage
    module engine() let(
      ...
    ) if ($this_verb==FL_ADD)
      ; // verb implementation code

      else if ($this_verb==FL_BBOX)
      ; // verb implementation code

      else if ($this_verb==FL_CUTOUT)
      ; // verb implementation code

      else if ($this_verb==FL_DRILL)
      ; // verb implementation code

      else if ($this_verb==FL_LAYOUT)
      ; // verb implementation code

      else if ($this_verb==FL_MOUNT)
      ; // verb implementation code

      else
        fl_error(["unimplemented verb",$this_verb]);

    ...

    fl_vmanage(verbs,object,octant=octant,direction=direction)
      engine();

Context variables:

| Name             | Context   | Description                                         |
| ---------------- | --------- | --------------------------------------------------- |
|                  | Children  | see [fl_generic_vmanage{}](mngm-engine.md#module-fl_generic_vmanage) Children context                     |


__Parameters:__

__octant__  
when undef native positioning is used

__direction__  
desired direction [director,rotation], native direction when undef


