/*!
 * NON-PORTABLE DEFINITIONS, DON'T USE TOGETHER OTHER LIBRARIES INCLUDES.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <core.scad>

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

//! [Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping first octant
O0 = FL_O0;
//! [Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping octant 1
O1 = FL_O1;
//! [Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping octant 2
O2 = FL_O2;
//! [Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping octant 3
O3 = FL_O3;
//! [Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping octant 4
O4 = FL_O4;
//! [Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping octant 5
O5 = FL_O5;
//! [Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping octant 6
O6 = FL_O6;
//! [Gray code](https://en.wikipedia.org/wiki/Gray_code) enumeration mapping octant 7
O7 = FL_O7;

//! Roman enumeration of first quadrant
QI    = FL_QI;
//! Roman enumeration of quadrant 2
QII   = FL_QII;
//! Roman enumeration of quadrant 3
QIII  = FL_QIV;
//! Roman enumeration of quadrant 4
QIV   = FL_QIV;


//! see variable NIL
NIL     = FL_NIL;
//! see variable FL_2xNIL
2xNIL   = FL_2xNIL;

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
