/* Examples for testing */

  
 lambda x:<a:Bool,b:Bool>. x;
 

"hello";

unit;

lambda x:A. x;

let x=true in x;

timesfloat 2.0 3.14159;

{x=true, y=false}; 
{x=true, y=false}.x;
{true, false}; 
{true, false}.1; 


lambda x:Bool. x;
(lambda x:Bool->Bool. if x false then true else false) 
  (lambda x:Bool. if x then false else true); 

lambda x:Nat. succ x;
(lambda x:Nat. succ (succ x)) (succ 0); 

T = Nat->Nat;
lambda f:T. lambda x:Nat. f (f x);

let f = lambda x:<a:Nat,b:Nat>.
  case x of
    <a=v> ==> v
  | <b=v> ==> succ v
in
let a = <a=1> as <a:Nat,b:Nat> in
f(a);

let f = lambda x:<a:Nat,b:Nat>.
  case x of
    <a=v> ==> v
  | <b=v> ==> succ v
in
let a = <b=1> as <a:Nat,b:Nat> in
f(a);

let dbl = fix (lambda dbl:Nat->Nat. lambda e : Nat.
  if iszero e then 0 else succ(succ(dbl (pred e)))
)in
dbl 10;
