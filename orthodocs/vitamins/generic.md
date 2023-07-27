# package vitamins/generic

## Dependencies

```mermaid
graph LR
    A1[vitamins/generic] --o|include| A2[foundation/defs]
    A1 --o|use| A3[foundation/2d-engine]
    A1 --o|use| A4[foundation/3d-engine]
    A1 --o|use| A5[foundation/bbox-engine]
    A1 --o|use| A6[foundation/mngm]
```

## Variables

---

### variable FL_GENERIC_NS

__Default:__

    "GENERIC"

## Functions

---

### function fl_generic_Vitamin

__Syntax:__

```text
fl_generic_Vitamin(name,bbox,ghost=true,cut_directions)
```

## Modules

---

### module fl_generic_vitamin

__Syntax:__

    fl_generic_vitamin(verbs=FL_ADD,type,cut_thick=0,cut_tolerance=0,cut_drift=0,debug,octant,direction)

