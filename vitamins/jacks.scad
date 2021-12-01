/*
 * NopACADlib Jack definitions wrapper.
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

//*****************************************************************************
// Jack keys
// function fl_jack_???KV(value)             = fl_kv("jack/???",value);

//*****************************************************************************
// Jack getters
// function fl_jack_type(type)              = fl_get(type,fl_jack_???KV()); 

//*****************************************************************************
// Jack constructors
function fl_jack_new(utype) = let(
  // following data definitions taken from NopSCADlib jack() module
  l = 12,
  w = 7,
  h = 6,
  ch = 2.5,
  // calculated bounding box corners
  bbox      = [[-l/2,-w/2,0],[+l/2+ch,+w/2,h]]
) [
  fl_bb_corners(value=bbox),
  fl_director(value=+FL_X),fl_rotor(value=+FL_Y),
];

FL_JACK = fl_jack_new();

FL_JACK_DICT = [
  FL_JACK,
];

use     <jack.scad>
