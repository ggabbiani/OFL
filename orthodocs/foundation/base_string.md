# package foundation/base_string

string utility implementation file.



*Published under __GNU General Public License v3__*

## Variables

---

### variable FL_EXCLUDE_ANY

__Default:__

    ["AND",function(one,other)one!=other]

see [fl_list_filter()](#function-fl_list_filter) «operator» parameter

---

### variable FL_INCLUDE_ALL

__Default:__

    ["OR",function(one,other)one==other]

see [fl_list_filter()](#function-fl_list_filter) «operator» parameter

## Functions

---

### function fl_list_filter

__Syntax:__

```text
fl_list_filter(list,operator,compare,__result__=[],__first__=true)
```

---

### function fl_list_flatten

__Syntax:__

```text
fl_list_flatten(list)
```

recursively flatten infinitely nested list

---

### function fl_list_has

__Syntax:__

```text
fl_list_has(list,item)
```

---

### function fl_str_lower

__Syntax:__

```text
fl_str_lower(s)
```

---

### function fl_str_upper

__Syntax:__

```text
fl_str_upper(s)
```

