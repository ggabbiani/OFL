/*!
 * PCB definition file.
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
use     <../dxf.scad>

include <../../ext/NopSCADlib/lib.scad>
include <../../ext/NopSCADlib/vitamins/screws.scad>

include <../foundation/components.scad>
include <../foundation/grid.scad>
include <../foundation/hole.scad>
include <../foundation/label.scad>

include <ethers.scad>
include <generic.scad>
include <hdmi.scad>
include <heatsinks.scad>
include <jacks.scad>
include <pin_headers.scad>
include <screw.scad>
include <sd.scad>
include <switch.scad>
include <trimpot.scad>
include <usbs.scad>

use <../foundation/mngm-engine.scad>

//! namespace for PCB engine
FL_PCB_NS  = "pcb";

//! PCB frame engine
FL_PCB_ENGINE_FRAME="PCB frame engine";

//*****************************************************************************
// PCB properties
// when invoked by «type» parameter act as getters
// when invoked by «value» parameter act as property constructors
function fl_pcb_components(type,value)  = fl_property(type,"pcb/components",value);
function fl_pcb_radius(type,value)      = fl_property(type,"pcb/corners radius",value);
function fl_pcb_thick(type,value)       = fl_property(type,"pcb/thickness",value);
function fl_pcb_grid(type,value)        = fl_property(type,"pcb/grid",value);
/*!
 * Translation matrices used during children() layout as returned by
 * fl_lay_holes().
 *
 * TODO: remove if unused
 */
function fl_pcb_layoutArray(type,value) = fl_property(type,"pcb/layout translation array",value);

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
    assert(!fl_dbg_assert() || fl_tt_isBoundingBox(bare),"«bare» must be a bounding box in low-high format")
  let(
    comp_bbox = components ? fl_comp_BBox(components) : undef,
    pload     = payload ? payload : comp_bbox,
    bbox      = function (type,key,default) pload
                  ? [
                      [bare[0].x,bare[0].y,min(bare[0].z,pload[0].z)],
                      [bare[1].x,bare[1].y,max(bare[1].z,pload[1].z)]
                    ]
                  : bare
  ) [
    fl_native(value=true),
    fl_name(value=name),
    fl_bb_corners(value=bbox),
    // fl_director(value=director),fl_rotor(value=rotor),
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
    fl_pcb_layoutArray(value=fl_lay_holes(holes)),
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
 *
 * The following labels can be passed as **components** parameter to fl_pcb{} when
 * performing FL_CUTOUT:
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
 * | "PIM TOP"  | Pimoroni heat sink (top part)                 |
 * | "PIM BOT"  | Pimoroni heat sink (bottom part)              |
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
    ["POWER IN", fl_Component(FL_USB_NS,  [25.5,11.2,0        ], [+Z,0] , [+X], FL_USB_TYPE_C  ,[[FL_COMP_DRIFT,-1.3]]) ],
    ["HDMI0",    fl_Component(FL_HDMI_NS, [25, 26, 0          ], [+Z,0 ], [+X], FL_HDMI_TYPE_D ,[[FL_COMP_DRIFT,-1.26]] )],
    ["HDMI1",    fl_Component(FL_HDMI_NS, [25, 39.5, 0        ], [+Z,0 ], [+X], FL_HDMI_TYPE_D ,[[FL_COMP_DRIFT,-1.26]] )],
    ["A/V",      fl_Component(FL_JACK_NS, [22, 54, 0          ], [+Z,0 ], [+X], FL_JACK_BARREL  )],
    ["USB2",     fl_Component(FL_USB_NS,  [w/2-9, 79.5, 0     ], [+Z,90], [+Y,+Z], FL_USB_TYPE_Ax2,[[FL_COMP_DRIFT,-3], [FL_COMP_COLOR,fl_grey(30)]] )],
    ["USB3",     fl_Component(FL_USB_NS,  [w/2-27, 79.5, 0    ], [+Z,90], [+Y,+Z], FL_USB_TYPE_Ax2,[[FL_COMP_DRIFT,-3], [FL_COMP_COLOR,"DodgerBlue"]] )],
    ["ETHERNET", fl_Component(FL_ETHER_NS,[w/2-45.75, 77.5, 0 ], [+Z,90], [+Y,+Z], FL_ETHER_RJ45  ,[[FL_COMP_DRIFT,-3]] )],
    ["GPIO",     fl_Component(FL_PHDR_NS, [-w/2+3.5, 32.5, 0  ], [+Z,90], [+Z], FL_PHDR_GPIOHDR)],
    ["uSD",      fl_Component(FL_SD_NS,   [0, 2, -pcb_t       ], [-Z,0 ], [-Y], FL_SD_MOLEX_uSD_SOCKET, [[FL_COMP_OCTANT,+Y+Z],[FL_COMP_DRIFT,2]] )],
    ["PIM TOP",  fl_Component(FL_HS_NS,   [0, 0, 0            ], [+Z,0 ], [+Z], FL_HS_PIMORONI_TOP )],
    ["PIM BOT",  fl_Component(FL_HS_NS,   [0, 0, -pcb_t       ], [+Z,0 ], [+Y,-Z], FL_HS_PIMORONI_BOTTOM,[[FL_COMP_DRIFT,-2]] )],
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
 * The following labels can be passed as **components** parameter to fl_pcb{} when performing FL_CUTOUT:
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
    ["RF IN", fl_Component(FL_JACK_NS, [0,15,0], [+Z,-90  ], [-X], FL_JACK_MCXJPHSTEM1)],
    ["GPIO",  fl_Component(FL_PHDR_NS, [32.5, size.y-3.5, 0], [+Z,0 ], [+Z], FL_PHDR_GPIOHDR_F_SMT_LOW)],
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
      ["USB3 IN",   fl_Component(FL_USB_NS, [-w/2+13.5,+l/2-6,-(pcb_t+1)],                  [+Z,90], [+Y], FL_USB_TYPE_Ax1_NF, [[FL_COMP_SUB,0.5],[FL_COMP_DRIFT,-2.5],[FL_COMP_COLOR,"OrangeRed"]])],
      ["POWER IN",  fl_Component(FL_USB_NS, [+w/2-10,+l/2-sz_uA.x/2+0.5,0],                 [+Z,90], [+Y], FL_USB_TYPE_uA_NF,  [[FL_COMP_DRIFT,-0.5]])],
      ["USB3-1",    fl_Component(FL_USB_NS, [+w/2-(6+tol+sz_A.y/2),-l/2+6,-(pcb_t+1)],      [+Z,-90],[-Y], FL_USB_TYPE_Ax1_NF, [[FL_COMP_SUB,tol],[FL_COMP_DRIFT,-2.5],[FL_COMP_COLOR,"DodgerBlue"]])],
      ["USB3-2",    fl_Component(FL_USB_NS, [+w/2-(6+3*tol+3/2*sz_A.y+5),-l/2+6,-(pcb_t+1)],[+Z,-90],[-Y], FL_USB_TYPE_Ax1_NF, [[FL_COMP_SUB,tol],[FL_COMP_DRIFT,-2.5],[FL_COMP_COLOR,"DodgerBlue"]])],
      ["USB3-3",    fl_Component(FL_USB_NS, [-w/2+(6+3*tol+3/2*sz_A.y+5),-l/2+6,-(pcb_t+1)],[+Z,-90],[-Y], FL_USB_TYPE_Ax1_NF, [[FL_COMP_SUB,tol],[FL_COMP_DRIFT,-2.5],[FL_COMP_COLOR,"DodgerBlue"]])],
      ["USB3-4",    fl_Component(FL_USB_NS, [-w/2+(6+tol+sz_A.y/2),-l/2+6,-(pcb_t+1)],      [+Z,-90],[-Y], FL_USB_TYPE_Ax1_NF, [[FL_COMP_SUB,tol],[FL_COMP_DRIFT,-2.5],[FL_COMP_COLOR,"DodgerBlue"]])],
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
      ["TRIMPOT", fl_Component(FL_TRIM_NS, [-5,-sz.y/2+0.5,0], [+Y,0], [+Z], FL_TRIM_POT10,  [[FL_COMP_OCTANT,+X-Y+Z]])],
      // create four component specifications, one for each hole position, labelled as "PIN-0", "PIN-1", "PIN-2", "PIN-3"
      for(i=[0:len(holes)-1]) let(label=str("PIN-",i))
        [label,fl_Component(FL_PHDR_NS, holes[i],[+Z,0],[+Z],1PIN)],
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
          fl_Hole(pos,d,+Z,pcb_t,loct=-sign(pos.x)*X-sign(pos.y)*Y)
    ],
    components=comps,
    vendors=[["Amazon","https://www.amazon.it/gp/product/B07ZYW68C4"]]
  );

