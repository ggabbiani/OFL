/*!
 * "Supported walls" figure
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <OFL/library.scad>

  T=1.5;
  l=10;
  $fl_technology=FL_TECH_FDM;
  fl_cube(size=[l,l,T], octant=+X+Z);
  fl_cube(size=[T,l,l], octant=+X+Z);
  #translate([T,0,T])
    fl_cube(size=[l-T,fl_techLimit(FL_LIMIT_SWALLS),l-T],octant=+X+Z);
