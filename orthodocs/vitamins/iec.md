# package vitamins/iec

## Dependencies

```mermaid
graph LR
    A1[vitamins/iec] --o|include| A2[foundation/polymorphic-engine]
    A1 --o|include| A3[foundation/unsafe_defs]
    A1 --o|include| A4[vitamins/screw]
```

## Variables

---

### variable FL_IEC_320_C14_SWITCHED_FUSED_INLET

__Default:__

    fl_IEC(IEC_320_C14_switched_fused_inlet)

IEC320 C14 switched fused inlet module.

![FL_IEC_320_C14_SWITCHED_FUSED_INLET](256x256/fig_FL_IEC_320_C14_SWITCHED_FUSED_INLET.png)


---

### variable FL_IEC_DICT

__Default:__

    [FL_IEC_FUSED_INLET,FL_IEC_FUSED_INLET2,FL_IEC_320_C14_SWITCHED_FUSED_INLET,FL_IEC_INLET,FL_IEC_INLET_ATX,FL_IEC_INLET_ATX2,FL_IEC_YUNPEN,FL_IEC_OUTLET,]

---

### variable FL_IEC_FUSED_INLET

__Default:__

    fl_IEC(IEC_fused_inlet)

IEC fused inlet JR-101-1F.

![FL_IEC_FUSED_INLET](256x256/fig_FL_IEC_FUSED_INLET.png)


---

### variable FL_IEC_FUSED_INLET2

__Default:__

    fl_IEC(IEC_fused_inlet2)

IEC fused inlet old.

![FL_IEC_FUSED_INLET](256x256/fig_FL_IEC_FUSED_INLET2.png)


---

### variable FL_IEC_INLET

__Default:__

    fl_IEC(IEC_inlet)

IEC inlet.

![FL_IEC_INLET](256x256/fig_FL_IEC_INLET.png)


---

### variable FL_IEC_INLET_ATX

__Default:__

    fl_IEC(IEC_inlet_atx)

IEC inlet for ATX.

![FL_IEC_INLET_ATX](256x256/fig_FL_IEC_INLET_ATX.png)


---

### variable FL_IEC_INLET_ATX2

__Default:__

    fl_IEC(IEC_inlet_atx2)

IEC die cast inlet for ATX.

![FL_IEC_INLET_ATX2](256x256/fig_FL_IEC_INLET_ATX2.png)


---

### variable FL_IEC_NS

__Default:__

    "iec"

---

### variable FL_IEC_OUTLET

__Default:__

    fl_IEC(IEC_outlet)

IEC outlet RS 811-7193.

![FL_IEC_OUTLET](256x256/fig_FL_IEC_OUTLET.png)


---

### variable FL_IEC_YUNPEN

__Default:__

    fl_IEC(IEC_yunpen)

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

    fl_iec(verbs=FL_ADD,this,thick,direction,octant)

__Parameters:__

__thick__  
thickness for FL_DRILL and FL_CUTOUT


