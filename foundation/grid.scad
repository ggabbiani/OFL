/*!
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <3d.scad>

function fl_grid_quad(
  //! bounding box relative grid origin
  origin=[0,0],
  //! 2d deltas
  step,
  //! used for clipping the out of region points
  bbox,
  //! generator (default generator just returns its center resulting in a quad grid ... hence the name)
  generator=function(point,bbox) [point]
) = let(
  low   = bbox[0],
  high  = bbox[1],
  step  = is_num(step) ? [step,step] : step
) [
    for(y=[low.y+origin.y:step.y:high.y])
      for(x=[low.x+origin.x:step.x:high.x],p=generator([x,y],bbox))
        p
  ];

function fl_grid_hex(
  //! bounding box relative grid origin
  origin=[0,0],
  //! scalar radial step
  r_step,
  //! used for clipping the out of region points
  bbox
) = assert(is_num(r_step))
  let(
    edges = 6,
    size  = let(bb = fl_bb_ipoly(r=r_step,n=edges)) bb[1]-bb[0],
    // hex generator
    generator = function(point,bbox) let(
        center  = point,
        // builds points needed for a circle given «center» and «r»
        points  = fl_circle(center=center,r=r_step,$fn=edges)
        // FIXME: eliminate double points algorithmically generated in hex mode
        // TODO: predictive point clipping (but something about children radius must be passed along)
        // clipped = [for(p=points) if (p.x>bbox[0].x && p.y>bbox[0].y && p.x<bbox[1].x && p.y<bbox[1].y) p]
      )
      // echo(points=points)
      echo(center=center) concat([center],points)
  )
  fl_grid_quad(origin,size,bbox,generator);

module fl_grid_layout(
  //! grid origin relative to bounding box
  origin=[0,0],
  //! 2d deltas for quad grid
  step,
  //! scalar radial step for hex grid
  r_step,
  //! used for clipping the out of region points
  bbox,
  clip=true
) {

  module grid() {
    for(p=points)
      translate(p)
        children();
  }

  assert(fl_XOR(step!=undef,r_step!=undef));
  points  = step!=undef
          ? fl_grid_quad(origin,step,bbox)
          : fl_grid_hex(origin,r_step,bbox);
  fl_trace("points",points);
  if (clip)
    intersection() {
      grid() children();
      fl_bb_add(bbox,2d=true);
    }
  else
    grid()
      children();
}
