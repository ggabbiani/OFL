include <../foundation/2d-engine.scad>
include <../foundation/limits.scad>
include <../vitamins/magnets.scad>
include <../vitamins/knurl_nuts.scad>

$fn=100;
e=[15,19];
h=30;
// printing technology
$fl_print_tech  = "Fused deposition modeling";  // [Selective Laser sintering,Fused deposition modeling,Stereo lithography,Material jetting,Binder jetting,Direct metal Laser sintering]
// Default color for printable items (i.e. artifacts)
$fl_filament  = "DodgerBlue"; // [DodgerBlue,Blue,OrangeRed,SteelBlue]
VIEW_MODE="FULL"; // [FULL,PARTIAL,PRINT ME!]

// [hidden]

clearance = fl_techLimit(FL_LIMIT_CLEARANCE)/2;

magnet  = FL_MAG_M3_CS_D10x2;
// magnet  = FL_MAG_M3_CS_D10x5;
screw   = fl_screw(magnet);
mag_sz  = fl_bb_size(magnet);
T       = mag_sz.z+clearance;
emi_d   = mag_sz.x+2;
knut    = FL_KNUT_M3x4x5;
echo(str("emi_d/2=",emi_d/2),str("knut thick=",fl_knut_thick(knut)));

t=[0,e.y/2,20];

  difference() {
    fl_color() {
      linear_extrude(height = h) {
        // elliptic arc
        fl_ellipticArc(e=e, angles = [0,90], thick =T);
        translate(fl_ellipseXY(e=e-T/2*[1,1],angle=0))
          fl_circle(r = T/2);
        // linear surface
        fl_square(size = [T,e.y-T], corners = [0,0,0,0],quadrant=+X+Y);
        fl_circle(r = T/2,quadrant=+X);
      }

      translate(t) {
        // emi-sphere for brass insert
        translate(X(T-NIL))
          fl_color()
            intersection() {
              fl_sphere(d=emi_d);
              fl_cube(size = [emi_d/2,emi_d,emi_d],octant=+X);
            }
      }
    }
    translate(t)
      fl_magnet([FL_FOOTPRINT,FL_LAYOUT],type=magnet,fp_gross=clearance,thick=emi_d/2,octant=-Z,direction=[-X,90])
        translate(-Z(mag_sz.z+clearance-NIL)) fl_cylinder(h=emi_d/2, d=2*fl_knut_r(knut)-1,octant=-Z);
  }


translate(t)
  fl_magnet(
    [FL_ADD,FL_ASSEMBLY,FL_LAYOUT],
    type=magnet,octant=-Z,direction=[-X,90],
    $FL_ADD       = VIEW_MODE=="FULL"?"ON":"OFF",
    $FL_ASSEMBLY  = VIEW_MODE=="FULL"?"ON":"OFF",
    $FL_LAYOUT    = VIEW_MODE!="PRINT ME!"?"ON":"OFF"
  ) translate(-Z(T))
    fl_knut(type=knut,octant=-Z,$FL_ADD=VIEW_MODE!="PRINT ME!"?"ON":"OFF");