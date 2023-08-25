/*!
 * Component package for OpenSCAD Foundation Library.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <core.scad>

use <bbox-engine.scad>

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
  engine,
  position,
  direction,
  type,
  parameters
) =
assert(!fl_debug(),fl_debug())
[engine,position,undef,direction,type,parameters];

/*!
 * Component context:
 *
 *  - $comp_engine    : engine to be triggered for component rendering
 *  - $comp_position  : component position
 *  - $comp_direction : new coordinate system in [[direction], rotation] format
 *  - $comp_director  : new coordinate system direction vector
 *  - $comp_rotation  : new coordinate system rotation value around new direction
 *  - $comp_type
 *  - $comp_subtract  : the tolerance to be used during component FL_FOOTPRINT difference from parent shape
 *  - $comp_drift     : additional delta during component FL_CUTOUT
 *  - $comp_color
 *  - $comp_octant
 *  - $comp_cutdir    : cutout direction for the component in the __hosting__ coordinate system
 *                      TODO: remove this variable since **OBSOLETE**
 *
 */
module fl_comp_Context(
  //! component definition:
  component
  ) {
  assert(!fl_debug() || fl_tt_isComponent(component),component);

  $comp_engine    = assert(is_string(component[0])) component[0];
  $comp_position  = assert(fl_tt_is3d(component[1]),component[1]) component[1];
  // $comp_cutdir    = assert(fl_tt_isAxis(component[2])) component[2]; // **OBSOLETE**
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
        Tbbox       = fl_bb_calc(pts=points)
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
