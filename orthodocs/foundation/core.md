# package foundation/core

Base definitions for OpenSCAD.

This file is part of the 'OpenSCAD Foundation Library' (OFL) project.

Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Variables

---

### variable $FL_ADD

__Default:__

    is_undef($FL_ADD)?"ON":$FL_ADD

---

### variable $FL_ASSEMBLY

__Default:__

    is_undef($FL_ASSEMBLY)?"ON":$FL_ASSEMBLY

---

### variable $FL_AXES

__Default:__

    is_undef($FL_AXES)?"ON":$FL_AXES

---

### variable $FL_BBOX

__Default:__

    is_undef($FL_BBOX)?"TRANSPARENT":$FL_BBOX

---

### variable $FL_CUTOUT

__Default:__

    is_undef($FL_CUTOUT)?"ON":$FL_CUTOUT

---

### variable $FL_DRILL

__Default:__

    is_undef($FL_DRILL)?"ON":$FL_DRILL

---

### variable $FL_FOOTPRINT

__Default:__

    is_undef($FL_FOOTPRINT)?"ON":$FL_FOOTPRINT

---

### variable $FL_HOLDERS

__Default:__

    is_undef($FL_HOLDERS)?"ON":$FL_HOLDERS

---

### variable $FL_LAYOUT

__Default:__

    is_undef($FL_LAYOUT)?"ON":$FL_LAYOUT

---

### variable $FL_MOUNT

__Default:__

    is_undef($FL_MOUNT)?"ON":$FL_MOUNT

---

### variable $FL_PAYLOAD

__Default:__

    is_undef($FL_PAYLOAD)?"DEBUG":$FL_PAYLOAD

---

### variable $FL_RENDER

__Default:__

    is_undef($FL_RENDER)?!$preview:$FL_RENDER

