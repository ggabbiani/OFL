# package vitamins/countersinks

## Dependencies

```mermaid
graph LR
    A1[vitamins/countersinks] --o|include| A2[foundation/defs]
```

## Variables

---

### variable FL_CS_DICT

__Default:__

    [FL_CS_M3,FL_CS_M4,FL_CS_M5,FL_CS_M6,FL_CS_M8,FL_CS_M10,FL_CS_M12,FL_CS_M16,FL_CS_M20]

---

### variable FL_CS_M10

__Default:__

    fl_Countersink("FL_CS_M10","M10 countersink",20+10/5,angle=90)

---

### variable FL_CS_M12

__Default:__

    fl_Countersink("FL_CS_M12","M12 countersink",24+12/5,angle=90)

---

### variable FL_CS_M16

__Default:__

    fl_Countersink("FL_CS_M16","M16 countersink",30+16/5,angle=90)

---

### variable FL_CS_M20

__Default:__

    fl_Countersink("FL_CS_M20","M20 countersink",36+20/5,angle=90)

---

### variable FL_CS_M3

__Default:__

    fl_Countersink("FL_CS_M3","M3 countersink",6+3/5,angle=90)

---

### variable FL_CS_M4

__Default:__

    fl_Countersink("FL_CS_M4","M4 countersink",8+4/5,angle=90)

---

### variable FL_CS_M5

__Default:__

    fl_Countersink("FL_CS_M5","M5 countersink",10+5/5,angle=90)

---

### variable FL_CS_M6

__Default:__

    fl_Countersink("FL_CS_M6","M6 countersink",12+6/5,angle=90)

---

### variable FL_CS_M8

__Default:__

    fl_Countersink("FL_CS_M8","M8 countersink",16+8/5,angle=90)

---

### variable FL_CS_NS

__Default:__

    "cs"

## Functions

---

### function fl_Countersink

__Syntax:__

```text
fl_Countersink(name,description,d,angle)
```

---

### function fl_cs_angle

__Syntax:__

```text
fl_cs_angle(type,value)
```

---

### function fl_cs_d

__Syntax:__

```text
fl_cs_d(type,value)
```

---

### function fl_cs_h

__Syntax:__

```text
fl_cs_h(type)
```

## Modules


---

### module fl_countersink

__Syntax:__

    fl_countersink(verbs,type,direction,octant)

