/*
 * Empty file description
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <root.scad>

module client2() {
  echo(str("client2.scad: ",$custom));
}

root();
client2();