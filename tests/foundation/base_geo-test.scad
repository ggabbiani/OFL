/*
 * Base geometry test.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../lib/OFL/foundation/base_geo.scad>

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
