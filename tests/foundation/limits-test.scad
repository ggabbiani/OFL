/*
 * Foundation test for 3d printing limits
 *
 * NOTE: this file is generated automatically from 'template-nogui.scad', any
 * change will be lost.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


include <../../lib/OFL/foundation/limits.scad>

// end of automatically generated code

for(limits=__FL_LIMITS__) {
  $fl_print_tech=limits[0];
  settings=limits[1];
  for(prop=settings) {
    // echo(prop=prop);
    name=prop[0];
    value=prop[1];
    // echo(str(name,"=",value));
    assert(value==fl_techLimit(name));
  }
}
