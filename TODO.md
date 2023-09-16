# TODOs

## General TODOs

- [ ] implement module fl_frame() for 3d frames;
- [x] remove fl_director() and fl_rotor() properties. In place of them use default native coordinate system [+Z,+X];
- [ ] transform some of the special global constants into special module parameters manageable through common API:

    \$FL\_DEBUG ⇒ function fl_parm_DEBUG() = is_undef($debug) ? false : $debug;

## v4.0.0 TODOs

- [ ] foundation/unsafe_defs.scad should be used only from examples and tests
- [x] re-implement FL_AXES verb
- [x] detect all the 'objects' instantiating fl_director() and fl_rotor() and check their client modules for the new local coordinate system settings
- [ ] implement FL_SYMBOLS verb
- [x] foundation/components.scad: added fl_Component() constructor. Modified component data record removing the cut direction ($comp_cutdir) and updated fl_comp_Context() consequently.
- [x] foundation/3d.scad: renamed as 3d-engine.scad. Simplified fl_direction() signature after the two type properties (director/rotor) are now defaulted to the local coordinate systems that is always defined as [+Z,+X].
- [x] foundation/defs.scad: added FL_SYMBOLS. Added a new general property fl_cutout() defining the available cut-out directions for a generic type.
- [x] foundation/defs.scad: renamed as foundation/core.scad
- [x] global change: moved the FL_AXES implementation directly on the module engine APIs.
- [x] foundation/limits.scad: added for recommended settings/limits for 3d printing properties (values taken from [Knowledge base | Hubs](https://www.hubs.com/knowledge-base/))
- [x] foundation/mngm.scad: implementation of FL_SYMBOLS in fl_manage(). Simplified fl_manage() signature after the removal of the [director,rotor] couple, substitute by the native coordinate system defaulted as [+Z,+X]
- [x] foundation/symbol.scad: moved definitions inside foundation/defs.scad
- [x] foundation/type_trait.scad: updated function fl_tt_isComponent() to the new record format used for components.
- [x] artifacts/box.scad: modified signature for module fl_box(), implemented FL_LAYOUT verb and defined a variable context to be passed to children
- [x] artifacts/t-nut.scad: added a T-nut engine.
- [ ] artifacts/t-nut.scad: add a dictionary of predefined sizes aligned with [NopSCADlib](https://github.com/nophead/NopSCADlib) definitions (m3,M4,M5,M6)
- [x] examples/camera-mount.scad: camera mount for D-Link DCS 932L into SnapMaker 2.0 enclosure
- [x] examples/rpi4-box: extend the auto adaptive box engine to the new Khadas VIM1 pcb. Example renamed into examples/sbc-box.scad
- [x] tests/artifacts/box-test.scad: aligned with changes on artifacts/box.scad
- [x] tests/artifacts/tnut-test.scad: first implementation
- [x] vitamins/countersinks.scad: added «tolerance» parameter to module fl_countersink()
- [x] global: added proper property fl_cutout() settings to all the types actually implementing the FL_CUTOUT verb
- [ ] global: extend the OFL APIs for implementing the newly introduced 'standard' parameter «debug»
- [ ] documentation: introduce parameter standardization
- [x] tests: implement an automatic test generator mechanism able to standardize - where possible - the customizer parameters
- [x] global: implement an automatic documentation picture generator mechanism
- [x] vitamins/generic.scad: new generic vitamins with no-op FL_ADD semantic but fully programmable FL_CUTOUT implementation. This module has been used for implementing proper component cutout on complex PCBs.
- [x] test/vitamins/generic.scad: first implementation
- [ ] include third libraries into the distribution
- [x] some package rename adhering the architectural documentation
- [x] general Makefile implementing documents/pictures/example generation
- [x] moved library sources into a single top level directory, same for tests and examples
- [ ] remove obsolete drawio library
- [x] rewrite sata library with dxf
- [x] fixed .dxf file warnings during OpenSCAD loading
- [x] improved object positioning by fl_octant() extension now managing also 'undef' dimensional translations
- [x] function fl_octant() extended in order to manage also the invariants
- [x] all OFL base shapes but fl_cube() are centered to the origin: now fl_cube() is centered by default as well

## Changed file names

| old                               | new                           |
| --------                          | --------                      |
| foundation/2d.scad                | foundation/2d-engine.scad     |
| foundation/3d.scad                | foundation/3d-engine.scad     |
| foundation/base_geo.scad          | foundation/core.scad          |
| foundation/base_kv.scad           | foundation/core.scad          |
| foundation/base_parameters.scad   | foundation/core.scad          |
| foundation/base_string.scad       | foundation/core.scad          |
| foundation/base_trace.scad        | foundation/core.scad          |
| foundation/bbox.scad              | foundation/bbox-engine.scad   |
| foundation/defs.scad              | foundation/core.scad          |
| foundation/mngm.scad              | foundation/mngm-engine.scad   |
| foundation/symbol.scad            | -                             |
