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

// contructor for debug context parameter
function fl_parm_Debug(
  labels  = false,
  symbols = false
) = [labels,symbols];

// When true fl_assert() is enabled
function fl_asserts() = is_undef($fl_asserts) ? false : assert(is_bool($fl_asserts)) $fl_asserts;

// When true debug statements are turned on
function fl_debug() = is_undef($fl_debug) ? false : assert(is_bool($fl_debug)) $fl_debug;

// Default color for printable items (i.e. artifacts)
function fl_filament() = is_undef($fl_filament) ? "DodgerBlue" : assert(is_string($fl_filament)) $fl_filament;

// When true debug labels are turned on
function fl_parm_labels(debug) = is_undef(debug) ? false : assert(is_bool(debug[0])) debug[0];

// When true debug symbols are turned on
function fl_parm_symbols(debug) = is_undef(debug) ? false : assert(is_bool(debug[1])) debug[1];