/*
 * Model for Khadas SBC VIM1.
 *
 * The following labels can be passed as **components** parameter to fl_pcb{} when
 * performing FL_CUTOUT:
 *
 * | Label            | Description                               |
 * |------------------|-------------------------------------------|
 * | "USB 2.0 900mA"  | USB 2.0 speed, 900mA max output           |
 * | "USB-C"          | USB 2.0 OTG and 5V power input            |
 * | "HDMI0"          | HDMI 2.0b output                          |
 * | "ETHERNET"       | 10/100 Mbps Ethernet                      |
 * | "USB 2.0 500mA"  | USB 2.0 speed, 500mA max output           |
 * | "POWER"          | Power button                              |
 * | "FUNCTION"       | Function button                           |
 * | "RESET"          | Reset button                              |
 * | "GPIO"           | 40-Pin GPIO                               |
 * | "LEDS"           | Blue & white leds                         |
 * | "2-CH INFRA"     | 2-channel infrared receiver               |
 * | "HEAT SINK"      | heatsink for all VIM SBCs and Edge-V SBCs |
 */
FL_PCB_VIM1 = let(
  screw = M2_cap_screw,
  d     = screw_radius(screw)*2,
  pcb_t = 1,
  comps = [
    ["USB 2.0 900mA", fl_Component(FL_USB_NS,     [0.63, -47.6, 1.2],[+Z,-90 ],[-Y],FL_USB_TYPE_Ax1_NF_SM,[[FL_COMP_DRIFT,-2],[FL_COMP_COLOR,fl_grey(30)],[FL_COMP_OCTANT,+X+Y+Z]]) ],
    ["USB-C",         fl_Component(FL_USB_NS,     [19, -48-2.15, 0], [+Z,-90 ],[-Y],FL_USB_TYPE_C,[[FL_COMP_DRIFT,-1.5],[FL_COMP_OCTANT,+X+Y+Z]] )],
    ["HDMI0",         fl_Component(FL_HDMI_NS,    [31,  -45.3-0.2,  1.1],     [+Z,-90 ],[-Y],  FL_HDMI_TYPE_A ,[[FL_COMP_DRIFT,-1.5],[FL_COMP_OCTANT,+X+Y+Z]] )],
    ["uSD",           fl_Component(FL_SD_NS,      [(31+fl_bb_size(FL_HDMI_TYPE_A).y/2-fl_bb_size(FL_SD_MOLEX_uSD_SOCKET).x/2), -44.5, -pcb_t],  [-Z,0   ],[-Y], FL_SD_MOLEX_uSD_SOCKET, [[FL_COMP_OCTANT,-X-Y+Z],[FL_COMP_DRIFT,0*2]] )],
    ["ETHERNET",      fl_Component(FL_ETHER_NS,   [48.6+7.2,-44.9-11.1,0],  [+Z,-90 ],[-Y],  FL_ETHER_RJ45_SM,[[FL_COMP_DRIFT,-2*FL_ETHER_FRAME_T]] )] ,
    ["USB 2.0 500mA", fl_Component(FL_USB_NS,     [68.23, -47.6, 1.2],        [+Z,-90 ],[-Y],  FL_USB_TYPE_Ax1_NF_SM,[[FL_COMP_DRIFT,-2],[FL_COMP_COLOR,fl_grey(30)],[FL_COMP_OCTANT,+X+Y+Z]] )],
    ["POWER",         fl_Component(FL_SWT_NS,     [3.02, -9.96, 0],       [+Z,180 ],[-X],FL_SWT_USWITCH_7p2x3p4x3x2p5, [[FL_COMP_OCTANT,+X+Y+Z]] )],
    ["FUNCTION",      fl_Component(FL_SWT_NS,     [3.02, -19.99, 0],        [+Z,180 ],[-X],FL_SWT_USWITCH_7p2x3p4x3x2p5, [[FL_COMP_OCTANT,+X+Y+Z]] )],
    ["RESET",         fl_Component(FL_SWT_NS,     [3.02, -30.02, 0],        [+Z,180 ],[-X],FL_SWT_USWITCH_7p2x3p4x3x2p5, [[FL_COMP_OCTANT,+X+Y+Z]] )],
    ["GPIO",          fl_Component(FL_PHDR_NS,    [31.5,  -3.2, 0],         [+Z,0 ],[+Z],  FL_PHDR_GPIOHDR)],
    ["LEDS",          fl_Component(FL_GENERIC_NS, [73.3,  -3.65,  0],     [+Z,0 ],[+Y],  fl_generic_Vitamin(bbox=[O,[2,3.5,1]],cut_directions=[+Y]))],
    ["2-CH INFRA",    fl_Component(FL_GENERIC_NS, [65.5, -3.04,     0],     [+Z,0 ],[+Y],  fl_generic_Vitamin(bbox=[O,[6.8,3,3.5]],cut_directions=[+Y]))],
    ["HEAT SINK",     fl_Component(FL_HS_NS,      [0.5,   -0.5, 0],         [+Z,0 ],[+Z],  FL_HS_KHADAS, [[FL_COMP_OCTANT,+X-Y+Z]] )],
  ],
  gpio_c  = fl_comp_connectors(comps[9][1])[0],
  conns   = [
    fl_conn_clone(gpio_c,type="plug",direction=[+Z,-90],octant=-X-Y),
  ]
) fl_PCB(
  "KHADAS-SBC-VIM1",
  [[0,-56,-1],[82,0,0]],
  thick=pcb_t,
  holes=[
    fl_Hole([2.5  ,-2.5 ,0] ,d,+Z,pcb_t),
    fl_Hole([79.5 ,-2.5 ,0] ,d,+Z,pcb_t),
    fl_Hole([16.5 ,-48  ,0] ,d,+Z,pcb_t),
    fl_Hole([65.5 ,-48  ,0] ,d,+Z,pcb_t),
  ],
  components  = comps,
  screw       = screw,
  dxf         = "vitamins/vim1.dxf",
  color       = "DarkOliveGreen",
  connectors  = conns
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
  FL_PCB_VIM1,
];

