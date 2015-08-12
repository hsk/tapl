open Format
open Syntax
open Support.Error
open Support.Pervasive

(* ------------------------   BIG STEP EVALUATION  ------------------------ *)
let bigstep = ref false

let rec eval t =
  match t with
  | TmIf(fi,t1,t2,t3) ->
      let t1' = eval t1 in
      begin match t1' with
      | TmTrue(_) -> eval(t2)
      | TmFalse(_) -> eval(t3)
      | _ -> t
      end
  | TmSucc(fi,t1) ->
    begin match eval t1 with
    | TmPred(fi, t1) -> t1
    | t1 -> TmSucc(fi, t1)
    end
  | TmPred(fi,t1) ->
    begin match eval t1 with
    | TmSucc(fi, t1) -> t1
    | TmZero(fi) -> TmZero(fi)
    | t1 -> TmPred(fi, t1)
    end
  | TmIsZero(fi,t1) ->
    begin match eval t1 with
    | TmZero(_) -> TmTrue(dummyinfo)
    | _ -> TmFalse(dummyinfo)
    end
  | t -> t

(* ------------------------   EVALUATION  ------------------------ *)

exception NoRuleApplies

let rec isnumericval t = match t with
    TmZero(_) -> true
  | TmSucc(_,t1) -> isnumericval t1
  | _ -> false

let rec isval t = match t with
    TmTrue(_)  -> true
  | TmFalse(_) -> true
  | t when isnumericval t  -> true
  | _ -> false

let rec eval1 t = match t with
    TmIf(_,TmTrue(_),t2,t3) ->
      t2
  | TmIf(_,TmFalse(_),t2,t3) ->
      t3
  | TmIf(fi,t1,t2,t3) ->
      let t1' = eval1 t1 in
      TmIf(fi, t1', t2, t3)
  | TmSucc(fi,t1) ->
      let t1' = eval1 t1 in
      TmSucc(fi, t1')
  | TmPred(_,TmZero(_)) ->
      TmZero(dummyinfo)
  | TmPred(_,TmSucc(_,nv1)) when (isnumericval nv1) ->
      nv1
  | TmPred(fi,t1) ->
      let t1' = eval1 t1 in
      TmPred(fi, t1')
  | TmIsZero(_,TmZero(_)) ->
      TmTrue(dummyinfo)
  | TmIsZero(_,TmSucc(_,nv1)) when (isnumericval nv1) ->
      TmFalse(dummyinfo)
  | TmIsZero(fi,t1) ->
      let t1' = eval1 t1 in
      TmIsZero(fi, t1')
  | _ -> 
      raise NoRuleApplies

let eval t =
  if !bigstep then eval t else
  let rec eval t =
    try let t' = eval1 t
        in eval t'
    with NoRuleApplies -> t
  in eval t

(* ------------------------   TYPING  ------------------------ *)

let rec typeof t =
  match t with
  | TmTrue(fi) -> 
      TyBool
  | TmFalse(fi) -> 
      TyBool
  | TmIf(fi,t1,t2,t3) ->
     if (=) (typeof t1) TyBool then
       let tyT2 = typeof t2 in
       if (=) tyT2 (typeof t3) then tyT2
       else error fi "arms of conditional have different types"
     else error fi "guard of conditional not a boolean"
  | TmZero(fi) ->
      TyNat
  | TmSucc(fi,t1) ->
      if (=) (typeof t1) TyNat then TyNat
      else error fi "argument of succ is not a number"
  | TmPred(fi,t1) ->
      if (=) (typeof t1) TyNat then TyNat
      else error fi "argument of pred is not a number"
  | TmIsZero(fi,t1) ->
      if (=) (typeof t1) TyNat then TyBool
      else error fi "argument of iszero is not a number"