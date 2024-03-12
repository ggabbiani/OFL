/*!
 * Wrapper for NopSCADlib extrusions defining T-slot structural framing as
 * described [T-slot structural framing](https://en.wikipedia.org/wiki/T-slot_structural_framing)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../NopSCADlib/vitamins/extrusions.scad>
include <../foundation/3d-engine.scad>

use <../foundation/mngm-engine.scad>

//! namespace
FL_TSP_NS  = "t-slotted profile";

//**** getters ****************************************************************

//! return false when profile doesn't have center hole, its ⌀ otherwise
function fl_tsp_centerD(type) = let(
  value = extrusion_center_hole(fl_nopSCADlib(type))
) value<0 ? abs(value) : false;

//! return false when profile doesn't have corner holes, the ⌀ otherwise
function fl_tsp_cornerD(type) = let(
  value = extrusion_corner_hole_wd(fl_nopSCADlib(type))
) value<0 ? abs(value) : false;

//! channel width
function fl_tsp_chW(type) = extrusion_channel_width(fl_nopSCADlib(type));

//! internal channel width
function fl_tsp_intChW(type) = extrusion_channel_width_internal(fl_nopSCADlib(type));

//! tab thickness
function fl_tsp_tabT(type) = extrusion_tab_thickness(fl_nopSCADlib(type));

//! nominal cross-section size
function fl_tsp_nominalSize(type) = fl_tsp_w(type);

//! width
function fl_tsp_w(type) = extrusion_width(fl_nopSCADlib(type));

//! height
function fl_tsp_h(type) = extrusion_height(fl_nopSCADlib(type));

function fl_tsp_filletR(type)    = extrusion_fillet(fl_nopSCADlib(type));


//! Cross-section constructor
function fl_tsp_CrossSection(
  //! verbatim NopSCADlib cross-section definition
  nop
) = assert(nop) [
  fl_nopSCADlib(value=nop),
];

/*!
 * ![fractional T-slot cross-section](256x256/fig-FL_TSP_E1515.png)
 *
 * 15 series T-slotted cross-section size 15mm ⌀3.3mm
 */
FL_TSP_E1515  = fl_tsp_CrossSection(E1515);

/*!
 * ![metric T-slot cross-section](256x256/fig-FL_TSP_E2020.png)
 *
 * 20 series T-slotted cross-section size 20mm ⌀4.2mm
 */
FL_TSP_E2020  = fl_tsp_CrossSection(E2020);

/*!
 * ![metric T-slot cross-section](256x256/fig-FL_TSP_E2020t.png)
 *
 * 20 series T-slotted cross-section size 20mm ⌀5mm
 */
FL_TSP_E2020t = fl_tsp_CrossSection(E2020t);

/*!
 * ![metric T-slot cross-section](256x256/fig-FL_TSP_E2040.png)
 *
 * 20 series T-slotted cross-section size 40mm ⌀4.2mm
 */
FL_TSP_E2040  = fl_tsp_CrossSection(E2040);

/*!
 * ![metric T-slot cross-section](256x256/fig-FL_TSP_E2060.png)
 *
 * 20 series T-slotted cross-section size 60mm ⌀4.2mm
 */
FL_TSP_E2060  = fl_tsp_CrossSection(E2060);

/*!
 * ![metric T-slot cross-section](256x256/fig-FL_TSP_E2080.png)
 *
 * 20 series T-slotted cross-section size 80mm ⌀4.2mm
 */
FL_TSP_E2080  = fl_tsp_CrossSection(E2080);

/*!
 * ![metric T-slot cross-section](256x256/fig-FL_TSP_E3030.png)
 *
 * 30 series T-slotted cross-section size 30mm ⌀6.8mm
 */
FL_TSP_E3030  = fl_tsp_CrossSection(E3030);

/*!
 * ![metric T-slot cross-section](256x256/fig-FL_TSP_E3060.png)
 *
 * 30 series T-slotted cross-section size 60mm ⌀6.8mm
 */
FL_TSP_E3060  = fl_tsp_CrossSection(E3060);

/*!
 * ![metric T-slot cross-section](256x256/fig-FL_TSP_E4040.png)
 *
 * 40 series T-slotted cross-section size 40mm ⌀10.5mm
 */
FL_TSP_E4040  = fl_tsp_CrossSection(E4040);

/*!
 * ![metric T-slot cross-section](256x256/fig-FL_TSP_E4040t.png)
 *
 * 40 series T-slotted cross-section size 40mm ⌀10mm
 */
FL_TSP_E4040t = fl_tsp_CrossSection(E4040t);

/*!
 * ![metric T-slot cross-section](256x256/fig-FL_TSP_E4080.png)
 *
 * 40 series T-slotted cross-section size 80mm ⌀10.5mm
 */
FL_TSP_E4080  = fl_tsp_CrossSection(E4080);

//! T-slotted cross-section dictionary
FL_XTR_DICT = [
  FL_TSP_E1515,
  FL_TSP_E2020,
  FL_TSP_E2020t,
  FL_TSP_E2040,
  FL_TSP_E2060,
  FL_TSP_E2080,
  FL_TSP_E3030,
  FL_TSP_E3060,
  FL_TSP_E4040,
  FL_TSP_E4040t,
  FL_TSP_E4080,
];

function fl_tsp_length(type,value)    = fl_property(type,"tsp/length",value);

//! T-slotted profile constructor
function fl_tsp_TProfile(
  xsec,
  length
) = assert(xsec,xsec) assert(length,length) let(
  nop = fl_nopSCADlib(xsec),
  w   = extrusion_width(nop),
  h   = extrusion_height(nop)
) [
  fl_nopSCADlib(value=nop),
  // fl_tsp_xsection(value=xsec),
  fl_tsp_length(value=length),
  fl_bb_corners(value=[[-w/2,-h/2,-length/2],[+w/2,+h/2,+length/2]])
];

/*!
 * TODO: document context variables
 */
module fl_tProfile(
  //! supported verbs: FL_ADD, FL_AXES, FL_BBOX, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  type,
  /*!
   * floating semi-axis list (es. [+X,-Y]) for FL_LAYOUT
   *
   * NOTE: ±Z is excluded
   */
  lay_surface,
  //! see constructor fl_parm_Debug()
  debug,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant,
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(is_undef(lay_surface) || fl_tt_isAxisList(lay_surface),lay_surface);

  // nop   = fl_nopSCADlib(fl_tsp_xsection(type));
  nop   = fl_nopSCADlib(type);
  bbox  = fl_bb_corners(type);
  size  = bbox[1]-bbox[0];
  D     = direction ? fl_direction(direction) : I;
  M     = fl_octant(octant,bbox=bbox);

  module do_fprint() {
    translate(-Z(size.z/2))
      linear_extrude(size.z)
        fl_square(size=[size.x,size.y],corners=extrusion_fillet(nop));
  }

  module do_layout() {
    assert(lay_surface);
    // children context
    let(
      $tsp_size = size,
      $tsp_tabT = fl_tsp_tabT(type)
    ) for($tsp_surface=lay_surface)
        translate(abs(size/2*$tsp_surface)*$tsp_surface)
          children();
  }

  fl_manage(verbs,M,D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier)
        extrusion(nop, size.z,center=true, cornerHole=false);

    } else if ($verb==FL_AXES) {
      fl_modifier($FL_AXES)
        fl_doAxes(size,direction,debug);

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier)
        fl_bb_add(bbox);

    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier)
        do_fprint();

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier)
        do_layout() children();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
