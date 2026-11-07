# package vitamins/iec

## Dependencies

```mermaid
graph LR
    A1[vitamins/iec] --o|include| A2[foundation/unsafe_defs]
    A1 --o|include| A3[vitamins/screw]
```

NopSCADlib IEC wrapper library. This library wraps NopSCADlib IEC instances
into the OFL APIs.

This file is part of the 'OpenSCAD Foundation Library' (OFL) project.

Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Variables

---

### variable FL_IEC_320_C14_SWITCHED_FUSED_INLET

__Default:__

    fl_IEC(IEC_320_C14_switched_fused_inlet,name="FL_IEC_320_C14_SWITCHED_FUSED_INLET")

IEC320 C14 switched fused inlet module.

![FL_IEC_320_C14_SWITCHED_FUSED_INLET](256x256/fig_FL_IEC_320_C14_SWITCHED_FUSED_INLET.png)


---

### variable FL_IEC_FUSED_INLET

__Default:__

    fl_IEC(IEC_fused_inlet,name="FL_IEC_FUSED_INLET")

IEC fused inlet JR-101-1F.

![FL_IEC_FUSED_INLET](256x256/fig_FL_IEC_FUSED_INLET.png)


---

### variable FL_IEC_FUSED_INLET2

__Default:__

    fl_IEC(IEC_fused_inlet2,name="FL_IEC_FUSED_INLET2")

IEC fused inlet old.

![FL_IEC_FUSED_INLET](256x256/fig_FL_IEC_FUSED_INLET2.png)


---

### variable FL_IEC_INLET

__Default:__

    fl_IEC(IEC_inlet,name="FL_IEC_INLET")

IEC inlet.

![FL_IEC_INLET](256x256/fig_FL_IEC_INLET.png)


---

### variable FL_IEC_INLET_ATX

__Default:__

    fl_IEC(IEC_inlet_atx,name="FL_IEC_INLET_ATX")

IEC inlet for ATX.

![FL_IEC_INLET_ATX](256x256/fig_FL_IEC_INLET_ATX.png)


---

### variable FL_IEC_INLET_ATX2

__Default:__

    fl_IEC(IEC_inlet_atx2,name="FL_IEC_INLET_ATX2")

IEC die cast inlet for ATX.

![FL_IEC_INLET_ATX2](256x256/fig_FL_IEC_INLET_ATX2.png)


---

### variable FL_IEC_INV

__Default:__

    fl_Inventory([FL_IEC_FUSED_INLET,FL_IEC_FUSED_INLET2,FL_IEC_320_C14_SWITCHED_FUSED_INLET,FL_IEC_INLET,FL_IEC_INLET_ATX,FL_IEC_INLET_ATX2,FL_IEC_YUNPEN,FL_IEC_OUTLET,])

---

### variable FL_IEC_NS

__Default:__

    "iec"

---

### variable FL_IEC_OUTLET

__Default:__

    fl_IEC(IEC_outlet,name="FL_IEC_OUTLET")

IEC outlet RS 811-7193.

![FL_IEC_OUTLET](256x256/fig_FL_IEC_OUTLET.png)


---

### variable FL_IEC_YUNPEN

__Default:__

    fl_IEC(IEC_yunpen,name="FL_IEC_YUNPEN")

IEC inlet filtered.

![FL_IEC_YUNPEN](256x256/fig_FL_IEC_YUNPEN.png)


## Functions

---

### function fl_IEC

__Syntax:__

```text
fl_IEC(nop,name,description)
```

IEC mains inlets and outlet constructor. It wraps the corresponding
NopSCADlib object.


## Modules

---

### module fl_iec

__Syntax:__

    fl_iec(verbs=FL_ADD,this,direction,octant)

Context variables:

| name           | Context   | Description
| ---            | ---       | ---
| $fl_thickness  | Parameter | used in FL_CUTOUT, FL_DRILL and FL_MOUNT
| $fl_tolerance  | Parameter | used during FL_CUTOUT. See also [fl_parm_tolerance()](../foundation/core.md#function-fl_parm_tolerance)
| $iec_screw     | Children  | native OFL screw used by the IEC


__Parameters:__

__verbs__  
supported verbs: FL_ADD, FL_AXES, FL_BBOX, FL_CUTOUT, FL_DRILL, FL_LAYOUT, FL_MOUNT

__direction__  
desired direction [director,rotation], native direction when undef ([+X+Y+Z])

__octant__  
when undef native positioning is used


