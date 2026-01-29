/*
 * IECFusedInlet figure.
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
 *
 * Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <../../../lib/OFL/vitamins/iec.scad>

IEC = "FL_IEC_FUSED_INLET"; // [FL_IEC_FUSED_INLET,FL_IEC_FUSED_INLET2,FL_IEC_320_C14_SWITCHED_FUSED_INLET,FL_IEC_INLET,FL_IEC_INLET_ATX,FL_IEC_INLET_ATX2,FL_IEC_YUNPEN,FL_IEC_OUTLET]

/* [Hidden] */

iec = fl_switch(IEC, [
  ["FL_IEC_FUSED_INLET",                    FL_IEC_FUSED_INLET],
  ["FL_IEC_FUSED_INLET2",                   FL_IEC_FUSED_INLET2],
  ["FL_IEC_320_C14_SWITCHED_FUSED_INLET",   FL_IEC_320_C14_SWITCHED_FUSED_INLET],
  ["FL_IEC_INLET",                          FL_IEC_INLET],
  ["FL_IEC_INLET_ATX",                      FL_IEC_INLET_ATX],
  ["FL_IEC_INLET_ATX2",                     FL_IEC_INLET_ATX2],
  ["FL_IEC_YUNPEN",                         FL_IEC_YUNPEN],
  ["FL_IEC_OUTLET",                         FL_IEC_OUTLET]
]);
fl_iec(FL_ADD,iec);
