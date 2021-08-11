/*
 * Created on Fri Jul 16 2021.
 *
 * Copyright © 2021 Giampiero Gabbiani.
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

include <defs.scad>

$fn       = 50;           // [3:50]
$FL_TRACE    = false;
$FL_RENDER   = false;
$FL_DEBUG    = false;

/* [Hidden] */

module __test__() {
  size    = [10.41,2.25];
  dio_pts = [[0,0],[1,0],[1,1.1/size.y],[1.15/size.x,1.1/size.y],[1.15/size.x,1],[0,1],[0,0]];
  pts     = dio_import(dio_pts,size);
  fl_trace("pts",pts);
  %polygon(points=pts);
}

// FL_Y invert and scale to size from draw.io coords
// Draw.io store geometries in the domain [0..1]
// So the final size is just a scale operation.
// Expressing an actual size in the span [0..1] is
// just a matter of dividing the actual size for the
// global FL_X or FL_Y length.
function dio_import(points,size,center=false) =
  assert(points!=undef && is_list(points))
  assert(size!=undef && is_list(size))
  let(
    M = [
      [size.x, 0,       (center ? -size.x/2 : 0)  ],
      [0,     -size.y,  (center ? +size.y/2 : 0)  ],
      [0,      0,       1                         ]
    ]
  )
  [for(p=points)  let(r=M * [p.x,p.y,1]) [r.x,r.y] ];

  __test__();
