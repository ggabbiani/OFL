/*
 * Created on Tue May 11 2021.
 *
 * Copyright © 2021 Giampiero Gabbiani.
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

include <TOUL.scad>

// May trigger debug statement in client modules / functions
$FL_DEBUG   = false;
// When true, disables PREVIEW corrections like FL_NIL
$FL_RENDER  = false;
// When true, unsafe definitions are not allowed
$FL_SAFE    = true;
// When true, fl_trace() mesages are turned on
$FL_TRACE   = false;

// simple workaround for the z-fighting problem during preview
FL_NIL = ($preview && !$FL_RENDER ? 0.01 : 0);

// PER SURFACE distance in case of movable parts to be doubled when applied to a diameter
fl_MVgauge  = 0.6;

// PER SURFACE distance in case of jointed parts to be doubled when applied to a diameter
fl_JNgauge  = fl_MVgauge/4;

// Recommended tolerance for FDM as stated in https://www.3dhubs.com/knowledge-base/how-design-snap-fit-joints-3d-printing/
fl_FDMtolerance = 0.5;

FL_X = [1,0,0];
FL_Y = [0,1,0];
FL_Z = [0,0,1];
FL_O = [0,0,0];

// identity matrix in homogeneous coordinates
FL_I=[
  [1,0,0,0],
  [0,1,0,0],
  [0,0,1,0],
  [0,0,0,1],
];

// translation matrix in homogeneous coordinates
function fl_T(t) = is_list(t)
  ? [
      [1,0,0, t.x ],
      [0,1,0, t.y ],
      [0,0,1, t.z ],
      [0,0,0, 1   ]
    ]
  : fl_T([t,t,t]);

// scale matrix in homogeneous coordinates
function fl_S(s) = is_list(s) 
  ? [
      [s.x, 0,    0,    0 ],
      [0,   s.y,  0,    0 ],
      [0,   0,    s.z,  0 ],
      [0,   0,    0,    1 ]
    ]
  : fl_S([s,s,s]);

// rotation around FL_X matrix
function fl_Rx(theta) = [
  [1,           0,            0,           0],
  [0,           cos(theta),   -sin(theta), 0],
  [0,           sin(theta),   cos(theta),  0],
  [0,           0,            0,           1]
];

// rotation around FL_Y matrix
function fl_Ry(theta) = [
  [cos(theta),  0,            sin(theta),  0],
  [0,           1,            0,           0],
  [-sin(theta), 0,            cos(theta),  0],
  [0,           0,            0,           1]
];

// rotation around FL_Z matrix
function fl_Rz(theta) = [
  [cos(theta),  -sin(theta),  0,  0],
  [sin(theta),  cos(theta),   0,  0],
  [0,           0,            1,  0],
  [0,           0,            0,  1]
];

function fl_R(angle) = fl_Rz(angle.z) * fl_Ry(angle.y) * fl_Rx(angle.x);

function fl_X(x) = [x,0,0];
function fl_Y(y) = [0,y,0];
function fl_Z(z) = [0,0,z];

function fl_is_set(flag,list) = search([flag],list)!=[[]];
// for conditional setup of a list use something like:
// draw  = [
//   if (SW_NO_BREAKOUT) USB_NO_BREAKOUT,
//   if (SW_BBOX)        USB_ADD_BBOX,
//   if (SW_FIXING_BASE) USB_ADD_FIXING_BASE,
//   if (SW_ADD_POINTER) USB_ADD_POINTER,
// ];

FL_ADD        = "FL_ADD adds shapes to scene.";
FL_FOOTPRINT  = "FL_FOOTPRINT adds a footprint to scene, usually a simplified FL_ADD.";
FL_DRILL      = "FL_DRILL layout of predefined drill shapes (like holes with predefined screw diameter).";
FL_LAYOUT     = "FL_LAYOUT layout of user passed accessories (like alternative screws).";
FL_ASSEMBLY   = "FL_ASSEMBLY layout of predefined auxiliary shapes (like predefined screws).";
FL_AXES       = "FL_AXES unconditional draw of local reference fl_axes.";
FL_BBOX       = "FL_BBOX adds a bounding box containing the object.";
FL_CUTOUT     = "FL_CUTOUT layout of predefined cutout shapes (+FL_X,-FL_X,+FL_Y,-FL_Y,+FL_Z,-FL_Z).";
FL_HOLDERS    = "FL_HOLDERS adds vitamine holders to the scene. **DEPRECATED**";
FL_PAYLOAD    = "FL_PAYLOAD adds a box representing the payload of the shape";
FL_DEPRECATED = "FL_DEPRECATED is a test verb. **DEPRECATED**";
FL_OBSOLETE   = "FL_OBSOLETE is a test verb. **OBSOLETE**";

// generic property getter with default value when not found 
function fl_get(type,property,default) = 
  assert(property!=undef,"Undefined property")
  assert(type!=undef,str("Undefined object for property '",property,"'."))
  let(index_list=search([property],type))
  // echo(index_list=index_list)
  index_list != [[]] 
  ?  type[index_list[0]][1] 
  : assert(default!=undef,str("Property '",property,"' not found on type:",type)) default;

//*****************************************************************************
// Standard getters
function fl_name(type)          = fl_get(type,"name"); 
function fl_description(type)   = fl_get(type,"description"); 
function fl_size(type)          = fl_get(type,"size");
function fl_width(type)         = fl_size(type).x;
function fl_height(type)        = fl_size(type).y;
function fl_thickness(type)     = fl_size(type).z;
function fl_connectors(type)    = fl_get(type,"connectors");
function fl_product(type)       = fl_get(type,"product");
function fl_bbCorners(type)     = fl_get(type,"bounding corners");

//*****************************************************************************
// type traits
function fl_has(type,property,check) =
  assert(is_string(property))
  assert(is_list(type))
  assert(is_function(check))
  let(i=search([property],type)) 
  i != [[]] ? assert(len(type[i[0]])==2,"Malformed type") check(type[i[0]][1]) : false;

function fl_has_size(type) = fl_has(type,"size",function(value) is_num(value));
function fl_hasBbCorners(type)  = fl_has(type,"bounding corners",function(value) is_list(value) && len(value)==2);

module fl_parse(verbs) {
  for($verb=is_list(verbs) ? verbs : [verbs]) {
    tokens = split($verb);
    fl_trace(tokens[0]);
    if (fl_is_set("**DEPRECATED**",tokens)) {
      fl_trace(str("***WARN*** ", tokens[0], " is marked as DEPRECATED and will be removed in future version!"),always=true);
    } else if (fl_is_set("**OBSOLETE**",tokens)) {
      assert(false,str(tokens[0], " is marked as OBSOLETE!"));
    }
    children();
  }
}

function fl_trace(a1,a2,n=0,always=false) =
  a2!=undef ? str(strcat([for (i=[$parent_modules-1:-1:n]) parent_module(i)],"->"),": ",str(a1,"==",a2))
  : str(strcat([for (i=[$parent_modules-1:-1:n]) parent_module(i)],"->"),": ",a1);

module fl_trace(a1,a2,n=1,always=false) {
  assert(a1!=undef);
  if ($FL_TRACE||always) echo(fl_trace(a1,a2,n,always));
}

/*
 * Applies a Rotation Matrix for aligning fl_vector A (from) to fl_vector B (to).
 *
 * Taken from 
 * [How to Calculate a Rotation Matrix to Align Vector A to Vector B in 3D](https://gist.github.com/kevinmoran/b45980723e53edeb8a5a43c49f134724)
 */
