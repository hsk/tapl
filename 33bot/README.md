# test

## example

```
/* Examples for testing */

 lambda x:Top. x;
  (lambda x:Top. x) (lambda x:Top. x);
 (lambda x:Top->Top. x) (lambda x:Top. x);
 

lambda x:Bot. x;
lambda x:Bot. x x; 
```

## result

```
(lambda x:Top. x) : Top -> Top
(lambda x:Top. x) : Top
(lambda x:Top. x) : Top -> Top
(lambda x:Bot. x) : Bot -> Bot
(lambda x:Bot. x x) : Bot -> Bot
```
