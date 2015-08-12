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
true => true
(if false then true else false) => false
0 => 0
(succ (pred 0)) => 1
(iszero (pred 2)) => false
(succ (succ (pred 1))) => 2
```
