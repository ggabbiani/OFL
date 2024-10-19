/*
 * Quaternions library
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

/*!
 * Quaternion constructor from an angle «theta» around «vector»
 */
function fl_Quaternion(vector,theta=0) =
  theta ?
    let(
      half      = theta / 2,
      cos_half  = cos(half),
      sin_half  = sin(half)
    ) [
      cos_half,vector.x*sin_half,vector.y*sin_half,vector.z*sin_half
    ]
  :  [0,vector.x,vector.y,vector.z]
  ;
