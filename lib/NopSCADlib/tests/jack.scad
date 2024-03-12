//
// NopSCADlib Copyright Chris Palmer 2018
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
include <../utils/core/core.scad>

use <../vitamins/jack.scad>

module jacks() {
    translate([0, 0])
        jack_4mm_plastic("black",3, grey(20));

    translate([20, 0])
        jack_4mm("blue",3, "royalblue");

    translate([40, 0])
        jack_4mm_shielded("brown", 3, "sienna");

    translate([60, 0])
        post_4mm("red",3);

    translate([80, 0])
        power_jack(3);
}

if($preview)
    let($show_threads = true)
        jacks();
