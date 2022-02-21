/*
 * PCB definition file.
 *
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
include <../foundation/grid.scad>
include <../foundation/hole.scad>
include <ethers.scad>
include <hdmi.scad>
include <jacks.scad>
include <pin_headers.scad>
include <screw.scad>
include <usbs.scad>

include <NopSCADlib/lib.scad>
include <NopSCADlib/vitamins/screws.scad>

// namespace for PCB engine
FL_PCB_NS  = "pcb";

//*****************************************************************************
// PCB properties
// when invoked by «type» parameter act as getters
// when invoked by «value» parameter act as property constructors
function fl_pcb_components(type,value)  = fl_property(type,"pcb/components",value);
function fl_pcb_radius(type,value)      = fl_property(type,"pcb/corners radius",value);
function fl_pcb_thick(type,value)       = fl_property(type,"pcb/thickness",value);
function fl_pcb_grid(type,value)        = fl_property(type,"pcb/grid",value);

//*****************************************************************************
// COMPONENTS
// TODO: move elsewhere

// Component context for children()
module fl_comp_Context(
  component // component definition: ["engine", [position], [[director],rotation], type, properties]
  ) {
  $engine     = component[0];
  $position   = component[1];
  $direction  = component[2];
  $director   = $direction[0];
  $rotation   = $direction[1];
  $type       = component[3];
  // properties
  properties  = component[4];
  $subtract   = fl_optional(properties,"comp/sub");
  $drift      = fl_optional(properties,"comp/drift",0);
  $color      = fl_optional(properties,"comp/color");
  $octant     = fl_optional(properties,"comp/octant");
  children();
}

// trigger children modules with component specifications context
module fl_comp_Specs(
  specs // component specifications: ["label",component]
  ) {

  $label      = specs[0];
  $component  = specs[1];
  fl_comp_Context($component) children();
}

// exact calculation of the resulting bounding box out of a list of component specifications
function fl_comp_BBox(spec_list) =
  assert(len(spec_list)>0,spec_list)
  let(
    // list of component bounding boxes translated by their position
    bboxes = [for(specs=spec_list)
      let(
        component   = specs[1],
        position    = component[1],
        direction   = component[2],
        type        = component[3],
        properties  = component[4],
        octant      = fl_optional(properties,"comp/octant"),
        // component bounding box
        bbox        = fl_bb_corners(type),
        // component direction matrix
        D           = fl_direction(type,direction),
        // translation by component position
        T           = T(position),
        // eventual component placement
        M           = octant ? fl_octant(octant=octant,bbox=bbox) : I,
        // transformed bounding box points
        points      = [for(corner=bbox) fl_transform(T*D*M,corner)],
        // build transformed bounding box from points
        Tbbox       = fl_bb_calc(pts=points)
      ) Tbbox
    ]
  ) fl_bb_calc(bboxes);

//*****************************************************************************

// base constructor
function fl_PCB(
    name,
    // bare (i.e. no payload) pcb's bounding box
    bare,
    // pcb thickness
    thick = 1.6,
    color  = "green",
    // corners radius
    radius=0,
    // Optional payload bounding box.
    // When passed it concurs in pcb's bounding box calculations
    payload,
    // each row represents a hole with the following format:
    // [[point],[normal], diameter, thickness]
    holes = [],
    // each row represent one component with the following format:
    // ["label", ["engine", [position], [[director],rotation] type],subtract]
    components,
    // grid specs
    grid,
    screw
  ) = let(
    comp_bbox = components ? fl_comp_BBox(components) : undef,
    pload = payload ? payload : comp_bbox,
    bbox  = pload ? [bare[0],[bare[1].x,bare[1].y,max(bare[1].z,pload[1].z)]]
                  : bare
  ) [
    fl_native(value=true),
    fl_name(value=name),
    fl_bb_corners(value=bbox),
    fl_director(value=+Z),fl_rotor(value=+X),
    fl_pcb_thick(value=thick),
    fl_pcb_radius(value=radius),
    if (pload) fl_payload(value=pload), // optional payload
    fl_holes(value=holes),
    fl_pcb_components(value=components),
    fl_material(value=color),
    fl_screw(value=screw),
    fl_pcb_grid(value=grid),
  ];

/**
 * PCB constructor from NopSCADlib.
 *
 * Only basic PCB attributes are imported from NopSCADlib types:
 *
 *  - sizing
 *  - material
 *  - holes
 *  - screw
 *  - grid
 *
 * NO COMPONENT IS CURRENTLY IMPORTED. STILL A WORK IN PROGRESS USE fl_pcb_adapter instead
 */
