# package vitamins/usbs


__Includes:__

    foundation/util

## Variables


---

### variable FL_USB_DICT

__Default:__

    [FL_USB_TYPE_Ax1,FL_USB_TYPE_Ax1_NF,FL_USB_TYPE_Ax2,FL_USB_TYPE_B,FL_USB_TYPE_C,FL_USB_TYPE_uA,FL_USB_TYPE_uA_NF,]

---

### variable FL_USB_NS

__Default:__

    "usb"

---

### variable FL_USB_TYPE_Ax1

__Default:__

    fl_USB_new("Ax1")

---

### variable FL_USB_TYPE_Ax1_NF

__Default:__

    fl_USB_new("Ax1",false)

---

### variable FL_USB_TYPE_Ax2

__Default:__

    fl_USB_new("Ax2")

---

### variable FL_USB_TYPE_B

__Default:__

    fl_USB_new("B")

---

### variable FL_USB_TYPE_C

__Default:__

    fl_USB_new("C")

---

### variable FL_USB_TYPE_uA

__Default:__

    fl_USB_new("uA")

---

### variable FL_USB_TYPE_uA_NF

__Default:__

    fl_USB_new("uA",false)

## Functions


---

### function fl_USB_flange

__Syntax:__

    fl_USB_flange(type,value)

---

### function fl_USB_new

__Syntax:__

    fl_USB_new(utype,flange=true)

---

### function fl_USB_type

__Syntax:__

    fl_USB_type(type,value)

## Modules


---

### module fl_USB

__Syntax:__

    fl_USB(verbs=FL_ADD,type,cut_thick,tolerance=0,cut_drift=0,tongue,direction,octant)

---

### module molex_usb_Ax1

__Syntax:__

    molex_usb_Ax1(cutout,tongue)

Draw Molex USB A connector suitable for perf board

---

### module molex_usb_Ax2

__Syntax:__

    molex_usb_Ax2(cutout,tongue)

Draw Molex dual USB A connector suitable for perf board

---

### module usb_A

__Syntax:__

    usb_A(h,v_flange_l,bar,cutout,tongue,flange=true)

---

### module usb_A_tongue

__Syntax:__

    usb_A_tongue(color)

---

### module usb_Ax1

__Syntax:__

    usb_Ax1(cutout=false,tongue="white",flange=true)

Draw USB type A single socket

---

### module usb_Ax2

__Syntax:__

    usb_Ax2(cutout=false,tongue="white")

Draw USB type A dual socket

---

### module usb_B

__Syntax:__

    usb_B(cutout=false)

Draw USB B connector

---

### module usb_C

__Syntax:__

    usb_C(cutout=false)

Draw USB C connector

---

### module usb_uA

__Syntax:__

    usb_uA(cutout=false,flange=true)

Draw USB micro A connector

