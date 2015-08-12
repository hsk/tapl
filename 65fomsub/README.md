# test

## example

```
/* Examples for testing */

 lambda X. lambda x:X. x; 
 (lambda X. lambda x:X. x) [All X.X->X]; 

lambda x:Top. x;
 (lambda x:Top. x) (lambda x:Top. x);
(lambda x:Top->Top. x) (lambda x:Top. x);


lambda X<:Top->Top. lambda x:X. x x; 

```

## result

```
(lambda X. lambda x:X. x) : All X. X -> X
(lambda x:All X. X->X. x) : (All X. X->X) -> (All X. X -> X)
(lambda x:Top. x) : Top -> Top
(lambda x:Top. x) : Top
(lambda x:Top. x) : Top -> Top
(lambda X<:Top->Top. lambda x:X. x x) : All X<:Top->Top. X -> Top
```
