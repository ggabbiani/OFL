/*
 * Empty file description
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <root.scad>

module client1() {
  echo(str("client1.scad: ",$custom));
}

root();
client1();