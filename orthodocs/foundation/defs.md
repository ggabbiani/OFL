# package foundation/defs


__Includes:__

    foundation/base_geo
    foundation/base_kv
    foundation/base_parameters
    foundation/base_string
    foundation/base_trace

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

---

### variable FL_ADD

__Default:__

    "FL_ADD add base shape (no components nor screws)"

---

### variable FL_ASSEMBLY

__Default:__

    "FL_ASSEMBLY add predefined component shape(s)"

---

### variable FL_AXES

__Default:__

    "FL_AXES draw of local reference axes"

---

### variable FL_BBOX

__Default:__

    "FL_BBOX adds a bounding box containing the object"

---

### variable FL_CUTOUT

__Default:__

    "FL_CUTOUT layout of predefined cutout shapes (±X,±Y,±Z)."

---

### variable FL_DEPRECATED

__Default:__

    "FL_DEPRECATED is a test verb. **DEPRECATED**"

---

### variable FL_DRAW

__Default:__

    [FL_ADD,FL_ASSEMBLY]

---

### variable FL_DRILL

__Default:__

    "FL_DRILL layout of predefined drill shapes (like holes with predefined screw diameter)"

---

### variable FL_FOOTPRINT

__Default:__

    "FL_FOOTPRINT adds a footprint to scene, usually a simplified FL_ADD"

---

### variable FL_HOLDERS

__Default:__

    "FL_HOLDERS adds vitamine holders to the scene. **DEPRECATED**"

---

### variable FL_I

__Default:__

    [[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1],]

---

### variable FL_LAYOUT

__Default:__

    "FL_LAYOUT layout of user passed accessories (like alternative screws)"

---

### variable FL_MOUNT

__Default:__

    "FL_MOUNT mount shape through predefined screws"

---

### variable FL_NIL

__Default:__

    ($preview&&!$FL_RENDER?0.01:0)

---

### variable FL_NIL2

__Default:__

    2*FL_NIL

---

### variable FL_O

__Default:__

    [0,0,0]

---

### variable FL_OBSOLETE

__Default:__

    "FL_OBSOLETE is a test verb. **OBSOLETE**"

---

### variable FL_PAYLOAD

__Default:__

    "FL_PAYLOAD adds a box representing the payload of the shape"

---

### variable FL_X

__Default:__

    [1,0,0]

---

### variable FL_Y

__Default:__

    [0,1,0]

---

### variable FL_Z

__Default:__

    [0,0,1]

---

### variable fl_FDMtolerance

__Default:__

    0.5

---

### variable fl_JNgauge

__Default:__

    fl_MVgauge/4

---

### variable fl_MVgauge

__Default:__

    0.6

## Functions


---

### function fl_2

__Syntax:__

    fl_2(v)

---

### function fl_3

__Syntax:__

    fl_3(v)

---

### function fl_4

__Syntax:__

    fl_4(v)

---

### function fl_R

__Syntax:__

    fl_R(u,theta)

---

### function fl_Rx

__Syntax:__

    fl_Rx(theta)

---

### function fl_Rxyz

__Syntax:__

    fl_Rxyz(angle)

---

### function fl_Ry

__Syntax:__

    fl_Ry(theta)

---

### function fl_Rz

__Syntax:__

    fl_Rz(theta)

---

### function fl_S

__Syntax:__

    fl_S(s)

---

### function fl_T

__Syntax:__

    fl_T(t)

---

### function fl_X

__Syntax:__

    fl_X(x)

---

### function fl_XOR

__Syntax:__

    fl_XOR(c1,c2)

---

### function fl_Y

__Syntax:__

    fl_Y(y)

---

### function fl_Z

__Syntax:__

    fl_Z(z)

---

### function fl_accum

__Syntax:__

    fl_accum(v)

---

### function fl_align

__Syntax:__

    fl_align(from,to)

---

### function fl_assert

__Syntax:__

    fl_assert(condition,message,result)

---

### function fl_connectors

__Syntax:__

    fl_connectors(type,value)

---

### function fl_deprecated

__Syntax:__

    fl_deprecated(bad,value,replacement)

---

### function fl_description

__Syntax:__

    fl_description(type,value)

---

### function fl_dict_search

__Syntax:__

    fl_dict_search(dictionary,name)

---

### function fl_director

__Syntax:__

    fl_director(type,value)

---

### function fl_dxf

__Syntax:__

    fl_dxf(type,value)

---

### function fl_engine

__Syntax:__

    fl_engine(type,value)

---

### function fl_has

__Syntax:__

    fl_has(type,property,check=function(value)true)

---

### function fl_height

__Syntax:__

    fl_height(type)

---

### function fl_isEven

__Syntax:__

    fl_isEven(n)

---

### function fl_isMultiple

__Syntax:__

    fl_isMultiple(n,m)

---

### function fl_isOdd

__Syntax:__

    fl_isOdd(n)

---

### function fl_isSet

__Syntax:__

    fl_isSet(flag,list)

---

### function fl_material

__Syntax:__

    fl_material(type,value,default)

---

### function fl_name

__Syntax:__

    fl_name(type,value)

---

### function fl_native

__Syntax:__

    fl_native(type,value)

---

### function fl_nopSCADlib

__Syntax:__

    fl_nopSCADlib(type,value,default)

---

### function fl_parse_diameter

__Syntax:__

    fl_parse_diameter(r,r1,d,d1,def)

---

### function fl_parse_l

__Syntax:__

    fl_parse_l(l,l1,def)

---

### function fl_parse_radius

__Syntax:__

    fl_parse_radius(r,r1,d,d1,def)

---

### function fl_payload

__Syntax:__

    fl_payload(type,value)

---

### function fl_pcb

__Syntax:__

    fl_pcb(type,value)

---

### function fl_pop

__Syntax:__

    fl_pop(l,i=0)

---

### function fl_push

__Syntax:__

    fl_push(list,item)

---

### function fl_rotor

__Syntax:__

    fl_rotor(type,value)

---

### function fl_screw

__Syntax:__

    fl_screw(type,value)

---

### function fl_size

__Syntax:__

    fl_size(type)

---

### function fl_sub

__Syntax:__

    fl_sub(list,from,to)

---

### function fl_thick

__Syntax:__

    fl_thick(type)

---

### function fl_tolerance

__Syntax:__

    fl_tolerance(type,value)

---

### function fl_transform

__Syntax:__

    fl_transform(M,v)

Returns M * v , actually transforming v by M.

:memo: **NOTE:** result in 3d format


---

### function fl_vendor

__Syntax:__

    fl_vendor(type,value)

---

### function fl_version

__Syntax:__

    fl_version()

---

### function fl_versionNumber

__Syntax:__

    fl_versionNumber()

---

### function fl_width

__Syntax:__

    fl_width(type)

---

### function palette

__Syntax:__

    palette(name)

---

### function verb2modifier

__Syntax:__

    verb2modifier(verb)

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

    fl_color(color=fl_filament(),alpha=1)

---

### module fl_manage

__Syntax:__

    fl_manage(verbs,placement,direction,size,debug,connectors,holes)

---

### module fl_modifier

__Syntax:__

    fl_modifier(behaviour,reset=true)

---

### module fl_overlap

__Syntax:__

    fl_overlap(u1,u2,position)

---

### module fl_vector

__Syntax:__

    fl_vector(P,outward=true,endpoint="arrow",ratio=20)

---

### module fl_versor

__Syntax:__

    fl_versor(P)

