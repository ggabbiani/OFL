/*
 * Base geometry test.
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

include <../../foundation/base_geo.scad>

let(
  vector  = [1.2,13,-4.5],
  versor  = fl_versor(vector)
) assert(norm(versor)==1);

let(
  a = [1.3,-5.2,10],
  b = +5 * a
) assert(fl_isParallel(a,b));

let(
  a = [1.3,-5.2,10],
  b = -5 * a
) assert(fl_isParallel(a,b,exact=false));

let(
  a = [1.3,-5.2,10],
  b = [-5*a.z,-5*a.y,+2*a.z]
) assert(fl_isParallel(a,b,exact=false)==false);

let(
  a = [1,0,0],
  b = [2,0,0]
) assert(fl_isParallel(a,b));
