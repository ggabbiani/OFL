/*!
 * OpenSCAD customizer helpers.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../foundation/unsafe_defs.scad>

//! prefix used for namespacing
FL_CUST_NS  = "cust";

function fl_cust_undef(value,_if_="undef",_when_=false) =
  value==_if_ || _when_ ?
    undef :
    value;
