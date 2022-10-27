/*!
 * UNPORTABLE DEFINITIONS, DON'T USE TOGETHER OTHER LIBRARIES INCLUDES.
 *
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org).
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL).
 *
 * OFL is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * OFL is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with OFL.  If not, see <http://www.gnu.org/licenses/>.
 */

include <defs.scad>

//! see variable FL_X
X = FL_X;
//! see variable FL_Y
Y = FL_Y;
//! see variable FL_Z
Z = FL_Z;
//! see variable FL_O
O = FL_O;
//! see variable FL_I
I = FL_I;

//! see variable NIL
NIL   = FL_NIL;
//! see variable NIL2
NIL2  = FL_NIL2;

//! see fl_T()
function T(t)       = fl_T(t);
//! see fl_S()
function S(s)       = fl_S(s);
//! see fl_Rx()
function Rx(alpha)  = fl_Rx(alpha);
//! see fl_Ry()
function Ry(alpha)  = fl_Ry(alpha);
//! see fl_Rz()
function Rz(alpha)  = fl_Rz(alpha);
//! see fl_Rxyz()
function Rxyz(alpha)= fl_Rxyz(alpha);
//! see fl_R()
function R(u,theta) = fl_R(u,theta);

//! see fl_X()
function X(x) = x*X;
//! see fl_Y()
function Y(y) = y*Y;
//! see fl_Z()
function Z(z) = z*Z;
