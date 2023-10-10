/*!
 * Internal import facility.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * This library fix imported data relative to the OFL source root.
 */

module __import__(file, layer, center=false, dpi=96, convexity=1) {
  import(file=file,layer=layer,center=center,dpi=dpi,convexity=convexity);
}
