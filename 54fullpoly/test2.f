E = Rec E. <f:Float, mul:{E,E}>;

eval = fix (lambda eval:E->Float. lambda e:E.
  case e of
  <f=v> ==> v
  | <mul=ee> ==> timesfloat (eval ee.1) (eval ee.2)
);

eval (<mul={<f=1.2> as E,<f=1.2> as E}> as E);
