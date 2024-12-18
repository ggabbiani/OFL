# TODOs

## General TODOs

- [X] implement module fl_frame() for 3d frames;
- [X] remove fl_director() and fl_rotor() properties. In place of them use
  default native coordinate system [+Z,+X];

## v4.0.0 TODOs

- [X] foundation/unsafe_defs.scad should be used only when code is NOT mixed
  with external libraries
- [X] re-implement FL_AXES verb
- [X] detect all the 'objects' instantiating fl_director() and fl_rotor() and
  check their client modules for the new local coordinate system settings
- [X] foundation/components.scad: added fl_Component() constructor. Modified
  component data record removing the cut direction ($comp_cutdir) and updated
  fl_comp_Context() consequently.
- [X] foundation/3d.scad: renamed as 3d-engine.scad. Simplified fl_direction()
  signature after the two type properties (director/rotor) are now defaulted to
  the local coordinate  systems that is always defined as [+Z,+X].
- [X] foundation/defs.scad: added FL_SYMBOLS. Added a new general property
  fl_cutout() defining the available cut-out directions for a generic type.
- [X] foundation/defs.scad: renamed as foundation/core.scad
- [X] global change: moved the FL_AXES implementation directly on the module
  engine APIs.
- [X] foundation/limits.scad: added for recommended settings/limits for 3d
  printing properties (values taken from [Knowledge base |
  Hubs](https://www.hubs.com/knowledge-base/))
- [X] foundation/mngm.scad: implementation of FL_SYMBOLS in fl_manage().
  Simplified fl_manage() signature after the removal of the [director,rotor]
  couple, substitute by the native  coordinate system defaulted as [+Z,+X]
- [X] foundation/symbol.scad: moved definitions inside foundation/defs.scad
- [X] foundation/type_trait.scad: updated function fl_tt_isComponent() to the
  new record format used for components.
- [X] artifacts/box.scad: modified signature for module fl_box(), implemented
  FL_LAYOUT verb and defined a variable context to be passed to children
- [X] artifacts/t-nut.scad: added a T-nut engine.
- [X] artifacts/t-nut.scad: add a dictionary of predefined sizes aligned with
  [NopSCADlib](https://github.com/nophead/NopSCADlib) definitions (M3,M4,M5,M6)
- [X] examples/camera-mount.scad: camera mount for D-Link DCS 932L into
  SnapMaker 2.0 enclosure
- [X] examples/rpi4-box: extend the auto adaptive box engine to the new Khadas
  VIM1 pcb. Example renamed into examples/sbc-box.scad
- [X] tests/artifacts/box-test.scad: aligned with changes on artifacts/box.scad
- [X] tests/artifacts/tnut-test.scad: first implementation
- [X] vitamins/countersinks.scad: added «tolerance» parameter to module
  fl_countersink()
- [X] global: added proper property fl_cutout() settings to all the types
  actually implementing the FL_CUTOUT verb
- [X] global: implemented a 'debug context' based on a set of special variables
  with the target of modify the API verb implementation;
- [X] engine parameter standardization:
        engine_stub(verbs=FL_ADD,this,...,octant,direction);
- [X] tests: implement an automatic test generator mechanism able to
  standardize, where possible, the customizer parameters
- [X] tests: tests executions now under GNU Make (removed old bin/test.sh,
  replaced by its 'python' version to be more cross-platform executable)
- [X] tests: 'make' driven test generation and execution, now independent from
  root
- [X] documentation: 'make' driven documentation and picture generation, now
  independent from root
- [X] tests: make them available on all supported platform
- [X] global: implement an automatic documentation picture generator mechanism
- [X] vitamins/generic.scad: new generic vitamins with no-op FL_ADD semantic but
  fully programmable FL_CUTOUT implementation. This module has been used for
  implementing proper  component cutout on complex PCBs.
- [X] test/vitamins/generic.scad: first implementation
- [X] include third libraries into the distribution
- [X] some package rename adhering the architectural documentation
- [X] general Makefile implementing documents/pictures/example generation
- [X] moved library sources into a single top level directory, same for tests
  and examples
- [X] removed obsolete drawio library
- [X] rewrite sata library with dxf
- [X] fixed .dxf file warnings during OpenSCAD loading
- [X] improved object positioning by fl_octant() extension now managing also
  'undef' dimensional translations
- [X] all OFL base shapes but fl_cube() are centered to the origin: now
  fl_cube() is centered by default as well
- [X] standardize the common api parameter syntax
- [X] removed the obsolete $fl_debug;
- [X] modified fl_error{} signature;
- [X] fixed z-offset on sata connector symbols;
- [X] fixed regression in hds while showing sata debug symbols;
- [X] modify sata and hd signatures for debug symbol handling in place of show
  connectors parameter;
- [X] fixed fl_connect() to manage parent «octant» and «direction» parameters;
- [X] function fl_dbg_assert() used in place of fl_debug();
- [X] renamed foundation/profile.scad into artifacts/profiles-engine.scad;
- [X] renamed foundation/type_trait.scad into foundation/traits-engine.scad;
- [X] implemented FL_CUTOUT in hds and sata packages;
- [ ] review and apply everywhere the new polymorph engine for rewriting and
  subtyping all the existing modules. Use vitamins/iec.scad as implementation
  example/reference.
- [ ] implement everywhere the multi-verb global parameters (ex.
  fl_parm_tolerance() and fl_parm_thickness())
- [ ] modify FL_DRILL verb implementation according to the type of drill to be
  performed: TAP drill vs CLEARANCE drill.
- [ ] differentiate documentation by release
- [ ] fully wrap the NopSCADlib screw library
- [X] renamed knut_nut-test.{conf,json,scad} into knut_nuts-test.{conf,json,scad}
- [ ] unify dictionary search: for list fl_list_filter(), for vitamins fl_«name
  space»_find/select() (see fl_pcb_select{}). Eliminate fl_«name
  space»_search(). Involved libraries (not exhaustive list):
  - countersinks
  - screw (after wrapper setup)
- [ ] move vitamins dictionaries into inventories (dictionaries should be used
  only in generic libraries)
- [X] add constructors to spacer and pcb_holder libraries
- [X] new artifact: fl_pcb_frame adapting a pcb to holes in order to be later
  mounted on standard pcb holder
- [ ] fix bug in fl_sector(): order of generated points must follow the sign of
  the angle.
- [X] implemented PCB frames as PCB proxies
- [ ] integrate in tests also the examples
- [ ] constructor for fl_layout()
- [ ] review and apply everywhere the new generalized cutout algorithm. Use
  vitamins/{ethers,heatsink,usbs}.scad as implementation example/reference.
- [X] implemented new PCB component filtering.
- [X] fix documentation generation under Ubuntu
- [X] fixed regression after the generic cutout algorithm implementation in pcb
  engine
- [ ] create template tests
- [ ] setup a 3rdy part application template;
- [ ] complete DIN rails implementing missing verbs (like FL_MOUNT)
- [X] added Snap-fit joints
- [X] added 'point' symbol
- [X] added fl_2d_closest() algorithm
- [ ] apply fl_2d_closest() algorithm during symbol and label debugging (see fl_bentPlate{})
- [X] added dimension line management
- [ ] add dimension lines to relevant tests (see artifacts/joints.scad)
- [ ] fix bug in fl_2d_closest() algorithm (see artifacts/joints.scad)
- [ ] add fl_circular_layout{} and cyl_layout{} (from 'super-pipe' project);
- [ ] add fan_guard component to fans;
- [X] added fl_Object() constructor helper in new package 'type-engine;
- [ ] finalize quaternions support;
- [X] applied Makefile function make-picture and check-picture in all picture related targets;
- [X] modified library tree moving NopSCADlib, Round-Anything and scad-utils into lib/ext/;

## future TODOs

- [ ] add Parameter execution context (for tolerance and thickness);
- [ ] insert 2d shape hierarchy into the official documentation;
- [ ] write an application customizer template similar to the one existing for tests;
- [ ] add package with customizer helpers;
- [ ] document Docker build process and more generally developer information;
