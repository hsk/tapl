# test

## example

```
/* Examples for testing */

 lambda x:Bool. x;
 (lambda x:Bool->Bool. if x false then true else false) 
   (lambda x:Bool. if x then false else true); 

lambda x:Nat. succ x;
(lambda x:Nat. succ (succ x)) (succ 0); 

lambda x:A. x;


(lambda x:X. lambda y:X->X. y x);
(lambda x:X->X. x 0) (lambda y:Nat. y); 

```

## result

```
(lambda x:Bool. x) : Bool -> Bool
                     true : Bool
       (lambda x:Nat. (succ x)) : Nat -> Nat
                           3 : Nat
    (lambda x:A. x) : A -> A
                  (lambda x:X. lambda y:X->X. y x) : X -> (X->X) -> X
                                   0 : Nat
    ```
