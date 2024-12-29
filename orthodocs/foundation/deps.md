# Dependencies

```mermaid
graph TD
    A1[foundation/2d-engine] --o|include| A2[foundation/unsafe_defs]
    A1 --o|use| A3[foundation/bbox-engine]
    A1 --o|use| A4[foundation/mngm-engine]
    A5[foundation/3d-engine] --o|include| A1
    A5 --o|use| A6[foundation/traits-engine]
    A5 --o|use| A7[foundation/type-engine]
    A8[foundation/algo-engine] --o|include| A5
    A3 --o|include| A9[foundation/core]
    A10[foundation/components] --o|include| A3
    A11[foundation/connect] --o|include| A12[foundation/util]
    A9
    A13[foundation/dimensions] --o|include| A2
    A13 --o|use| A5
    A13 --o|use| A3
    A14[foundation/fillet] --o|include| A5
    A15[foundation/grid] --o|include| A5
    A16[foundation/hole] --o|include| A17[foundation/label]
    A17 --o|include| A5
    A18[foundation/limits] --o|include| A9
    A4 --o|include| A2
    A4 --o|use| A3
    A19[foundation/quaternions]
    A20[foundation/template] --o|include| A2
    A6 --o|include| A9
    A7 --o|include| A9
    A7 --o|use| A3
    A2 --o|include| A9
    A12 --o|include| A5
```

