# Dependencies

```mermaid
graph TD
    A1[foundation/2d-engine] --o|include| A2[foundation/unsafe_defs]
    A1 --o|use| A3[foundation/bbox-engine]
    A1 --o|use| A4[foundation/mngm-engine]
    A5[foundation/3d-engine] --o|include| A1
    A5 --o|include| A6[foundation/type_trait]
    A5 --o|use| A7[foundation/polymorphic-engine]
    A8[foundation/algo-engine] --o|include| A5
    A3 --o|include| A9[foundation/core]
    A10[foundation/components] --o|include| A3
    A11[foundation/connect] --o|include| A12[foundation/util]
    A9
    A13[foundation/dimensions] --o|include| A2
    A13 --o|use| A5
    A13 --o|use| A3
    A13 --o|use| A7
    A14[foundation/drawio] --o|include| A1
    A15[foundation/fillet] --o|include| A5
    A16[foundation/grid] --o|include| A5
    A17[foundation/hole] --o|include| A18[foundation/label]
    A18 --o|include| A5
    A19[foundation/limits] --o|include| A9
    A4 --o|include| A9
    A7 --o|include| A9
    A7 --o|use| A5
    A7 --o|use| A3
    A7 --o|use| A4
    A20[foundation/profile] --o|include| A5
    A20 --o|include| A18
    A21[foundation/quaternions]
    A22[foundation/template] --o|include| A2
    A22 --o|use| A7
    A6 --o|include| A9
    A2 --o|include| A9
    A12 --o|include| A5
```

