# package artifacts/box

## Dependencies

```mermaid
graph LR
    A1[artifacts/box] --o|include| A2[artifacts/spacer]
    A1 --o|include| A3[foundation/fillet]
    A1 --o|include| A4[foundation/profile]
    A1 --o|include| A5[foundation/util]
    A1 --o|include| A6[vitamins/knurl_nuts]
    A1 --o|include| A7[vitamins/screw]
```

## Modules


---

### module fl_box

__Syntax:__

    fl_box(verbs=FL_ADD,preset,xsize,isize,pload,thick,radius,parts,tolerance=0.3,material_upper,material_lower,fillet=true,direction,octant)

