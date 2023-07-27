# package artifacts/t-nut

## Dependencies

```mermaid
graph LR
    A1[artifacts/t-nut] --o|include| A2[foundation/unsafe_defs]
    A1 --o|include| A3[vitamins/countersinks]
    A1 --o|include| A4[vitamins/screw]
    A1 --o|use| A5[foundation/3d-engine]
    A1 --o|use| A6[foundation/bbox-engine]
    A1 --o|use| A7[foundation/hole]
    A1 --o|use| A8[foundation/mngm]
```

## Functions

---

### function fl_TNut

__Syntax:__

```text
fl_TNut(opening,size,thickness,screw,knut=false)
```

constructor



   ⤒
   󠁼|
   ⤓


## Modules

---

### module fl_tnut

__Syntax:__

    fl_tnut(verbs=FL_ADD,type,tolerance=0,coutersink=false,debug,direction,octant)

__Parameters:__

__verbs__  
supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT

__tolerance__  
tolerances added to [nut, hole, countersink] dimensions

tolerance=x means [x,x,x]


__debug__  
see constructor [fl_parm_Debug()](../foundation/base_parameters.md#function-fl_parm_debug)

__direction__  
desired direction [director,rotation], native direction when undef ([+Z,0])

__octant__  
when undef native positioning is used


