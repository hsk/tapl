# test

## example

```
/* Examples for testing */

 lambda x:A. x;


lambda f:Rec X.A->A. lambda x:A. f x;

```

## result

```
(lambda x:A. x) : A -> A
(lambda f:Rec X. A->A. lambda x:A. f x) : (Rec X. A->A) -> A -> A
```
