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
    A13[foundation/drawio] --o|include| A1
    A14[foundation/fillet] --o|include| A5
    A15[foundation/grid] --o|include| A5
    A16[foundation/hole] --o|include| A17[foundation/label]
    A17 --o|include| A5
    A18[foundation/limits] --o|include| A9
    A4 --o|include| A9
    A7 --o|include| A9
    A7 --o|use| A5
    A7 --o|use| A3
    A7 --o|use| A4
    A19[foundation/profile] --o|include| A5
    A20[foundation/template] --o|include| A2
    A20 --o|use| A7
    A6 --o|include| A9
    A2 --o|include| A9
    A12 --o|include| A5
```