// TODO: fix and complete
function fl_pcb_import(nop,payload) = let(
    w         = max(pcb_width(nop),pcb_length(nop)),
    l         = min(pcb_width(nop),pcb_length(nop)),
    h         = 0,
    pcb_t     = pcb_thickness(nop),
    bbox      = [[-w/2,-l/2,0],[+w/2,+l/2,pcb_t+h]]
  ) fl_PCB(nop[1],bbox,pcb_t,pcb_colour(nop),pcb_radius(nop),payload,fl_pcb_NopHoles(nop),undef,pcb_grid(nop),pcb_screw(nop));

/**
 * Helper for conversion from NopSCADlib hole format to OFL.
 */
function fl_pcb_NopHoles(nop) = let(
  pcb_t     = pcb_thickness(nop),
  hole_d    = pcb_hole_d(nop),
  nop_holes = pcb_holes(nop),
  holes     = [
    for(h=nop_holes) [
      let(p=pcb_coord(nop, h)) [p.x,p.y,pcb_t],  // 3d point
      +FL_Z,  // plane normal
      hole_d, // hole diameter
      pcb_t   // hole depth
    ]
  ]
) holes;

FL_PCB_RPI4 = let(
  w       = 56,
  l       = 85,
  h       = 16,
  pcb_t   = 1.5,
  hole_d  = 2.7,
  bare    = [[-w/2,0,-pcb_t],[+w/2,l,0]],
  payload = [[bare[0].x,bare[0].y,0],[bare[1].x,bare[1].y,h]],
  holes   = [
    [[ 24.5, 3.5,  0 ], +FL_Z, hole_d, pcb_t],
    [[ 24.5, 61.5, 0 ], +FL_Z, hole_d, pcb_t],
    [[-24.5, 3.5,  0 ], +FL_Z, hole_d, pcb_t],
    [[-24.5, 61.5, 0 ], +FL_Z, hole_d, pcb_t],
  ],
  comps = [
    //["label",   ["engine",    [position],           [[director],rotation] type,           [engine specific parameters]]]
    ["POWER IN",  [FL_USB_NS,   [25.5,      11.2, 0], [+X,0  ],             FL_USB_TYPE_C  ,[["comp/drift",-1.3]]]],
    ["HDMI0",     [FL_HDMI_NS,  [25,        26,   0], [+X,0  ],             FL_HDMI_TYPE_D ,[["comp/drift",-1.26]]]],
    ["HDMI1",     [FL_HDMI_NS,  [25,        39.5, 0], [+X,0  ],             FL_HDMI_TYPE_D ,[["comp/drift",-1.26]]]],
    ["A/V",       [FL_JACK_NS,  [22,        54,   0], [+X,0  ],             FL_JACK        ]],
    ["USB2",      [FL_USB_NS,   [w/2-9,     79.5, 0], [+Y,0  ],             FL_USB_TYPE_Ax2,[["comp/drift",-3]]]],
    ["USB3",      [FL_USB_NS,   [w/2-27,    79.5, 0], [+Y,0  ],             FL_USB_TYPE_Ax2,[["comp/drift",-3]]]],
    ["ETHERNET",  [FL_ETHER_NS, [w/2-45.75, 77.5, 0], [+Y,0  ],             FL_ETHER_RJ45  ,[["comp/drift",-3]]]],
    ["GPIO",      [FL_PHDR_NS,  [-w/2+3.5,  32.5, 0], [+Z,90 ],             FL_PHDR_RPIGPIO]],
  ]
) fl_PCB("RPI4-MODBP-8GB",bare,pcb_t,"green",3,undef,holes,comps,undef,M3_cap_screw);

