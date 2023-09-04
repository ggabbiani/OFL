# package foundation/core

Base definitions for OpenSCAD.

This file is part of the 'OpenSCAD Foundation Library' (OFL) project.

Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Variables

---

### variable $FL_ADD

__Default:__

    "ON"

---

### variable $FL_ASSEMBLY

__Default:__

    "ON"

---

### variable $FL_AXES

__Default:__

    "ON"

---

### variable $FL_BBOX

__Default:__

    "TRANSPARENT"

---

### variable $FL_CUTOUT

__Default:__

    "ON"

---

### variable $FL_DRILL

__Default:__

    "ON"

---

### variable $FL_FOOTPRINT

__Default:__

    "ON"

---

### variable $FL_HOLDERS

__Default:__

    "ON"

---

### variable $FL_LAYOUT

__Default:__

    "ON"

---

### variable $FL_MOUNT

__Default:__

    "ON"

---

### variable $FL_PAYLOAD

__Default:__

    "DEBUG"

---

### variable $FL_RENDER

__Default:__

    !$preview

When true, disables PREVIEW corrections (see [variable FL_NIL](#variable-fl_nil))

---

### variable $FL_SYMBOLS

__Default:__

    "ON"

---

### variable FL_2xNIL

__Default:__

    2*FL_NIL

---

### variable FL_ADD

__Default:__

    "FL_ADD add base shape (no components nor screws)"

add a base shape (with no components nor screws)

---

### variable FL_ASSEMBLY

__Default:__

    "FL_ASSEMBLY add predefined component shape(s)"

add predefined component shape(s).

:memo: **NOTE:** this operation doesn't include screws, for these see [variable FL_MOUNT](#variable-fl_mount)


---

### variable FL_AXES

__Default:__

    "FL_AXES draw of local reference axes"

draws local reference axes

---

### variable FL_BBOX

__Default:__

    "FL_BBOX adds a bounding box containing the object"

adds a bounding box containing the object

---

### variable FL_CUTOUT

__Default:__

    "FL_CUTOUT layout of predefined cutout shapes (±X,±Y,±Z)."

layout of predefined cutout shapes (±X,±Y,±Z)

---

### variable FL_DEPRECATED

__Default:__

    "FL_DEPRECATED is a test verb. **DEPRECATED**"

is a test verb for library development

---

### variable FL_DRAW

__Default:__

    [FL_ADD,FL_ASSEMBLY]

composite verb serializing one ADD and ASSEMBLY operation.
See also [variable FL_ADD](#variable-fl_add) and [variable FL_ASSEMBLY](#variable-fl_assembly)


---

### variable FL_DRILL

__Default:__

    "FL_DRILL layout of predefined drill shapes (like holes with predefined screw diameter)"

layout of predefined drill shapes (like holes with predefined screw diameter)

---

### variable FL_EXCLUDE_ANY

__Default:__

    ["AND",function(one,other)one!=other]

see [fl_list_filter()](#function-fl_list_filter) «operator» parameter

---

### variable FL_FOOTPRINT

__Default:__

    "FL_FOOTPRINT adds a footprint to scene, usually a simplified FL_ADD"

adds a footprint to scene, usually a simplified ADD operation (see [variable FL_ADD](#variable-fl_add))

---

### variable FL_HOLDERS

__Default:__

    "FL_HOLDERS adds vitamine holders to the scene. **DEPRECATED**"

adds vitamine holders to the scene. **Warning** this verb is **DEPRECATED**

---

### variable FL_I

__Default:__

    [[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1],]

identity matrix in homogeneous coordinates

---

### variable FL_INCLUDE_ALL

__Default:__

    ["OR",function(one,other)one==other]

see [fl_list_filter()](#function-fl_list_filter) «operator» parameter

---

### variable FL_LAYOUT

__Default:__

    "FL_LAYOUT layout of user passed accessories (like alternative screws)"

layout of user passed accessories (like alternative screws)

---

### variable FL_MOUNT

__Default:__

    "FL_MOUNT mount shape through predefined screws"

mount shape through predefined screws

---

### variable FL_NIL

__Default:__

    ($preview&&!$FL_RENDER?0.01:0)

simple workaround for the z-fighting problem during preview

---

### variable FL_O

__Default:__

    [0,0,0]

Origin

---

### variable FL_OBSOLETE

__Default:__

    "FL_OBSOLETE is a test verb. **OBSOLETE**"

is a test verb for library development

---

### variable FL_PAYLOAD

__Default:__

    "FL_PAYLOAD adds a box representing the payload of the shape"

adds a box representing the payload of the shape

---

### variable FL_SYMBOLS

__Default:__

    "FL_SYMBOLS adds symbols and labels usually for debugging"

add symbols and labels usually for debugging

---

### variable FL_X

__Default:__

    [1,0,0]

X axis

---

### variable FL_Y

__Default:__

    [0,1,0]

Y axis

---

### variable FL_Z

__Default:__

    [0,0,1]

Z axis

---

### variable fl_FDMtolerance

__Default:__

    0.5

Recommended tolerance for FDM as stated in [How do you design snap-fit joints for 3D printing?](https://www.3dhubs.com/knowledge-base/how-design-snap-fit-joints-3d-printing/)

---

### variable fl_JNgauge

__Default:__

    fl_MVgauge/4

PER SURFACE distance in case of jointed parts to be doubled when applied to a diameter

---

### variable fl_MVgauge

__Default:__

    0.6

PER SURFACE distance in case of movable parts to be doubled when applied to a diameter

## Functions

---

### function fl_2

__Syntax:__

```text
fl_2(v)
```

transforms 3D to 2D coords

---

### function fl_3

__Syntax:__

```text
fl_3(v)
```

transforms homogeneous to 3D coords

---

### function fl_4

__Syntax:__

```text
fl_4(v)
```

transforms 3D coords to homogeneous

---

### function fl_R

__Syntax:__

```text
fl_R(u,theta)
```

rotation matrix about arbitrary axis.

TODO: check with more efficient alternative [here](https://gist.github.com/kevinmoran/b45980723e53edeb8a5a43c49f134724)


__Parameters:__

__u__  
arbitrary axis

__theta__  
rotation angle around «u»


---

### function fl_Rx

__Syntax:__

```text
fl_Rx(theta)
```

rotation around X matrix

---

### function fl_Rxyz

__Syntax:__

```text
fl_Rxyz(angle)
```

composite rotation around X then Y then Z axis

---

### function fl_Ry

__Syntax:__

```text
fl_Ry(theta)
```

rotation around Y matrix

---

### function fl_Rz

__Syntax:__

```text
fl_Rz(theta)
```

rotation around Z matrix

---

### function fl_S

__Syntax:__

```text
fl_S(s)
```

scale matrix in homogeneous coordinates

---

### function fl_T

__Syntax:__

```text
fl_T(t)
```

translation matrix in homogeneous coordinates

__Parameters:__

__t__  
depending on the passed value the actual translation matrix will be:

- scalar ⇒ [t,t,t]
- 2d space vector⇒ [t.x,t.y,0]
- 3d space vector⇒ [t.x,t.y,t.z]



---

### function fl_X

__Syntax:__

```text
fl_X(x)
```

Axis X * scalar «x». Generally used for X translation

---

### function fl_XOR

__Syntax:__

```text
fl_XOR(c1,c2)
```

---

### function fl_Y

__Syntax:__

```text
fl_Y(y)
```

Axis Y * scalar «y». Generally used for Y translation

---

### function fl_Z

__Syntax:__

```text
fl_Z(z)
```

Axis Z * scalar «z». Generally used for Z translation

---

### function fl_accum

__Syntax:__

```text
fl_accum(v)
```

---

### function fl_align

__Syntax:__

```text
fl_align(from,to)
```

Applies a Rotation Matrix for aligning fl_vector A (from) to fl_vector B (to).

Taken from
[How to Calculate a Rotation Matrix to Align Vector A to Vector B in 3D](https://gist.github.com/kevinmoran/b45980723e53edeb8a5a43c49f134724)


---

### function fl_assert

__Syntax:__

```text
fl_assert(condition,message,result)
```

---

### function fl_asserts

__Syntax:__

```text
fl_asserts()
```

When true [fl_assert()](#function-fl_assert) is enabled

**TODO**: remove since deprecated.


---

### function fl_connectors

__Syntax:__

```text
fl_connectors(type,value)
```

---

### function fl_cutout

__Syntax:__

```text
fl_cutout(type,value)
```

---

### function fl_debug

__Syntax:__

```text
fl_debug()
```

When true debug statements are turned on

---

### function fl_deprecated

__Syntax:__

```text
fl_deprecated(bad,value,replacement)
```

deprecated function call

---

### function fl_description

__Syntax:__

```text
fl_description(type,value)
```

---

### function fl_dict_search

__Syntax:__

```text
fl_dict_search(dictionary,name)
```

---

### function fl_dxf

__Syntax:__

```text
fl_dxf(type,value)
```

---

### function fl_engine

__Syntax:__

```text
fl_engine(type,value)
```

---

### function fl_filament

__Syntax:__

```text
fl_filament()
```

Default color for printable items (i.e. artifacts)

---

### function fl_get

__Syntax:__

```text
fl_get(type,key,default)
```

Mandatory property getter with default value when not found

Never return undef.

| type    | key     | default | key found | result    | semantic |
| ------- | ------- | ------- | --------- | --------- | -------- |
| defined | defined | *       | true      | value     | GETTER   |
| defined | defined | defined | false     | default   | GETTER   |

**ERROR** in all the other cases


---

### function fl_grey

__Syntax:__

```text
fl_grey(n)
```

Generate a shade of grey to pass to color().

---

### function fl_has

__Syntax:__

```text
fl_has(type,property,check=function(value)true)
```

---

### function fl_height

__Syntax:__

```text
fl_height(type)
```

---

### function fl_isEven

__Syntax:__

```text
fl_isEven(n)
```

true when n is even

---

### function fl_isMultiple

__Syntax:__

```text
fl_isMultiple(n,m)
```

true when n is multiple of m

---

### function fl_isOdd

__Syntax:__

```text
fl_isOdd(n)
```

true when n is odd

---

### function fl_isOrthogonal

__Syntax:__

```text
fl_isOrthogonal(a,b)
```

---

### function fl_isParallel

__Syntax:__

```text
fl_isParallel(a,b,exact=true)
```

---

### function fl_isSet

__Syntax:__

```text
fl_isSet(flag,list)
```

return true if «flag» is present in «list».
TODO: make a case insensitive option


---

### function fl_list_filter

__Syntax:__

```text
fl_list_filter(list,operator,compare,__result__=[],__first__=true)
```

---

### function fl_list_flatten

__Syntax:__

```text
fl_list_flatten(list)
```

recursively flatten infinitely nested list

---

### function fl_list_has

__Syntax:__

```text
fl_list_has(list,item)
```

---

### function fl_material

__Syntax:__

```text
fl_material(type,value,default)
```

---

### function fl_name

__Syntax:__

```text
fl_name(type,value)
```

---

### function fl_native

__Syntax:__

```text
fl_native(type,value)
```

---

### function fl_nopSCADlib

__Syntax:__

```text
fl_nopSCADlib(type,value,default)
```

---

### function fl_optProperty

__Syntax:__

```text
fl_optProperty(type,key,value,default)
```

'bipolar' optional property helper:

- type/key{/default} ↦ returns the property value (no error if property not found)
- key{/value}        ↦ returns the property [key,value] (acts as a property constructor)

This getter returns 'undef' when the key is not found and no default is passed.

| type    | key     | default | key found | result      | semantic |
| ------- | ------- | ------- | --------- | ----------- | -------- |
| undef   | defined | undef   | *         | [key,value] | SETTER   |
| defined | defined | *       | false     | default     | GETTER   |
| defined | defined | *       | true      | value       | GETTER   |

**ERROR** in all the other cases


---

### function fl_optional

__Syntax:__

```text
fl_optional(type,key,default)
```

Optional getter, no error when property is not found.

Return «default» when «type» is undef or empty, or when «key» is not found

| type    | key     | default | key found | result    | semantic |
| ------- | ------- | ------- | --------- | --------- | -------- |
| undef   | *       | *       | *         | default   | GETTER   |
| defined | defined | *       | false     | default   | GETTER   |
| defined | defined | *       | true      | value     | GETTER   |

**ERROR** in all the other cases


---

### function fl_palette

__Syntax:__

```text
fl_palette(color,axis)
```

returns the canonical axis color when invoked by «axis»

    X ⟹ red
    Y ⟹ green
    Z ⟹ blue

or the corresponding color palette if invoked by «color»

__NOTE__: «axis» and «color» are mutually exclusive.


---

### function fl_parm_Debug

__Syntax:__

```text
fl_parm_Debug(labels=false,symbols=false,components=[])
```

constructor for debug context parameter

__Parameters:__

__labels__  
when true, labels to symbols are assigned and displayed

__symbols__  
when true symbols are displayed


---

### function fl_parm_Octant

__Syntax:__

```text
fl_parm_Octant(x,y,z)
```

Constructor for the octant parameter from values as passed by customizer
(see [fl_octant()](3d-engine.md#function-fl_octant) for the semantic behind).

Each dimension can assume one out of four values:

- "undef": mapped to undef
- -1,0,+1: untouched


---

### function fl_parm_components

__Syntax:__

```text
fl_parm_components(debug,label)
```

---

### function fl_parm_labels

__Syntax:__

```text
fl_parm_labels(debug)
```

When true debug labels are turned on

---

### function fl_parm_symbols

__Syntax:__

```text
fl_parm_symbols(debug)
```

When true debug symbols are turned on

---

### function fl_parse_diameter

__Syntax:__

```text
fl_parse_diameter(r,r1,d,d1,def)
```

---

### function fl_parse_l

__Syntax:__

```text
fl_parse_l(l,l1,def)
```

---

### function fl_parse_radius

__Syntax:__

```text
fl_parse_radius(r,r1,d,d1,def)
```

---

### function fl_payload

__Syntax:__

```text
fl_payload(type,value)
```

---

### function fl_pcb

__Syntax:__

```text
fl_pcb(type,value)
```

---

### function fl_pop

__Syntax:__

```text
fl_pop(l,i=0)
```

removes till the i-indexed element from the top of list «l»

---

### function fl_property

__Syntax:__

```text
fl_property(type,key,value,default)
```

'bipolar' property helper:

- type/key{/default} ↦ returns the property value (error if property not found)
- key{/value}        ↦ returns the property [key,value] (acts as a property constructor)

It concentrates property key definition reducing possible mismatch when
referring to property key in the more usual getter/setter function pair.

This getter never return undef.

| type    | key     | default | key found | result      | semantic |
| ------- | ------- | ------- | --------- | ----------- | -------- |
| undef   | defined | undef   | *         | [key,value] |  SETTER  |
| defined | defined | *       | true      | value       |  GETTER  |
| defined | defined | defined | false     | default     |  GETTER  |

**ERROR** in all the other cases


---

### function fl_push

__Syntax:__

```text
fl_push(list,item)
```

push «item» on tail of list «l»

---

### function fl_screw

__Syntax:__

```text
fl_screw(type,value)
```

---

### function fl_size

__Syntax:__

```text
fl_size(type)
```

---

### function fl_str_lower

__Syntax:__

```text
fl_str_lower(s)
```

---

### function fl_str_upper

__Syntax:__

```text
fl_str_upper(s)
```

---

### function fl_sub

__Syntax:__

```text
fl_sub(list,from,to)
```

---

### function fl_switch

__Syntax:__

```text
fl_switch(value,cases,otherwise)
```

---

### function fl_thick

__Syntax:__

```text
fl_thick(type)
```

---

### function fl_tolerance

__Syntax:__

```text
fl_tolerance(type,value)
```

---

### function fl_trace

__Syntax:__

```text
fl_trace(msg,result,always=false)
```

trace helper function.

See module [fl_trace{}](#module-fl_trace).


---

### function fl_transform

__Syntax:__

```text
fl_transform(M,v)
```

Returns M * v , actually transforming v by M.

:memo: **NOTE:** result in 3d format


__Parameters:__

__M__  
4x4 transformation matrix

__v__  
fl_vector (in homogeneous or 3d format)


---

### function fl_vendor

__Syntax:__

```text
fl_vendor(type,value)
```

---

### function fl_version

__Syntax:__

```text
fl_version()
```

---

### function fl_versionNumber

__Syntax:__

```text
fl_versionNumber()
```

---

### function fl_versor

__Syntax:__

```text
fl_versor(v)
```

---

### function fl_width

__Syntax:__

```text
fl_width(type)
```

---

### function sort

__Syntax:__

```text
sort(vec)
```

quick sort algorithm

## Modules

---

### module fl_align

__Syntax:__

    fl_align(from,to)

---

### module fl_assert

__Syntax:__

    fl_assert(condition,message)

---

### module fl_axes

__Syntax:__

    fl_axes(size=1,reverse=false)

---

### module fl_color

__Syntax:__

    fl_color(color,alpha=1)

Set current color and alpha channel, using variable $fl_filament when «color» is
undef. When variable $fl_debug is true, color information is ignored and debug
modifier is applied to children().


---

### module fl_modifier

__Syntax:__

    fl_modifier(behavior,reset=true)

Modifier module for verbs.


__Parameters:__

__behavior__  
"OFF","ON","ONLY","DEBUG","TRANSPARENT"


---

### module fl_overlap

__Syntax:__

    fl_overlap(u1,u2,position)

Aligns children from u1 to u2 and move to position

---

### module fl_status

__Syntax:__

    fl_status()

---

### module fl_trace

__Syntax:__

    fl_trace(msg,value,always=false)

trace helper module.

prints «msg» prefixed by its call order either if «always» is true or if its
current call order is ≤ $FL_TRACES.

Used $special variables:

- $FL_TRACE affects trace messages according to its value:
  - -2   : all traces disabled
  - -1   : all traces enabled
  - [0,∞): traces with call order ≤ $FL_TRACES are enabled


__Parameters:__

__msg__  
message to be printed

__value__  
optional value generally usable for printing a variable content

__always__  
when true the trace is always printed


---

### module fl_vector

__Syntax:__

    fl_vector(P,outward=true,endpoint="arrow",ratio=20)

Draws a fl_vector [out|in]ward P

---

### module fl_versor

__Syntax:__

    fl_versor(P)

Draws a fl_versor facing point P

