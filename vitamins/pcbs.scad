/*!
 * PCB definition file.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
include <../foundation/grid.scad>
include <../foundation/hole.scad>
include <../foundation/label.scad>
use     <../dxf.scad>

include <ethers.scad>
include <hdmi.scad>
include <jacks.scad>
include <pin_headers.scad>
include <screw.scad>
include <sd.scad>
include <trimpot.scad>
include <usbs.scad>

include <NopSCADlib/lib.scad>
include <NopSCADlib/vitamins/screws.scad>

//! namespace for PCB engine
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
// TODO: abstract components from PCBs and move alone

/*!
 * Component context:
 *
 *  - $engine    : engine to be triggered for component rendering
 *  - $position  : component position
 *  - $direction
 *  - $director
 *  - $rotation
 *  - $type
 *  - $subtract  : the tolerance to be used during component FL_FOOTPRINT difference from parent shape
 *  - $drift     : additional positioning during component positioning
 *  - $color
 *  - $octant
 *
 * TODO: prepend component namespace to context variable name
 */
module fl_comp_Context(
  //! component definition: ["engine", [position], [[director],rotation], type, properties]
  component
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

/*!
 * Component specifications context:
 *
 *  - $label
 *  - $component
 *
 * plus component context (see fl_comp_Context{})
 */
module fl_comp_Specs(
  //! component specifications: ["label",component]
  specs
  ) {

  $label      = specs[0];
  $component  = specs[1];
  fl_comp_Context($component) children();
}

//! exact calculation of the resulting bounding box out of a list of component specifications
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
        M           = fl_octant(octant,bbox=bbox),
        // transformed bounding box points
        points      = [for(corner=bbox) fl_transform(T*D*M,corner)],
        // build transformed bounding box from points
        Tbbox       = fl_bb_calc(pts=points)
      ) Tbbox
    ]
  ) fl_bb_calc(bboxes);

/*!
 * returns the component with «label»
 *
 * **NOTE:** error when label is not unique
 */
function fl_comp_search(type,label,comps) = let(
  components  = comps ? comps : assert(type) fl_pcb_components(type),
  result      = [for(specs=components) if (label==specs[0]) specs[1]]
) assert(len(result)==1,result) result[0];

/*!
 * returns «component» connectors transformed according to component position/orientation
 */
function fl_comp_connectors(component)  = let(
  position    = component[1],
  direction   = component[2],
  type        = component[3],
  T           = T(position),
  D           = fl_direction(proto=type,direction=direction),
  M           = T*D,
  connectors  = fl_connectors(type)
) fl_conn_import(connectors,M);

//*****************************************************************************

//! base constructor
function fl_PCB(
    //! optional name for the constructed type
    name,
    /*!
     * bare (i.e. no payload) pcb's bounding box in the format `[[x,y,z],[X,Y,Z]]`
     *
     * See also fl_tt_isBoundingBox() for its definition.
     */
    bare,
    //! pcb thickness
    thick = 1.6,
    color  = "green",
    //! corners radius
    radius=0,
    /*!
     * Optional payload bounding box.
     * When passed it concurs in pcb's bounding box calculations
     */
    payload,
    /*!
     * each row represents a hole as returned from fl_Hole()
     */
    holes = [],
    /*!
     * each row represent one component with the following format:
     *
     * `["label", ["engine", [position], [[director],rotation], type],subtract]`
     */
    components,
    //! grid specs
    grid,
    screw,
    /*!
     * Name of a DXF file used for describing the pcb geometry. When passed it
     * will be used for rendering by verbs like FL_ADD.
     *
     * NOTE: the presence of a DXF file doesn't replace the bounding box
     * parameter, since OpenSCAD is unable to return it from the DXF import{}
     * module.
     */
    dxf,
    vendors,
    connectors,
    director=+Z,
    rotor=+X
  ) =
  assert(fl_tt_isBoundingBox(bare),"«bare» must be a bounding box in high-low format")
  let(
    comp_bbox = components ? fl_comp_BBox(components) : undef,
    pload = payload ? payload : comp_bbox,
    bbox  = pload
          ? [
              // bare[0],
              [bare[0].x,bare[0].y,min(bare[0].z,pload[0].z)],
              [bare[1].x,bare[1].y,max(bare[1].z,pload[1].z)]
            ]
          : bare
  ) [
    fl_native(value=true),
    fl_name(value=name),
    fl_bb_corners(value=bbox),
    fl_director(value=director),fl_rotor(value=rotor),
    fl_engine(value=FL_PCB_NS),
    fl_pcb_thick(value=thick),
    fl_pcb_radius(value=radius),
    if (pload) fl_payload(value=pload), // optional payload
    fl_holes(value=holes),
    fl_pcb_components(value=components),
    fl_material(value=color),
    fl_screw(value=screw),
    fl_pcb_grid(value=grid),
    if (dxf!=undef) fl_dxf(value=dxf),
    if (vendors) fl_vendor(value=vendors),
    if (connectors) fl_connectors(value=connectors),
  ];