FL_PCB_MH4PU_P = let(
    name  = "ORICO 4 Ports USB 3.0 Hub 5 Gbps with external power supply port",
    w     = 84,
    l     = 39,
    pcb_t = 1.6,
    bare  = [[-w/2,-l/2,-pcb_t],[+w/2,+l/2,0]],
    holes = [
      let(r=2)    [[-w/2+r+1,-l/2+r+2,0], +Z, 2*r, pcb_t],
      let(r=2)    [[+w/2-r-1,-l/2+r+2,0], +Z, 2*r, pcb_t],
      let(r=2)    [[-w/2+r+1,+l/2-r-2,0], +Z, 2*r, pcb_t],
      let(r=2)    [[+w/2-r-1,+l/2-r-2,0], +Z, 2*r, pcb_t],
      let(r=1.25) [[-w/2+r+1,0,0],        +Z, 2*r, pcb_t, [["hole/screw",M2p5_pan_screw]]],
      let(r=1.25) [[+w/2-r-1,0,0],        +Z, 2*r, pcb_t, [["hole/screw",M2p5_pan_screw]]],
      let(r=1.25) [[-w/2+r+37.5+r,0,0],   +Z, 2*r, pcb_t, [["hole/screw",M2p5_pan_screw]]],
    ],
    sz_A  = fl_size(FL_USB_TYPE_Ax1),
    sz_uA = fl_size(FL_USB_TYPE_uA),
    tol   = 0.5,
    comps = [
    //["label",     ["engine",  [position],                               [[director],rotation]  type,            [engine specific parameters]]]
      ["USB3 IN",   [FL_USB_NS, [-w/2+13.5,+l/2-6,-(pcb_t+1)],                    [+Y,0],       FL_USB_TYPE_Ax1_NF, [["comp/sub",0.5],["comp/drift",-2.5],["comp/color","OrangeRed"]]]],
      ["POWER IN",  [FL_USB_NS, [+w/2-10,+l/2-sz_uA.x/2+0.5,0],                   [+Y,0],       FL_USB_TYPE_uA_NF,  [["comp/drift",-0.5]]]],
      ["USB3-1",    [FL_USB_NS, [+w/2-(6+tol+sz_A.y/2),-l/2+6,-(pcb_t+1)],        [-Y,0],       FL_USB_TYPE_Ax1_NF, [["comp/sub",tol],["comp/drift",-2.5],["comp/color","DodgerBlue"]]]],
      ["USB3-2",    [FL_USB_NS, [+w/2-(6+3*tol+3/2*sz_A.y+5),-l/2+6,-(pcb_t+1)],  [-Y,0],       FL_USB_TYPE_Ax1_NF, [["comp/sub",tol],["comp/drift",-2.5],["comp/color","DodgerBlue"]]]],
      ["USB3-3",    [FL_USB_NS, [-w/2+(6+3*tol+3/2*sz_A.y+5),-l/2+6,-(pcb_t+1)],  [-Y,0],       FL_USB_TYPE_Ax1_NF, [["comp/sub",tol],["comp/drift",-2.5],["comp/color","DodgerBlue"]]]],
      ["USB3-4",    [FL_USB_NS, [-w/2+(6+tol+sz_A.y/2),-l/2+6,-(pcb_t+1)],        [-Y,0],       FL_USB_TYPE_Ax1_NF, [["comp/sub",tol],["comp/drift",-2.5],["comp/color","DodgerBlue"]]]],
    ]
  ) fl_PCB(name,bare,pcb_t,"DarkCyan",1,undef,holes,comps,undef,M3_cap_screw);


FL_PCB_PERF70x50  = fl_pcb_import(PERF70x50);
FL_PCB_PERF60x40  = fl_pcb_import(PERF60x40);
FL_PCB_PERF70x30  = fl_pcb_import(PERF70x30);
FL_PCB_PERF80x20  = fl_pcb_import(PERF80x20);

FL_PCB_DICT = [
  FL_PCB_RPI4,
  FL_PCB_PERF70x50,
  FL_PCB_PERF60x40,
  FL_PCB_PERF70x30,
  FL_PCB_PERF80x20,

  FL_PCB_MH4PU_P,
];

