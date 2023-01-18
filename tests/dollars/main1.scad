/*
 * Empty file description
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <client1.scad>

$custom="main1";

module main1() {
  echo(str("main1.scad: ",$custom));
}

root();
client1();
main1();