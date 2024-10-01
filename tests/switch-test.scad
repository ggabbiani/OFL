include <../lib/OFL/foundation/core.scad>

let(
  value  = 2.5,
  result = fl_switch(value,[
      [2,  3.2],
      [2.5,4.0],
      [3,  4.0],
      [5,  6.4],
      [6,  8.0],
      [8,  9.6]
    ]
  ),
  expected = 4.0
) echo(result=result) assert(result==expected,result);

let(
  value  = 2.5,
  result = fl_switch(value,[
      [function(e) (e<0),  "negative"],
      [0,                  "null"    ],
      [function(e) (e>0),  "positive"]
    ]
  ),
  expected = "positive"
) echo(result=result) assert(result==expected,result);

let(
  value  = 2.5,
  result = fl_switch(value,[
      [function(e) (e<0),  "negative"],
      [0,                  "null"    ],
    ]
  ),
  expected = undef
) echo(result=result) assert(result==expected,result);

let(
  value  = 2.5,
  result = fl_switch(value,[
      [function(e) (e<0),  "negative"],
      [0,                  "null"    ],
    ],
    "default"
  ),
  expected = "default"
) echo(result=result) assert(result==expected,result);