module fl_pcb(
  // FL_ADD, FL_ASSEMBLY, FL_AXES, FL_BBOX, FL_CUTOUT, FL_DRILL, FL_LAYOUT, FL_PAYLOAD
  verbs=FL_ADD,
  type,
  // FL_CUTOUT tolerance
  cut_tolerance=0,
  // FL_CUTOUT component filter by label
  cut_label,
  // FL_CUTOUT component filter by direction (+X,+Y or +Z)
  cut_direction,
  // FL_DRILL and FL_CUTOUT thickness in fixed form [[-X,+X],[-Y,+Y],[-Z,+Z]] or scalar shortcut
  thick=0,
  // FL_LAYOUT,FL_ASSEMBLY directions in floating semi-axis list form
  lay_direction=[+Z],
  // desired direction [director,rotation], native direction when undef
  direction,
  // when undef native positioning is used
  octant
) {
  assert(is_list(verbs)||is_string(verbs),verbs);
  assert(!(cut_direction!=undef && cut_label!=undef),"cutout filtering cannot be done by label and direction at the same time");

  fl_trace("thick",thick);

  pcb_t     = fl_pcb_thick(type);
  comps     = fl_pcb_components(type);
  size      = fl_bb_size(type);
  bbox      = fl_bb_corners(type);
  pload     = fl_has(type,fl_payload()[0]) ? fl_payload(type) : undef;
  holes     = fl_holes(type);
  screw     = fl_has(type,fl_screw()[0]) ? fl_screw(type) : undef;
  screw_r   = screw ? screw_radius(screw) : 0;
  thick     = is_num(thick) ? [[thick,thick],[thick,thick],[thick,thick]]
            : assert(fl_tt_isAxisVList(thick)) thick;
  dr_thick  = thick.z[0]; // thickness along -Z
  cut_thick = thick;
  material  = fl_material(type,default="green");
  radius    = fl_pcb_radius(type);
  grid      = fl_has(type,fl_pcb_grid()[0]) ? fl_pcb_grid(type) : undef;

  D         = direction ? fl_direction(proto=type,direction=direction)  : I;
  M         = octant    ? fl_octant(octant=octant,bbox=bbox)            : I;

  function fl_pcb_NopHoles(nop) = let(
    pcb_t     = pcb_thickness(nop),
    hole_d    = pcb_hole_d(nop),
    nop_holes = pcb_holes(nop),
    holes     = [
      for(h=nop_holes) [
        let(p=pcb_coord(nop, h)) [p.x,p.y,pcb_t],  // 3d point
        +Z,                           // plane normal
        hole_d,                       // hole diameter
        pcb_t                         // hole depth
      ]
    ]
  ) holes;

  module grid_plating() {
  /**
  * Return the grid size in [cols,rows] format
  */
  function fl_grid_geometry(grid,size) = let(
      cols  = is_undef(grid[2]) ? round((size.x - 2 * grid.x) / inch(0.1))  : grid[2] - 1,
      rows  = is_undef(grid[3]) ? round((size.y - 2 * grid.y) / inch(0.1))  : grid[3] - 1
    ) [cols,rows];

    t               = size.z;
    plating         = 0.1;
    fr4             = material != "sienna";
    plating_colour  = is_undef(grid[4]) ? ((material == "green" || material == "#2140BE") ? silver : material == "sienna" ? copper : gold) : grid[4];
    color(plating_colour)
      translate(-Z(plating))
        linear_extrude(fr4 ? t + 2 * plating : plating) {
          fl_grid_layout(
            step    = inch(0.1),
            bbox    = bbox+[grid,-grid],
            clip    = false
          ) difference() {
            circle(d=2);
            circle(d=2-NIL2-2*0.5);
          };

          // oval lands at the ends
          if (fr4 && len(grid) < 3) {
            screw_x = holes[0][0].x;
            y0      = grid.y;
            rows    = fl_grid_geometry(grid,size).y;
            for(end = [-1, 1], y = [1 : rows - 1])
              translate([end * screw_x, y0 + y * inch(0.1) - size.y / 2])
                hull()
                  for(x = [-1, 1])
                    translate([x * 1.6 / 2, 0])
                      circle(d = 2);
          }
        }
  }

  // TODO: better clarify the kind of native positioning, right now it places pcb on first quadrant
  // then translate according the bounding box. This doesn't match the behaviour followed
  // for holes, that are instead already placed in the final full 3d space
  module do_add() {
    fl_color(material) difference() {
      translate(Z(bbox[0].z)) linear_extrude(pcb_t)
        difference() {
          translate(bbox[0])
            fl_square(corners=radius,size=[size.x,size.y],quadrant=+X+Y);
          if (grid)
            fl_grid_layout(
              step    = inch(0.1),
              bbox    = bbox+[grid,-grid],
              clip    = false
            ) circle(d=1);
        }
        do_layout("components")
          if ($subtract!=undef) {
            // TODO: extend to all the engines once sure FL_FOOTPRINT is implemented for all of them
            if ($engine==FL_USB_NS) fl_USB(verbs=FL_FOOTPRINT,type=$type,direction=$direction,tolerance=$subtract);
          }
      if (holes)
        fl_holes(holes,[-X,+X,-Y,+Y,-Z,+Z],pcb_t);
    }
    if (grid)
      grid_plating();
  }

  module do_layout(class,label,directions) {
    assert(is_string(class));
    assert(label==undef||is_string(label));
    assert(directions==undef||is_list(directions));
    fl_trace("class",class);
    fl_trace("directions",directions);
    fl_trace("label",label);
    fl_trace("children",$children);

    if (label) {
      assert(class=="components",str("Cannot layout BY LABEL on class '",class,"'"));
      $label      = label;
      $component  = fl_optional(comps,$label);
      if ($component!=undef) fl_comp_Context($component) translate($position) children();
      else echo(str("***WARN***: component '",label,"' not found"));
    } else if (directions) {
      assert(class=="components",str("Cannot layout BY DIRECTION on class '",class,"'"));
      for(c=comps) fl_comp_Specs(c) {  // «c» = ["label",component]
        // triggers a component if its director matches the direction list
        if (search([$director],directions)!=[[]]) {
          translate($position) children();
        }
      }
    } else {  // by class
      if (class=="components")
        for(c=comps) fl_comp_Specs(c) {  // «c» = ["label",component]
          translate($position) children();
        }
      else if (class=="holes")
        fl_lay_holes(holes,lay_direction)
          children();
      else
        assert(false,str("unknown component class '",class,"'."));
    }
  }

  module do_assembly() {
    do_layout("components")
      if ($engine==FL_USB_NS)
        fl_USB(type=$type,direction=$direction,tongue=$color);
      else if ($engine==FL_HDMI_NS)
        fl_hdmi(type=$type,direction=$direction);
      else if ($engine==FL_JACK_NS)
        fl_jack(type=$type,direction=$direction);
      else if ($engine==FL_ETHER_NS)
        fl_ether(type=$type,direction=$direction);
      else if ($engine==FL_PHDR_NS)
        fl_pinHeader(FL_ADD,type=$type,direction=$direction);
      else if ($engine==FL_TRIM_NS)
        fl_trimpot(FL_ADD,type=$type,direction=$direction,octant=$octant);
      else
        assert(false,str("Unknown engine ",$engine));
  }

  module do_mount() {
    if (holes)
      fl_lay_holes(holes,lay_direction)
        let(scr = is_undef($hole_screw) ? screw : $hole_screw)
          fl_screw([FL_ADD,FL_ASSEMBLY],type=scr,thick=dr_thick+pcb_t);
  }

  module do_drill() {
    fl_lay_holes(holes,lay_direction)
      fl_cylinder(d=$hole_d,h=dr_thick+pcb_t,octant=-$hole_n);
  }

  module do_cutout() {
    module trigger(component) {
      cut_thick = $director==+X ? cut_thick.x[1] : $director==-X ? cut_thick.x[0]
                : $director==+Y ? cut_thick.y[1] : $director==-Y ? cut_thick.y[0]
                : $director==+Z ? cut_thick.z[1] : cut_thick.z[0];
      // echo($director=$director,$engine=$engine,cut_thick=cut_thick);
      if ($engine==FL_USB_NS)
        fl_USB(FL_CUTOUT,$type,cut_thick=cut_thick-$drift,tolerance=cut_tolerance,direction=$direction,cut_drift=$drift);
      else if ($engine==FL_HDMI_NS)
        fl_hdmi(FL_CUTOUT,$type,cut_thick=cut_thick-$drift,cut_tolerance=cut_tolerance,cut_drift=$drift,direction=$direction);
      else if ($engine==FL_JACK_NS)
        fl_jack(FL_CUTOUT,$type,cut_thick=cut_thick-$drift,cut_tolerance=cut_tolerance,cut_drift=$drift,direction=$direction);
      else if ($engine==FL_ETHER_NS)
        fl_ether(FL_CUTOUT,$type,cut_thick=cut_thick-$drift,cut_tolerance=cut_tolerance,cut_drift=$drift,direction=$direction);
      else if ($engine==FL_PHDR_NS) let(
          thick = size.z-pcb_t+cut_thick
        ) fl_pinHeader(FL_CUTOUT,$type,cut_thick=thick,cut_tolerance=cut_tolerance,direction=$direction);
      else if ($engine==FL_TRIM_NS) let(
          thick = size.z-pcb_t-11.5+cut_thick
        ) fl_trimpot(FL_CUTOUT,type=$type,cut_thick=thick,cut_tolerance=cut_tolerance,cut_drift=$drift,direction=$direction,octant=$octant);
      else
        assert(false,str("Unknown engine ",$engine));
    }

    if (cut_label)
      do_layout("components",cut_label) fl_comp_Context($component) trigger($component);
    else
      do_layout("components",undef,cut_direction) trigger($component);
  }

  module do_payload() {
    if (pload)
      fl_bb_add(pload);
  }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_assembly();

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_CUTOUT) {
      fl_modifier($modifier) do_cutout();

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier) do_drill();

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout("holes")
        children();

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier) do_mount();

    } else if ($verb==FL_PAYLOAD) {
      fl_modifier($modifier) do_payload();

    } else
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
  }
}

