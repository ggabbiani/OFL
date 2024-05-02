# TODOs

## General TODOs

- [x] implement module fl_frame() for 3d frames;
- [x] remove fl_director() and fl_rotor() properties. In place of them use
  default native coordinate system [+Z,+X];
- [ ] transform some of the special global constants into special module
  parameters manageable through common API:

    \$FL\_DEBUG ⇒ function fl_parm_DEBUG() = is_undef($debug) ? false : $debug;

## v4.0.0 TODOs

- [x] foundation/unsafe_defs.scad should be used only when code is NOT mixed
  with external libraries
- [x] re-implement FL_AXES verb
- [x] detect all the 'objects' instantiating fl_director() and fl_rotor() and
  check their client modules for the new local coordinate system settings
- [x] foundation/components.scad: added fl_Component() constructor. Modified
  component data record removing the cut direction ($comp_cutdir) and updated
  fl_comp_Context() consequently.
- [x] foundation/3d.scad: renamed as 3d-engine.scad. Simplified fl_direction()
  signature after the two type properties (director/rotor) are now defaulted to
  the local coordinate  systems that is always defined as [+Z,+X].
- [x] foundation/defs.scad: added FL_SYMBOLS. Added a new general property
  fl_cutout() defining the available cut-out directions for a generic type.
- [x] foundation/defs.scad: renamed as foundation/core.scad
- [x] global change: moved the FL_AXES implementation directly on the module
  engine APIs.
- [x] foundation/limits.scad: added for recommended settings/limits for 3d
  printing properties (values taken from [Knowledge base |
  Hubs](https://www.hubs.com/knowledge-base/))
- [x] foundation/mngm.scad: implementation of FL_SYMBOLS in fl_manage().
  Simplified fl_manage() signature after the removal of the [director,rotor]
  couple, substitute by the native  coordinate system defaulted as [+Z,+X]
- [x] foundation/symbol.scad: moved definitions inside foundation/defs.scad
- [x] foundation/type_trait.scad: updated function fl_tt_isComponent() to the
  new record format used for components.
- [x] artifacts/box.scad: modified signature for module fl_box(), implemented
  FL_LAYOUT verb and defined a variable context to be passed to children
- [x] artifacts/t-nut.scad: added a T-nut engine.
- [X] artifacts/t-nut.scad: add a dictionary of predefined sizes aligned with
  [NopSCADlib](https://github.com/nophead/NopSCADlib) definitions (M3,M4,M5,M6)
- [x] examples/camera-mount.scad: camera mount for D-Link DCS 932L into
  SnapMaker 2.0 enclosure
- [x] examples/rpi4-box: extend the auto adaptive box engine to the new Khadas
  VIM1 pcb. Example renamed into examples/sbc-box.scad
- [x] tests/artifacts/box-test.scad: aligned with changes on artifacts/box.scad
- [x] tests/artifacts/tnut-test.scad: first implementation
- [x] vitamins/countersinks.scad: added «tolerance» parameter to module
  fl_countersink()
- [x] global: added proper property fl_cutout() settings to all the types
  actually implementing the FL_CUTOUT verb
- [ ] global: extend the OFL APIs for implementing the newly introduced
  'standard' parameter «debug»
- [ ] engine parameter standardization:
        engine_stub(verbs=FL_ADD,this,...,octant,direction,debug);
- [x] tests: implement an automatic test generator mechanism able to
  standardize, where possible, the customizer parameters
- [x] tests: tests executions now under GNU Make (removed old bin/test.sh,
  replaced by its 'python' version to be more cross-platform executable)
- [x] tests: 'make' driven test generation and execution, now independent from
  root
- [x] documentation: 'make' driven documentation and picture generation, now
  independent from root
- [ ] tests: make them available on all supported platform
- [x] global: implement an automatic documentation picture generator mechanism
- [x] vitamins/generic.scad: new generic vitamins with no-op FL_ADD semantic but
  fully programmable FL_CUTOUT implementation. This module has been used for
  implementing proper  component cutout on complex PCBs.
- [x] test/vitamins/generic.scad: first implementation
- [x] include third libraries into the distribution
- [x] some package rename adhering the architectural documentation
- [x] general Makefile implementing documents/pictures/example generation
- [x] moved library sources into a single top level directory, same for tests
  and examples
- [ ] remove obsolete drawio library
- [x] rewrite sata library with dxf
- [x] fixed .dxf file warnings during OpenSCAD loading
- [x] improved object positioning by fl_octant() extension now managing also
  'undef' dimensional translations
- [x] all OFL base shapes but fl_cube() are centered to the origin: now
  fl_cube() is centered by default as well
- [ ] standardize the common api parameter syntax
- [ ] modify FL_DRILL verb implementation according to the type of drill to be
  performed: TAP drill vs CLEARANCE drill.
- [ ] differentiate documentation by release
- [ ] fully wrap the NopSCADlib screw library
- [x] rename knut_nut-test.{conf,json,scad} into knut_nuts-test.{conf,json,scad}
- [ ] unify dictionary search: for list fl_list_filter(), for vitamins fl_«name
  space»_find/select() (see fl_pcb_select{}). Eliminate fl_«name
  space»_search(). Involved libraries (not exhaustive list):
  - countersinks
  - screw (after wrapper setup)
- [ ] move vitamins dictionaries into inventories (dictionaries should be used
  only in generic libraries)
- [x] add constructors to spacer and pcb_holder libraries
- [x] new artifact: fl_pcb_frame adapting a pcb to holes in order to be later
  mounted on standard pcb holder
- [ ] fix bug in fl_sector(): order of generated points must follow the sign of
  the angle.
- [x] implemented PCB frames as PCB proxies
- [ ] integrate in tests also the examples
- [ ] constructor for fl_layout()
- [ ] review and apply everywhere the new generalized cutout algorithm. Use
  vitamins/{ethers,heatsink,usbs}.scad as implementation example/reference.
- [ ] review and apply everywhere the new polymorph engine for rewriting and
  subtyping all the existing modules. Use vitamins/iec.scad as implementation
  example/reference.
- [x] implemented new PCB component filtering.
- [x] fix documentation generation under Ubuntu
- [x] fixed regression after the generic cutout algorithm implementation in pcb
  engine
- [ ] create template tests
- [ ] complete DIN rails implementing missing verbs
- [x] added 'point' symbol




## Changed file names

| old                               | new                               |
| --------                          | --------                          |
| foundation/2d.scad                | foundation/2d-engine.scad         |
| foundation/3d.scad                | foundation/3d-engine.scad         |
| foundation/base_geo.scad          | foundation/core.scad              |
| foundation/base_kv.scad           | foundation/core.scad              |
| foundation/base_parameters.scad   | foundation/core.scad              |
| foundation/base_string.scad       | foundation/core.scad              |
| foundation/base_trace.scad        | foundation/core.scad              |
| foundation/bbox.scad              | foundation/bbox-engine.scad       |
| foundation/defs.scad              | foundation/core.scad              |
| foundation/mngm.scad              | foundation/mngm-engine.scad       |
| foundation/symbol.scad            | -                                 |
| tests/vitamins/knu_nut-test.conf  | tests/vitamins/knu_nuts-test.conf |
| tests/vitamins/knu_nut-test.json  | tests/vitamins/knu_nuts-test.json |
| tests/vitamins/knu_nut-test.scad  | tests/vitamins/knu_nuts-test.scad |

