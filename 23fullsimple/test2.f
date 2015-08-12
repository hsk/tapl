/* Examples for testing */

  
 
let f = lambda x:<a:Bool,b:Bool>. x in
f (<a=true> as <a:Bool,b:Bool>);


let f = lambda x:<a:Bool,b:Bool>.
  case x of
    <a=val> ==> val
  | <b=val> ==> val
in
let a = <a=true> as <a:Bool,b:Bool> in
f(a);

let f = lambda x:<a:Bool,b:Bool>.
  case x of
    <a=val> ==> val
  | <b=val> ==> val
in
let a = <b=true> as <a:Bool,b:Bool> in
f(a);
