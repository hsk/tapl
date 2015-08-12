
let fix i =
  (fun f ->
    (fun x -> f (fun y -> (x x) y))
    (fun x -> f (fun y -> (x x) y)))
  i


let rec fix f x = f (fix f) x

type e =
  | EInt of int
  | EAdd of e * e

let eval =
  fix (fun eval e ->
    match e with
    | EInt(a) -> a
    | EAdd(a,b) -> eval a + eval b
  )

let _ =
  Printf.printf "eval %d\n" (eval (EAdd(EInt 1, EInt 2)))
