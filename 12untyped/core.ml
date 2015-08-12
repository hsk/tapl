open Format
open Syntax
open Support.Error
open Support.Pervasive

(* ------------------------   BIG STEP EVALUATION  ------------------------ *)
let bigstep = ref false

let rec eval ctx t =
  match t with
  | TmApp(fi,t1,t2) ->
      let t1 = eval ctx t1 in
      let t2 = eval ctx t2 in
      begin match t1 with
      | TmAbs(_,x,t12) ->
        eval ctx (termSubstTop t2 t12)
      | _ -> TmApp(fi, t1, t2)
      end
  | t -> t

(* ------------------------   EVALUATION  ------------------------ *)

let rec isval ctx t = match t with
    TmAbs(_,_,_) -> true
  | _ -> false

exception NoRuleApplies

let rec eval1 ctx t = match t with
    TmApp(fi,TmAbs(_,x,t12),v2) when isval ctx v2 ->
      termSubstTop v2 t12
  | TmApp(fi,v1,t2) when isval ctx v1 ->
      let t2' = eval1 ctx t2 in
      TmApp(fi, v1, t2')
  | TmApp(fi,t1,t2) ->
      let t1' = eval1 ctx t1 in
      TmApp(fi, t1', t2)
  | _ -> 
      raise NoRuleApplies

let eval ctx t =
  if !bigstep then eval ctx t else
  let rec eval ctx t =
    try let t' = eval1 ctx t
        in eval ctx t'
    with NoRuleApplies -> t
  in eval ctx t

