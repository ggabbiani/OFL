/*
 * Ethernet definition file.
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

FL_ETHER_NS = "ether";

FL_ETHER_RJ45 = let(
  bbox  = let(l=21,w=16,h=13.5) [[-l/2,-w/2,0],[+l/2,+w/2,h]]
) [
  fl_name(value="RJ45"),
  fl_bb_corners(value=bbox),
  fl_size(value=bbox[1]-bbox[0]),
  fl_director(value=+FL_X),fl_rotor(value=-FL_Z),
];

FL_ETHER_DICT = [
  FL_ETHER_RJ45,
];

use     <ether.scad>