When true, disables PREVIEW corrections (see [variable FL_NIL](#variable-fl_nil))

---

### variable FL_2D

__Default:__

    function(3d)fl_2(3d)

function literal converting 3D to 2D coords by clipping Z plane

NOTE: it's safe to be used as function literal parameter in [fl_list_transform()](#function-fl_list_transform)


---

### variable FL_2xNIL

__Default:__

    2*FL_NIL

---

### variable FL_3D

__Default:__

    function(2d)[2d.x,2d.y,0]

function literal converting from 2d to 3d by projection on plane Z==0

NOTE: it's safe to be used as function literal parameter in [fl_list_transform()](#function-fl_list_transform)


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

    "FL_CUTOUT"

Layout of predefined cutout shapes (±X,±Y,±Z).

Default cutouts are provided through extrusion of object sections along
one or more semi-axes (±X,±Y,±Z).

**Preferred directions**

Preferred cutout directions are specified through the [fl_cutout()](#function-fl_cutout) property as
a list of directions along which the cutout occurs on eventually alternative
sections. This is the case - for example - of an audio jack socket (see
[variable FL_JACK_BARREL](../vitamins/jacks.md#variable-fl_jack_barrel)): on all directions but +X (its 'preferred' cutout
direction) the cutout is the standard one, on +X axis the cutout section is
circular to allow the insertion of the jack plug.

:memo: **NOTE:** The [fl_cutout()](#function-fl_cutout) property also modifies the behavior of the object
when it is passed as a component (via fl_Component()) of a 'parent' object.
In these cases, in fact, the object will no longer modify the bounding box of
its parent in the 'preferred' directions, while on all the others it will
maintain the standard behavior.

:memo: **NOTE:** The existence of one or more 'preferred' cutout direction, modify
also the behavior of a FL_CUTOUT operation. When no cutout direction is
provided, the preferred directions are anyway executed. The only way for
producing a no-op is passing an empty cutout direction list (`cut_dirs=[]`).

:memo: **NOTE:** The main difference between this verb and FL_DRILL (see variable
FL_DRILL) is that the FL_CUTOUT acts on every semi-axis provided by the
caller, while the latter operates ONLY along its 'preferred' direction(s).


**Usage**

when implementing this verb inside a [fl_vmanage{}](3d-engine.md#module-fl_vmanage) loop, its typical usage is
the following:

    ...
    cut_dirs    = cut_dirs ? cut_dirs : fl_cutout(type);
    ...
    fl_vmanage(verbs,type,octant=octant,direction=direction)
      ...
      else if ($this_verb==FL_CUTOUT)
        fl_cutoutLoop(cut_dirs, fl_cutout($this))
          if ($co_preferred) {
            // $co_current contain the current preferred cutout direction
            ...
          } else {
            fl_new_cutout($this_bbox,$co_current,drift=drift,$fl_tolerance=$fl_tolerance+2xNIL)
              // children shape from which create the 'standard' cutout
              ...
          }
      ...

**Parameters**

FL_CUTOUT behavior can be modified through the following parameters:

| Name           | Type              | Default                 | Description                                       |
| -------------- | ----------------- | ----------------------- | ------------------------------------------------- |
| cut_dirs       | parameter         | Object 'preferred' ones as returned by the [fl_cutout()](#function-fl_cutout) property | list of semi-axes indicating the cutout directions. |
| cut_drift      | parameter         | 0                       | Cutout extrusions are adjacent to the object bounding box, this parameter adds or subtracts a delta. |
| cut_trim       | parameter         | undef                   | 3d translation applied to children() before extrusion, when set object section is modified like the «cut» parameters does in the OpenSCAD primitive projection{} |
| $fl_thickness  | parameter context | see fl_parm_thickness() | overall thickness of the cutout surface           |
| $fl_tolerance  | parameter context | see fl_parm_tolerance() | delta added or subtracted from the object section |



---

### variable FL_DEPRECATED

__Default:__

    "FL_DEPRECATED is a test verb. **DEPRECATED**"

test verb for library development

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

Layout of predefined drill shapes.

Drills can be of two types:

- tap drill: compared to its screw, it has a smaller diameter to allow
  threading. According to a commonly used formula, the tap drill diameter
  usually can be calculated from the __nominal diameter minus the thread
  pitch__;
- clearance drill: it has a larger diameter to allow the screw to pass
  through. Usually equals to __nominal diameter plus clearance value__;

Context parameters used:

| Name           | Description                     |
| -------------  | ------------------------------- |
| $fl_thickness  | material thickness to be drilled, see also [fl_parm_thickness()](#function-fl_parm_thickness) |


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

### variable FL_O0

__Default:__

    [+1,+1,+1]

[Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping first octant

---

### variable FL_O1

__Default:__

    [-1,+1,+1]

[Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping octant 1

---

### variable FL_O2

__Default:__

    [-1,-1,+1]

[Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping octant 2

---

### variable FL_O3

__Default:__

    [+1,-1,+1]

[Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping octant 3

---

### variable FL_O4

__Default:__

    [+1,-1,-1]

[Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping octant 4

---

### variable FL_O5

__Default:__

    [-1,-1,-1]

[Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping octant 5

---

### variable FL_O6

__Default:__

    [-1,+1,-1]

[Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping octant 6

---

### variable FL_O7

__Default:__

    [+1,+1,-1]

[Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping octant 7

---

### variable FL_OBSOLETE

__Default:__

    "FL_OBSOLETE is a test verb. **OBSOLETE**"

test verb for library development

---

### variable FL_PAYLOAD

__Default:__

    "FL_PAYLOAD adds a box representing the payload of the shape"

adds a box representing the payload of the shape

---

### variable FL_QI

__Default:__

    [+1,+1,undef]

Roman enumeration of first quadrant

---

### variable FL_QII

__Default:__

    [-1,+1,undef]

Roman enumeration of quadrant 2

---

### variable FL_QIII

__Default:__

    [-1,-1,undef]

Roman enumeration of quadrant 3

---

### variable FL_QIV

__Default:__

    [+1,-1,undef]

Roman enumeration of quadrant 4

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

transforms 3D to 2D coords by clipping Z plane

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

### function fl_OFL

__Syntax:__

```text
fl_OFL(type,value,default)
```

when present and true indicates the object is an OFL one

TODO: duplicate of [fl_native()](#function-fl_native)?!


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

### function fl_atof

__Syntax:__

```text
fl_atof(str)
```

Ascii string to number conversion function atof() by Jesse Campbell.

Scientific notation support added by Alexander Pruss.

Copyright © 2017, Jesse Campbell <www.jbcse.com>

SPDX-License-Identifier: [CC-BY-4.0](https://spdx.org/licenses/CC-BY-4.0.html)


---

### function fl_atoi

__Syntax:__

```text
fl_atoi(str,base=10,i=0,nb=0)
```

Returns the numerical form of a string

Usage:

    echo(fl_atoi("491585"));                 // 491585
    echo(fl_atoi("-15"));                    // -15
    echo(fl_atoi("01110", 2));               // 14
    echo(fl_atoi("D5A4", 16));               // 54692
    echo(fl_atoi("-5") + fl_atoi("10") + 5); // 10

Original code pasted from TOUL: [The OpenScad Usefull
Library](http://www.thingiverse.com/thing:1237203)

Copyright © 2015, Nathanaël Jourdane <nathanael@jourdane.net>

SPDX-License-Identifier: [CC-BY-4.0](https://spdx.org/licenses/CC-BY-4.0.html)


__Parameters:__

__str__  
The string to converts (representing a number)

__base__  
The base conversion of the number

| Value  | Description           |
| ------ | --------------------- |
| 2      | for binary            |
| 10     | for decimal (default) |
| 16     | for hexadecimal       |



---

### function fl_connectors

__Syntax:__

```text
fl_connectors(type,value)
```

---

### function fl_cumulativeSum

__Syntax:__

```text
fl_cumulativeSum(v)
```

returns a vector in which each item is the sum of the previous ones

---

### function fl_currentView

__Syntax:__

```text
fl_currentView()
```

returns the esoteric name associated to the current OpenSCAD view:

| Returned string  | Projection plane  |
| ---------------- | ----------------- |
| "right"          | YZ                |
| "top"            | XY                |
| "bottom"         | YX                |
| "left"           | ZY                |
| "front"          | XZ                |
| "back"           | ZX                |
| "other"          | -                 |


---

### function fl_cutout

__Syntax:__

```text
fl_cutout(type,value,default)
```

cut-out directions in floating semi-axis list form as described in
[fl_tt_isAxisList()](traits-engine.md#function-fl_tt_isaxislist).

This property represents the list of cut-out directions supported by the
passed type.

TODO: rename as plural


---

### function fl_dbg_assert

__Syntax:__

```text
fl_dbg_assert()
```

When true debug asserts are turned on

---

### function fl_dbg_color

__Syntax:__

```text
fl_dbg_color()
```

When true OFL color debug is enabled

---

### function fl_dbg_components

__Syntax:__

```text
fl_dbg_components(label)
```

checks if component «label» is marked for debugging

---

### function fl_dbg_dimensions

__Syntax:__

```text
fl_dbg_dimensions()
```

When true dimension lines are turned on

---

### function fl_dbg_labels

__Syntax:__

```text
fl_dbg_labels()
```

When true debug labels are turned on

---

### function fl_dbg_symbols

__Syntax:__

```text
fl_dbg_symbols()
```

When true debug symbols are turned on

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

### function fl_dict_names

__Syntax:__

```text
fl_dict_names(dictionary)
```

return a list with the names of the objects present in «dictionary»

---

### function fl_dict_organize

__Syntax:__

```text
fl_dict_organize(dictionary,range,func)
```

build a dictionary with rows constituted by items with equal property as
retrieved by «func».

example:

      dict = [
        ["first", 7],
        ["second",9],
        ["third", 9],
        ["fourth",2],
        ["fifth", 2],
      ];

      result   = fl_dict_organize(dictionary=dict, range=[0:10], func=function(item) item[1]);

is functionally equal to:

      result = [
        [], //  0
        [], //  1
        [   //  2
          ["fourth", 2],
          ["fifth",  2]
        ],
        [], // 3
        [], // 4
        [], // 5
        [], // 6
        [   // 7
          ["first", 7]
        ],
        [], // 8
        [   // 9
          ["second", 9], ["third", 9]
        ],
        []  // 10
      ];


---

### function fl_dict_search

__Syntax:__

```text
fl_dict_search(dictionary,name)
```

---

### function fl_dimensions

__Syntax:__

```text
fl_dimensions(type,value)
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

### function fl_error

__Syntax:__

```text
fl_error(message)
```

compose an error message

__Parameters:__

__message__  
string or vector of strings


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

### function fl_holes

__Syntax:__

```text
fl_holes(type,value)
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

### function fl_list_AND

__Syntax:__

```text
fl_list_AND(a,b,index_only=false)
```

Logic AND between two lists.

Example:

    a         = [   +X,+Y,-Y,-Z],
    b         = [-X      ,-Y,-Z],
    result    = fl_list_AND(a,b),
    expected  = [-Y,-Z]



---

### function fl_list_filter

__Syntax:__

```text
fl_list_filter(list,filter)
```

return the items from «list» matching a list of conditions.

example 1: filter out numbers from a list of heterogeneous values

    heters = ["a", 4, -1, false, 5, "a string"];
    nums   = fl_list_filter(heters,function(item) is_num(item));

the returned list «nums» is equal to `[4, -1, 5]`

example 2: include only items matching two conditions executed in sequence:

1. is a number
2. is positive

        let(
          list      = ["a", 4, -1, false, 5, "a string"],
          expected  = [4,5],
          result    = fl_list_filter(list,[
            function(item) is_num(item),// check if number (first)
            function(item) item>0       // check if positive (last)
          ])
        ) assert(result==expected,result) echo(result=result);

__NOTE__: filter execution order is the same of their occurrence in
«filters». In the example above the list is first reduced to just the
numbers, then each remaining item is checked for positiveness.


__Parameters:__

__list__  
the list to be filtered

__filter__  
either a function literal or a list of function literals called on each «list» item


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

### function fl_list_head

__Syntax:__

```text
fl_list_head(list,n)
```

Returns the «list» head according to «n»:

- n>0: returns the first «n» elements of «list»
- n<0: returns «list» minus the last «n» items
- n==0: returns []

example:

    list=[1,2,3,4,5,6,7,8,9,10]
    fl_list_head(list,3)==[1,2,3]

example:

    list=[1,2,3,4,5,6,7,8,9,10]
    fl_list_head(list,-7)==[1,2,3]


---

### function fl_list_max

__Syntax:__

```text
fl_list_max(list,score=function(item)item)
```

Return the «list» item with max score. Return undef if «list» is empty.


__Parameters:__

__score__  
function that assigns a score to an element in the «list»: default to item
itself.



---

### function fl_list_medianIndex

__Syntax:__

```text
fl_list_medianIndex(l)
```

calculates the median INDEX of a list


---

### function fl_list_min

__Syntax:__

```text
fl_list_min(list,score=function(item)item)
```

Return the «list» item with min score. Return undef if «list» is empty.


__Parameters:__

__score__  
function that assigns a score to an element in the «list»: default to item
itself.



---

### function fl_list_pack

__Syntax:__

```text
fl_list_pack(left,right)
```

pack two list in a new one like in the following code:

    labels = ["label 1", "label 2", "label 3", "label 4"];
    values = [1, 2, 3];
    result = fl_list_pack(labels,values);

if equivalent to:

    result = [
      ["label 1",  1     ],
      ["label 2",  2     ],
      ["label 3",  3     ],
      ["label 4",  undef ]
    ]


---

### function fl_list_sort

__Syntax:__

```text
fl_list_sort(vec,cmp=function(e1,e2)(e1-e2))
```

quick sort «vec» (from [oampo/missile](https://github.com/oampo/missile))

---

### function fl_list_sub

__Syntax:__

```text
fl_list_sub(list,from,to)
```

returns a sub list

---

### function fl_list_tail

__Syntax:__

```text
fl_list_tail(list,n)
```

Returns the «list» tail according to «n»:

- n>0: returns the last «n» elements of «list»
- n<0: returns «list» minus the first «n» items
- n==0: returns []

example:

    list=[1,2,3,4,5,6,7,8,9,10]
    fl_list_tail(list,3)==[8,9,10]

example:

    list=[1,2,3,4,5,6,7,8,9,10]
    fl_list_tail(list,-7)==[8,9,10]


---

### function fl_list_transform

__Syntax:__

```text
fl_list_transform(list,M,in=function(3d)3d,out=function(3d)3d)
```

Transforms each item in «list» applying the homogeneous transformation matrix
«M». By default the in() and out() lambdas manage 3d points, but overloading
them it is possible to manage different input/output formats like in the
following example:

    // list of 2d points
    list    = [[1,2],[3,4],[5,6]];
    // desired translation in 2d space
    t       = [1,2];
    // translation matrix
    M       = fl_T(t);
    result  = fl_list_transform(
      list,
      M,
      // extend a 2d point into 3d space plane Z==0
      function(2d) [2d.x,2d.y,0],
      // conversion from 3d to 2d space again
      function(3d) [3d.x,3d.y]
    );
    // «expected» result is a list of translated 2d points
    expected = [for(item=list) item+t];
    assert(result==expected);



---

### function fl_list_unique

__Syntax:__

```text
fl_list_unique(dict)
```

strips duplicates from a «dict»

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

TODO: duplicate of [fl_OFL()](#function-fl_ofl)?!


---

### function fl_nominal

__Syntax:__

```text
fl_nominal(type,value)
```

---

### function fl_nopSCADlib

__Syntax:__

```text
fl_nopSCADlib(type,value,default)
```

Verbatim NopSCADlib definition

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
| defined | defined | *       | true      | value       | GETTER   |
| defined | defined | *       | false     | default     | GETTER   |

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

### function fl_parm_MultiVerb

__Syntax:__

```text
fl_parm_MultiVerb(value)
```

Constructor for multi verb parameter.

OFL engines act in a two steps sequence:

1. builds of a number of metrics from the input parameters that will be
   shared among the different verb invocations
2. invoke verbs one by one in the exact order in which they are passed from
   client

Even if generally sensible, this approach has some drawbacks when the
parameter value must be different according to the verb being actually
invoked (for example the «tolerance» used during an FL_DRILL could be
different by the one used during FL_FOOTPRINT). To avoid the split of a
engine invocation as many times as the desired parameter value requires, the
parameter can be passed in a verb-dependant form like in the following code
example:

    tolerance  = fl_parm_MultiVerb([
      [FL_DRILL,     0.1],
      [FL_FOOTPRINT, 0.2]
    ]);
    ...
    fl_engine(verbs=[FL_DRILL,FL_FOOTPRINT],tolerance=tolerance,...);

Inside the engine the tolerance value __for the currently executed verb__ can
be retrieved by the following code:

    tolerance = fl_parm_tolerance(default=0.05);

with the following resulting values:

| verb             | value |
| ----             | ----  |
| FL_DRILL         | 0.1   |
| FL_FOOTPRINT     | 0.2   |
| all other cases  | 0.05  |

NOTE: a special key "*" can be used in the constructor to define a default
value for non matched verbs. This defaults will override the «default»
parameter passed to client function (like [fl_parm_tolerance()](#function-fl_parm_tolerance) or
[fl_parm_thickness()](#function-fl_parm_thickness)). If the previous example is modified in this way:

    tolerance  = fl_parm_MultiVerb([
      [FL_DRILL,     0.1 ],
      [FL_FOOTPRINT, 0.2 ],
      ["*",          0.01]
    ]);
    ...
    fl_engine(verbs=[FL_DRILL,FL_FOOTPRINT],tolerance=tolerance,...);

the resulting values will be:

| verb             | value |
| ----             | ----  |
| FL_DRILL         | 0.1   |
| FL_FOOTPRINT     | 0.2   |
| all other cases  | 0.01  |


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

### function fl_parm_SignedPair

__Syntax:__

```text
fl_parm_SignedPair(list)
```

The function takes an unordered pair of two opposite signed values and
returns an ordered list with the negative value at position 0 and the
positive at position 1.

When the input is a scalar, its absolute value will be used for both
negative/positive values with sign flag set accordingly.

This type is used for storing semi-axis related values like - for example -
thickness values. The transformed value is still compatible with the passed
input, so can be safely forwarded to other signed-value parameters. Otoh, it
simplifies the fetch of its components once 'normalized' in fixed-form with
negative/positive parts at index 0/1 respectively.

Example 1:

    ordered    = fl_list_SignedPair([+3,-7]);

«ordered» is equal to `[-7,+3]`.

Example 2:

    ordered    = fl_list_SignedPair(-5);

«ordered» is now equal to `[-5,+5]`.

This type is used - for example - for specifying a thickness value along an
axis.


---

### function fl_parm_multiverb

__Syntax:__

```text
fl_parm_multiverb(value,default)
```

Multi valued verb-dependent parameter getter.

See [fl_parm_MultiVerb()](#function-fl_parm_multiverb) for details.

__NOTE__: this function asserts «value» must well formed


__Parameters:__

__value__  
parameter value

__default__  
default value eventually overridden by default key/value ("*",default value)


---

### function fl_parm_thickness

__Syntax:__

```text
fl_parm_thickness(default=0)
```

Multi valued verb-dependent thickness parameter getter.

See [fl_parm_multiverb()](#function-fl_parm_multiverb) for details.


---

### function fl_parm_tolerance

__Syntax:__

```text
fl_parm_tolerance(default=0)
```

Multi valued verb-dependent tolerance parameter getter.

See [fl_parm_multiverb()](#function-fl_parm_multiverb) for details.


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

pay-load bounding box, it contributes to the overall bounding box calculation

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

### function fl_quadraticSolve

__Syntax:__

```text
fl_quadraticSolve(a,b,c,epsilon=NIL)
```

solves a quadratic equation ax^2+bx+c=0 through the Quadratic Formula.

---

### function fl_radius

__Syntax:__

```text
fl_radius(type,value)
```

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

### function fl_split

__Syntax:__

```text
fl_split(str,sep=" ",i=0,word="",v=[])
```

Returns a vector of substrings by cutting the string `str` each time where `sep` appears.
See also: [fl_strcat()](#function-fl_strcat), str2vec()

Usage:

    str = "OpenScad is a free CAD software.";
    echo(fl_split(str));                 // ["OpenScad", "is", "a", "free", "CAD", "software."]
    echo(fl_split(str)[3]);              // "free"
    echo(fl_split("foo;bar;baz", ";"));  // ["foo", "bar", "baz"]

Original code pasted from TOUL: [The OpenScad Useful
Library](http://www.thingiverse.com/thing:1237203)

Copyright © 2015, Nathanaël Jourdane <nathanael@jourdane.net>

SPDX-License-Identifier: [CC-BY-4.0](https://spdx.org/licenses/CC-BY-4.0.html)


__Parameters:__

__str__  
the original string

__sep__  
The separator who cuts the string (" " by default)


---

### function fl_stl

__Syntax:__

```text
fl_stl(type,value)
```

---

### function fl_str_concat

__Syntax:__

```text
fl_str_concat(list)
```

return a string that is the concatenation of all the list members

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

### function fl_strcat

__Syntax:__

```text
fl_strcat(v,sep="",str="",i=0,j=0)
```

Returns a string of a concatenated vector of substrings `v`, with an optionally
separator `sep` between each. See also: [fl_split()](#function-fl_split).

Usage:
    v = ["OpenScad", "is", "a", "free", "CAD", "software."];
    echo(fl_strcat(v));      // "OpenScadisafreeCADsoftware."
    echo(fl_strcat(v, " ")); // "OpenScad is a free CAD software."

Original code pasted from TOUL: [The OpenScad Useful
Library](http://www.thingiverse.com/thing:1237203)

Copyright © 2015, Nathanaël Jourdane <nathanael@jourdane.net>

SPDX-License-Identifier: [CC-BY-4.0](https://spdx.org/licenses/CC-BY-4.0.html)


__Parameters:__

__v__  
The vector of string to concatenate

__sep__  
A separator which will added between each substrings


---

### function fl_substr

__Syntax:__

```text
fl_substr(str,pos=0,len=-1,substr="")
```


Returns a substring of a string.

Usage:

    str = "OpenScad is a free CAD software.";
    echo(fl_substr(str, 12)); // "a free CAD software."
    echo(fl_substr(str, 12, 10)); // "a free CAD"
    echo(fl_substr(str, len=8)); // or fl_substr(str, 0, 8); // "OpenScad"

Original code pasted from TOUL: [The OpenScad Useful
Library](http://www.thingiverse.com/thing:1237203)

Copyright © 2015, Nathanaël Jourdane <nathanael@jourdane.net>

SPDX-License-Identifier: [CC-BY-4.0](https://spdx.org/licenses/CC-BY-4.0.html)


__Parameters:__

__str__  
the original string

__pos__  
(optional): the substring position (0 by default).

__len__  
(optional): the substring length (string length by default).


---

### function fl_switch

__Syntax:__

```text
fl_switch(value,cases,otherwise)
```

implementation of switch statement as a function: when «value» matches a case,
the corresponding value is returned, undef otherwise.

example:

    value  = 2.5;
    result = fl_switch(value,[
        [2,  3.2],
        [2.5,4.0],
        [3,  4.0],
        [5,  6.4],
        [6,  8.0],
        [8,  9.6]
      ]
    );

result will be 4.0.

'case' list elements can be function literal like in the following example:

    value  = 2.5;
    result = fl_switch(value,[
        [function(e) (e<0),  "negative"],
        [0,                  "null"    ],
        [function(e) (e>0),  "positive"]
      ]
    );

result will be "positive".


__Parameters:__

__value__  
the value to be checked

__cases__  
a list with each item composed by a couple «expression result»/«value»

__otherwise__  
value returned in case of no match or when «value» is undef


---

### function fl_tag

__Syntax:__

```text
fl_tag(type,value)
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

### function fl_vector_sign

__Syntax:__

```text
fl_vector_sign(v)
```

Defines the vector signum function as a function ℝⁿ → ℝⁿ returning
[sign(x₁), sign(x₂), …, sign(xₙ)] when v is [x₁, x₂, …, xₙ].


---

### function fl_vendor

__Syntax:__

```text
fl_vendor(type,value)
```

---

### function fl_verb2modifier

__Syntax:__

```text
fl_verb2modifier(verb)
```

given a verb returns the corresponding modifier value

---

### function fl_verbList

__Syntax:__

```text
fl_verbList(supported)
```

setup a verb list according on the setting of the runtime attributes

example:

    verbs         = fl_verbList([FL_ADD,FL_ASSEMBLY,FL_AXES]);

is functionally equivalent to the following:

    verbs = [
      if ($FL_ADD!="OFF")      FL_ADD,
      if ($FL_ASSEMBLY!="OFF") FL_ASSEMBLY,
      if ($FL_BBOX!="OFF")     FL_BBOX,
    ];

if elsewhere the attribute variables as been set like this:

    $FL_ADD       = "OFF"
    $FL_ASSEMBLY  = "ON"
    $FL_BBOX      = "DEBUG"

«verbs» will hold the following contents:

    [FL_ASSEMBLY,FL_BBOX]

while FL_ADD is ignored since its runtime attribute is "OFF"


__Parameters:__

__supported__  
list of supported verbs whose runtime attribute is checked for they
eventual insertion in the returned list



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

### function fl_view

__Syntax:__

```text
fl_view(name)
```

Returns the rotation list corresponding to an OpenSCAD projection view.

Example setting OpenSCAD projection programmatically by changing the variable
$vpn value to the "top" view:

    $vpr = fl_view("top");



__Parameters:__

__name__  
one of the following esoteric names:

- "right"
- "top"
- "bottom"
- "left"
- "front"
- "back"



---

### function fl_width

__Syntax:__

```text
fl_width(type)
```

## Modules

---

### module fl_align

__Syntax:__

    fl_align(from,to)

---

### module fl_axes

__Syntax:__

    fl_axes(size=1,reverse=false)

this module add the local coordinate system with 2 or 3 axes according to
what specified in «size» parameter.

NOTE: to force a 2d coordinate system in place of a 3d one, is enough to
truncate the size from 3d to 2d like in the following example:

    size3d = [1,2,3];
    fl_axes(size=[size.x,size.y]);


---

### module fl_color

__Syntax:__

    fl_color(color,alpha=1)

Set current color and alpha channel, using variable $fl_filament when «color»
is undef. When [fl_dbg_color()](#function-fl_dbg_color)==true, «color» information is ignored and the
debug modifier is applied to children(). If «color» is equal to "ignore" no
color is applied to children.


---

### module fl_dbg_Context

__Syntax:__

    fl_dbg_Context(labels=false,symbols=false,components,dimensions=false,assertions=false,color=true)

Debug context constructor module. This constructor setup its context special
variables according to its parameters, then executes a children() call. The
typical usage is the following:

    fl_dbg_Context(...) {
      // here the children modules invocations
      ...
    }

The debug context is constituted by the following special variables:

| Name             | Description                                            |
| ---              | ---                                                    |
| $dbg_Assert      | (bool) when true, debug assertions are executed        |
| $dbg_Color       | (bool) when true, [fl_color{}](#module-fl_color) will be set to debug      |
| $dbg_Components  | (string\|string list) string or list of strings equals to the component label of which debug information will be shown |
| $dbg_Dimensions  | (bool) when true, labels to symbols are assigned and displayed |
| $dbg_Labels      | (bool) when true, symbol labels are shown              |
| $dbg_Symbols     | (bool) when true symbols are shown                     |

OFL provides also a list of getters for all the special variables used:

| Name             | Getter              |
| ---              | ---                 |
| $dbg_Assert      | [fl_dbg_assert()](#function-fl_dbg_assert)     |
| $dbg_Color       | fl_dbg_color()      |
| $dbg_Components  | fl_dbg_components() |
| $dbg_Dimensions  | fl_dbg_dimensions() |
| $dbg_Labels      | [fl_dbg_labels()](#function-fl_dbg_labels)     |
| $dbg_Symbols     | fl_dbg_symbols()    |

See also: [fl_dbg_dump{}](#module-fl_dbg_dump).


__Parameters:__

__labels__  
when true, symbol labels are shown

__symbols__  
when true symbols are shown

__components__  
a string or a list of strings equals to the component label of which
direction information will be shown


__dimensions__  
dimension lines

__assertions__  
enable or disable assertions


---

### module fl_dbg_dump

__Syntax:__

    fl_dbg_dump()

Debug context dump and children() execution.

---

### module fl_error

__Syntax:__

    fl_error(message,condition)

force an error if condition is false or undef

__Parameters:__

__message__  
string or vector of strings

__condition__  
error if false or undef


---

### module fl_extrude_if

__Syntax:__

    fl_extrude_if(condition,height,convexity)

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

### module fl_parm_dump

__Syntax:__

    fl_parm_dump()

Parameter context dump (mainly used for debug)

---

### module fl_render_if

__Syntax:__

    fl_render_if(condition)

when «condition» is true children are render()ed, fast CSG is used otherwise

---

### module fl_root_dump

__Syntax:__

    fl_root_dump()

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

- $FL_TRACES affects trace messages according to its value:
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

