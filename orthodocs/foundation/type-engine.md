# package foundation/type-engine

## Dependencies

```mermaid
graph LR
    A1[foundation/type-engine] --o|include| A2[foundation/core]
    A1 --o|use| A3[foundation/bbox-engine]
```

## Functions

---

### function fl_Object

__Syntax:__

```text
fl_Object(bbox,pload,name,description,engine,others=[])
```

Base constructor for OFL pseudo-objects.


__Parameters:__

__bbox__  
mandatory bounding-box

__pload__  
optional payload

__name__  
optional name

__description__  
optional description

__engine__  
optional engine

__others__  
optional other key/value list to be concatenated.


