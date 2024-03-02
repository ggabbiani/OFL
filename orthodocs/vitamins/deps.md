# Dependencies

```mermaid
graph TD
    A1[vitamins/countersinks]
    A2[vitamins/ethers]
    A3[vitamins/generic]
    A4[vitamins/hdmi]
    A5[vitamins/hds] --o|include| A6[vitamins/sata]
    A5 --o|include| A7[vitamins/screw]
    A8[vitamins/heatsinks]
    A9[vitamins/iec] --o|include| A7
    A10[vitamins/jacks]
    A11[vitamins/knurl_nuts] --o|include| A7
    A12[vitamins/magnets] --o|include| A1
    A12 --o|include| A7
    A13[vitamins/pcbs] --o|include| A2
    A13 --o|include| A3
    A13 --o|include| A4
    A13 --o|include| A8
    A13 --o|include| A10
    A13 --o|include| A14[vitamins/pin_headers]
    A13 --o|include| A7
    A13 --o|include| A15[vitamins/sd]
    A13 --o|include| A16[vitamins/switch]
    A13 --o|include| A17[vitamins/trimpot]
    A13 --o|include| A18[vitamins/usbs]
    A14
    A19[vitamins/psus] --o|include| A7
    A6
    A20[vitamins/sata-adapters] --o|include| A6
    A7
    A15
    A21[vitamins/spdts]
    A16
    A22[vitamins/template]
    A17
    A18
```

