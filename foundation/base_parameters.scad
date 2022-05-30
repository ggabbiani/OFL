/*
 * Common parameter helpers
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

/**
 * debug setter
 */
function fl_parm_setDebug(labels=false,symbols=false) = [
  labels,
  symbols
];

/**
 * debug getter
 */
function fl_parm_getDebug(value,sub) = let(
  labels      = value[0],
  symbols     = value[1]
)   sub=="labels"   ? labels
  : sub=="symbols"  ? symbols
  : assert(false,str("Unknown sub parameter '",sub,"'")) false;

// $fl_asserts getter
function fl_asserts() = is_undef($fl_asserts) ? false : $fl_asserts;