/*!
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
 * **WARNING:** no component is currently imported. still a work in progress
 * use fl_pcb_adapter{} instead.
 *
 * TODO: fix and complete
 */
function fl_pcb_import(nop,payload) = let(
    w         = max(pcb_width(nop),pcb_length(nop)),
    l         = min(pcb_width(nop),pcb_length(nop)),
    h         = 0,
    pcb_t     = pcb_thickness(nop),
    bbox      = [[-w/2,-l/2,-pcb_t],[+w/2,+l/2,h]]
  ) fl_PCB(nop[1],bbox,pcb_t,pcb_colour(nop),pcb_radius(nop),payload,fl_pcb_NopHoles(nop),undef,pcb_grid(nop),pcb_screw(nop));

/*!
 * Helper for conversion from NopSCADlib hole format to OFL.
 */
function fl_pcb_NopHoles(nop) = let(
  pcb_t     = pcb_thickness(nop),
  hole_d    = pcb_hole_d(nop),
  nop_holes = pcb_holes(nop),
  holes     = [
    for(h=nop_holes) fl_Hole(
      position  = let(p=pcb_coord(nop, h)) [p.x,p.y,0],
      d         = hole_d,
      normal    = +Z,
      depth     = pcb_t
    )
  ]
) holes;
/*!
 * Model for Raspberry PI 4.
 * The following labels can be passed as **cut_label** parameter to fl_pcb{} when performing FL_CUTOUT:
 *
 * | Label      | Description                                   |
 * |------------|-----------------------------------------------|
 * | "POWER IN" | 5V DC via USB-C connector                     |
 * | "HDMI0"    | micro-HDMI port 0                             |
 * | "HDMI1"    | micro-HDMI port 1                             |
 * | "A/V"      | 4-pole stereo audio and composite video port  |
 * | "USB2"     | USB 2.0 port                                  |
 * | "USB3"     | USB 3.0 port                                  |
 * | "ETHERNET" | Gigabit Ethernet                              |
 * | "GPIO"     | Raspberry Pi standard 40 pin GPIO header      |
 * | "uSD"      | Micro-SD card slot                            |
 */
