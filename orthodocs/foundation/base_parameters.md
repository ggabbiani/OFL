# package foundation/base_parameters

Common parameter helpers

Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Functions

---

### function fl_asserts

__Syntax:__

```text
fl_asserts()
```

When true [fl_assert()](defs.md#function-fl_assert) is enabled

---

### function fl_debug

__Syntax:__

```text
fl_debug()
```

When true debug statements are turned on

---

### function fl_filament

__Syntax:__

```text
fl_filament()
```

Default color for printable items (i.e. artifacts)

---

### function fl_parm_Debug

__Syntax:__

```text
fl_parm_Debug(labels=false,symbols=false)
```

contructor for debug context parameter

__Parameters:__

__labels__  
when true, labels to symbols are assigned and displayed

__symbols__  
when true symbols are displayed


---

### function fl_parm_labels

__Syntax:__

```text
fl_parm_labels(debug)
```

When true debug labels are turned on

---

### function fl_parm_symbols

__Syntax:__

```text
fl_parm_symbols(debug)
```

When true debug symbols are turned on

