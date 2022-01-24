/*
 * Copyright © 2021 Giampiero Gabbiani (giampiero@gabbiani.org)
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
 * along with OFL.  If not, see <http: //www.gnu.org/licenses/>.
 */

include <layout.scad>

function fl_grid_quad(
  // bounding box relative grid origin
  origin=[0,0],
  // 2d deltas
  step,
  // used for clipping the out of region points
  bbox,
  // generator (default generator just returns its center resulting in a quad grid ... hence the name)
  generator=function(x,y,bbox) [[x,y]]
) = let(
  low   = bbox[0],
  high  = bbox[1],
  step  = is_num(step) ? [step,step] : step
) [
    for(y=[low.y+origin.y:step.y:high.y]) [
      for(x=[low.x+origin.x:step.x:high.x])
        generator(x,y,bbox)
    ]
  ];

function fl_grid_hex(
  // bounding box relative grid origin
  origin=[0,0],
  // scalar radial step
  r_step,
  // used for clipping the out of region points
  bbox
) = assert(is_num(r_step))
  let(
    edges = 6,
    size  = let(bb = fl_bb_ipoly(r=r_step,n=edges)) bb[1]-bb[0],
    // hex generator
    generator = function(x,y,bbox) let(
        center  = [x,y],
        // builds points needed for a circle given «center» and «r»
        points  = fl_circle(center=center,r=r_step,$fn=edges),
        clipped = [for(p=points) if (p.x>bbox[0].x && p.y>bbox[0].y && p.x<bbox[1].x && p.y<bbox[1].y) p]
      ) concat([center],clipped)
  ) fl_grid_quad(origin,size,bbox,generator);

module fl_grid_layout(
  // grid origin relative to bounding box
  origin=[0,0],
  // 2d deltas for quad grid
  step,
  // scalar radial step for hex grid
  r_step,
  // used for clipping the out of region points
  bbox,
  clip=true
) {

  module grid() {
    union() for(row=points,set=row,p=set)
      translate(p)
        children();
  }

  // echo($FL_TRACE=$FL_TRACE);
  assert(fl_XOR(step!=undef,r_step!=undef));
  // fl_trace("$id",$id);
  // fl_trace("origin",origin);
  // fl_trace("step",step);
  // fl_trace("r_step",r_step);
  // fl_trace("bbox",bbox);
  points  = step!=undef
          ? fl_grid_quad(origin,step,bbox)
          : fl_grid_hex(origin,r_step,bbox);
  if (clip)
    intersection() {
      grid() children();
      fl_bb_add(bbox,2d=true);
    }
  else
    grid()
      children();
}
