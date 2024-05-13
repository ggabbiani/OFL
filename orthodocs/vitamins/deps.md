# Dependencies

```mermaid
graph TD
    A1[vitamins/countersinks]
    A2[vitamins/ethers]
    A3[vitamins/fans]
    A4[vitamins/generic]
    A5[vitamins/hdmi]
    A6[vitamins/hds] --o|include| A7[vitamins/sata]
    A6 --o|include| A8[vitamins/screw]
    A9[vitamins/heatsinks]
    A10[vitamins/iec] --o|include| A8
    A11[vitamins/jacks]
    A12[vitamins/knurl_nuts] --o|include| A8
    A13[vitamins/magnets] --o|include| A1
    A13 --o|include| A8
    A14[vitamins/pcbs] --o|include| A2
    A14 --o|include| A4
    A14 --o|include| A5
    A14 --o|include| A9
    A14 --o|include| A11
    A14 --o|include| A15[vitamins/pin_headers]
    A14 --o|include| A8
    A14 --o|include| A16[vitamins/sd]
    A14 --o|include| A17[vitamins/switch]
    A14 --o|include| A18[vitamins/trimpot]
    A14 --o|include| A19[vitamins/usbs]
    A15
    A20[vitamins/psus] --o|include| A8
    A7
    A21[vitamins/sata-adapters] --o|include| A7
    A8
    A16
    A22[vitamins/spdts]
    A17
    A23[vitamins/template]
    A18
    A19
```

