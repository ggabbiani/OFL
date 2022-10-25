# package artifacts/spacer

## Dependencies

```mermaid
graph LR
    A1[artifacts/spacer] --o|include| A2[foundation/hole]
    A1 --o|include| A3[foundation/tube]
    A1 --o|include| A4[foundation/unsafe_defs]
    A1 --o|include| A5[vitamins/knurl_nuts]
```

## Variables

---

### variable FL_SPC_NS

__Default:__

    "spc"

## Functions

---

### function fl_bb_spacer

__Syntax:__

```text
fl_bb_spacer(h,r)
```

---

### function fl_spc_holeRadius

__Syntax:__

```text
fl_spc_holeRadius(screw,knut)
```

## Modules

---

### module fl_spacer

__Syntax:__

    fl_spacer(verbs=FL_ADD,h,r,d,thick=0,lay_direction=[+Z,-Z],screw,knut=false,direction,octant)

