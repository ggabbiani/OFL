/*!
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

include <torus.scad>

module fl_sym_plug(verbs=[FL_ADD,FL_AXES],type=undef,size=0.5) {
  fl_symbol(verbs,type,size,"plug");
}

module fl_sym_socket(verbs=[FL_ADD,FL_AXES],type=undef,size=0.5) {
  fl_symbol(verbs,type,size,"socket");
}

/*!
 * provides the symbol required in its 'canonical' form:
 * - "plug": 'a piece that fits into a hole in order to close it'
 *          Its canonical form implies an orientation of the piece coherent
 *          with its insertion movement along +Z axis.
 * - "socket": 'a part of the body into which another part fits'
 *          Its canonical form implies an orientation of the piece coherent
 *          with its fitting movement along -Z axis.
 *
 * variable FL_LAYOUT is used for proper label orientation
 *
 * Children context:
 *
 * - $sym_ldir: [axis,angle]
 * - $sym_size: size in 3d format
 */
module fl_symbol(
  //! supported verbs: FL_ADD, FL_LAYOUT
  verbs   = FL_ADD,
  // really needed?
  type    = undef,
  //! default size given as a scalar
  size    = 0.5,
  //! currently "plug" or "socket"
  symbol
  ) {
  assert(verbs!=undef);

  sz      = size==undef ? [0.5,0.5,0.5] : is_list(size) ? size : [size,size,size];
  d1      = sz.x * 2/3;
  d2      = 0;
  overlap = sz.z / 5;
  h       = (sz.z + 2 * overlap) / 3;
  delta   = h - overlap;
  fl_trace("verbs",verbs);
  fl_trace("size",size);
  fl_trace("sz",sz);

  module context() {
    $sym_ldir = symbol=="plug" ? [+Z,0] : [-Z,180];
    $sym_size = sz;

    children();
  }

  module do_add() {
    fl_trace("d1",d1);
    fl_trace("d2",d2);

    fl_color("blue")
      resize(sz)
        translate(Z(symbol=="socket"?-h:0))
          for(i=symbol=="plug"?[0:+2]:[-2:0])
            translate(Z(i*delta))
              fl_cylinder(d1=d1,d2=d2,h=h);

    %fl_cube(octant=symbol=="plug"?-Z:+Z,size=[sz.x,sz.y,0.1]);
    let(sz=2*sz) {
      fl_color("red") translate(-X(sz.x/2)) fl_vector(X(sz.x),ratio=30);
      fl_color("green") translate(-Y(sz.y/2)) fl_vector(Y(sz.y),ratio=30);
    }
  }

  module do_layout() {
    context() children();
  }

  fl_manage(verbs) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout() children();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

/*!
 * this symbol uses as input a complete node context.
 *
 * The symbol is oriented according to the hole normal.
 */
module fl_sym_hole(
  //! supported verbs: FL_ADD
  verbs = FL_ADD
) {
  radius  = $hole_d/2;
  D       = fl_align(from=+Z,to=$hole_n);
  rotor   = fl_transform(D,+X);
  bbox    = [
    [-radius,-radius,-$hole_depth],
    [+radius,+radius,0]
  ];
  size    = bbox[1]-bbox[0];
  fl_trace("verbs",verbs);

  module do_add() {
    let(l=$hole_d*3/2,r=radius/20) {
      fl_color("red")
        translate(-X(l/2))
          fl_cylinder(r=r,h=l,direction=[+X,0]);
      fl_color("green")
        translate(-Y(l/2))
          fl_cylinder(r=r,h=l,direction=[+Y,0]);
      fl_color("black")
        for(z=[0,-$hole_depth])
          translate(Z(z))
            fl_torus(r=r,R=$hole_d/2);
    }
    if ($hole_depth)
      %fl_cylinder(d=$hole_d,h=$hole_depth,octant=-Z);
    fl_color("blue")
      fl_vector($hole_depth*Z);
  }

  fl_manage(verbs,direction=D) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}

/*!
 * display the direction change from a native coordinate system and a new
 * direction specification in [direction,rotation] format.
 */
module fl_sym_direction(
  //! supported verbs: FL_ADD
  verbs = FL_ADD,
  //! Native Coordinate System in [director axis, rotor axis] form
  ncs = [+FL_Z,+FL_X],
  /*!
   * direction in [Axis–angle representation](https://en.wikipedia.org/wiki/Axis%E2%80%93angle_representation)
   * in the format
   *
   *     [axis,rotation angle]
   */
  direction,
  //! default size given as a scalar
  size    = 0.5
) {
  assert(!fl_debug() || fl_tt_isDirectionRotation(direction));
  assert(!fl_debug() || ncs[0]*ncs[1]==0,str(ncs[0]," and ", ncs[1], " must be orthogonal"));

  // returns the angle between vector «a» and «b»
  function angle(a,b) = let(
    dot_prod = a*b
  ) dot_prod==0 ? 90 : acos(dot_prod/norm(a)/norm(b));

  function projectOnPlane(v,p) = let(
    u1 = fl_versor(p[0]),
    u2 = fl_versor(p[1])
  ) v*(u1+u2);

  angle   = direction[1];
  sz      = size==undef ? [0.5,0.5,0.5] : is_list(size) ? size : [size,size,size];
  ratio   = 20;
  d       = sz.x/ratio;
  head_r  = 1.5 * d;
  e       = [sz.x/2-0*head_r,sz.y/2-0*head_r];

  curr_director = let(versor=fl_versor(ncs[0])) abs(versor*sz)*versor;
  curr_rotor    = let(versor=fl_versor(ncs[1])) abs(versor*sz)*versor;
  curr_axis     = let(versor=fl_versor(cross(curr_director,curr_rotor))) abs(versor*sz)*versor;;

  dir_color     = fl_palette(curr_director);
  rot_color     = fl_palette(curr_rotor);
  axis_color    = fl_palette(cross(curr_director,curr_rotor));

  // invert matrix for original coordinate system representation after
  // the direction change
  m = matrix_invert(fl_align(ncs[0],direction[0]));

  // old director in the new coordinate system
  old_director  = fl_3(m * fl_4(curr_director));
  old_rotor     = fl_3(m * fl_4(curr_rotor));
  // old_axis      = cross(old_director,old_rotor);

  assert(!fl_debug() || (old_director*old_rotor<=FL_NIL),old_director*old_rotor);

  // Native Coordinate System DIRECTOR
  fl_color(dir_color) rotate(-angle,curr_director) {
    // current director
    fl_cylinder(h=norm(curr_director), d=d, octant=fl_versor(curr_director), direction=[curr_director,0]);

    // angle between [new director, old director]
    dir_rotation  = angle(curr_director,old_director);
    2d            = fl_circleXY(norm(curr_director),dir_rotation);

    // projection matrix the XY plane to the rotation plane of the DIRECTOR
    m = (fl_isParallel(old_director,curr_director,false))
      ? echo("PARALLEL") (fl_versor(old_director)==fl_versor(curr_director)
        ? echo("EQUAL") FL_I  // equality
        : echo("OPPOSITE") fl_R(curr_director,angle)*fl_Ry(180)*fl_Rx(90)*fl_Rz(90)*fl_Rx(90))  // opposite
      : echo("NOT PARALLEL") fl_planeAlign(X,[2d.x,2d.y,0],old_director,curr_director); // parallel

    // rotation angle visualization
    multmatrix(m) {
      r = norm(curr_director);

      if (dir_rotation!=0) let(a=dir_rotation/2)
        translate(fl_circleXY(r-d/2,a))
          rotate(90+a,Z)
            translate(-Z(d/4))
              linear_extrude(d/2)
                fl_ipoly(r=head_r,n=3);

      // rotation angle built on XY plane
      translate(-Z(d/4))
        linear_extrude(d/2)
          fl_arc(r=r,angles=[0,dir_rotation],thick=d);
    }

  }

  // let(r = norm(curr_director),dir_rotation  = angle(curr_director,old_director))
  // translate(-Z(d/4))
  //   linear_extrude(d/2)
  //     fl_arc(r=r,angles=[0,dir_rotation],thick=d);

  // Native Coordinate System ROTOR
  fl_color(rot_color) {
    fl_cylinder(h=norm(curr_rotor), d=d, octant=O, direction=[curr_rotor,0]);

    if (angle!=0) let(a=angle/2)
      translate(fl_ellipseXY(e-[d,d]/2,angle=-a>0?-a:360-a))
        rotate(angle<0?-90-a:90-a,Z)
          translate(-Z(d/4))
            linear_extrude(d/2)
              fl_ipoly(r=head_r,n=3,quadrant=O);

    // rotation angle visualization on [old_director,Z plane]
    fl_planeAlign(X,Y,ncs[1],cross(ncs[0],ncs[1]))
      // rotation angle built on [X,Y] plane
      translate(-Z(d/4))
        linear_extrude(d/2)
          fl_ellipticArc(e=e,angles=[0,-angle],thick=d);
  }
}