/**
 * Calculates a cubic bounding block from a bounding blocks list or 3d point set
 */
// TODO: move elsewhere
function fl_bb_calc(
    // list of bounding blocks to be included in the new one
    bbs,
    // list of 3d points to be included in the new bounding block
    pts
  ) =
  assert(fl_XOR(bbs!=undef,pts!=undef))
  assert(bbs==undef || len(bbs)>0,bbs)
  assert(pts==undef || len(pts)>0,pts)
  bbs!=undef
  ? let(
    xs  = [for(bb=bbs) bb[0].x],
    ys  = [for(bb=bbs) bb[0].y],
    zs  = [for(bb=bbs) bb[0].z],
    XS  = [for(bb=bbs) bb[1].x],
    YS  = [for(bb=bbs) bb[1].y],
    ZS  = [for(bb=bbs) bb[1].z]
  ) [[min(xs),min(ys),min(zs)],[max(XS),max(YS),max(ZS)]]
  : let(
    xs  = [for(p=pts) p.x],
    ys  = [for(p=pts) p.y],
    zs  = [for(p=pts) p.z]
  ) [[min(xs),min(ys),min(zs)],[max(xs),max(ys),max(zs)]];

/**
 * PCB adapter for NopSCADlib.
 *
 * While full attributes rendering is supported via NopSCADlib APIs, only basic
 * support is provided to OFL verbs, sometimes even with different behaviour:
 *
 * FL_ADD       - being impossible to render NopSCADlib pcbs without components,
 *                this verb always renders components too;
 * FL_ASSEMBLY  - only screws are added during assembly, since
 *                components are always rendered during FL_ADD;
 * FL_AXES      - no changes;
 * FL_BBOX      - while OFL native PCBs includes also components sizing in
 *                bounding box calculations, the adapter bounding box is
 *                'reduced' to pcb only. The only way to mimic OFL native
 *                behaviour is to explicity add the payload capacity through
 *                the «payload» parameter.
 * FL_CUTOUT    - always applied to all the components, it's not possible to
 *                reduce component triggering by label nor direction.
 *                No cutout tolerance is provided either;
 * FL_DRILL     - no changes
 * FL_LAYOUT    - no changes
 * FL_PAYLOAD   - unsupported by native OFL PCBs
 *
 * Others:
 *
 * Placement    - working with the FL_BBOX limitations
 * Orientation  - no changes
 */