function fl_align(from,to) =
  assert(is_list(from))
  assert(is_list(to))
  assert(norm(from)>0)
  assert(norm(to)>0)

  let(u1 = from / norm(from),u2 = to / norm(to))
  u1==u2 ? FL_I : 
  u1==-u2 ? fl_S(-1) : // in this case the algorithm would fails, so we use a simpler way
  let(
    axis  = cross( u1, u2 ), // cross product == prodotto vettoriale: normale al piano [u1,u2] 
    cosA  = u1 * u2, // dot product == prodotto scalare: Σa[i]*b[i] nullo se u1 e u2 sono ortogonali
    k     = 1.0 / (1.0 + cosA)
  )
  [
        [(axis.x * axis.x * k) + cosA, (axis.y * axis.x * k) - axis.z, (axis.z * axis.x * k) + axis.y,0],
        [(axis.x * axis.y * k) + axis.z,(axis.y * axis.y * k) + cosA,(axis.z * axis.y * k) - axis.x,  0],
        [(axis.x * axis.z * k) - axis.y,(axis.y * axis.z * k) + axis.x,(axis.z * axis.z * k) + cosA,  0],
        [0,     0,    0,    1]
  ];

module fl_align(from,to) {
  assert(is_list(from));
  assert(is_list(to));
  assert(norm(from)>0);
  assert(norm(to)>0);
  
