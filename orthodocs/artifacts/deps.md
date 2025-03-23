# Dependencies

```mermaid
graph TD
    A1[artifacts/box] --o|include| A2[artifacts/spacer]
    A1 --o|use| A3[artifacts/profiles-engine]
    A4[artifacts/caddy]
    A5[artifacts/din_rails]
    A6[artifacts/joints]
    A7[artifacts/pcb_holder] --o|include| A2
    A3
    A2
    A8[artifacts/t-nut]
    A9[artifacts/t-profiles]
    A10[artifacts/template]
```