module fl_pcb_adapter(
  // FL_ADD, FL_ASSEMBLY, FL_AXES, FL_BBOX, FL_CUTOUT, FL_DRILL, FL_LAYOUT, FL_PAYLOAD
  verbs=FL_ADD,
  type,
  // FL_DRILL thickness in fixed form [[-X,+X],[-Y,+Y],[-Z,+Z]] or scalar shortcut
  thick=0,
  // pay-load bounding box, is added to the overall bounding box calculation
  payload,
  // desired direction [director,rotation], native direction when undef
  direction,
  // when undef native positioning is used
  octant
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  fl_trace("thick",thick);

  pcb_t     = pcb_thickness(type);
  comps     = pcb_components(type);
  size      = pcb_size(type);
  bbox      = let(bare=[[-size.x/2,-size.y/2,0],[+size.x/2,+size.y/2,+size.z]]) payload ? fl_bb_calc(bbs=[bare,payload]) : bare;
  holes     = fl_pcb_NopHoles(type);
  screw     = pcb_screw(type);
  screw_r   = screw ? screw_radius(screw) : 0;
  thick     = is_num(thick) ? [[thick,thick],[thick,thick],[thick,thick]]
            : assert(fl_tt_isAxisVList(thick)) thick;
  dr_thick  = thick.z[0]; // thickness along -Z
  material  = fl_material(type,default="green");
  radius    = pcb_radius(type);
  grid      = pcb_grid(type);

  D         = direction ? fl_direction(proto=type,direction=direction,default=[+Z,+X])  : I;
  M         = octant    ? fl_octant(octant=octant,bbox=bbox) : I;

  fl_trace("screw",screw);
  fl_trace("components",comps);
  fl_trace("type",type);
  fl_trace("holes",holes);
  fl_trace("bbox",bbox);
  fl_trace("grid",grid);

  module do_add() {
    pcb(type) children();
  }

  module do_layout() {
    if (holes)
      fl_lay_holes(holes,[+Z])
        children();
  }

  module do_assembly() {
    if (holes)
      fl_lay_holes(holes,[+Z])
        fl_screw([FL_ADD,FL_ASSEMBLY],type=screw,nut="default",thick=dr_thick+pcb_t,nwasher=true);
  }

  module do_drill() {
    if (holes)
      fl_lay_holes(holes,[+Z])
        fl_cylinder(d=$hole_d,h=dr_thick+pcb_t,octant=-$hole_n);
  }

  module do_cutout() {
    pcb_cutouts(type);
  }

  module do_payload() {
    if (payload)
      fl_bb_add(payload);
  }

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout()
        children();

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_assembly();

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier) do_drill();

    } else if ($verb==FL_CUTOUT) {
      fl_modifier($modifier) do_cutout();

    } else if ($verb==FL_PAYLOAD) {
      fl_modifier($modifier) do_payload();

    } else
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
  }
}

