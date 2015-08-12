# test

## example

```
/* Examples for testing */

 lambda x:Bot. x;
 lambda x:Bot. x x; 

 
lambda x:<a:Bool,b:Bool>. x;


lambda x:Top. x;
 (lambda x:Top. x) (lambda x:Top. x);
(lambda x:Top->Top. x) (lambda x:Top. x);


(lambda r:{x:Top->Top}. r.x r.x) 
  {x=lambda z:Top.z, y=lambda z:Top.z}; 


"hello";

unit;

lambda x:A. x;

let x=true in x;

{x=true, y=false}; 
{x=true, y=false}.x;
{true, false}; 
{true, false}.1; 


if true then {x=true,y=false,a=false} else {y=false,x={},b=false};

timesfloat 2.0 3.14159;




lambda x:Bool. x;
(lambda x:Bool->Bool. if x false then true else false) 
  (lambda x:Bool. if x then false else true); 

lambda x:Nat. succ x;
(lambda x:Nat. succ (succ x)) (succ 0); 

T = Nat->Nat;
lambda f:T. lambda x:Nat. f (f x);

x = ref 5; x := 8; !x;

let dbl = fix (lambda dbl:Nat->Nat. lambda e : Nat.
  if iszero e then 0 else succ(succ(dbl (pred e)))
)in
dbl 10;
```

## result

```
(lambda x:Bot. x) : Bot -> Bot
(lambda x:Bot. x x) : Bot -> Bot
(lambda x:<a:Bool,b:Bool>. x)
  : <a:Bool,b:Bool> -> <a:Bool, b:Bool>
(lambda x:Top. x) : Top -> Top
(lambda x:Top. x) : Top
(lambda x:Top. x) : Top -> Top
(lambda z:Top. z) : Top
"hello" : String
unit : Unit
(lambda x:A. x) : A -> A
true : Bool
{x=true, y=false} : {x:Bool, y:Bool}
true : Bool
{true, false} : {Bool, Bool}
true : Bool
{x=true, y=false, a=false} : {x:Top, y:Bool}
6.28318 : Float
(lambda x:Bool. x) : Bool -> Bool
true : Bool
(lambda x:Nat. (succ x)) : Nat -> Nat
3 : Nat
T :: *
(lambda f:T. lambda x:Nat. f (f x)) : T -> Nat -> Nat
x : Ref Nat
unit : Unit
8 : Nat
20 : Nat
```
