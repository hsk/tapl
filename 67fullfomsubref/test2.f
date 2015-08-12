E = Rep. E <f:Float, mul:{Ref Float, Ref E}>;

eval = fix (lambda eval:E->Float. lambda e:E.
  case e of
  <f=v> ==> v
  | <mul=ee> ==> !(ee.1)
);

eval (<mul={ref 1.2,ref (<f:1.2> as E)}> as E);