// TODO: MOVE ME!!!!

FL_TRIM_NS    = "trim";

FL_TRIM_POT10  = let(
  sz  = [9.5,10+1.5,4.8]
) [
  fl_name(value="ten turn trimpot"),
  fl_bb_corners(value=[[-sz.x/2,-sz.y/2-1.5/2,0],[sz.x/2,sz.y/2-1.5/2,sz.z]]),
  fl_director(value=+Z),fl_rotor(value=+X),
];

module fl_trimpot(
  // supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  type,
  // thickness for FL_CUTOUT
  cut_thick,
  // tolerance used during FL_CUTOUT
  cut_tolerance=0,
  // translation applied to cutout (default 0)
  cut_drift=0,
  // desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  // when undef native positioning is used
  octant
) {
  bbox  = fl_bb_corners(type);
  size  = fl_bb_size(type);
  D     = direction ? fl_direction(proto=type,direction=direction)  : FL_I;
  M     = octant    ? fl_octant(octant=octant,bbox=bbox)            : FL_I;

  module do_add() {
    trimpot10();
  }
  module do_bbox() {}
  module do_assembly() {}
  module do_layout() {}
  module do_drill() {}

  fl_manage(verbs,M,D,size) {
    if ($verb==FL_ADD) {
      fl_modifier($modifier) trimpot10();
    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox);
    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout()
        children();
    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier);
    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier);
    } else if ($verb==FL_CUTOUT) {
      fl_modifier($modifier)
        translate(-Y(6.5+cut_drift))
          fl_cutout(len=cut_thick,delta=cut_tolerance,trim=[0,5.1,0],z=-Y,cut=true)
            do_add();
    } else {
      assert(false,str("***UNIMPLEMENTED VERB***: ",$verb));
    }
  }
}