FL_PCB_RPI4 = let(
  w       = 56,
  l       = 85,
  h       = 16,
  pcb_t   = 1.5,
  hole_d  = 2.7,
  bare    = [[-w/2,0,-pcb_t],[+w/2,l,0]],
  payload = [[bare[0].x,bare[0].y,0],[bare[1].x,bare[1].y,h]],
  holes   = [
    fl_Hole([ 24.5, 3.5,  0 ], hole_d,  depth=pcb_t,  loct=-X),
    fl_Hole([ 24.5, 61.5, 0 ], hole_d,  +Z, pcb_t,loct=+Y),
    fl_Hole([-24.5, 3.5,  0 ], hole_d,  +Z, pcb_t,loct=+X),
    fl_Hole([-24.5, 61.5, 0 ], hole_d,  +Z, pcb_t,loct=+Y),
  ],
  comps = [
    //TODO: engine can be retrieved from type
    //["label",   ["engine",    [position],           [[director],rotation] type,           [engine specific parameters]]]
    ["POWER IN",  [FL_USB_NS,   [25.5,      11.2, 0], [+X,0  ],             FL_USB_TYPE_C  ,[["comp/drift",-1.3]]]],
    ["HDMI0",     [FL_HDMI_NS,  [25,        26,   0], [+X,0  ],             FL_HDMI_TYPE_D ,[["comp/drift",-1.26]]]],
    ["HDMI1",     [FL_HDMI_NS,  [25,        39.5, 0], [+X,0  ],             FL_HDMI_TYPE_D ,[["comp/drift",-1.26]]]],
    ["A/V",       [FL_JACK_NS,  [22,        54,   0], [+X,0  ],             FL_JACK_BARREL  ]],
    ["USB2",      [FL_USB_NS,   [w/2-9,     79.5, 0], [+Y,0  ],             FL_USB_TYPE_Ax2,[["comp/drift",-3]]]],
    ["USB3",      [FL_USB_NS,   [w/2-27,    79.5, 0], [+Y,0  ],             FL_USB_TYPE_Ax2,[["comp/drift",-3]]]],
    ["ETHERNET",  [FL_ETHER_NS, [w/2-45.75, 77.5, 0], [+Y,0  ],             FL_ETHER_RJ45  ,[["comp/drift",-3]]]],
    ["GPIO",      [FL_PHDR_NS,  [-w/2+3.5,  32.5, 0], [+Z,90 ],             FL_PHDR_GPIOHDR]],
    ["uSD",       [FL_SD_NS,    [0,       2, -pcb_t], [-Y,180],             FL_SD_MOLEX_uSD_SOCKET, [["comp/octant",+Y+Z],["comp/drift",2]] ]],
  ],
  vendors = [["Amazon","https://www.amazon.it/gp/product/B0899VXM8F"]],
  gpio_c  = fl_comp_connectors(comps[7][1])[0],
  conns   = [
    fl_conn_clone(gpio_c,type="plug",direction=[+Z,-90],octant=-X-Y),
  ]
) fl_PCB("RPI4-MODBP-8GB",bare,pcb_t,"green",3,undef,holes,comps,undef,M3_cap_screw,vendors=vendors,connectors=conns);

/*!
 * PCB RF cutout taken from https://www.rfconnector.com/mcx/edge-mount-jack-pcb-connector
 *
 * The following labels can be passed as **cut_label** parameter to fl_pcb{} when performing FL_CUTOUT:
 *
 * | Label      | Description                             |
 * |------------|-----------------------------------------|
 * | "RF IN"  | Antenna connector                         |
 * | "GPIO"   | Raspberry Pi standard 40 pin GPIO header  |
 */
FL_PCB_RPI_uHAT = let(
  pcb_t   = 1.6,
  size    = [65,30,pcb_t],
  bare    = [[0,0,-pcb_t],[size.x,size.y,0]],
  hole_d  = 2.75,
  holes   = [
    fl_Hole([ 3.5,         size.y-3.5, 0 ], hole_d, +Z, pcb_t,loct=-Y),
    fl_Hole([ size.x-3.5,  size.y-3.5, 0 ], hole_d, +Z, pcb_t,loct=-Y),
    fl_Hole([ size.x-3.5,  3.5,        0 ], hole_d, +Z, pcb_t,loct=+Y),
  ],
  comps   = [
  //["label",  ["engine",     [position],              [[director],rotation] type,                [engine specific parameters]]]
    ["RF IN",  [FL_JACK_NS,   [0,      15, 0],         [-X,0  ],             FL_JACK_MCXJPHSTEM1      ]],
    ["GPIO",   [FL_PHDR_NS,   [32.5,   size.y-3.5, 0], [+Z,0 ],              FL_PHDR_GPIOHDR_F_SMT_LOW]],
  ],
  vendors = [["Amazon","https://www.amazon.it/gp/product/B07JKH36VR"]],
  gpio_conn_pos = fl_conn_pos(fl_comp_connectors(comps[1][1])[1]),
  rf_conn_pos   = fl_conn_pos(fl_comp_connectors(comps[0][1])[0]),
  connectors  = [
    conn_Socket(fl_phdr_cid(2p54header,[20,2]),+X,+Y,[gpio_conn_pos.x,gpio_conn_pos.y,-pcb_t],octant=+X+Y,direction=[-Z,180]),
    conn_Socket(fl_phdr_cid(2p54header,[20,2]),-X,+Y,[gpio_conn_pos.x,gpio_conn_pos.y,4],octant=+X+Y,direction=[-Z,0]),
    conn_Socket("antenna",-Z,+Y,rf_conn_pos,octant=+X+Y,direction=[-Z,-90]),
  ]
  ) fl_PCB("Raspberry PI uHAT",bare,pcb_t,"green",radius=3,
      dxf="vitamins/tv-hat.dxf",screw=M2p5_cap_screw,holes=holes,components=comps,vendors=vendors,connectors=connectors);

