# package artifacts/joints

## Dependencies

```mermaid
graph LR
    A1[artifacts/joints] --o|include| A2[foundation/dimensions]
    A1 --o|include| A3[foundation/label]
    A1 --o|use| A4[foundation/3d-engine]
    A1 --o|use| A5[foundation/bbox-engine]
    A1 --o|use| A6[foundation/fillet]
```

Snap-fit joints, for 'how to' about snap-fit joint 3d printing, see also [How
do you design snap-fit joints for 3D printing? | Protolabs
Network](https://www.hubs.com/knowledge-base/how-design-snap-fit-joints-3d-printing/)

This file is part of the 'OpenSCAD Foundation Library' (OFL) project.

Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)

chirurgia@cemsverona.it


## Variables

---

### variable FL_JNT_INVENTORY

__Default:__

    []

package inventory as a list of pre-defined and ready-to-use 'objects'

---

### variable FL_JNT_NS

__Default:__

    "jnt"

prefix used for namespacing

## Functions

---

### function fl_jnt_LongitudinalSection

__Syntax:__

```text
fl_jnt_LongitudinalSection(length,arm_l,tooth_l,h,undercut,alpha=30,orientation=+Z)
```

__Parameters:__

__length__  
total cantilever length (i.e. arm + tooth). This parameter is mandatory.

__arm_l__  
arm length. This parameter is mandatory.

__tooth_l__  
tooth length (mandatory parameter)


__h__  
thickness in scalar or [root,end] form. Scalar value means constant thickness.

__undercut__  
undercut

__alpha__  
angle of inclination for the tooth

__orientation__  
move direction: +Z or -Z


---

### function fl_jnt_RectCantilever

__Syntax:__

```text
fl_jnt_RectCantilever(description,length,arm_l,tooth_l,h,b,undercut,alpha=30,orientation=+Z,fillet=0)
```

creates a cantilever joint with rectangle cross-section.

The following pictures show the relations between the passed parameters and
the object geometry:

__FRONT VIEW__:

![Front view](800x600/fig_joints_front_view.png)

__RIGHT VIEW__:

![Right view](800x600/fig_joints_right_view.png)

__TOP VIEW__

![Top view](800x600/fig_joints_top_view.png)


__Parameters:__

__description__  
optional description

__length__  
total cantilever length (i.e. arm + tooth)

__arm_l__  
arm length

__tooth_l__  
tooth length: automatically calculated according to «alpha» angle if undef


__h__  
thickness in scalar or [root,end] form. Scalar value means constant thickness.

__b__  
width in scalar or [root,end] form. Scalar value means constant width.

__alpha__  
angle of inclination for the tooth

__orientation__  
move direction: +Z or -Z

__fillet__  
optional fillet radius.

- 0 ⇒ no fillet
- "auto" ⇒ auto calculated radius
- scalar ⇒ client defined radius value

__NOTE__: currently not (yet) implemented



---

### function fl_jnt_RectCantileverConst

__Syntax:__

```text
fl_jnt_RectCantileverConst(description,length,l,h,b,undercut,alpha=30,orientation=+Z,fillet=0)
```

creates a cantilever joint with constant rectangle cross-section

__Parameters:__

__description__  
optional description

__length__  
total cantilever length (i.e. arm + tooth)

__h__  
thickness in scalar.

__b__  
width in scalar.

__orientation__  
move direction: +Z or -Z

__fillet__  
optional fillet radius.

- 0 ⇒ no fillet
- "auto" ⇒ auto calculated radius
- scalar ⇒ client defined radius value



---

### function fl_jnt_RectCantileverFullScaled

__Syntax:__

```text
fl_jnt_RectCantileverFullScaled(description,length,l,h,b,undercut,alpha=30,orientation=+Z,fillet=0)
```

Creates a cantilever joint with a scaled section thickness from «h» to «h»/2
and a scaled section width from «b» to «b»/4


__Parameters:__

__description__  
optional description

__length__  
total cantilever length (i.e. arm + tooth)

__h__  
thickness in scalar.

__b__  
width in scalar.

__orientation__  
move direction: +Z or -Z

__fillet__  
optional fillet radius.

- 0 ⇒ no fillet
- "auto" ⇒ auto calculated radius
- scalar ⇒ client defined radius value



---

### function fl_jnt_RectCantileverScaledThickness

__Syntax:__

```text
fl_jnt_RectCantileverScaledThickness(description,length,l,h,b,undercut,alpha=30,orientation=+Z,fillet=0)
```

Creates a cantilever joint with a scaled section thickness from «h» to «h»/2


__Parameters:__

