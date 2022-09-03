# package foundation/bbox

## Dependencies

```mermaid
graph LR
    A1[foundation/bbox] --o|include| A2[foundation/defs]
```

## Functions

---

### function fl_bb_calc

__Syntax:__

```text
fl_bb_calc(bbs,pts)
```

---

### function fl_bb_center

__Syntax:__

```text
fl_bb_center(type)
```

---

### function fl_bb_corners

__Syntax:__

```text
fl_bb_corners(type,value)
```

---

### function fl_bb_new

__Syntax:__

```text
fl_bb_new(negative=[0,0,0],size=[0,0,0],positive)
```

---

### function fl_bb_size

__Syntax:__

```text
fl_bb_size(type)
```

---

### function fl_bb_transform

__Syntax:__

```text
fl_bb_transform(M,bbcorners)
```

---

### function fl_bb_vertices

__Syntax:__

```text
fl_bb_vertices(bbcorners)
```