//! select a pcb by name
function fl_pcb_select(
  //! name as returned by fl_name()
  name,
  inventory = FL_PCB_DICT
) = fl_switch(name,fl_list_pack(fl_dict_names(inventory),inventory));

//! returns a list with all the components label
function fl_pcb_compLabels(type)  = let(
  specs = fl_pcb_components(type)
) [for(s=specs) s[0]];

/*!
  * Filter the pcb component labels according to «rules».
  *
  * The algorithm used will setup one function literal for all the assertive
  * labels (the ones without any preceding '-' char) and as many function
  * literals as the negate labels (the ones with '-' char) present in the list.
  * This function literals list will be passed to fl_list_filter(). The
  * resulting logic will include all the component labels of a pcb appearing in
  * the assertive filter AND not listed in any of the negative ones.
  *
  * When undef all the supported components are used.
  *
  * Example:
  *
  *     // ASSEMBLY all components but "PIM BOT"
  *     fl_pcb(FL_ASSEMBLY,FL_PCB_RPI4,components="-PIM BOT");
  *
  *     // ASSEMBLY all components but "PIM BOT" and "PIM TOP"
  *     fl_pcb(FL_ASSEMBLY,FL_PCB_RPI4,components=["-PIM BOT","-PIM TOP"]);
  *
  *     // ASSEMBLY with only "PIM TOP" component
  *     fl_pcb(FL_ASSEMBLY,FL_PCB_RPI4,components="PIM TOP");
  *
  *     // ASSEMBLY with only "PIM BOT" and "PIM TOP" components
  *     fl_pcb(FL_ASSEMBLY,FL_PCB_RPI4,components=["PIM BOT","PIM TOP"]);
  *
  */
function fl_pcb_compFilter(pcb,rules) = let(
  rules = is_list(rules) ? rules : rules ? [rules] : [],
  // list of all component specifications ["label",component]
  all   = fl_pcb_components(pcb),
  neg_f = [
    // one filter function for each negative rule
    for(rule=rules)
      if (rule[0]=="-")
        let(_r = rule)
        function(comp_specs)
        let(comp_label=comp_specs[0])
        comp_label!=fl_substr(_r,1),
  ],
  add_f =
    let(add=[for(rule=rules) if (rule[0]!="-") rule])
    add ?
      function(comp_specs,_list=add)
        let(
          len       = len(_list),
          comp_label= comp_specs[0]
        )
        len==0 ?
          false :
          comp_label==_list[0] ?
            true :
            len==1 ?
              false :
              let(rest=fl_list_tail(_list,-1)) add_f(comp_specs,rest) :
      undef,
  filters = concat(
    neg_f,
    [
      // one filter function for all positive rule (if any)
      // this realizes the positive 'or' logic
      if (add_f)
        add_f
    ]
  )
) fl_list_filter(all,filters);

/*!
 * PCB engine.
 *
 * __Runtime context__
 *
 * | Name           | Description                         |
 * | ---            | ---                                 |
 * | $fl_tolerance  | used during FL_CUTOUT operations    |
 * | Debug context  | see fl_dbg_Context{} for details  |
 *
 * __Children context:__
 *
 * | Name           | Description                         |
 * | ---            | ---                                 |
 * | Hole context   | see fl_hole_Context{} for details   |
 * | $pcb_radius    | pcb radius                          |
 * | $pcb_thick     | pcb thickness                       |
 * | $pcb_verb      | pcb invoked verb                    |
 */
