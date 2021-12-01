/*
 * NopACADlib HDMI definitions wrapper.
 *
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL).
 *
 * OFL is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * OFL is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with OFL.  If not, see <http: //www.gnu.org/licenses/>.
 */
include <../foundation/defs.scad>

function fl_hdmi_new(nop_type) = let(
    l   = hdmi_depth(nop_type),
    iw1 = hdmi_width1(nop_type),
    iw2 = hdmi_width2(nop_type),
    ih1 = hdmi_height1(nop_type),
    ih2 = hdmi_height2(nop_type),
    h   = hdmi_height(nop_type),
    t   = hdmi_thickness(nop_type),
    bbox  = let(d=max(iw1,iw2)+2*t) [[-l/2,-d/2,h-2*t-ih2],[+l/2,+d/2,h]]
) [
  fl_nopSCADlib(value=nop_type),
  fl_bb_corners(value=bbox),
  fl_director(value=+FL_X),fl_rotor(value=+FL_Y),
];

// following HDMI socket definitions are taken from NopSCADlib/vitamins/pcb.scad
FL_HDMI_TYPE_A  = fl_hdmi_new(
  [ "hdmi_full", "HDMI socket",        12,   14,   10,  3,    4.5, 6.5, 0.5 ]
);
FL_HDMI_TYPE_C  = fl_hdmi_new(
  [ "hdmi_mini", "Mini HDMI socket",    7.5, 10.5, 8.3, 1.28, 2.5, 3.2, 0.35 ]
);
FL_HDMI_TYPE_D  = fl_hdmi_new(
  [ "hdmi_micro", "Micro HDMI socket", 8.5,  5.9, 4.43, 1.4, 2.3, 3,   0.3 ]
);

FL_HDMI_DICT = [
  FL_HDMI_TYPE_A,
  FL_HDMI_TYPE_C,
  FL_HDMI_TYPE_D
];

use     <hdmi.scad>
