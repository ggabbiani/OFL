# package dxf

Internal dxf import facility.

Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)

Due to a bug [Import paths not relative to the file with the import. #217](https://github.com/openscad/openscad/issues/217#issuecomment-136832010)
relative path mechanism doesn't work properly for 'included' modules. The
workaround is to 'USE' a convenient module placed on top of the library hierarchy.

At May 7,2021 the issue
[dxf_dim, dxf_cross and import use a different strategy to find the dxf file · Issue #2768 · openscad/openscad](https://github.com/openscad/openscad/issues/2768)
has been closed. Unfortunately the problem with dxf_cross() is still open as
for current OpenSCAD stable version (dated January 1, 2021). This means that
the current OFL version of __dxf_cross__() can be run only on nightly
version of OpenSCAD later then the date of the issue fixup.


