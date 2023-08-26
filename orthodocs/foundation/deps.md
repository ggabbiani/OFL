# Dependencies

```mermaid
graph TD
    A1[foundation/2d-engine] --o|include| A2[foundation/mngm]
    A1 --o|include| A3[foundation/unsafe_defs]
    A1 --o|use| A4[foundation/bbox-engine]
    A5[foundation/3d-engine] --o|include| A1
    A5 --o|include| A6[foundation/type_trait]
    A5 --o|use| A4
    A7[foundation/algo-engine] --o|include| A5
    A4 --o|include| A8[foundation/core]
    A9[foundation/components] --o|include| A4
    A10[foundation/connect] --o|include| A11[foundation/util]
    A8
    A12[foundation/drawio] --o|include| A1
    A13[foundation/fillet] --o|include| A5
    A14[foundation/grid] --o|include| A5
    A15[foundation/hole] --o|include| A16[foundation/label]
    A16 --o|include| A5
    A17[foundation/limits] --o|include| A8
    A2 --o|include| A8
    A18[foundation/profile] --o|include| A5
    A19[foundation/template] --o|include| A5
    A6 --o|include| A8
    A3 --o|include| A8
    A11 --o|include| A5
```

