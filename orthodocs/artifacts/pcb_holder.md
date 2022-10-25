# package artifacts/pcb_holder

## Dependencies

```mermaid
graph LR
    A1[artifacts/pcb_holder] --o|include| A2[artifacts/spacer]
```

## Functions

---

### function fl_bb_holderByHoles

__Syntax:__

```text
fl_bb_holderByHoles(pcb,h)
```

---

### function fl_bb_holderBySize

__Syntax:__

```text
fl_bb_holderBySize(pcb,h,tolerance=0.5,screw=M3_cap_screw,knut=false)
```

## Modules

---

### module fl_pcb_holderByHoles

__Syntax:__

    fl_pcb_holderByHoles(verbs,pcb,h,thick=0,knut=false,frame,lay_direction=[+Z,-Z],direction,octant)

---

### module fl_pcb_holderBySize

__Syntax:__

    fl_pcb_holderBySize(verbs,pcb,h,tolerance=0.5,screw=M3_cap_screw,knut=false,thick=0,frame=0,lay_direction=[+Z,-Z],direction,octant)

