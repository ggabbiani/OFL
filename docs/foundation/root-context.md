# Root context

The **Root context** controls the behavior of each OFL verb. Differently from
the other context, *Root* context doesn't provide an explicit constructor
module, since its variables are initialized by the library itself.

The list of modifier variables with their corresponding defaults are listed
below:

| Name          | Modified verb | Default       |
| ------------- | ------------- | ------------- |
| $FL_ADD       | FL_ADD        | "ON"          |
| $FL_ASSEMBLY  | FL_ASSEMBLY   | "ON"          |
| $FL_AXES      | FL_AXES       | "ON"          |
| $FL_BBOX      | FL_BBOX       | "TRANSPARENT" |
| $FL_CUTOUT    | FL_CUTOUT     | "ON"          |
| $FL_DRILL     | FL_DRILL      | "ON"          |
| $FL_FOOTPRINT | FL_FOOTPRINT  | "ON"          |
| $FL_LAYOUT    | FL_LAYOUT     | "ON"          |
| $FL_MOUNT     | FL_MOUNT      | "ON"          |
| $FL_PAYLOAD   | FL_PAYLOAD    | "DEBUG"       |
| $FL_SYMBOLS   | FL_SYMBOLS    | "ON"          |

The possible values for these special variables are the following:

| Value       | Description                             |
| ----------- | --------------------------------------- |
| undef       | default value used                      |
| ON          | shape is added without modifications    |
| OFF         | shape is discarded                      |
| ONLY        | OpenSCAD root modifier is applied       |
| DEBUG       | OpenSCAD debug modifier is applied      |
| TRANSPARENT | OpenSCAD background modifier is applied |
