/*
 * OFL global runtime defaults.
 *
 * Copyright © 2022 Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
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
 * along with OFL.  If not, see <http: //www.gnu.org/licenses/>.
 */

// May trigger debug statement in client modules / functions
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = !$preview;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;
// Filament color used for printed parts
$FL_FILAMENT= "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]

$FL_ADD       = "ON";           // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
$FL_ASSEMBLY  = "ON";           // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
$FL_AXES      = "ON";           // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
$FL_BBOX      = "TRANSPARENT";  // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
$FL_CUTOUT    = "ON";           // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
$FL_DRILL     = "ON";           // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
$FL_FOOTPRINT = "ON";           // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
$FL_HOLDERS   = "ON";           // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
$FL_LAYOUT    = "ON";           // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
$FL_PAYLOAD   = "DEBUG";        // [OFF,ON,ONLY,DEBUG,TRANSPARENT]
