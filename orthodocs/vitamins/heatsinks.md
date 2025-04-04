# package vitamins/heatsinks

## Dependencies

```mermaid
graph LR
    A1[vitamins/heatsinks] --o|include| A2[foundation/core]
    A1 --o|use| A3[foundation/3d-engine]
    A1 --o|use| A4[foundation/bbox-engine]
    A1 --o|use| A5[foundation/mngm-engine]
```

Heatsinks definition file.

Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Variables

---

### variable FL_HS_DICT

__Default:__

    [FL_HS_PIMORONI_TOP,FL_HS_PIMORONI_BOTTOM,FL_HS_KHADAS]

---

### variable FL_HS_KHADAS

__Default:__

    let(Zs=2,Zh=1,Zf=5.45,Zt=2.2)[fl_name(value="KHADAS VIM SBC Heatsink"),fl_bb_corners(value=[[0.5,-49.57,0],[81.49,-0.49,Zs+Zh+Zf],]),fl_screw(value=M2_cap_screw),fl_dxf(value="vitamins/hs-khadas.dxf"),fl_engine(value="Khadas"),fl_cutout(value=[+Z]),fl_property(key="separator height",value=Zs),fl_property(key="heatsink height",value=Zh),fl_property(key="fin height",value=Zf),fl_property(key="tooth height",value=Zt),]

---

### variable FL_HS_NS

__Default:__

    "hs"

namespace

---

### variable FL_HS_PIMORONI_BOTTOM

__Default:__

    let(Tbase=2,Tfluting=2.3,Tholders=3,Tchamfer=2.3,size=[56,87,Tbase+Tfluting+Tholders])[fl_name(value="PIMORONI Raspberry Pi 4 Heatsink Case - bottom"),fl_bb_corners(value=[[-size.x/2,0,-size.z],[+size.x/2,size.y,0],]),fl_screw(value=M2p5_cap_screw),fl_dxf(value="vitamins/pimoroni.dxf"),fl_vendor(value=[["Amazon","https://www.amazon.it/gp/product/B082Y21GX5/"],]),fl_engine(value="Pimoroni"),fl_cutout(value=[+Y]),["corner radius",3],["chamfer thickness",Tchamfer],["base thickness",Tbase],["fluting thickness",Tfluting],["holders thickness",Tholders],["part","bottom"],]

---

### variable FL_HS_PIMORONI_TOP

__Default:__

    let(Tbase=1.5,Tfluting=8.6,Tholders=5.5,Tchamfer=2.3,size=[56,70,Tbase+Tfluting+Tholders])[fl_name(value="PIMORONI Raspberry Pi 4 Heatsink Case - top"),fl_bb_corners(value=[[-size.x/2,0,0],[+size.x/2,size.y,size.z],]),fl_screw(value=M2p5_cap_screw),fl_dxf(value="vitamins/pimoroni.dxf"),fl_vendor(value=[["Amazon","https://www.amazon.it/gp/product/B082Y21GX5/"],]),fl_engine(value="Pimoroni"),fl_cutout(value=[+Z]),["corner radius",3],["chamfer thickness",Tchamfer],["base thickness",Tbase],["fluting thickness",Tfluting],["holders thickness",Tholders],["part","top"],]

## Modules

---

### module fl_heatsink

__Syntax:__

    fl_heatsink(verbs=FL_ADD,type,cut_drift=0,cut_dirs,octant,direction)

Common wrapper for different heat sink model engines.

Context variables:

| Name           | Context   | Description                                 |
| -------------  | -------   | ------------------------------------------- |
| $fl_thickness  | Parameter | thickness in FL_CUTOUT (see [variable FL_CUTOUT](../foundation/core.md#variable-fl_cutout))
| $fl_tolerance  | Parameter | tolerance in FL_CUTOUT and FL_FOOTPRINT (see [variable FL_CUTOUT](../foundation/core.md#variable-fl_cutout) and variable FL_FOOTPRINT)
| $co_current    | Children  | current cutout axis
| $co_preferred  | Children  | true if $co_current axis is a preferred one


__Parameters:__

__verbs__  
supported verbs: FL_ADD, FL_AXES, FL_BBOX, FL_CUTOUT, FL_FOOTPRINT

__cut_drift__  
translation applied to cutout (default 0)

__cut_dirs__  
Cutout direction list in floating semi-axis list (see also [fl_tt_isAxisList()](../foundation/traits-engine.md#function-fl_tt_isaxislist)).

__octant__  
when undef native positioning is used

__direction__  
desired direction [director,rotation], native direction when undef ([+X+Y+Z])


