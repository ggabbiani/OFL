/*
 * Empty file description
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

// include <defaults.scad>
include <lib.scad>

$custom = "CUSTOM";
$fa     = 999;

// echo($fa=$fa);
// echo("main ",$custom);
main();

module main() {
  test();
  // test($custom="Pluto",$fa=666);
}