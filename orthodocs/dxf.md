# package dxf

Internal dxf import facility.

Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)

SPDX-License-Identifier: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)

Due to a bug [Import paths not relative to the file with the import. #217](https://github.com/openscad/openscad/issues/217#issuecomment-136832010)
relative path mechanism doesn't work properly for 'included' modules. The
workaround is to use a convenient __undocumented__ module placed on top of
the module hierarchy.


