/*!
 * key/values
 *
 * Copyright © 2021-2022 Giampiero Gabbiani (giampiero@gabbiani.org)
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

/*!
 * Optional getter, no error when property is not found.
 *
 * Return «default» when «props» is undef or empty, or when «key» is not found
 */
function fl_optional(props,key,default) =
  props==undef ? default : let(r=search([key],props)) r!=[[]] ? props[r[0]][1] : default;

/*!
 * Mandatory property getter with default value when not found
 *
 * Never return undef
 */
function fl_get(type,key,default) =
  assert(key!=undef)
  assert(type!=undef)
  let(index_list=search([key],type))
  index_list != [[]]
  ? type[index_list[0]][1]
  : assert(default!=undef,str("Key not found ***",key,"*** in ",type)) default;

/*!
 * 'bipolar' property helper:
 *
 * - type/key{/default} ↦ value       (mandatory property getter)
 * - key{/value}        ↦ [key,value] (property constructor)
 *
 * It concentrates property key definition reducing possible mismatch when
 * referring to property key in the more usual getter/setter function pair.
 */
function fl_property(type,key,value,default)  =
  assert(key!=undef)
  type!=undef
  ? fl_get(type,key,default)              // property getter
  : assert(default==undef)  [key,value];  // property constructor

/*!
 * 'bipolar' optional property helper:
 *
 * - type/key{/default} ↦ value       (optional property getter)
 * - key{/value}        ↦ [key,value] (property constructor)
 *
 * It concentrates property key definition reducing possible mismatch when
 * referring to property key in the more usual getter/setter function pair.
 */
function fl_optProperty(type,key,value,default) =
  type!=undef ? fl_optional(type,key,default) : fl_property(key=key,value=value);

