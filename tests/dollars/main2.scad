/*
 * Empty file description
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

use <client2.scad>

$custom="main2";

module main2() {
  echo(str("main2.scad: ",$custom));
}

root();
client2();
main2();