FL_PCB_MH4PU_P = let(
    name  = "ORICO 4 Ports USB 3.0 Hub 5 Gbps with external power supply port",
    w     = 84,
    l     = 39,
    pcb_t = 1.6,
    bare  = [[-w/2,-l/2,-pcb_t],[+w/2,+l/2,0]],
    holes = [
      let(r=2)    fl_Hole([-w/2+r+1,-l/2+r+2,0],  2*r,+Z, pcb_t,  loct=+Y),
      let(r=2)    fl_Hole([+w/2-r-1,-l/2+r+2,0],  2*r,+Z, pcb_t,  loct=+Y),
      let(r=2)    fl_Hole([-w/2+r+1,+l/2-r-2,0],  2*r,+Z, pcb_t,  loct=-Y),
      let(r=2)    fl_Hole([+w/2-r-1,+l/2-r-2,0],  2*r,+Z, pcb_t,  loct=-Y),
      let(r=1.25) fl_Hole([-w/2+r+1,0,0],         2*r,+Z, pcb_t,  loct=+X,  screw=M2p5_pan_screw),
      let(r=1.25) fl_Hole([+w/2-r-1,0,0],         2*r,+Z, pcb_t,  loct=-X,  screw=M2p5_pan_screw),
      let(r=1.25) fl_Hole([-w/2+r+37.5+r,0,0],    2*r,+Z, pcb_t,  loct=+Y,  screw=M2p5_pan_screw),
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
    ],
    vendors=[["Amazon","https://www.amazon.it/gp/product/B07VQLXCTB"]]
  ) fl_PCB(name,bare,pcb_t,"DarkCyan",1,undef,holes,comps,undef,M3_cap_screw,vendors=vendors);

FL_PCB_HILETGO_SX1308 = let(
    pcb_t = 1.6,
    sz    = [23,16,pcb_t],
    // holes positions
    holes = [for(x=[-sz.x/2+2.5,+sz.x/2-2.5],y=[-sz.y/2+2.5,+sz.y/2-2.5]) [x,y,0]],
    1PIN  = fl_PinHeader("1-pin",nop=2p54header,engine="male"),
    comps = [
      //["label", ["engine",   [position        ],  [[director],rotation],  type,           [engine specific parameters]]]
      ["TRIMPOT", [FL_TRIM_NS, [-5,-sz.y/2+0.5,0],  [+Y,0],                 FL_TRIM_POT10,  [["comp/octant",+X-Y+Z]]  ]],
      // create four component specifications, one for each hole position, labelled as "PIN-0", "PIN-1", "PIN-2", "PIN-3"
      for(i=[0:len(holes)-1]) let(label=str("PIN-",i))
        [label,   [FL_PHDR_NS, holes[i],            [+Z,0],                 1PIN]],
    ]
  ) fl_PCB(
    name  = "HiLetgo SX1308 DC-DC Step up power module",
    // bare (i.e. no payload) pcb's bounding box
    bare  = [[-sz.x/2,-sz.y/2,-sz.z],[+sz.x/2,+sz.y/2,0]],
    // pcb thickness
    thick = pcb_t,
    color  = "DarkCyan",
    holes = let(r=0.75,d=r*2) [
      for(i=[0:len(holes)-1])
        let(pos=holes[i])
          fl_Hole(pos,d,+Z,0,loct=-sign(pos.x)*X-sign(pos.y)*Y)
    ],
    components=comps,
    vendors=[["Amazon","https://www.amazon.it/gp/product/B07ZYW68C4"]]
  );


