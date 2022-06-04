/*
 * Base tracing helpers.
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

include <TOUL.scad> // TOUL       : The OpenScad Usefull Library

/**
 * trace helper function.
 *
 * See module fl_trace().
 */
function fl_trace(msg,result,always=false) = let(
  call_chain  = strcat([for (i=[$parent_modules-1:-1:0]) parent_module(i)],"->"),
  mdepth      = $parent_modules
) assert(msg)
  (always||(!is_undef($FL_TRACES) && ($FL_TRACES==-1||$FL_TRACES>=mdepth)))
  ? echo(mdepth,str(call_chain,": ",msg,"==",result)) result
  : result;

/**
 * trace helper module.
 *
 * prints «msg» prefixed by its call order either if «always» is true or if its
 * current call order is ≤ $FL_TRACES.
 *
 * Used $special variables:
 *  $FL_TRACE affects trace messages according to its value:
 *    -2    - all traces disabled
 *    -1    - all traces enabled
 *    [0,∞) - traces with call order ≤ $FL_TRACES are enabled
 */
module fl_trace(
  // message to be printed
  msg,
  // optional value generally usable for printing a variable content
  value,
  // when true the trace is always printed
  always=false
) {
  mdepth      = $parent_modules-1;
  if (always||(!is_undef($FL_TRACES) && ($FL_TRACES==-1||$FL_TRACES>=mdepth)))
    let(
      call_chain  = strcat([for (i=[$parent_modules-1:-1:1]) parent_module(i)],"->")
    ) echo(mdepth,str(call_chain,": ",is_undef(value)?msg:str(msg,"==",value))) children();
  else
    children();
}
