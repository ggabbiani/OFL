/*!
 * Component package for OpenSCAD Foundation Library.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <bbox-engine.scad>

//! namespace for component package
FL_COMP_NS  = "comp";

//*****************************************************************************
// Components properties

/*!
 * [OPTIONAL] tolerance used during component FL_FOOTPRINT difference from
 * parent shape
 */
FL_COMP_SUB = str(FL_COMP_NS,"/sub");
/*!
 * [OPTIONAL] additional delta during component FL_CUTOUT
 */
FL_COMP_DRIFT = str(FL_COMP_NS,"/drift");
/*!
 * [OPTIONAL] color attribute passed to component.
 *
 * __NOTE__: the semantic is component specific.
 */
FL_COMP_COLOR = str(FL_COMP_NS,"/color");
/*!
 * [OPTIONAL] component octant
 */
FL_COMP_OCTANT = str(FL_COMP_NS,"/octant");

/*
 * Component constructor
 */
function fl_Component(
  //! engine to be triggered during component rendering
  engine,
  position,
  //! new coordinate system in [[direction], rotation] format
  direction,
  /*!
   * List of floating semi-axes in the host's reference system. Defines the
   * cutout directions that the host object would like the component to
   * handle.
   */
  cutdirs,
  type,
  /*!
   * list of optional component properties:
   *
   * - FL_COMP_SUB - see variable FL_COMP_SUB
   * - FL_COMP_DRIFT - see variable FL_COMP_DRIFT
   * - FL_COMP_COLOR - see variable FL_COMP_COLOR
   * - FL_COMP_OCTANT - see variable FL_COMP_OCTANT
   */
  parameters
) = let(
  // transform component directions into host coordinate system
  comp_dirs       = fl_cutout(type),
  D               = fl_direction(direction),
  // host-coordinate-system component direction
  host_dirs       = [for(d=comp_dirs) fl_transform(D,d)],
  // the following indexes are valid for host_dirs and comp_dirs
  indexes         = fl_list_AND(cutdirs,host_dirs,true),
  // component-coordinate-system available directions
  comp_available  = [for (i=indexes) comp_dirs[i]],
  // host-coordinate-system available directions
  host_available  = [for (i=indexes) host_dirs[i]]
) [engine,position,comp_available,direction,type,parameters,host_available];

/*!
 * Returns the floating semi-axes list in the component's reference system,
 * defining all the cutout directions a component is called to manage.
 * Concretely filters the requested __host__ cut directions to a subset of the
 * __component__ configured ones
 */
function fl_comp_actualCuts(
  /*!
   * floating semi-axes list in host's reference system. «undef» stands for 'all
   * the configured component directions'
   */
  directions
) =
  directions ?
    [for (i=fl_list_AND(directions,$host_cutdirs,true)) $comp_cutdirs[i]] :
    undef;

/*!
 * Component context:
 *
 *  - $comp_engine    : engine to be triggered during component rendering
 *  - $comp_position  : component position
 *  - $comp_direction : new coordinate system in [[direction], rotation] format
 *  - $comp_director  : new coordinate system direction vector
 *  - $comp_rotation  : new coordinate system rotation value around new direction
 *  - $comp_type
 *  - $comp_subtract  : the tolerance to be used during component FL_FOOTPRINT
 *    difference from parent shape
 *  - $comp_drift     : additional delta during component FL_CUTOUT
 *  - $comp_color
 *  - $comp_octant
 *  - $host_cutdirs   : List of floating semi-axes in the host's reference
 *    system. Defines all the cutout directions a component should be able to
 *    manage. This value is needed by the host object layout engine.
 *  - $comp_cutdirs   : List of floating semi-axes in the component's reference
 *    system. Defines all the cutout directions a component should be able to
 *    manage.
 */
module fl_comp_Context(
  //! component definition:
  component
  ) {
  assert(!fl_debug() || fl_tt_isComponent(component),component);

  $comp_engine    = assert(is_string(component[0])) component[0];
  $comp_position  = assert(fl_tt_is3d(component[1]),component[1]) component[1];
  $comp_cutdirs   = assert(fl_tt_isAxisList(component[2])) component[2];
  $host_cutdirs   = assert(fl_tt_isAxisList(component[6])) component[6];
  $comp_direction = assert(is_list(component[3])) component[3];
  $comp_director  = assert(fl_tt_isAxis($comp_direction[0])) $comp_direction[0];
  $comp_rotation  = assert(is_num($comp_direction[1])) $comp_direction[1];
  $comp_type      = component[4];

  // properties
  properties      = component[5];
  $comp_subtract  = fl_optional(properties,FL_COMP_SUB);
  $comp_drift     = fl_optional(properties,FL_COMP_DRIFT,0);
  $comp_color     = fl_optional(properties,FL_COMP_COLOR);
  $comp_octant    = fl_optional(properties,FL_COMP_OCTANT);

  children();
}

/*!
 * Component specifications context:
 *
 *  - $comp_label
 *  - $comp_component
 *
 * plus component context (see fl_comp_Context{})
 */
module fl_comp_Specs(
  //! component specification: ["label",component]
  specs
  ) {
  $comp_label      = specs[0];
  $comp_component  = specs[1];
  fl_comp_Context($comp_component) children();
}

//! exact calculation of the resulting bounding box out of a list of component specifications
function fl_comp_BBox(spec_list) =
  assert(!fl_debug() || fl_tt_isCompSpecList(spec_list),spec_list)
  let(
    // list of component bounding boxes translated by their position
    bboxes = [for(specs=spec_list)
      let(
        component   = specs[1],
        position    = component[1],
        direction   = component[3],
        type        = component[4],
        properties  = component[5],
        octant      = fl_optional(properties,FL_COMP_OCTANT),
        // component bounding box
        bbox        = fl_bb_corners(type),
        // component direction matrix
        D           = fl_direction(direction),
        // translation by component position
        T           = T(position),
        // eventual component placement
        M           = fl_octant(octant,bbox=bbox),
        // transformed bounding box points
        points      = [for(corner=bbox) fl_transform(T*D*M,corner)],
        // build transformed bounding box from points
        Tbbox       = fl_bb_polyhedron(points=points)
      ) Tbbox
    ]
  ) fl_bb_calc(bboxes);

/*!
 * returns the component with «label»
 *
 * **NOTE:** error when label is not unique
 */
function fl_comp_search(type,label,comps) = let(
  components  = comps ? comps : assert(!fl_debug() || type) fl_pcb_components(type),
  result      = [for(specs=components) if (label==specs[0]) specs[1]]
) assert(!fl_debug() || len(result)==1,result) result[0];

/*
 * returns all the «component» connectors transformed according to component
 * position/orientation
 */
function fl_comp_connectors(component)  = let(
  position    = component[1],
  direction   = component[3],
  type        = component[4],
  T           = T(position),
  D           = fl_direction(direction),
  M           = T*D,
  connectors  = fl_connectors(type)
) fl_conn_import(connectors,M);
