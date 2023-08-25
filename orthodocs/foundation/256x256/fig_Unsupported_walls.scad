include <OFL/library.scad>

T=1.5;
l=10;
$fl_technology=FL_TECH_FDM;
fl_cube(size=[l,l,T], octant=+X+Z);
#translate([0,0,T])
  fl_cube(size=[l,fl_techLimit(FL_LIMIT_SWALLS),l-T],octant=+X+Z);
