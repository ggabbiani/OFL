# package foundation/base_trace

Base tracing helpers.

Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)


## Functions

---

### function fl_trace

__Syntax:__

```text
fl_trace(msg,result,always=false)
```

trace helper function.

See module [fl_trace{}](#module-fl_trace).


## Modules

---

### module fl_trace

__Syntax:__

    fl_trace(msg,value,always=false)

trace helper module.

prints «msg» prefixed by its call order either if «always» is true or if its
current call order is ≤ $FL_TRACES.

Used $special variables:

- $FL_TRACE affects trace messages according to its value:
  - -2   : all traces disabled
  - -1   : all traces enabled
  - [0,∞): traces with call order ≤ $FL_TRACES are enabled


