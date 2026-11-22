# OFL API: a critical review

This page reviews the OFL API design, focusing on **verbs**. It asks whether
verbs keep parameter passing small or whether they add complexity, and it
proposes changes for the 4.0.0 release.

Snapshot: November 2026, OFL 3.5.1 with the 4.0.0 changes in progress. All
figures refer to `lib/OFL`.

## Summary

Verbs are worth keeping. They do **not** reduce the number of parameters, and
they often increase it. Their real value is that each component owns
everything about itself: shape, holes, footprint and mounting. Most of the
complexity comes from the plumbing around verbs, not from the idea.

## Figures

| Item | Value |
| --- | --- |
| public modules (`module fl_…`) | 107 |
| median number of module parameters | 6 |
| `fl_vloop()` / `fl_vmanage()` call sites | 26 / 35 (plus 9 `fl_2d_vloop()`) |
| `unimplemented verb` error branches | 70 |
| `fl_modifier($modifier…)` calls | 93 |
| distinct `$xxx_…` context variables | 109 (plus `$this_*`) |

## What works

### Each component owns its interfaces

One object answers every question about itself:

- `FL_ADD` gives its shape;
- `FL_DRILL` gives the holes the hosting panel must subtract;
- `FL_FOOTPRINT` and `FL_BBOX` give its envelope;
- `FL_MOUNT` and `FL_ASSEMBLY` give its screws and accessories.

The parent module does not need to know where a PCB has its holes. It asks
for `FL_DRILL` inside a `difference()`. Without verbs, that geometry would be
copied wherever it is needed, and the copies would drift apart.

### Uniform signatures and property-based objects

Modules follow the same shape: `verbs, object, …, octant, direction`. Objects
are property lists. Because of this, generic modules work on objects of
different kinds: `fl_layout{}` arranges PCBs, hard disks and PSUs in the same
call (see `tests/foundation/layout-test`).

### Per-verb debugging

The `$FL_*` variables support `ON/ONLY/DEBUG/TRANSPARENT` for each verb. These
modes map onto OpenSCAD modifier characters and make Customizer-driven tests
very effective.

## Where the complexity comes from

### 1. Verbs add up parameters

One signature has to serve every operation, so it collects the parameters of
all of them. In `fl_spacer{}`, `thick` matters only for `FL_DRILL` and
`FL_MOUNT`, while `anchor` and `fillet` matter only for `FL_ADD`. The link
between a parameter and its verb exists only in comments: a caller cannot
tell which parameters matter for the verbs it passes.

### 2. Two sources of truth for a verb

A verb runs when it is in the `verbs` list **and** its `$FL_*` variable is not
`"OFF"`. For example, `fans-test` and `din_rails-test` must pass
`$FL_LAYOUT="ON"` to `fl_layout{}`, otherwise the Customizer default `"OFF"`
disables it. This state is hidden, and it arrives through dynamic scoping.

### 3. Context variables are invisible in the API

Dynamic scoping is the only way OpenSCAD can pass data to children, so some
context variables are unavoidable. But they do not appear in any signature,
they are hard to discover, and they can collide. `fl_layout{}` still uses
`$i`, `$item` and `$len` without a prefix, as its own TODO notes.

### 4. Repeated code in every module

Every module repeats:

- an `if/else` chain over the verbs;
- an `unimplemented verb` branch (70 in total);
- explicit `fl_modifier($modifier)` calls (93 in total).

Two loop implementations also coexist (`fl_vloop()` and `fl_vmanage()`), so
the migration between them is half done.

### 5. Supported verbs are declared only in comments

The supported verbs are listed only in `//! supported verbs: …` comments. An
unsupported verb fails only when the model is generated, inside the module.

### 6. Bipolar property functions

The same function reads a property and builds it
(`fl_property(type,key,value)`). This is compact but ambiguous.

### 7. Positional arguments are fragile

With long signatures, any positional argument after `verbs, object` breaks
when parameters are reordered. Moving `layout` into the second position of
`fl_layout{}` for 4.0.0 is a recent example.

## Proposals for 4.0.0

Ordered by benefit for the effort:

1. **Declare supported verbs as data.** Use a module constant or an object
   property, and let `fl_vmanage()` reject unsupported verbs. This removes the
   70 `unimplemented verb` branches, and the documentation can be generated
   from the same data.
2. **Use a single loop.** Finish the migration to `fl_vmanage()` and its 2D
   counterpart, and handle `$modifier` inside it.
3. **Prefix the context variables** (for example `$lay_i`, `$lay_item`), and
   document them in a table for each module, as `fl_spacer{}` already does.
4. **Separate `verbs` from `$FL_*`.** The `verbs` list decides *what* is
   produced. `$FL_*` decides only *how* it is shown, and no longer disables a
   verb that was explicitly requested.
5. **Named arguments only after `verbs, object`.** Write the rule into the
   guidelines and enforce it with checks like the one in `fl_layout{}`, which
   rejects a non-layout second argument.
6. **Optional: group verb-specific parameters,** such as the drilling ones,
   into an object or property list, as already done for `knut`.

Proposals 1–3 do not change behaviour for library users and remove most of
the repeated code. Proposal 4 is a real breaking change, so the 4.0.0 major
release is the right time to make it.