__description__  
optional description

__length__  
total cantilever length (i.e. arm + tooth)

__h__  
thickness in scalar.

__b__  
width in scalar.

__orientation__  
move direction: +Z or -Z

__fillet__  
optional fillet radius.

- 0 ⇒ no fillet
- "auto" ⇒ auto calculated radius
- scalar ⇒ client defined radius value



---

### function fl_jnt_RectCantileverScaledWidth

__Syntax:__

```text
fl_jnt_RectCantileverScaledWidth(description,length,l,h,b,undercut,alpha=30,orientation=+Z,fillet=0)
```

Creates a cantilever joint with a scaled section width from «b» to «b»/4


__Parameters:__

__description__  
optional description

__length__  
total cantilever length (i.e. arm + tooth)

__h__  
thickness in scalar.

__b__  
width in scalar.

__orientation__  
move direction: +Z or -Z

__fillet__  
optional fillet radius.

- 0 ⇒ no fillet
- "auto" ⇒ auto calculated radius
- scalar ⇒ client defined radius value



---

### function fl_jnt_RingCantilever

__Syntax:__

```text
fl_jnt_RingCantilever(description,length,arm_l,tooth_l,h,theta,undercut,alpha=30,orientation=+Z,r,fillet=0)
```

__Parameters:__

__description__  
optional description

__length__  
total cantilever length (i.e. arm + tooth)

__arm_l__  
arm length

__tooth_l__  
tooth length: automatically calculated according to «alpha» angle if undef


__h__  
thickness in scalar or [root,end] form. Scalar value means constant thickness.

__theta__  
angular width in scalar or [root,end] form. Scalar value means constant
angular width.


__alpha__  
angle of inclination for the tooth

__orientation__  
move direction: +Z or -Z

__r__  
outer radius

__fillet__  
optional fillet radius.

- 0 ⇒ no fillet
- "auto" ⇒ auto calculated radius
- scalar ⇒ client defined radius value

__NOTE__: currently not (yet) implemented



---

### function fl_jnt_RingCantileverConst

__Syntax:__

```text
fl_jnt_RingCantileverConst(description,length,arm_l,tooth_l,h,theta,undercut,alpha=30,orientation=+Z,r,fillet=0)
```

__Parameters:__

__description__  
optional description

__length__  
total cantilever length (i.e. arm + tooth)

__arm_l__  
arm length

__tooth_l__  
tooth length: automatically calculated according to «alpha» angle if undef


__h__  
thickness in scalar.

__theta__  
angular width in scalar or [root,end] form. Scalar value means constant
angular width.


__alpha__  
angle of inclination for the tooth

__orientation__  
move direction: +Z or -Z

__r__  
outer radius

__fillet__  
optional fillet radius.

- 0 ⇒ no fillet
- "auto" ⇒ auto calculated radius
- scalar ⇒ client defined radius value

__NOTE__: currently not (yet) implemented



---

### function fl_jnt_RingCantileverFullScaled

__Syntax:__

```text
fl_jnt_RingCantileverFullScaled(description,length,arm_l,tooth_l,h,theta,undercut,alpha=30,orientation=+Z,r,fillet=0)
```

__Parameters:__

__description__  
optional description

__length__  
total cantilever length (i.e. arm + tooth)

__arm_l__  
arm length

__tooth_l__  
tooth length: automatically calculated according to «alpha» angle if undef


__h__  
root thickness in scalar.

__theta__  
angular width in scalar or [root,end] form. Scalar value means constant
angular width.


__alpha__  
angle of inclination for the tooth

__orientation__  
move direction: +Z or -Z

__r__  
outer radius

__fillet__  
optional fillet radius.

- 0 ⇒ no fillet
- "auto" ⇒ auto calculated radius
- scalar ⇒ client defined radius value

__NOTE__: currently not (yet) implemented



---

### function fl_jnt_rectPoints

__Syntax:__

```text
fl_jnt_rectPoints(type,value)
```

3d polyhedron points

---

### function fl_jnt_sectPoints

__Syntax:__

```text
fl_jnt_sectPoints(type,value)
```

PolyRound points

## Modules

---

### module fl_jnt_joint

__Syntax:__

    fl_jnt_joint(verbs=FL_ADD,this,parameter,octant,direction)

Children context:

- $fl_thickness: radial thickness for FL_DRILL operations for ring shaped
  joints
- $FL_tolerance: tolerance for FL_FOOTPRINT operations


__Parameters:__

__verbs__  
supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT

__octant__  
when undef native positioning is used

__direction__  
desired direction [director,rotation], native direction when undef ([+X+Y+Z])


