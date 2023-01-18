# package foundation/base_kv

key/values

Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Functions

---

### function fl_get

__Syntax:__

```text
fl_get(type,key,default)
```

Mandatory property getter with default value when not found

Never return undef


---

### function fl_optProperty

__Syntax:__

```text
fl_optProperty(type,key,value,default)
```

'bipolar' optional property helper:

- type/key{/default} ↦ value       (optional property getter)
- key{/value}        ↦ [key,value] (property constructor)

It concentrates property key definition reducing possible mismatch when
referring to property key in the more usual getter/setter function pair.


---

### function fl_optional

__Syntax:__

```text
fl_optional(props,key,default)
```

Optional getter, no error when property is not found.

Return «default» when «props» is undef or empty, or when «key» is not found


---

### function fl_property

__Syntax:__

```text
fl_property(type,key,value,default)
```

'bipolar' property helper:

- type/key{/default} ↦ value       (mandatory property getter)
- key{/value}        ↦ [key,value] (property constructor)

It concentrates property key definition reducing possible mismatch when
referring to property key in the more usual getter/setter function pair.