FL_PCB_PERF70x50  = fl_pcb_import(PERF70x50);
FL_PCB_PERF60x40  = fl_pcb_import(PERF60x40);
FL_PCB_PERF70x30  = fl_pcb_import(PERF70x30);
FL_PCB_PERF80x20  = fl_pcb_import(PERF80x20);

FL_PCB_DICT = [
      FL_PCB_HILETGO_SX1308,
      FL_PCB_MH4PU_P,
      FL_PCB_PERF70x50,
      FL_PCB_PERF60x40,
      FL_PCB_PERF70x30,
      FL_PCB_PERF80x20,
      FL_PCB_RPI4,
      FL_PCB_RPI_uHAT,
];

/*!
 * PCB engine.
 *
 * __parent context__:
 *
 * - $hole_syms - (OPTIONAL bool) enables hole symbles
 *
 * __children context__:
 *
 * - complete hole context
 * - $pcb_radius - pcb radius
 */
module fl_pcb(
  //! FL_ADD, FL_ASSEMBLY, FL_AXES, FL_BBOX, FL_CUTOUT, FL_DRILL, FL_LAYOUT, FL_PAYLOAD
  verbs=FL_ADD,
  type,
  //! FL_CUTOUT tolerance
  cut_tolerance=0,
  //! FL_CUTOUT component filter by label. For the possible values consult the relevant «type» supported labels.
  cut_label,
  //! FL_CUTOUT component filter by direction (+X,+Y or +Z)
  cut_direction,
  //! FL_DRILL and FL_CUTOUT thickness in fixed form [[-X,+X],[-Y,+Y],[-Z,+Z]] or scalar shortcut
  thick=0,
  //! FL_LAYOUT,FL_ASSEMBLY directions in floating semi-axis list form
  lay_direction=[+Z],
  //! see constructor fl_parm_Debug()
  debug,
  //! desired direction [director,rotation], native direction when undef
  direction,
  //! when undef native positioning is used
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
  neg_delta = -pcb_t-bbox[0].z;
  dr_thick  = pcb_t+neg_delta+thick.z[0]; // thickness along -Z
  cut_thick = thick;
  material  = fl_material(type,default="green");
  radius    = fl_pcb_radius(type);
  grid      = fl_has(type,fl_pcb_grid()[0]) ? fl_pcb_grid(type) : undef;
  dxf       = fl_optional(type,fl_dxf()[0]);
  conns     = fl_optional(type,fl_connectors()[0]);

  M         = fl_octant(octant,bbox=bbox);
  D         = direction ? fl_direction(type,direction=direction)  : I;

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
            screw_x = fl_hole_pos(holes[0]).x;
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
      translate(-Z(pcb_t)) linear_extrude(pcb_t)
        difference() {
          if (dxf)
            __dxf__(file=dxf,layer="0");
          else
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
            // TODO: either extend to all the engines once sure FL_FOOTPRINT is implemented for all of them or eliminate it and use dxf
            if ($engine==FL_USB_NS) fl_USB(verbs=FL_FOOTPRINT,type=$type,direction=$direction,tolerance=$subtract);
          }
      if (holes)
        fl_holes(holes,[-X,+X,-Y,+Y,-Z,+Z],pcb_t);

      // generates drills on pcb from components
      // TODO: extends to all the supported components
      do_layout("components")
        if ($director==+Z||$director==-Z)
          if ($engine==FL_PHDR_NS)
            translate(+Z(FL_NIL)) fl_pinHeader([FL_DRILL],$type,cut_thick=pcb_t+NIL2,octant=$octant,direction=$direction);

    }
    if (grid)
      translate(-Z(pcb_t)) grid_plating();

  }

  module context() {
    $pcb_radius = radius;
    children();
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
        fl_lay_holes(holes,lay_direction,screw=screw)
          context() children();
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
        fl_ether(type=$type,octant=$octant,direction=$direction);
      else if ($engine==FL_PHDR_NS)
        // FIXME: add namespace to context variables in order to avoid common parameters collision
        fl_pinHeader(FL_ADD,type=$type,octant=$octant,direction=$direction);
      else if ($engine==FL_TRIM_NS)
        fl_trimpot(FL_ADD,type=$type,direction=$direction,octant=$octant);
      else if ($engine==FL_SD_NS)
        fl_sd_usocket(FL_ADD,type=$type,octant=$octant,direction=$direction);
      else
        assert(false,str("Unknown engine ",$engine));
  }

  module do_mount() {
    if (holes)
      fl_lay_holes(holes,lay_direction)
        let(scr = is_undef($hole_screw) ? screw : $hole_screw)
          if (scr) fl_screw([FL_ADD,FL_ASSEMBLY],type=scr,thick=dr_thick);
  }

  module do_drill() {
    fl_lay_holes(holes,lay_direction)
      fl_cylinder(d=$hole_d,h=dr_thick,octant=-$hole_n);
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
        ) fl_pinHeader(FL_CUTOUT,$type,cut_thick=thick,cut_tolerance=cut_tolerance,octant=$octant,direction=$direction);
      else if ($engine==FL_TRIM_NS) let(
          thick = size.z-pcb_t-11.5+cut_thick
        ) fl_trimpot(FL_CUTOUT,type=$type,cut_thick=thick,cut_tolerance=cut_tolerance,cut_drift=$drift,direction=$direction,octant=$octant);
      else if ($engine==FL_SD_NS)
        // echo(cut_tolerance=cut_tolerance)
        fl_sd_usocket(FL_CUTOUT,type=$type,cut_thick=cut_thick+2,cut_tolerance=cut_tolerance,octant=$octant,direction=$direction);
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

  fl_manage(verbs,M,D,size,debug,connectors=conns,holes=holes) {
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

/*!
 * PCB adapter for NopSCADlib.
 *
 * While full attributes rendering is supported via NopSCADlib APIs, only basic
 * support is provided to OFL verbs, sometimes even with different behaviour:
 *
 * - FL_ADD       : being impossible to render NopSCADlib pcbs without components,
 *                  this verb always renders components too;
 * - FL_ASSEMBLY  : only screws are added during assembly, since
 *                  components are always rendered during FL_ADD;
 * - FL_AXES      : no changes;
 * - FL_BBOX      : while OFL native PCBs includes also components sizing in
 *                  bounding box calculations, the adapter bounding box is
 *                  'reduced' to pcb only. The only way to mimic OFL native
 *                  behaviour is to explicity add the payload capacity through
 *                  the «payload» parameter.
 * - FL_CUTOUT    : always applied to all the components, it's not possible to
 *                  reduce component triggering by label nor direction.
 *                  No cutout tolerance is provided either;
 * - FL_DRILL     : no changes
 * - FL_LAYOUT    : no changes
 * - FL_PAYLOAD   : unsupported by native OFL PCBs
 *
 * Others:
 *
 * - Placement    : working with the FL_BBOX limitations
 * - Orientation  : no changes
 */
module fl_pcb_adapter(
  //! FL_ADD, FL_ASSEMBLY, FL_AXES, FL_BBOX, FL_CUTOUT, FL_DRILL, FL_LAYOUT, FL_PAYLOAD
  verbs=FL_ADD,
  type,
  //! FL_DRILL thickness in fixed form [[-X,+X],[-Y,+Y],[-Z,+Z]] or scalar shortcut
  thick=0,
  //! pay-load bounding box, is added to the overall bounding box calculation
  payload,
  //! desired direction [director,rotation], native direction when undef
  direction,
  //! when undef native positioning is used
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
  M         = fl_octant(octant,bbox=bbox);

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

