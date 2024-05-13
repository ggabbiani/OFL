/*
 * Base geometry test
 *
 * NOTE: this file is generated automatically from 'template-nogui.scad', any
 * change will be lost.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

// **** TEST_INCLUDES *********************************************************

include <../../lib/OFL/foundation/core.scad>

// **** TEST_PROLOGUE *********************************************************

fl_status();

// end of automatically generated code

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
