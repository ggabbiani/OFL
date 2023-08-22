/*!
 * Base geometry.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

function fl_versor(v) = assert(is_list(v),v) v / norm(v);

function fl_isParallel(a,b,exact=true) = let(prod = fl_versor(a)*fl_versor(b)) (exact ? prod : abs(prod))==1;

function fl_isOrthogonal(a,b) = a*b==0;
