# test

## example

```
/* Examples for testing */

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

 
lambda x:<a:Bool,b:Bool>. x;



Counter = Rec P. {get:Nat, inc:Unit->P}; 
p = 
let create = 
  fix 
    (lambda cr: {x:Nat}->Counter.
      lambda s: {x:Nat}.
        fold [Counter]
          {get = s.x,
           inc = lambda _:Unit. cr {x=succ(s.x)}})
in
  create {x=0};
p1 = (unfold [Counter] p).inc unit;
(unfold [Counter] p1).get;


T = Nat->Nat;
lambda f:T. lambda x:Nat. f (f x);

let dbl = fix (lambda dbl:Nat->Nat. lambda e : Nat.
  if iszero e then 0 else succ(succ(dbl (pred e)))
)in
dbl 10;
```

## result

```
"hello" : String
unit : Unit
(lambda x:A. x) : A -> A
true : Bool
6.28318 : Float
{x=true, y=false} : {x:Bool, y:Bool}
true : Bool
{true, false} : {Bool, Bool}
true : Bool
(lambda x:Bool. x) : Bool -> Bool
true : Bool
(lambda x:Nat. (succ x)) : Nat -> Nat
3 : Nat
(lambda x:<a:Bool,b:Bool>. x)
  : <a:Bool,b:Bool> -> <a:Bool, b:Bool>
Counter :: *
p : Counter
p1 : Counter
1 : Nat
T :: *
(lambda f:T. lambda x:Nat. f (f x)) : T -> Nat -> Nat
20 : Nat
```
