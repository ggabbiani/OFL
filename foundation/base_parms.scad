/*
 * This file contains function helpers for managing commons APIs parameters.
 *
 * Copyright © 2022 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'Raspberry Pi4' (RPI4) project.
 *
 * RPI4 is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * RPI4 is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with RPI4.  If not, see <http: //www.gnu.org/licenses/>.
 */

function fl_parm_debug()     = is_undef($debug)     ? false : $debug;
// desired direction [director,rotation], native direction when undef
function fl_parm_direction() = is_undef($direction) ? undef : $direction;
// when undef native positioning is used
function fl_parm_octant()    = is_undef($octant) ? undef : $octant;

