/*
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

X = FL_X;
Y = FL_Y;
Z = FL_Z;
O = FL_O;
I = FL_I;

NIL   = FL_NIL;
NIL2  = FL_NIL2;

function T(t)       = fl_T(t);
function S(s)       = fl_S(s);
function Rx(alpha)  = fl_Rx(alpha);
function Ry(alpha)  = fl_Ry(alpha);
function Rz(alpha)  = fl_Rz(alpha);
function Rxyz(alpha)= fl_Rxyz(alpha);
function R(u,theta) = fl_R(u,theta);

function X(x) = x*X;
function Y(y) = y*Y;
function Z(z) = z*Z;
