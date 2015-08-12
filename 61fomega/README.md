# test

## example

```
/* Examples for testing */

 lambda X. lambda x:X. x; 
 (lambda X. lambda x:X. x) [All X.X->X]; 
```

## result

```
(lambda X. lambda x:X. x) : All X. X -> X
(lambda x:All X. X->X. x) : (All X. X->X) -> (All X. X -> X)
```
