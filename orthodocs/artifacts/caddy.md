# package artifacts/caddy

## Dependencies

```mermaid
graph LR
    A1[artifacts/caddy] --o|include| A2[foundation/fillet]
    A1 --o|include| A3[foundation/unsafe_defs]
```

## Variables

---

### variable FL_NS_CAD

__Default:__

    "cad"

## Modules

---

### module fl_caddy

__Syntax:__

    fl_caddy(verbs=FL_ADD,type,thick,faces,tolerance=fl_JNgauge,fillet=0,lay_verbs=[],direction,octant)

