/*!
 * UNPORTABLE DEFINITIONS, DON'T USE TOGETHER OTHER LIBRARIES INCLUDES.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
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
