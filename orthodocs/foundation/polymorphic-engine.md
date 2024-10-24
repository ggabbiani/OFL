# package foundation/polymorphic-engine

## Dependencies

```mermaid
graph LR
    A1[foundation/polymorphic-engine] --o|include| A2[foundation/core]
    A1 --o|use| A3[foundation/3d-engine]
    A1 --o|use| A4[foundation/bbox-engine]
    A1 --o|use| A5[foundation/mngm-engine]
```

## Modules

---

### module fl_polymorph

__Syntax:__

    fl_polymorph(verbs=FL_ADD,this,octant,direction)

This module manages OFL types leveraging children implementation of the
actual engine while decoupling standard OFL parameters manipulation from
other engine specific ones.
Essentially it uses children module in place of not yet implemented module
literals, simplifying the new type module writing.

:memo: __NOTE:__ this module can be used only by OFL 'objects'.

    // this is the actual object definition as a list of [key,values] items
    object = let(
      ...
    ) [
      fl_native(value=true),
      ...
    ];

A typical use of this high-level management module is the following:

    // this engine is called once for every verb passed to module fl_polymorph
    module engine() let(
      ...
    ) if ($this_verb==FL_ADD)
      ...;

      else if ($this_verb==FL_AXES)
        fl_doAxes($this_size,$this_direction);

      else if ($this_verb==FL_BBOX)
      ...;

      else if ($this_verb==FL_CUTOUT)
      ...;

      else if ($this_verb==FL_DRILL)
      ...;

      else if ($this_verb==FL_LAYOUT)
      ...;

      else if ($this_verb==FL_MOUNT)
      ...;

      else
        assert(false,str("***OFL ERROR***: unimplemented verb ",$this_verb));

    fl_polymorph(verbs,object,octant=octant,direction=direction)
      engine(thick=T)
        // child passed to engine for further manipulation (ex. during FL_LAYOUT)
        fl_cylinder(h=10,r=screw_radius($iec_screw),octant=-Z);

Children context:

- $this            : 3d object
- $this_verb       : currently processed verb
- $this_size       : object 3d dimensions
- $this_bbox       : bounding box corners in [low,high] format
- $this_direction  : orientation in [director,rotation] format
- $this_octant     : positioning octant
- $fl_thickness    : multi-verb parameter (see [fl_parm_thickness()](core.md#function-fl_parm_thickness))
- $fl_tolerance    : multi-verb parameter (see fl_parm_tolerance())



__Parameters:__

__verbs__  
supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT

__octant__  
when undef native positioning is used

__direction__  
desired direction [director,rotation], native direction when undef