module fl_pcb(
  //! FL_ADD, FL_ASSEMBLY, FL_AXES, FL_BBOX, FL_CUTOUT, FL_DRILL, FL_LAYOUT, FL_PAYLOAD
  verbs=FL_ADD,
  type,
  /*!
   * List of labels defining the components used during FL_ASSEMBLY and
   * FL_CUTOUT. The possible value are all the component labels defined by the
   * pcb. When inserting a plain label, the corresponding component will be used
   * during verb execution, while a label preceded with the '-' will exclude it
   * from verb execution.
   *
   * The algorithm used will setup one function literal for all the assertive
   * labels (the ones without any preceding '-' char) and as many function
   * literals as the negate labels (the ones with '-' char) present in the list.
   * This function literals list will be passed to fl_list_filter(). The
   * resulting logic will include all the component labels of a pcb appearing in
   * the assertive filter AND not listed in any of the negative ones.
   *
   * When undef all the supported components are used.
   *
   * Example:
   *
   *     // ASSEMBLY all components but "PIM BOT"
   *     fl_pcb(FL_ASSEMBLY,FL_PCB_RPI4,components="-PIM BOT");
   *
   *     // ASSEMBLY all components but "PIM BOT" and "PIM TOP"
   *     fl_pcb(FL_ASSEMBLY,FL_PCB_RPI4,components=["-PIM BOT","-PIM TOP"]);
   *
   *     // ASSEMBLY with only "PIM TOP" component
   *     fl_pcb(FL_ASSEMBLY,FL_PCB_RPI4,components="PIM TOP");
   *
   *     // ASSEMBLY with only "PIM BOT" and "PIM TOP" components
   *     fl_pcb(FL_ASSEMBLY,FL_PCB_RPI4,components=["PIM BOT","PIM TOP"]);
   *
   */
  components,
  /*!
   * Floating semi-axis list in the host's reference system (see also fl_tt_isAxisList()).
   *
   * This parameter sets a filter used during FL_CUTOUT, causing the trigger of
   * all and only the PCB components implementing cut out along at least one of
   * the passed directions
   *
   *    cut_direction=[+X,-Z]
   *
   * in this case all the components implementing cut-out along +X or -Z will
   * be triggered during the FL_CUTOUT.
   */
  cut_direction,
  /*!
   * thickness of any surrounding surface in fixed form
   *  [[-X,+X],[-Y,+Y],[-Z,+Z]] or scalar shortcut
   */
  thick=0,
  //! FL_ASSEMBLY,FL_LAYOUT,FL_MOUNT directions in floating semi-axis list form
  lay_direction=[+Z],
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef
  direction
) {
  assert(!fl_dbg_assert() || is_list(verbs)||is_string(verbs),verbs);

  module native() {

    pcb_t     = fl_pcb_thick(type);
    size      = fl_bb_size(type);
    bbox      = fl_bb_corners(type);
    pload     = fl_has(type,fl_payload()[0]) ? fl_payload(type) : undef;
    holes     = fl_holes(type);
    screw     = fl_has(type,fl_screw()[0]) ? fl_screw(type) : undef;
    screw_r   = screw ? screw_radius(screw) : 0;
    thick     = is_num(thick) ? [[thick,thick],[thick,thick],[thick,thick]]
              : assert(!fl_dbg_assert() || fl_tt_isAxisVList(thick)) thick;
    neg_delta = -pcb_t-bbox[0].z;
    dr_thick  = pcb_t+neg_delta+thick.z[0]; // thickness along -Z
    cut_thick = thick;
    material  = fl_material(type,default="green");
    radius    = fl_pcb_radius(type);
    grid      = fl_has(type,fl_pcb_grid()[0]) ? fl_pcb_grid(type) : undef;
    dxf       = fl_optional(type,fl_dxf()[0]);
    conns     = fl_optional(type,fl_connectors()[0]);
    lay_array = fl_pcb_layoutArray(type);
    comps     = components ?
      fl_pcb_compFilter(type,components) :
      fl_pcb_components(type);

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
      /*!
      * Return the grid size in [cols,rows] format
      */
      function fl_grid_geometry(grid,size) = let(
          cols  = is_undef(grid[2]) ? round((size.x - 2 * grid.x) / inch(0.1))  : grid[2] - 1,
          rows  = is_undef(grid[3]) ? round((size.y - 2 * grid.y) / inch(0.1))  : grid[3] - 1
        ) [cols,rows];

      t               = pcb_t;
      plating         = 0.1;
      fr4             = material != "sienna";
      plating_color  = is_undef(grid[4]) ? ((material == "green" || material == "#2140BE") ? silver : material == "sienna" ? copper : gold) : grid[4];
      color(plating_color)
        translate(-Z(plating))
          linear_extrude(fr4 ? t + 2 * plating : plating) {
            fl_grid_layout(
              step    = inch(0.1),
              bbox    = bbox+[grid,-grid],
              clip    = false
            ) difference() {
              circle(d=2);
              circle(d=2-2xNIL-2*0.5);
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
    // then translate according the bounding box. This doesn't match the behavior followed
    // for holes, that are instead already placed in the final full 3d space
    module do_add() {
      fl_color(material) difference() {
        translate(-Z(pcb_t)) linear_extrude(pcb_t)
          difference() {
            if (dxf)
              fl_importDxf(file=dxf,layer="0");
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
            if ($comp_subtract!=undef) {
              /*
               * TODO: either extend to all the engines once sure FL_FOOTPRINT
               * is implemented for all of them or eliminate it and use dxf
               */
              /*
               * FIXME: fl_USB{} doesn't have a «tolerance» parameter
               */
              if ($comp_engine==FL_USB_NS)
                fl_USB(verbs=FL_FOOTPRINT,type=$comp_type,direction=$comp_direction/* ,tolerance=$comp_subtract */);
            }
        if (holes)
          fl_holes(holes,[-X,+X,-Y,+Y,-Z,+Z],pcb_t);

        // generates drills on pcb from components
        // TODO: extends to all the supported components
        do_layout("components")
          if ($comp_director==+Z||$comp_director==-Z)
            if ($comp_engine==FL_PHDR_NS)
              translate(+Z(NIL)) fl_pinHeader([FL_DRILL],$comp_type,cut_thick=pcb_t+2xNIL,octant=$comp_octant,direction=$comp_direction);

      }
      if (grid)
        translate(-Z(pcb_t)) grid_plating();

    }

    module context() {
      $pcb_radius = radius;
      $pcb_thick  = pcb_t;
      $pcb_verb   = $this_verb;
      children();
    }

    module do_layout(class,directions) {

      module filter(dirs)
        for(c=comps)
          fl_comp_Specs(c)
            if (dirs) {
              // filter component whose cut_direction(s) is present in the
              // component direction list
              let(
                // transform component directions into pcb coordinate system
                dirs  = fl_cutout($comp_type),
                D     = fl_direction($comp_direction),
                new   = [for(d=dirs) fl_transform(D,d)]
              )
              if (search(new,cut_direction)!=[[]])
                children();
            } else {
              // no direction filtering
              children();
            }

      if (class=="components")
        filter(directions)
          translate($comp_position)
            children();
      else if (class=="holes")
        fl_lay_holes(holes,lay_direction,screw=screw)
          context()
            children();
      else
        assert(false,str("unknown component class '",class,"'."));
    }

    module do_assembly() {
      do_layout("components") let(
        selected  = fl_dbg_components($comp_label),
        verbs     = [
          FL_ADD,
          if (selected) FL_AXES
        ],
        $FL_ADD   = selected ? "DEBUG" : $FL_ADD,
        $FL_AXES  = selected ? "ON"    : "OFF"
      ) if ($comp_engine==FL_USB_NS)          // USB
          fl_USB(verbs,type=$comp_type,octant=$comp_octant,direction=$comp_direction,tongue=$comp_color);
        else if ($comp_engine==FL_HDMI_NS)    // HDMI
          fl_hdmi(verbs,type=$comp_type,octant=$comp_octant,direction=$comp_direction);
        else if ($comp_engine==FL_JACK_NS)    // JACK
          fl_jack(verbs,type=$comp_type,direction=$comp_direction,octant=$comp_octant);
        else if ($comp_engine==FL_ETHER_NS)   // ETHERNET
          fl_ether(verbs,type=$comp_type,octant=$comp_octant,direction=$comp_direction);
        else if ($comp_engine==FL_PHDR_NS)    // PIN HEADER
          fl_pinHeader(verbs,type=$comp_type,octant=$comp_octant,direction=$comp_direction);
        else if ($comp_engine==FL_TRIM_NS)    // TRIM POT
          fl_trimpot(verbs,type=$comp_type,direction=$comp_direction,octant=$comp_octant);
        else if ($comp_engine==FL_SD_NS)      // SECURE DIGITAL
          fl_sd_usocket(verbs,type=$comp_type,octant=$comp_octant,direction=$comp_direction);
        else if ($comp_engine==FL_SWT_NS) {   // SWITCH
          fl_switch(verbs,type=$comp_type,octant=$comp_octant,direction=$comp_direction);
        } else if ($comp_engine==FL_HS_NS)    // HEAT SINK
          fl_heatsink(verbs,type=$comp_type,octant=$comp_octant,direction=$comp_direction);
        else if ($comp_engine==FL_GENERIC_NS) // GENERIC VITAMIN
          fl_generic_vitamin(verbs,$comp_type,octant=$comp_octant,direction=$comp_direction);
        else
          assert(false,str("Unknown engine ",$comp_engine));
    }

    // FIXME: components should modify also the hole layout
    module do_mount() {
      if (holes)
        fl_lay_holes(holes,lay_direction)
          let(scr = is_undef($hole_screw) ? screw : $hole_screw)
            if (scr) fl_screw([FL_ADD,FL_ASSEMBLY],type=scr,$fl_thickness=dr_thick);
    }

    module do_drill() {
      fl_lay_holes(holes,lay_direction)
        fl_cylinder(d=$hole_d,h=dr_thick,octant=-$hole_n);
    }

    module do_cutout() {
      // triggers the component in context
      module trigger() {
        cut_thick = $comp_director==+X ? cut_thick.x[1] : $comp_director==-X ? cut_thick.x[0]
                  : $comp_director==+Y ? cut_thick.y[1] : $comp_director==-Y ? cut_thick.y[0]
                  : $comp_director==+Z ? cut_thick.z[1] : cut_thick.z[0];
        // echo(str("fl_pcb{} do_cutout{} trigger{",$comp_engine,"} cut_thick=",cut_thick))

        if ($comp_engine==FL_USB_NS)
          fl_USB(FL_CUTOUT,$comp_type,cut_thick=cut_thick-$comp_drift,cut_tolerance=$fl_tolerance,cut_dirs=fl_comp_actualCuts(cut_direction),octant=$comp_octant,direction=$comp_direction,cut_drift=$comp_drift);
        else if ($comp_engine==FL_HDMI_NS)
          fl_hdmi(FL_CUTOUT,$comp_type,$fl_thickness=cut_thick-$comp_drift,cut_drift=$comp_drift,octant=$comp_octant,direction=$comp_direction);
        else if ($comp_engine==FL_JACK_NS)
          fl_jack(FL_CUTOUT,$comp_type,$fl_thickness=cut_thick-$comp_drift,cut_drift=$comp_drift,octant=$comp_octant,direction=$comp_direction);
        else if ($comp_engine==FL_ETHER_NS)
          fl_ether(FL_CUTOUT,$comp_type,$fl_thickness=cut_thick-$comp_drift,$fl_tolerance=$fl_tolerance,cut_drift=$comp_drift,cut_dirs=fl_comp_actualCuts(cut_direction),octant=$comp_octant,direction=$comp_direction);
        else if ($comp_engine==FL_PHDR_NS) let(
            thick = bbox[1].z+cut_thick
          ) fl_pinHeader(FL_CUTOUT,$comp_type,cut_thick=thick,cut_tolerance=$fl_tolerance,octant=$comp_octant,direction=$comp_direction);
        else if ($comp_engine==FL_TRIM_NS) let(
            sz    = fl_bb_size($comp_type),
            thick = bbox[1].z-sz.y+cut_thick
          ) fl_trimpot(FL_CUTOUT,type=$comp_type,cut_thick=thick,cut_tolerance=$fl_tolerance,cut_drift=$comp_drift,direction=$comp_direction,octant=$comp_octant);
        else if ($comp_engine==FL_SD_NS)
          fl_sd_usocket(FL_CUTOUT,type=$comp_type,cut_thick=cut_thick+2,cut_tolerance=$fl_tolerance,octant=$comp_octant,direction=$comp_direction);
        else if ($comp_engine==FL_SWT_NS)
          fl_switch(FL_CUTOUT,type=$comp_type,cut_thick=cut_thick-$comp_drift,cut_tolerance=$fl_tolerance,cut_drift=$comp_drift,octant=$comp_octant,direction=$comp_direction);
        else if ($comp_engine==FL_HS_NS)
          // TODO: implement a rationale for heat-sinks cut-out operations
          fl_heatsink(FL_CUTOUT,type=$comp_type,cut_dirs=fl_comp_actualCuts(cut_direction),$fl_thickness=cut_thick-$comp_drift,cut_drift=$comp_drift,octant=$comp_octant,direction=$comp_direction);
        else if ($comp_engine==FL_GENERIC_NS)
          fl_generic_vitamin(FL_CUTOUT,$comp_type,$fl_thickness=cut_thick-$comp_drift,cut_drift=$comp_drift,octant=$comp_octant,direction=$comp_direction);
        else
          fl_error(["Unknown engine: '",$comp_engine,"'"]);
      }

      do_layout(class="components", directions=cut_direction)
        trigger();
    }

    module do_payload() {
      if (pload)
        fl_bb_add(pload,$FL_ADD=$FL_PAYLOAD);
    }

    module do_symbols(connectors,holes) {
      if (fl_dbg_symbols()) {
        if (connectors)
          fl_conn_debug(connectors);
        if (holes)
          fl_hole_debug(holes);
      }
    }

    // FIXME: currently $fl_tolerance in dxf based pcbs is applied only on
    // Z-axis
    module do_fprint() {
      translate(-Z(pcb_t+$fl_tolerance))
        linear_extrude(pcb_t+2*$fl_tolerance)
          if (dxf)
            fl_importDxf(file=dxf,layer="0");
          else
            translate(bbox[0]-$fl_tolerance*[1,1])
              fl_square(corners=radius,size=[size.x,size.y]+2*$fl_tolerance*[1,1],quadrant=+X+Y,$FL_ADD=$FL_FOOTPRINT);
    }

    if ($verb==FL_ADD) {
      do_symbols(conns,holes);
      do_add();

    } else if ($verb==FL_ASSEMBLY)
      do_assembly();

    else if ($verb==FL_BBOX)
      fl_bb_add(bbox);

    else if ($verb==FL_CUTOUT)
      do_cutout();

    else if ($verb==FL_DRILL)
      do_drill();

    else if ($verb==FL_FOOTPRINT)
      do_fprint();

    else if ($verb==FL_LAYOUT)
      do_layout("holes")
        children();

    else if ($verb==FL_MOUNT)
      do_mount();

    else if ($verb==FL_PAYLOAD)
      do_payload();

    else
      fl_error(["unimplemented verb",$this_verb]);
  }

  if (fl_optProperty(type,fl_engine()[0])==FL_PCB_ENGINE_FRAME)
    fl_pcb_frame(verbs,type,thick=thick,lay_direction=lay_direction,cut_tolerance=$fl_tolerance,components=components,cut_direction=cut_direction,direction=direction,octant=octant)
      children();
  else
    fl_vmanage(verbs,type,octant=octant,direction=direction)
      native()
        children();

}

/*!
 * PCB adapter for NopSCADlib.
 *
 * While full attributes rendering is supported via NopSCADlib APIs, only basic
 * support is provided to OFL verbs, sometimes even with different behavior:
 *
 * - FL_ADD       : being impossible to render NopSCADlib pcbs without components,
 *                  this verb always renders components too;
 * - FL_ASSEMBLY  : only screws are added during assembly, since
 *                  components are always rendered during FL_ADD;
 * - FL_AXES      : no changes;
 * - FL_BBOX      : while OFL native PCBs includes also components sizing in
 *                  bounding box calculations, the adapter bounding box is
 *                  'reduced' to pcb only. The only way to mimic OFL native
 *                  behavior is to explicitly add the payload capacity through
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
 *
 * TODO: fix FL_ASSEMBLY behavior splitting screws to FL_MOUNT
 */
module fl_pcb_adapter(
  //! FL_ADD, FL_ASSEMBLY, FL_AXES, FL_BBOX, FL_CUTOUT, FL_DRILL, FL_LAYOUT, FL_PAYLOAD
  verbs=FL_ADD,
  type,
  //! FL_DRILL thickness in fixed form [[-X,+X],[-Y,+Y],[-Z,+Z]] or scalar shortcut
  thick=0,
  //! pay-load bounding box, is added to the overall bounding box calculation
  payload,
  //! when undef native positioning is used
  octant,
  //! desired direction [director,rotation], native direction when undef
  direction
) {
  assert(!fl_dbg_assert() || is_list(verbs)||is_string(verbs),verbs);

  fl_trace("thick",thick);

  pcb_t     = pcb_thickness(type);
  comps     = pcb_components(type);
  size      = pcb_size(type);
  bbox      = let(bare=[[-size.x/2,-size.y/2,0],[+size.x/2,+size.y/2,+size.z]]) payload ? fl_bb_calc([bare,payload]) : bare;
  holes     = fl_pcb_NopHoles(type);
  screw     = pcb_screw(type);
  screw_r   = screw ? screw_radius(screw) : 0;
  thick     = is_num(thick) ? [[thick,thick],[thick,thick],[thick,thick]]
            : assert(!fl_dbg_assert() || fl_tt_isAxisVList(thick)) thick;
  dr_thick  = thick.z[0]; // thickness along -Z
  material  = fl_material(type,default="green");
  radius    = pcb_radius(type);
  grid      = pcb_grid(type);

  D         = direction ? fl_direction(direction)  : I;
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
        fl_screw([FL_ADD,FL_ASSEMBLY],type=screw,nut="default",$fl_thickness=dr_thick+pcb_t,nwasher=true);
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

  fl_vloop(verbs,bbox,octant,direction) {
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
      fl_error(["unimplemented verb",$this_verb]);
  }
}

//**** PCB Frames *************************************************************

/*!
 * A PCB frame is a size driven adapter for PCBs, providing them the necessary
 * holes to be fixed in a box.
 *
 * This Constructor assumes the bare PCB bounding box depth is from -«pcb thick»
 * to 0.
 */
function fl_pcb_Frame(
  //! pcb object to be framed
  pcb,
  //! nominal screw ⌀
  d=2,
  /*!
   * List of Z-axis thickness for top and bottom faces or a common scalar value
   * for both.
   *
   * Positive value set thickness for the top face, negative for bottom while a
   * scalar can be used for both.
   *
   *     faces = [+3,-1]
   *
   * is interpreted as 3mm top, 1mm bottom
   *
   *     faces = [-1]
   *
   * is interpreted as 1mm bottom
   *
   *     faces = 2
   *
   * is interpreted as 2mm for top and bottom faces
   *
   */
  faces=1.2,
  //! distance between holes and external frame dimensions
  wall=1.5,
  /*!
   * overlap in the form [wide,thin]: wide overlap is along major pcb dimension,
   * thin overlap is along the minor pcb one
   */
  overlap=[1,0.5],
  /*!
   * inclusion is the size along major pcb dimension, laterally surrounding the pcb
   */
  inclusion=5,
  countersink=false,
  /*!
   * Frame layout method:
   *
   *     - "auto" (default) : auto detected based on PCB dimensions
   *     - "horizontal"     : holders are deployed horizontally from left to
   *                          right
   *     - "vertical"       : holders are deployed vertically from bottom to top
   */
  layout="auto"
) = let(
  horizontal  = layout=="auto" ? assert(pcb) let(sz=fl_bb_size(pcb)) sz.x>sz.y : layout=="horizontal",
  r           = d/2,
  pcb_bb      =
    assert(pcb)
    let(
      bb  = fl_bb_corners(pcb)
    ) horizontal ? bb : let(
      cog     = bb[0]+(bb[1]-bb[0])/2,
      R       = T(cog)*fl_R(+Z,90)*T(-cog),
      corners = fl_list_transform(bb,R)
    ) [
      [min(corners[0].x,corners[1].x),min(corners[0].y,corners[1].y),min(corners[0].z,corners[1].z)],
      [max(corners[0].x,corners[1].x),max(corners[0].y,corners[1].y),max(corners[0].z,corners[1].z)]
    ],

  // FROM HERE ONWARDS THE ALGORITHM BEHAVES AS IF THE LAYOUT WERE 'HORIZONTAL'
  pcb_cog = pcb_bb[0]+(pcb_bb[1]-pcb_bb[0])/2,  // PCB's center of gravity
  pcb_t   = fl_pcb_thick(pcb),
  pcb_sz  = pcb_bb[1]-pcb_bb[0],
  screw   = fl_screw_search(d=d,head_type=countersink?hs_cs_cap:hs_cap)[0],
  faces   = fl_parm_SignedPair(faces),
  depth   = abs(faces[0])+faces[1]+pcb_t,
  delta   = [+r,-(r+wall)],
  bbox    = fl_bb_calc([
    // bare holder bounding box
    [[pcb_bb[0].x-wall, pcb_bb[0].y-(d+2*wall),-(1+pcb_t)],[pcb_bb[1].x+wall,pcb_bb[1].y+(d+2*wall),+1]],
    // PCB bounding box
    pcb_bb
    ]),
  // four holes at the pcb corners + Δ
  holes   = [
      for(
        x=[pcb_bb[0].x+delta.x,pcb_bb[1].x-delta.x],
        y=[pcb_bb[0].y+delta.y,pcb_bb[1].y-delta.y]
      ) fl_Hole([x,y,faces[1]],d,depth=depth,screw=screw)
    ],
  w_over  = overlap[0],
  t_over  = overlap[1],
  /*
   * left bottom corner sector: we use the list transform function for
   * translating the 2d points returned from fl_sector() to the first hole.
   * NOTE: we drop first sector point (the center)
   */
  sec_lb  = fl_list_transform(
    // exclude first point (i.e. sector's center)
    fl_list_sub(fl_sector(r=r+wall, angles=[180,270]),1),
    // translation to holes[0]
    T(fl_hole_pos(holes[0])),
    FL_3D,FL_2D
  ),
  // left side internal points
  pts_l     = [
    [pcb_bb[0].x+inclusion, pcb_bb[0].y-(d+2*wall)],
    [pcb_bb[0].x+inclusion, pcb_bb[0].y+t_over],
    [pcb_bb[0].x+w_over,    pcb_bb[0].y+t_over],
    [pcb_bb[0].x+w_over,    pcb_bb[1].y-t_over],
    [pcb_bb[0].x+inclusion, pcb_bb[1].y-t_over],
    [pcb_bb[0].x+inclusion, pcb_bb[1].y+(d+2*wall)],
  ],
  // left top corner sector: see comment about left bottom corner sector
  sec_lt  = fl_list_transform(
    // sector center removal
    fl_list_sub(fl_sector(r=r+wall, angles=[90,180]),1),
    // translation to holes[1]
    T(fl_hole_pos(holes[1])),
    FL_3D,FL_2D
  ),
  left = concat(sec_lb,pts_l,sec_lt),
  // +180° rotation around axis PCB's center of gravity
  right = fl_list_transform(left,T(pcb_cog) * fl_R(+Z,180) * T(-pcb_cog),FL_3D,FL_2D),
  // if the layout is 'vertical' we need to rotate back -90° the results
  M_back        = horizontal ? I      : T(pcb_cog) * fl_R(+Z,-90) * T(-pcb_cog),
  result_bbox   = horizontal ? bbox   : fl_bb_polyhedron(fl_list_transform(bbox,M_back)),
  result_left   = horizontal ? left   : fl_list_transform(left,M_back,FL_3D,FL_2D),
  result_right  = horizontal ? right  : fl_list_transform(right,M_back,FL_3D,FL_2D),
  result_holes  = horizontal ? holes : [
      for(hole=holes)
        let(p=fl_transform(M_back,fl_hole_pos(hole)))
          fl_Hole([p.x,p.y,faces[1]],d,depth=depth,screw=screw)
    ]
) [
  fl_OFL(value=true),
  fl_pcb(value=pcb),
  fl_bb_corners(value=result_bbox),
  ["pcbf/wall",wall],
  ["pcbf/inclusion",inclusion],
  ["pcbf/overlap",overlap],
  ["pcbf/left side points",result_left],
  fl_screw(value=screw),
  fl_holes(value=result_holes),
  ["pcbf/right side points",result_right],
  ["pcbf/[bottom,top] face thickness",faces],
  fl_engine(value=FL_PCB_ENGINE_FRAME),
  // 'proxyfied' properties
  fl_pcb_thick(value=function(frame,key,default)        fl_pcb_thick(pcb)),
  fl_pcb_components(value=function(frame,key,default)   fl_pcb_components(pcb)),
  fl_pcb_radius(value=function(frame,key,default)       fl_pcb_radius(pcb)),
  fl_pcb_layoutArray(value=function(frame,key,default)  fl_pcb_layoutArray(pcb)),
];

/*
 * PCB frame engine.
 *
 * This engine acts mostly as a proxy forwarding verbs to its embedded PCB.
 *
 */
module fl_pcb_frame(
  //! supported verbs: FL_ADD, FL_ASSEMBLY, FL_BBOX, FL_DRILL, FL_FOOTPRINT, FL_LAYOUT
  verbs       = FL_ADD,
  this,
  //! see homonymous parameter for fl_pcb{}
  cut_tolerance=0,
  //! see homonymous parameter for fl_pcb{}
  components,
  //! see homonymous parameter for fl_pcb{}
  cut_direction,
  //! see homonymous parameter for fl_pcb{}
  thick=0,
  //! see homonymous parameter for fl_pcb{}
  lay_direction=[+Z],
  frame_tolerance=0.2,
  /*!
   * PCB frame part visibility: defines which frame parts are shown.
   *
   * The full form is [«left|bottom part»,«right|top part»], where each list
   * item is a boolean managing the visibility of the corresponding part.
   *
   * Setting this parameter as a single boolean extends its value to both the parts.
   */
  frame_parts=true,
  //! desired direction [director,rotation], native direction when undef ([+X+Y+Z])
  direction,
  //! when undef native positioning is used
  octant,
) {
  assert(is_list(verbs)||is_string(verbs),verbs);

  bbox  = fl_bb_corners(this);
  size  = fl_bb_size(this);
  D     = direction ? fl_direction(direction) : I;
  M     = octant    ? fl_octant(octant,bbox=bbox) : I;

  screw       = fl_screw(this);
  d           = fl_screw_nominal(screw);
  r           = d/2;
  pcb         = fl_pcb(this);
  pcb_bb      = fl_bb_corners(pcb);
  pcb_t       = fl_pcb_thick(pcb);
  pcb_bare_sz = let(sz=pcb_bb[1]-pcb_bb[0]) [sz.x,sz.y,pcb_t];
  faces       = fl_property(this,"pcbf/[bottom,top] face thickness");
  depth       = abs(faces[0])+faces[1]+pcb_t;
  thick       = is_num(thick) ? [[thick,thick],[thick,thick],[thick,thick]]
              : assert(!fl_dbg_assert() || fl_tt_isAxisVList(thick)) thick;
  dr_thick    = depth+thick.z[0]; // thickness along -Z
  holes       = fl_holes(this);
  wall        = fl_property(this,"pcbf/wall");
  inclusion   = fl_property(this,"pcbf/inclusion");
  overlap     = fl_property(this,"pcbf/overlap");
  w_over      = overlap[0];
  t_over      = overlap[1];
  left        = (is_bool(frame_parts) ? frame_parts : frame_parts[0]) ? fl_property(this,"pcbf/left side points") : undef;
  right       = (is_bool(frame_parts) ? frame_parts : frame_parts[1]) ? fl_property(this,"pcbf/right side points") : undef;

  module do_symbols(holes) {
    if (holes)
      fl_hole_debug(holes);
  }

  module do_add() {
    fl_color()
      difference() {
        translate(-Z(abs(faces[0])+pcb_t))
          linear_extrude(depth) {
            if (left)
              polygon(left);
            if (right)
              polygon(right);
          }
        // remove PCB footprint
        translate(+Z(frame_tolerance/2))
          resize(pcb_bare_sz+frame_tolerance*[1,1,1])
            fl_pcb(FL_FOOTPRINT,pcb,$FL_FOOTPRINT="ON");
        // remove holes
        translate(-Z(0))
          fl_screw_holes(holes,[+Z], countersunk=true, tolerance=frame_tolerance, $FL_DRILL="ON");
      }
  }

  module do_assembly() {
    fl_pcb(FL_DRAW,type=pcb,components=components);
  }

  module do_cutout() {
    fl_pcb(FL_CUTOUT,pcb,$fl_tolerance=cut_tolerance,components=components,cut_direction=cut_direction,thick=thick, direction=direction, octant=octant);
  }

  module do_drill() {
    translate(-Z(depth))
    fl_screw_holes(holes,depth=thick,enable=lay_direction);
  }

  module do_footprint() {
    translate(-Z(pcb_t-faces[0]))
      linear_extrude(depth)
        fl_square(size=[size.x,size.y],corners=[for(hole=holes) fl_hole_d(hole)],$FL_ADD=$FL_FOOTPRINT);
  }

  module do_layout() {
    fl_lay_holes(holes,lay_direction)
      children();
  }

  module do_mount() {
    fl_lay_holes(holes,lay_direction)
      fl_screw([FL_ADD,FL_ASSEMBLY],type=$hole_screw,$fl_thickness=dr_thick);
  }

  module do_pload() {

  }

  fl_vloop(verbs,bbox,octant,direction) {
    if ($verb==FL_ADD) {
      do_symbols(holes=holes);
      fl_modifier($modifier) do_add();

    } else if ($verb==FL_ASSEMBLY) {
      fl_modifier($modifier) do_assembly();

    } else if ($verb==FL_BBOX) {
      fl_modifier($modifier) fl_bb_add(bbox,$FL_ADD=$FL_BBOX);

    } else if ($verb==FL_CUTOUT) {
      fl_modifier($modifier) do_cutout();

    } else if ($verb==FL_DRILL) {
      fl_modifier($modifier) do_drill();

    } else if ($verb==FL_FOOTPRINT) {
      fl_modifier($modifier) do_footprint();

    } else if ($verb==FL_LAYOUT) {
      fl_modifier($modifier) do_layout()
        children();

    } else if ($verb==FL_MOUNT) {
      fl_modifier($modifier) do_mount()
        children();

    } else if ($verb==FL_PAYLOAD) {
      fl_modifier($modifier)
        fl_pcb($verb,pcb);

    } else {
      fl_error(["unimplemented verb",$this_verb]);
    }
  }
}
