include <../../lib/OFL/vitamins/knurl_nuts.scad>

// nominal
echo("nominal==3:")
let(
  result = fl_knut_select(nominal=3)
) for(knut=result) let(
  nominal = fl_nominal(knut)
) assert(nominal==3) echo(str(fl_name(knut),": ",nominal));

echo("nominal≠3:")
let(
  result = fl_knut_select(nominal=["≠",3])
) for(knut=result) let(
  nominal = fl_nominal(knut)
) assert(nominal!=3) echo(str(fl_name(knut),": ",nominal));

echo("nominal>3:")
let(
  result = fl_knut_select(nominal=[">",3])
) for(knut=result) let(
  nominal = fl_nominal(knut)
) assert(nominal>3) echo(str(fl_name(knut),": ",nominal));

echo("nominal≥3:")
let(
  result = fl_knut_select(nominal=["≥",3])
) for(knut=result) let(
  nominal = fl_nominal(knut)
) assert(nominal>=3) echo(str(fl_name(knut),": ",nominal));

echo("nominal<3:")
let(
  result = fl_knut_select(nominal=["<",3])
) for(knut=result) let(
  nominal = fl_nominal(knut)
) assert(nominal<3) echo(str(fl_name(knut),": ",nominal));

echo("nominal≤3:")
let(
  result = fl_knut_select(nominal=["≤",3])
) for(knut=result) let(
  nominal = fl_nominal(knut)
) assert(nominal<=3) echo(str(fl_name(knut),": ",nominal));

// thread
echo("thread=='linear':")
let(
  result = fl_knut_select(thread="linear")
) for(knut=result) let(
  thread = fl_knut_thread(knut)
) assert(thread=="linear") echo(str(fl_name(knut),": ",thread));

echo("thread≠'linear':")
let(
  result = fl_knut_select(thread=["≠","linear"])
) for(knut=result) let(
  thread = fl_knut_thread(knut)
) assert(thread!="linear") echo(str(fl_name(knut),": ",thread));

// length
echo("length==4:")
let(
  result = fl_knut_select(length=4)
) for(knut=result) let(
  length = fl_thick(knut)
) assert(length==4) echo(str(fl_name(knut),": ",length));

echo("length≠4:")
let(
  result = fl_knut_select(length=["≠",4])
) for(knut=result) let(
  length = fl_thick(knut)
) assert(length!=4) echo(str(fl_name(knut),": ",length));

echo("length>4:")
let(
  result = fl_knut_select(length=[">",4])
) for(knut=result) let(
  length = fl_thick(knut)
) assert(length>4) echo(str(fl_name(knut),": ",length));

echo("length≥4:")
let(
  result = fl_knut_select(length=["≥",4])
) for(knut=result) let(
  length = fl_thick(knut)
) assert(length>=4) echo(str(fl_name(knut),": ",length));

echo("length<4:")
let(
  result = fl_knut_select(length=["<",4])
) for(knut=result) let(
  length = fl_thick(knut)
) assert(length<4) echo(str(fl_name(knut),": ",length));

echo("length≤4:")
let(
  result = fl_knut_select(length=["≤",4])
) for(knut=result) let(
  length = fl_thick(knut)
) assert(length<=4) echo(str(fl_name(knut),": ",length));
