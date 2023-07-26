/*!
 * key/values
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

/*!
 * Optional getter, no error when property is not found.
 *
 * Return «default» when «type» is undef or empty, or when «key» is not found
 *
 * | type    | key     | default | key found | result    | semantic |
 * | ------- | ------- | ------- | --------- | --------- | -------- |
 * | undef   | *       | *       | *         | default   | GETTER   |
 * | defined | defined | *       | false     | default   | GETTER   |
 * | defined | defined | *       | true      | value     | GETTER   |
 *
 * **ERROR** in all the other cases
 */
function fl_optional(type,key,default) =
  type==undef ? default : let(r=search([key],type)) r!=[[]] ? type[r[0]][1] : default;

/*!
 * Mandatory property getter with default value when not found
 *
 * Never return undef.
 *
 * | type    | key     | default | key found | result    | semantic |
 * | ------- | ------- | ------- | --------- | --------- | -------- |
 * | defined | defined | *       | true      | value     | GETTER   |
 * | defined | defined | defined | false     | default   | GETTER   |
 *
 * **ERROR** in all the other cases
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
 * - type/key{/default} ↦ returns the property value (error if property not found)
 * - key{/value}        ↦ returns the property [key,value] (acts as a property constructor)
 *
 * It concentrates property key definition reducing possible mismatch when
 * referring to property key in the more usual getter/setter function pair.
 *
 * This getter never return undef.
 *
 * | type    | key     | default | key found | result      | semantic |
 * | ------- | ------- | ------- | --------- | ----------- | -------- |
 * | undef   | defined | undef   | *         | [key,value] |  SETTER  |
 * | defined | defined | *       | true      | value       |  GETTER  |
 * | defined | defined | defined | false     | default     |  GETTER  |
 *
 * **ERROR** in all the other cases
 */
function fl_property(type,key,value,default)  =
  assert(key!=undef)
  type!=undef
  ? fl_get(type,key,default)              // property getter
  : assert(default==undef)  [key,value];  // property constructor

/*!
 * 'bipolar' optional property helper:
 *
 * - type/key{/default} ↦ returns the property value (no error if property not found)
 * - key{/value}        ↦ returns the property [key,value] (acts as a property constructor)
 *
 * This getter returns 'undef' when the key is not found and no default is passed.
 *
 * | type    | key     | default | key found | result      | semantic |
 * | ------- | ------- | ------- | --------- | ----------- | -------- |
 * | undef   | defined | undef   | *         | [key,value] | SETTER   |
 * | defined | defined | *       | false     | default     | GETTER   |
 * | defined | defined | *       | true      | value       | GETTER   |
 *
 * **ERROR** in all the other cases
 */
function fl_optProperty(type,key,value,default) =
  type!=undef ? fl_optional(type,key,default) : fl_property(key=key,value=value);

