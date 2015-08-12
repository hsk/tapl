# test

## example

```
/* Examples for testing */

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

lambda X. lambda x:X. x; 
(lambda X. lambda x:X. x) [All X.X->X]; 

lambda X<:Top->Top. lambda x:X. x x; 


lambda x:Bool. x;
(lambda x:Bool->Bool. if x false then true else false) 
  (lambda x:Bool. if x then false else true); 

lambda x:Nat. succ x;
(lambda x:Nat. succ (succ x)) (succ 0); 

T = Nat->Nat;
lambda f:T. lambda x:Nat. f (f x);


 {*All Y.Y, lambda x:(All Y.Y). x} as {Some X,X->X};


{*Nat, {c=0, f=lambda x:Nat. succ x}}
  as {Some X, {c:X, f:X->Nat}};
let {X,ops} = {*Nat, {c=0, f=lambda x:Nat. succ x}}
              as {Some X, {c:X, f:X->Nat}}
in (ops.f ops.c);



Pair = lambda X. lambda Y. All R. (X->Y->R) -> R;

pair = lambda X.lambda Y.lambda x:X.lambda y:Y.lambda R.lambda p:X->Y->R.p x y;

f = lambda X.lambda Y.lambda f:Pair X Y. f;

fst = lambda X.lambda Y.lambda p:Pair X Y.p [X] (lambda x:X.lambda y:Y.x);
snd = lambda X.lambda Y.lambda p:Pair X Y.p [Y] (lambda x:X.lambda y:Y.y);

pr = pair [Nat] [Bool] 0 false;
fst [Nat] [Bool] pr;
snd [Nat] [Bool] pr;

List = lambda X. All R. (X->R->R) -> R -> R; 

diverge =
lambda X.
  lambda _:Unit.
  fix (lambda x:X. x);

nil = lambda X.
      (lambda R. lambda c:X->R->R. lambda n:R. n)
      as List X; 

cons = 
lambda X.
  lambda hd:X. lambda tl: List X.
     (lambda R. lambda c:X->R->R. lambda n:R. c hd (tl [R] c n))
     as List X; 

isnil =  
lambda X. 
  lambda l: List X. 
    l [Bool] (lambda hd:X. lambda tl:Bool. false) true; 

head = 
lambda X. 
  lambda l: List X. 
    (l [Unit->X] (lambda hd:X. lambda tl:Unit->X. lambda _:Unit. hd) (diverge [X]))
    unit; 

tail =  
lambda X.  
  lambda l: List X. 
    (fst [List X] [List X] ( 
      l [Pair (List X) (List X)]
        (lambda hd: X. lambda tl: Pair (List X) (List X). 
          pair [List X] [List X] 
            (snd [List X] [List X] tl)  
            (cons [X] hd (snd [List X] [List X] tl))) 
        (pair [List X] [List X] (nil [X]) (nil [X]))))
    as List X; 

let dbl = fix (lambda dbl:Nat->Nat. lambda e : Nat.
  if iszero e then 0 else succ(succ(dbl (pred e)))
)in
dbl 10;
```

## result

```
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
(lambda X. lambda x:X. x) : All X. X -> X
(lambda x:All X. X->X. x) : (All X. X->X) -> (All X. X -> X)
(lambda X<:Top->Top. lambda x:X. x x) : All X<:Top->Top. X -> Top
(lambda x:Bool. x) : Bool -> Bool
true : Bool
(lambda x:Nat. (succ x)) : Nat -> Nat
3 : Nat
T :: *
(lambda f:T. lambda x:Nat. f (f x)) : T -> Nat -> Nat
{*All Y. Y, lambda x:All Y. Y.x} as {Some X, X->X}
  : {Some X, X->X}
{*Nat, {c=0,f=lambda x:Nat. (succ x)}} as {Some X, {c:X,f:X->Nat}}
  : {Some X, {c:X,f:X->Nat}}
1 : Nat
Pair :: * => * => *
pair : All X. All Y. X -> Y -> (All R. (X->Y->R) -> R)
f : All X. All Y. Pair X Y -> Pair X Y
fst : All X. All Y. Pair X Y -> X
snd : All X. All Y. Pair X Y -> Y
pr : All R. (Nat->Bool->R) -> R
0 : Nat
false : Bool
List :: * => *
diverge : All X. Unit -> X
nil : All X. List X
cons : All X. X -> List X -> List X
isnil : All X. List X -> Bool
head : All X. List X -> X
tail : All X. List X -> List X
20 : Nat
```
