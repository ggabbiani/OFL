/*
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

/*!
 * Due to a bug [Import paths not relative to the file with the import. #217](https://github.com/openscad/openscad/issues/217#issuecomment-136832010)
 * relative path mechanism doesn't work properly for 'included' modules. The
 * workaround is to use a convenient __undocumented__ module placed on top of
 * the module hierarchy.
 */

module __dxf__(file,layer) {
  import(file=file,layer=layer);
}
