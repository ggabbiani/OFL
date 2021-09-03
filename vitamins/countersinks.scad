/*
 * Countersink definitions, data taken from:
 * https://www.sailornautica.it/viti-metallo-inox-aisi-316-e-304/927-vite-testa-svasata-piana-esagono-incassato-m3-uni-5933-acciaio-inox-aisi-316.html
 *
 * Created  : on Mon Aug 30 2021.
 * Copyright: © 2021 Giampiero Gabbiani.
 * Email    : giampiero@gabbiani.org
 *
 * This file is part of the 'OpenSCAD Foundation Library' (OFL).
 *
 * OFL is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * OFL is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with OFL.  If not, see <http: //www.gnu.org/licenses/>.
 */

FL_CS_M3  = [
  ["name",              "FL_CS_M3"],
  ["description",       "M3 countersink"],
  ["nominal diameter",  3   ],
  ["head diameter",     6   ],
  ["height",            1.7 ],
];
FL_CS_M4  = [
  ["name",              "FL_CS_M4"],
  ["description",       "M4 countersink"],
  ["nominal diameter",  4   ],
  ["head diameter",     8   ],
  ["height",            2.3 ],
];
FL_CS_M5  = [
  ["name",              "FL_CS_M5"],
  ["description",       "M5 countersink"],
  ["nominal diameter",  5   ],
  ["head diameter",     10  ],
  ["height",            2.8 ],
];
FL_CS_M6  = [
  ["name",              "FL_CS_M6"],
  ["description",       "M6 countersink"],
  ["nominal diameter",  6   ],
  ["head diameter",     12  ],
  ["height",            3.3 ],
];
FL_CS_M8  = [
  ["name",              "FL_CS_M8"],
  ["description",       "M8 countersink"],
  ["nominal diameter",  8   ],
  ["head diameter",     16  ],
  ["height",            4.4 ],
];
FL_CS_M10  = [
  ["name",              "FL_CS_M10"],
  ["description",       "M10 countersink"],
  ["nominal diameter",  10  ],
  ["head diameter",     20  ],
  ["height",            5.5 ],
];
FL_CS_M12  = [
  ["name",              "FL_CS_M12"],
  ["description",       "M12 countersink"],
  ["nominal diameter",  12  ],
  ["head diameter",     24  ],
  ["height",            6.5 ],
];
FL_CS_M16  = [
  ["name",              "FL_CS_M16"],
  ["description",       "M16 countersink"],
  ["nominal diameter",  16  ],
  ["head diameter",     30  ],
  ["height",            7.5 ],
];
FL_CS_M20  = [
  ["name",              "FL_CS_M20"],
  ["description",       "M20 countersink"],
  ["nominal diameter",  20  ],
  ["head diameter",     36  ],
  ["height",            8.5 ],
];

FL_CS_DICT = [
  FL_CS_M3
  ,FL_CS_M4
  ,FL_CS_M5
  ,FL_CS_M6
  ,FL_CS_M8
  ,FL_CS_M10
  ,FL_CS_M12
  ,FL_CS_M16
  ,FL_CS_M20
];

use <countersink.scad>