  u1 = from / norm(from);
  u2 = to / norm(to);
  if (u1==u2)
    children();
  else if (u1==-u2) // in this case the algorithm would fails, so we use a simpler way
    multmatrix(fl_S(-1)) children();
  else {
    axis  = cross( u1, u2 ); // cross product == prodotto vettoriale: normale al piano [u1,u2] 
    cosA  = u1 * u2; // dot product == prodotto scalare: Σa[i]*b[i] nullo se u1 e u2 sono ortogonali
    k     = 1.0 / (1.0 + cosA);
    multmatrix(
      [
        [(axis.x * axis.x * k) + cosA, (axis.y * axis.x * k) - axis.z, (axis.z * axis.x * k) + axis.y,0],
        [(axis.x * axis.y * k) + axis.z,(axis.y * axis.y * k) + cosA,(axis.z * axis.y * k) - axis.x,  0],
        [(axis.x * axis.z * k) - axis.y,(axis.y * axis.z * k) + axis.x,(axis.z * axis.z * k) + cosA,  0],
        [0,     0,    0,    1]
      ])
      children();
  }
}

// Aligns children from u1 to u2 and move to position
module fl_overlap(u1,u2,position) {
  translate(position)
    fl_align(u1,u2)
      children();
}

// Draws a fl_vector [out|in]ward P
module fl_vector(P,outward=true,endpoint="arrow") { 
  assert(is_list(P));
  length  = norm(P);
  d       = length / 20;
  head_r  = 1.5 * d;

  if (norm(P)>0) {
    fl_align(FL_Z,P)
      color("grey") {
        if (outward)
          translate(fl_Z(length-head_r)) cylinder(r2=0,r1=head_r,h=head_r);
        else
          cylinder(r1=0,r2=head_r,h=head_r);
        if (outward)
          cylinder(d = d, h = length - head_r, $fn = 32);
        else
          translate(+fl_Z(head_r)) cylinder(d = d, h = length-head_r, $fn = 32);
      }
  }
}

function fl_versor(v) = v / norm(v);

// Draws a fl_versor facing point P
module fl_versor(P) {
  fl_vector(fl_versor(P));
}

module fl_axes(size=1,reverse=false) {
  sz  = is_list(size) 
      ? assert(size.x>=0 && size.y>=0 && size.z>=0) size 
      : assert(size>=0) [size,size,size];
  color("red")   fl_vector(sz.x*FL_X,reverse==undef || !reverse);
  color("green") fl_vector(sz.y*FL_Y,reverse==undef || !reverse);
  color("blue")  fl_vector(sz.z*FL_Z,reverse==undef || !reverse);
}

// general porpouse flags
FL_FLAG_DEBUG  = "OBSOLETE flag: enables debug mode";
FL_FLAG_AXES   = "OBSOLETE flag: adds local fl_axes during FL_ADD";

// general porpouse parameters
FL_PROP_FILAMENT_COLOR="string: color to be used for filament"; 

/* A do-nothing helper */
module fl_nop() {
  sphere(0);
}

// Static debug switch on DEBUG
module fl_color(color) {
  if (color==undef)
    if ($FL_DEBUG) #children(); else children();
  else
    color(color) fl_color() children();
}

