//
// NopSCADlib Copyright Chris Palmer 2020
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// This file is part of NopSCADlib.
//
// NopSCADlib is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of
// the License, or (at your option) any later version.
//
// NopSCADlib is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with NopSCADlib.
// If not, see <https://www.gnu.org/licenses/>.
//

//
//! Shaft couplings
//

//                                   L   D        d1   d2 flex?
SC_5x8_rigid  = [ "SC_5x8_rigid",    25, 12.5,    5,   8, false ];
SC_6x8_flex   = [ "SC_6x8_flex",     25, 19,      6,   8, true ];
shaft_couplings = [SC_5x8_rigid, SC_6x8_flex];

use <shaft_coupling.scad>
