open Format
open Syntax
open Support.Error
open Support.Pervasive

(* ------------------------   BIG STEP EVALUATION  ------------------------ *)
let bigstep = ref false

let rec eval ctx t =
  match t with
  | TmIf(fi,t1,t2,t3) ->
      let t1' = eval ctx t1 in
      begin match t1' with
      | TmTrue(_) -> eval ctx t2
      | TmFalse(_) -> eval ctx t3
      | _ -> t
      end
  | TmSucc(fi,t1) ->
    begin match eval ctx t1 with
    | TmPred(fi, t1) -> t1
    | t1 -> TmSucc(fi, t1)
    end
  | TmPred(fi,t1) ->
    begin match eval ctx t1 with
    | TmSucc(fi, t1) -> t1
    | TmZero(fi) -> TmZero(fi)
    | t1 -> TmPred(fi, t1)
    end
  | TmIsZero(fi,t1) ->
    begin match eval ctx t1 with
    | TmZero(_) -> TmTrue(dummyinfo)
    | _ -> TmFalse(dummyinfo)
    end
  | TmApp(fi,t1,t2) ->
      let t1 = eval ctx t1 in
      let t2 = eval ctx t2 in
      begin match t1 with
      | TmAbs(_,x,t12) ->
        eval ctx (termSubstTop t2 t12)
      | _ -> TmApp(fi, t1, t2)
      end
  | TmVar(fi,n,_) ->
      (match getbinding fi ctx n with
        | TmAbbBind(t) -> t 
        | _ -> t
      )
  | TmLet(fi,x,t1,t2) ->
      let t1' = eval ctx t1 in
      let ctx' = addbinding ctx x (TmAbbBind t1') in
      eval ctx' t2
  | TmTimesfloat(fi,t1,t2) ->
      let t1' = eval ctx t1 in
      let t2' = eval ctx t2 in
      begin match t1',t2' with
      | TmFloat(_,f1),TmFloat(_,f2) -> TmFloat(fi, f1 *. f2)
      | _,_ -> TmTimesfloat(dummyinfo, t1', t2')
      end
  | TmRecord(fi,fields) ->
      let rec evalafield = function
        | [] -> []
        | (l,ti)::rest -> 
            let ti' = eval ctx ti in
            let rest' = evalafield rest in
            (l, ti')::rest'
      in
      let fields' = evalafield fields in
      TmRecord(fi, fields')
  | TmProj(fi, t1, l) ->
      let t1' = eval ctx t1 in
      begin match t1' with
      | TmRecord(_, fields) ->
        (try List.assoc l fields
         with Not_found -> t)
      | _ -> t
      end
  | TmTrue _
  | TmFalse _
  | TmFloat _
  | TmString _
  | TmAbs _
  | TmZero _ -> t

(* ------------------------   EVALUATION  ------------------------ *)

exception NoRuleApplies

let rec isnumericval ctx t = match t with
    TmZero(_) -> true
  | TmSucc(_,t1) -> isnumericval ctx t1
  | _ -> false

let rec isval ctx t = match t with
    TmTrue(_)  -> true
  | TmFalse(_) -> true
  | TmFloat _  -> true
  | TmString _  -> true
  | t when isnumericval ctx t  -> true
  | TmAbs(_,_,_) -> true
  | TmRecord(_,fields) -> List.for_all (fun (l,ti) -> isval ctx ti) fields
  | _ -> false

let rec eval1 ctx t = match t with
    TmIf(_,TmTrue(_),t2,t3) ->
      t2
  | TmIf(_,TmFalse(_),t2,t3) ->
      t3
  | TmIf(fi,t1,t2,t3) ->
      let t1' = eval1 ctx t1 in
      TmIf(fi, t1', t2, t3)
  | TmVar(fi,n,_) ->
      (match getbinding fi ctx n with
          TmAbbBind(t) -> t 
        | _ -> raise NoRuleApplies)
  | TmApp(fi,TmAbs(_,x,t12),v2) when isval ctx v2 ->
      termSubstTop v2 t12
  | TmApp(fi,v1,t2) when isval ctx v1 ->
      let t2' = eval1 ctx t2 in
      TmApp(fi, v1, t2')
  | TmApp(fi,t1,t2) ->
      let t1' = eval1 ctx t1 in
      TmApp(fi, t1', t2)
  | TmRecord(fi,fields) ->
      let rec evalafield l = match l with 
        [] -> raise NoRuleApplies
      | (l,vi)::rest when isval ctx vi -> 
          let rest' = evalafield rest in
          (l,vi)::rest'
      | (l,ti)::rest -> 
          let ti' = eval1 ctx ti in
          (l, ti')::rest
      in let fields' = evalafield fields in
      TmRecord(fi, fields')
  | TmProj(fi, (TmRecord(_, fields) as v1), l) when isval ctx v1 ->
      (try List.assoc l fields
       with Not_found -> raise NoRuleApplies)
  | TmProj(fi, t1, l) ->
      let t1' = eval1 ctx t1 in
      TmProj(fi, t1', l)
  | TmTimesfloat(fi,TmFloat(_,f1),TmFloat(_,f2)) ->
      TmFloat(fi, f1 *. f2)
  | TmTimesfloat(fi,(TmFloat(_,f1) as t1),t2) ->
      let t2' = eval1 ctx t2 in
      TmTimesfloat(fi,t1,t2') 
  | TmTimesfloat(fi,t1,t2) ->
      let t1' = eval1 ctx t1 in
      TmTimesfloat(fi,t1',t2) 
  | TmSucc(fi,t1) ->
      let t1' = eval1 ctx t1 in
      TmSucc(fi, t1')
  | TmPred(_,TmZero(_)) ->
      TmZero(dummyinfo)
  | TmPred(_,TmSucc(_,nv1)) when (isnumericval ctx nv1) ->
      nv1
  | TmPred(fi,t1) ->
      let t1' = eval1 ctx t1 in
      TmPred(fi, t1')
  | TmIsZero(_,TmZero(_)) ->
      TmTrue(dummyinfo)
  | TmIsZero(_,TmSucc(_,nv1)) when (isnumericval ctx nv1) ->
      TmFalse(dummyinfo)
  | TmIsZero(fi,t1) ->
      let t1' = eval1 ctx t1 in
      TmIsZero(fi, t1')
  | TmLet(fi,x,v1,t2) when isval ctx v1 ->
      termSubstTop v1 t2 
  | TmLet(fi,x,t1,t2) ->
      let t1' = eval1 ctx t1 in
      TmLet(fi, x, t1', t2) 
  | _ -> 
      raise NoRuleApplies

let eval ctx t =
  if !bigstep then eval ctx t else
  let rec eval ctx t =
      try let t' = eval1 ctx t
          in eval ctx t'
      with NoRuleApplies -> t
  in eval ctx t

let evalbinding ctx b =
  match b with
  | TmAbbBind(t) ->
      let t' = eval ctx t in 
      TmAbbBind(t')
  | bind -> bind