function fl_parse_l(l,l1,def)              = (l != undef ? l : (l1!=undef ? l1 : def));
function fl_parse_radius(r,r1,d,d1,def)    = (r != undef ? r : (r1 != undef ? r1 : (d != undef ? d/2 : (d1!=undef ? d1/2:def))));
function fl_parse_diameter(r,r1,d,d1,def)  = (d != undef ? d : (d1 != undef ? d1 : (r != undef ? 2*r : (r1!=undef ? 2*r1:def))));

function fl_octant(
  type
  ,octant // 3d octant
  ,bbox   // bounding box corners
) = let(
  corner    = bbox!=undef ? bbox : fl_bbCorners(type),
  size      = assert(corner!=undef) corner[1] - corner[0],
  half_size = size / 2,
  delta     = [sign(octant.x) * half_size.x,sign(octant.y) * half_size.y,sign(octant.z) * half_size.z]
) fl_T(-corner[0]-half_size+delta);

function fl_quadrant(
  type
  ,quadrant // 2d quadrant
  ,bbox     // bounding box corners
) = let(
  corner    = bbox!=undef ? bbox : fl_bbCorners(type),
  c0        = assert(corner!=undef) 
              let(c=corner[0]) [c.x,c.y,c.z==undef?0:c.z], 
  c1        = let(c=corner[1]) [c.x,c.y,c.z==undef?0:c.z]
) fl_octant(octant=[quadrant.x,quadrant.y,0],bbox=[c0,c1]);

module fl_place(
  type
  ,octant   // 3d octant
  ,quadrant // 2d quadrant
  ,bbox     // bounding box corners
) {
  assert((octant!=undef && quadrant==undef) || (octant==undef && quadrant!=undef));
  M = octant!=undef ? fl_octant(type,octant,bbox) : fl_quadrant(type,quadrant,bbox);
  multmatrix(M) children();
}

module fl_placeIf(
  condition // when true placement is ignored
  ,type
  ,octant   // 3d octant
  ,quadrant // 2d quadrant
  ,bbox     // bounding box corners
) {
  if (condition) fl_place(type,octant,quadrant,bbox) children();
  else children();
}

/*
 * returns the fl_direction matrix from prototype
 */
function fl_direction(
  proto       // prototype for native director and rotor
  ,direction  // desired direction [director,rotation around director]
) = let(
  def_axis  = fl_get(proto,"default director"),
  def_rotor = fl_get(proto,"default rotor"),
  axis      = fl_versor(direction[0]),
  alpha     = direction[1],
  rotor     = fl_transform(fl_align(def_axis,axis),def_rotor),
  placement = [fl_transform(fl_R(alpha*axis),rotor),axis],
  M         = plane_align(def_rotor,def_axis,placement[0],placement[1])
) assert(alpha % 90 == 0,"Rotation around FL_Z must be a multiple of 90°")
  assert(axis==+FL_X || axis==-FL_X || axis==+FL_Y || axis==-FL_Y || axis==+FL_Z || axis==-FL_Z)
  M;


/* true when n is multiple of m */
function fl_isMultiple(n,m) = (n % m == 0);

/* true when n is even */
function fl_isEven(n) = fl_isMultiple(n,2);

/* true when n is odd */
function fl_isOdd(n) = !fl_isEven(n);

// transforms 3D to 2D coords
function fl_2(v) =
  assert(len(v)>1)
  [v.x,v.y];

// transforms homogeneous to 3D coords
function fl_3(v)  =
  assert(len(v)>2)
  len(v)==3 ? v : [v.x,v.y,v.z] / v[3];

// transforms 3D coords to homogeneous
function fl_4(v)  = 
  assert(len(v)>2)
  len(v)==3 ? [v.x,v.y,v.z,1] : v / v[3];

// Trasforma un vettore secondo la matrice M passata
// NOTE: result is in 3d format
function fl_transform(
  M   // 4x4 transformation matrix
  ,v  // fl_vector (in homogeneous or 3d format)
) =
  assert(len(M)==4 && len(M[0])==4,"Only 4x4 matrix are allowed.")
  fl_3(M * fl_4(v));

//**** math utils *************************************************************

function fl_accum(v)          = [for(p=v) 1]*v;
function fl_sub(list,from,to) = [for(i=from;i<to;i=i+1) list[i]];
