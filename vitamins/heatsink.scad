
include <heatsinks.scad>
include <pcbs.scad>
use     <screw.scad>

include <../foundation/unsafe_defs.scad>
include <../foundation/incs.scad>
include <NopSCADlib/lib.scad>
include <NopSCADlib/vitamins/screws.scad>

/**
 * FL_LAYOUT,FL_ASSEMBLY children context:
 *   $normal (==-Z)
 */
module pimoroni(
  verbs       = FL_ADD, // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  type,
  // FL_DRILL thickness in scalar form for -Z normal
  thick=0,
  direction,            // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  octant,               // when undef native positioning is used
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  axes  = fl_list_has(verbs,FL_AXES);
  verbs = fl_list_filter(verbs,FL_EXCLUDE_ANY,FL_AXES);

  bbox      = fl_bb_corners(type);
  size      = fl_bb_size(type);
  corner_r  = fl_get(type,"corner radius");
  bottom    = fl_get(type,"bottom part");
  top       = fl_get(type,"top part");
  rpi4      = FL_PCB_RPI4;
  pcb_t     = fl_PCB_thick(rpi4);
  screw     = fl_screw(type);
  dxf       = fl_get(type,"DXF model");

  bot_base_t    = fl_get(bottom,"layer 0 base thickness");
  bot_fluting_t = fl_get(bottom,"layer 0 fluting thickness");
  bot_holder_t  = fl_get(bottom,"layer 0 holders thickness");
  top_base_t    = fl_get(top,"layer 1 base thickness");
  top_fluting_t = fl_get(top,"layer 1 fluting thickness");
  top_holder_t  = fl_get(top,"layer 1 holders thickness");

  D         = direction ? fl_direction(proto=type,direction=direction)  : I;
  M         = octant    ? fl_octant(octant=octant,bbox=bbox)            : I;

  function bottom_sz() = [size.x,size.y,bot_base_t+bot_fluting_t+bot_holder_t];

  module do_add() {

    module bottom() {
      difference() {
        union() {
          // metal block
          translate(bbox[0]+[corner_r,corner_r])
            minkowski() {
              fl_cube(size=[size.x-2*corner_r, size.y-2*corner_r, bot_base_t]);
              fl_cylinder(r1=0, r2=corner_r, h=bot_fluting_t);
            }
          // add holders
          translate(+Z(bot_base_t+bot_fluting_t))
            linear_extrude(bot_holder_t)
              import(file=dxf,layer="0 holders");
        }
        // subtracts holes
        translate(-Z(NIL))
          linear_extrude(bot_base_t+bot_fluting_t+NIL2)
            import(file=dxf,layer="0 holes");
        // subtracts fluting
        translate(-Z(NIL))
          linear_extrude(bot_fluting_t)
            import(file=dxf,layer="0 fluting");
      }
      // let(
      //   sz  = bottom_sz(),
      //   bb  = [[-sz.x/2,0,0],[+sz.x/2,sz.y,sz.z]]
      // ) #fl_bb_add(bb);
    }

    module top() {
      bottom_sz = bottom_sz();
      translate(+Z(bottom_sz.z+pcb_t)) {
        difference() {
          union() {
            // add holders
            linear_extrude(top_holder_t)
              import(file=dxf,layer="0 holders");
            translate(+Z(top_holder_t)) {
              // metal block
              intersection() {
                translate(bbox[0]+[corner_r,corner_r])
                  minkowski() {
                    fl_cube(size=[size.x-2*corner_r, size.y-2*corner_r, top_base_t+top_fluting_t-2.3]);
                    fl_cylinder(r2=0, r1=corner_r, h=2.3);
                  }
                linear_extrude(top_base_t+top_fluting_t)
                  import(file=dxf,layer="1");
              }
            }
          }
          // subtracts fluting
          translate(+Z(top_holder_t)) {
            resize(newsize=[0,70+NIL,0])
              translate(Z(top_base_t+NIL))
                linear_extrude(top_fluting_t)
                  import(file=dxf,layer="1 fluting");
          }
          // subtracts GPIO
          fl_pcb([FL_ADD,FL_CUTOUT],rpi4,cut_label="GPIO",thick=5,cut_tolerance=2);
        }
      }
      // let(
      //   sz  = [size.x,size.y,top_base_t+top_fluting_t+top_holder_t],
      //   bb  = [[-sz.x/2,0,bottom_sz.z+pcb_t],[+sz.x/2,sz.y,bottom_sz.z+pcb_t+sz.z]]
      // ) #fl_bb_add(bb);
    }

    bottom();
    top();
  }

  module do_assembly() {
    t = bot_base_t+bot_holder_t;
    translate(+Z(bottom_sz().z+pcb_t))
      fl_pcb([FL_ADD,FL_ASSEMBLY],rpi4,thick=t,lay_direction=[]);
    do_layout() fl_color("DarkSlateGray")
        fl_screw(type=M2p5_cap_screw,len=10,direction=[$normal,0]);
  }

  module do_layout() {
    translate(+Z(bottom_sz().z+pcb_t))
      fl_pcb(FL_LAYOUT,rpi4,thick=bot_base_t+bot_holder_t)
        translate(-Z(pcb_t+bot_base_t+bot_holder_t)) 
          let($normal=-Z) children();
  }

  module do_drill() {
    do_layout()
      fl_cylinder(h=thick+bot_fluting_t,r=screw_radius(screw),octant=$normal);
  }

  multmatrix(D) {
    multmatrix(M) fl_parse(verbs) {
      if ($verb==FL_ADD) {
        fl_modifier($FL_ADD) do_add();

      } else if ($verb==FL_BBOX) {
        fl_modifier($FL_BBOX) fl_bb_add(bbox);

      } else if ($verb==FL_LAYOUT) {
        fl_modifier($FL_LAYOUT) do_layout()
          children();

      } else if ($verb==FL_FOOTPRINT) {
        fl_modifier($FL_FOOTPRINT) fl_bb_add(bbox);

      } else if ($verb==FL_ASSEMBLY) {
        fl_modifier($FL_ASSEMBLY) do_assembly();

      } else if ($verb==FL_DRILL) {
        fl_modifier($FL_DRILL) do_drill();

      } else {
        assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
      }
    }
    if (axes)
      fl_modifier($FL_AXES) fl_axes(size=1.2*size);
  }
}
