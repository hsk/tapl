# test

## example

```
/* Examples for testing */

 lambda x:Bot. x;
 lambda x:Bot. x x; 

lambda x:Top. x;
 (lambda x:Top. x) (lambda x:Top. x);
(lambda x:Top->Top. x) (lambda x:Top. x);


lambda x:Bool. x;
(lambda x:Bool->Bool. if x false then true else false) 
  (lambda x:Bool. if x then false else true); 

if error then true else false;


error true;
(lambda x:Bool. x) error;

```

## result

```
(lambda x:Bot. x) : Bot -> Bot
(lambda x:Bot. x x) : Bot -> Bot
(lambda x:Top. x) : Top -> Top
(lambda x:Top. x) : Top
(lambda x:Top. x) : Top -> Top
(lambda x:Bool. x) : Bool -> Bool
true : Bool
error : Bool
error : Bot
error : Bool
```
