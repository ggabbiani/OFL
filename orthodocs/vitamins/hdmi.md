# package vitamins/hdmi

## Dependencies

```mermaid
graph LR
    A1[vitamins/hdmi] --o|include| A2[foundation/util]
```

## Variables

---

### variable FL_HDMI_DICT

__Default:__

    [FL_HDMI_TYPE_A,FL_HDMI_TYPE_C,FL_HDMI_TYPE_D]

---

### variable FL_HDMI_NS

__Default:__

    "hdmi"

---

### variable FL_HDMI_TYPE_A

__Default:__

    fl_hdmi_new(["hdmi_full","HDMI socket",12,14,10,3,4.5,6.5,0.5])

---

### variable FL_HDMI_TYPE_C

__Default:__

    fl_hdmi_new(["hdmi_mini","Mini HDMI socket",7.5,10.5,8.3,1.28,2.5,3.2,0.35])

---

### variable FL_HDMI_TYPE_D

__Default:__

    fl_hdmi_new(["hdmi_micro","Micro HDMI socket",8.5,5.9,4.43,1.4,2.3,3,0.3])

## Functions

---

### function fl_hdmi_nameKV

__Syntax:__

```text
fl_hdmi_nameKV(value)
```

---

### function fl_hdmi_new

__Syntax:__

```text
fl_hdmi_new(nop_type)
```

## Modules


---

### module fl_hdmi

__Syntax:__

    fl_hdmi(verbs=FL_ADD,type,cut_thick,cut_tolerance=0,cut_drift=0,direction,octant)

