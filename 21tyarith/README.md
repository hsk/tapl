# test

## example

```
/* Examples for testing */

true;
if false then true else false; 

0; 
succ (pred 0);
iszero (pred (succ (succ 0))); 
succ(succ (pred (succ 0)));
```

## result

```
true : Bool
false : Bool
0 : Nat
1 : Nat
false : Bool
2 : Nat
```
