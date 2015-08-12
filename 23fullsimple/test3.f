/* Examples for testing */

{1.0,2.0};

let a = <a=true> as <a:Bool,b:Bool> in
a;

let a = <a=true> as <a:Bool,b:Float> in
a;

let a = <b=1.0> as <b:Float> in
a;

let a = <b={1.0,2.0}> as <b:{Float,Float}> in
a;

let a = <b={2.0,3.0}> as <b:{Float,Float}> in
case a of
<b=b> ==> timesfloat b.1 b.2;


let a = <b={2.0,3.0}> as <b:{Float,Float}> in
case a of
<b=b> ==> timesfloat b.1 b.2;

inert[Bool];
let a = inert[Bool] in a;

POINT={Float,Float};
let a={1.0,2.0} as POINT in a;



let sum = fix (lambda sum:Nat->Nat. lambda e : Nat.
  if iszero e then 0 else succ(succ(sum (pred e)))
)in
sum 10;
