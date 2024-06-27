# package artifacts/din_rails

## Dependencies

```mermaid
graph LR
    A1[artifacts/din_rails] --o|include| A2[foundation/dimensions]
    A1 --o|include| A3[foundation/label]
    A1 --o|include| A4[foundation/unsafe_defs]
    A1 --o|include| A5[foundation/util]
    A1 --o|use| A6[foundation/3d-engine]
    A1 --o|use| A7[foundation/bbox-engine]
    A1 --o|use| A8[foundation/polymorphic-engine]
```

A DIN rail is a metal rail of a standard type widely used for mounting
circuit breakers and industrial control equipment inside equipment racks.
These products are typically made from cold rolled carbon steel sheet with a
zinc-plated or chromated bright surface finish. Although metallic, they are
meant only for mechanical support and are not used as a busbar to conduct
electric current, though they may provide a chassis grounding connection.

The term derives from the original specifications published by Deutsches
Institut für Normung (DIN) in Germany, which have since been adopted as
European (EN) and international (IEC) standards. The original concept was
developed and implemented in Germany in 1928, and was elaborated into the
present standards in the 1950s.

This file is part of the 'OpenSCAD Foundation Library' (OFL) project.

Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Variables

---

### variable FL_DIN_NS

__Default:__

    "DIN"

prefix used for namespacing

---

### variable FL_DIN_PUNCH_4p2

__Default:__

    concat(fl_Punch(20),[["DIN/rail/punch_d",4.2],["DIN/rail/punch_len",12.2],])

---

### variable FL_DIN_PUNCH_6p3

__Default:__

    concat(fl_Punch(25),[["DIN/rail/punch_d",6.3],["DIN/rail/punch_len",18],])

---

### variable FL_DIN_RAIL_INVENTORY

__Default:__

    [FL_DIN_RAIL_TH15,FL_DIN_RAIL_TH35,FL_DIN_RAIL_TH35D]

rail constructor inventory

---

### variable FL_DIN_RAIL_TH15

__Default:__

    function(length,punched=true)fl_DIN_Rail(profile=FL_DIN_TS15,punch=punched?FL_DIN_PUNCH_4p2:undef,length=length)

---

### variable FL_DIN_RAIL_TH35

__Default:__

    function(length,punched=true)fl_DIN_Rail(profile=FL_DIN_TS35,punch=punched?FL_DIN_PUNCH_6p3:undef,length=length)

---

### variable FL_DIN_RAIL_TH35D

__Default:__

    function(length,punched=true)fl_DIN_Rail(profile=FL_DIN_TS35D,punch=punched?FL_DIN_PUNCH_6p3:undef,length=length)

---

### variable FL_DIN_TS15

__Default:__

    fl_DIN_TopHatSection("TS15",size=[[10.5,15],5.5],r=[0.2,0.5])

---

### variable FL_DIN_TS35

__Default:__

    fl_DIN_TopHatSection("TS35",size=[[27,35],7.5],r=[.8,.8])

top hat rail IEC/EN 60715 – 35 × 15


---

### variable FL_DIN_TS35D

__Default:__

    fl_DIN_TopHatSection("TS35D",size=[[27,35],15],r=[1.25,1.25],thick=1.5)

---

### variable FL_DIN_TS_INVENTORY

__Default:__

    [FL_DIN_TS15,FL_DIN_TS35,FL_DIN_TS35D]

DIN rail section inventory

## Functions

---

### function fl_DIN_Rail

__Syntax:__

```text
fl_DIN_Rail(profile,length,punch)
```

DIN Rails constructor

__Parameters:__

__profile__  
one of the supported profiles (see [variable FL_DIN_TS_INVENTORY](#variable-fl_din_ts_inventory))

__length__  
overall rail length

__punch__  
optional parameter as returned from [fl_Punch()](#function-fl_punch)


---

### function fl_DIN_TopHatSection

__Syntax:__

```text
fl_DIN_TopHatSection(name,description,size,r,thick=1)
```

Constructor for Top hat section (TH), type O, or type Ω, with hat-shaped
cross section.


__Parameters:__

__description__  
optional description

__size__  
Rails size in [[width-min,width-max],height]

__r__  
internal radii [upper radius,lower radius]


---

### function fl_Punch

__Syntax:__

```text
fl_Punch(step)
```

Punch constructor

## Modules

---

### module fl_DIN_puncher

__Syntax:__

    fl_DIN_puncher()

---

### module fl_DIN_rail

__Syntax:__

    fl_DIN_rail(verbs=FL_ADD,this,cut_thick,tolerance=0,cut_drift=0,cut_direction,octant,direction,debug)

__Parameters:__

__verbs__  
supported verbs: FL_ADD, FL_AXES, FL_BBOX, FL_CUTOUT, FL_DRILL, CO_FOOTPRINT, FL_LAYOUT, FL_MOUNT

__cut_thick__  
thickness for FL_CUTOUT

__tolerance__  
tolerance used during FL_CUTOUT and FL_FOOTPRINT

__cut_drift__  
translation applied to cutout (default 0)

__cut_direction__  
Cutout direction list in floating semi-axis list (see also [fl_tt_isAxisList()](../foundation/type_trait.md#function-fl_tt_isaxislist)).

Example:

    cut_direction=[+X,+Z]

in this case the ethernet plug will perform a cutout along +X and +Z.

:memo: **Note:** axes specified must be present in the supported cutout direction
list (retrievable through [fl_cutout()](../foundation/core.md#function-fl_cutout) getter)


__octant__  
when undef native positioning is used

__direction__  
desired direction [director,rotation], native direction when undef ([+X+Y+Z])

__debug__  
see constructor [fl_parm_Debug()](../foundation/core.md#function-fl_parm_debug)


---

### module fl_punch

__Syntax:__

    fl_punch(punch,length,thick)

Performs a punch along the Z axis using children.

Children context:

- $punch: the punch instance containing stepping data
- $punch_thick: thickness of the performed punch to be used by children
- $punch_step: punch stepping

TODO: extend to other generic axes, move source into core library


__Parameters:__

__punch__  
as returned by [fl_Punch()](#function-fl_punch)


