open Format
open Syntax
open Support.Error
open Support.Pervasive

(* ------------------------   EVALUATION  ------------------------ *)

exception NoRuleApplies

let rec isnumericval ctx t = match t with
    TmZero(_) -> true
  | TmSucc(_,t1) -> isnumericval ctx t1
  | _ -> false

let rec isval ctx t = match t with
    TmTrue(_)  -> true
  | TmFalse(_) -> true
  | TmString _  -> true
  | TmFloat _  -> true
  | t when isnumericval ctx t  -> true
  | TmAbs(_,_,_,_) -> true
  | TmRecord(_,fields) -> List.for_all (fun (l,ti) -> isval ctx ti) fields
  | TmTag(_,l,t1,_) -> isval ctx t1
  | TmUnit(_)  -> true
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
          TmAbbBind(t,_) -> t 
        | _ -> raise NoRuleApplies)
  | TmAscribe(fi,v1,tyT) when isval ctx v1 ->
      v1
  | TmAscribe(fi,t1,tyT) ->
      let t1' = eval1 ctx t1 in
      TmAscribe(fi,t1',tyT)
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
  | TmApp(fi,TmAbs(_,x,tyT11,t12),v2) when isval ctx v2 ->
      termSubstTop v2 t12
  | TmApp(fi,v1,t2) when isval ctx v1 ->
      let t2' = eval1 ctx t2 in
      TmApp(fi, v1, t2')
  | TmApp(fi,t1,t2) ->
      let t1' = eval1 ctx t1 in
      TmApp(fi, t1', t2)
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
  | TmTag(fi,l,t1,tyT) ->
      let t1' = eval1 ctx t1 in
      TmTag(fi, l, t1',tyT)
  | TmCase(fi,TmTag(_,li,v11,_),branches) when isval ctx v11->
      (try 
         let (x,body) = List.assoc li branches in
         termSubstTop v11 body
       with Not_found -> raise NoRuleApplies)
  | TmCase(fi,t1,branches) ->
      let t1' = eval1 ctx t1 in
      TmCase(fi, t1', branches)
  | TmLet(fi,x,v1,t2) when isval ctx v1 ->
      termSubstTop v1 t2 
  | TmLet(fi,x,t1,t2) ->
      let t1' = eval1 ctx t1 in
      TmLet(fi, x, t1', t2) 
  | TmFix(fi,v1) as t when isval ctx v1 ->
      (match v1 with
         TmAbs(_,_,_,t12) -> termSubstTop t t12
       | _ -> raise NoRuleApplies)
  | TmFix(fi,t1) ->
      let t1' = eval1 ctx t1
      in TmFix(fi,t1')
  | _ -> 
      raise NoRuleApplies

(* ------------------------   BIG STEP EVALUATION  ------------------------ *)
let bigstep = ref false

let rec eval ctx t =
  match t with
  | TmApp(fi,t1,t2) ->
      let t1 = eval ctx t1 in
      let t2 = eval ctx t2 in
      begin match t1 with
      | TmAbs(_,x,_,t12) ->
        eval ctx (termSubstTop t2 t12)
      | _ -> TmApp(fi, t1, t2)
      end
  | TmIf(fi,t1,t2,t3) ->
      let t1' = eval ctx t1 in
      begin match t1' with
      | TmTrue(_) -> eval ctx t2
      | TmFalse(_) -> eval ctx t3
      | t -> TmIf(fi, t, t2, t3)
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
  | TmVar(fi,n,_) ->
      (match getbinding fi ctx n with
        | TmAbbBind(t,_) -> t 
        | _ -> t
      )
  | TmLet(fi,x,t1,t2) ->
      let t1' = eval ctx t1 in
      let t2' = termSubstTop t1' t2 in
      eval ctx t2'
  
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
  | TmCase(fi,t1,branches) ->
      let t1 = eval ctx t1 in
      (match t1 with
        | TmTag(_,li,v11,_) ->
          (try 
            let (x,body) = List.assoc li branches in
            termSubstTop v11 body
          with Not_found -> TmCase(fi,t1,branches))
        | _ -> TmCase(fi,t1,branches)
      )
  | _ ->
      try let t' = eval1 ctx t
          in eval ctx t'
      with NoRuleApplies -> t

let eval ctx t =
  if !bigstep then eval ctx t else
  let rec eval ctx t =
      try let t' = eval1 ctx t
          in eval ctx t'
      with NoRuleApplies -> t
  in eval ctx t

let evalbinding ctx b = match b with
    TmAbbBind(t,tyT) ->
      let t' = eval ctx t in 
      TmAbbBind(t',tyT)
  | bind -> bind

let istyabb ctx i = 
  match getbinding dummyinfo ctx i with
    TyAbbBind(tyT) -> true
  | _ -> false

let gettyabb ctx i = 
  match getbinding dummyinfo ctx i with
    TyAbbBind(tyT) -> tyT
  | _ -> raise NoRuleApplies

let rec computety ctx tyT = match tyT with
    TyRec(x,tyS1) as tyS -> typeSubstTop tyS tyS1
  | TyVar(i,_) when istyabb ctx i -> gettyabb ctx i
  | _ -> raise NoRuleApplies

let rec simplifyty ctx tyT =
  try
    let tyT' = computety ctx tyT in
    simplifyty ctx tyT' 
  with NoRuleApplies -> tyT

let rec tyeqv seen ctx tyS tyT =
  List.mem (tyS,tyT) seen 
  || match (tyS,tyT) with
        (TyString,TyString) -> true
     | (TyFloat,TyFloat) -> true
     | (TyRec(x,tyS1),_) ->
          tyeqv ((tyS,tyT)::seen) ctx (typeSubstTop tyS tyS1) tyT
     | (_,TyRec(x,tyT1)) ->
          tyeqv ((tyS,tyT)::seen) ctx tyS (typeSubstTop tyT tyT1)
     | (TyId(b1),TyId(b2)) -> b1=b2
     | (TyVar(i,_), _) when istyabb ctx i ->
         tyeqv seen ctx (gettyabb ctx i) tyT
     | (_, TyVar(i,_)) when istyabb ctx i ->
         tyeqv seen ctx tyS (gettyabb ctx i)
     | (TyVar(i,_),TyVar(j,_)) -> i=j
     | (TyArr(tyS1,tyS2),TyArr(tyT1,tyT2)) ->
          (tyeqv seen ctx tyS1 tyT1) && (tyeqv seen ctx tyS2 tyT2)
     | (TyBool,TyBool) -> true
     | (TyNat,TyNat) -> true
     | (TyRecord(fields1),TyRecord(fields2)) -> 
          List.length fields1 = List.length fields2
          &&                                         
          List.for_all 
            (fun (li2,tyTi2) ->
               try let (tyTi1) = List.assoc li2 fields1 in
                   tyeqv seen ctx tyTi1 tyTi2
               with Not_found -> false)
            fields2
     | (TyVariant(fields1),TyVariant(fields2)) ->
          (List.length fields1 = List.length fields2)
          && List.for_all2
               (fun (li1,tyTi1) (li2,tyTi2) ->
                  (li1=li2) && tyeqv seen ctx tyTi1 tyTi2)
               fields1 fields2
     | (TyUnit,TyUnit) -> true
     | _ -> false

let tyeqv ctx tyS tyT = tyeqv [] ctx tyS tyT

(* ------------------------   TYPING  ------------------------ *)

let rec typeof ctx t =
  match t with
    TmInert(fi,tyT) ->
      tyT
  | TmString _ -> TyString
  | TmVar(fi,i,_) -> getTypeFromContext fi ctx i
  | TmAscribe(fi,t1,tyT) ->
     if tyeqv ctx (typeof ctx t1) tyT then
       tyT
     else
       error fi "body of as-term does not have the expected type"
  | TmRecord(fi, fields) ->
      let fieldtys = 
        List.map (fun (li,ti) -> (li, typeof ctx ti)) fields in
      TyRecord(fieldtys)
  | TmProj(fi, t1, l) ->
      (match simplifyty ctx (typeof ctx t1) with
          TyRecord(fieldtys) ->
            (try List.assoc l fieldtys
             with Not_found -> error fi ("label "^l^" not found"))
        | _ -> error fi "Expected record type")
  | TmAbs(fi,x,tyT1,t2) ->
      let ctx' = addbinding ctx x (VarBind(tyT1)) in
      let tyT2 = typeof ctx' t2 in
      TyArr(tyT1, typeShift (-1) tyT2)
  | TmApp(fi,t1,t2) ->
      let tyT1 = typeof ctx t1 in
      let tyT2 = typeof ctx t2 in
      (match simplifyty ctx tyT1 with
          TyArr(tyT11,tyT12) ->
            if tyeqv ctx tyT2 tyT11 then tyT12
            else error fi "parameter type mismatch"
        | _ -> error fi "arrow type expected")
  | TmFloat _ -> TyFloat
  | TmTimesfloat(fi,t1,t2) ->
      if tyeqv ctx (typeof ctx t1) TyFloat
      && tyeqv ctx (typeof ctx t2) TyFloat then TyFloat
      else error fi "argument of timesfloat is not a number"
  | TmTrue(fi) -> 
      TyBool
  | TmFalse(fi) -> 
      TyBool
  | TmIf(fi,t1,t2,t3) ->
     if tyeqv ctx (typeof ctx t1) TyBool then
       let tyT2 = typeof ctx t2 in
       if tyeqv ctx tyT2 (typeof ctx t3) then tyT2
       else error fi "arms of conditional have different types"
     else error fi "guard of conditional not a boolean"
  | TmZero(fi) ->
      TyNat
  | TmSucc(fi,t1) ->
      if tyeqv ctx (typeof ctx t1) TyNat then TyNat
      else error fi "argument of succ is not a number"
  | TmPred(fi,t1) ->
      if tyeqv ctx (typeof ctx t1) TyNat then TyNat
      else error fi "argument of pred is not a number"
  | TmIsZero(fi,t1) ->
      if tyeqv ctx (typeof ctx t1) TyNat then TyBool
      else error fi "argument of iszero is not a number"
  | TmCase(fi, t, cases) ->
      (match simplifyty ctx (typeof ctx t) with
         TyVariant(fieldtys) ->
           List.iter
             (fun (li,(xi,ti)) ->
                try let _ = List.assoc li fieldtys in ()
                with Not_found -> error fi ("label "^li^" not in type"))
             cases;
           let casetypes =
             List.map (fun (li,(xi,ti)) ->
                         let tyTi =
                           try List.assoc li fieldtys
                           with Not_found ->
                             error fi ("label "^li^" not found") in
                         let ctx' = addbinding ctx xi (VarBind(tyTi)) in
                         typeShift (-1) (typeof ctx' ti))
                      cases in
           let tyT1 = List.hd casetypes in
           let restTy = List.tl casetypes in
           List.iter
             (fun tyTi -> 
                if not (tyeqv ctx tyTi tyT1)
                then error fi "fields do not have the same type")
             restTy;
           tyT1
        | _ -> error fi "Expected variant type")
  | TmTag(fi, li, ti, tyT) ->
      (match simplifyty ctx tyT with
          TyVariant(fieldtys) ->
            (try
               let tyTiExpected = List.assoc li fieldtys in
               let tyTi = typeof ctx ti in
               if tyeqv ctx tyTi tyTiExpected
                 then tyT
                 else error fi "field does not have expected type"
             with Not_found -> error fi ("label "^li^" not found"))
        | _ -> error fi "Annotation is not a variant type")
  | TmLet(fi,x,t1,t2) ->
     let tyT1 = typeof ctx t1 in
     let ctx' = addbinding ctx x (VarBind(tyT1)) in         
     typeShift (-1) (typeof ctx' t2)
  | TmUnit(fi) -> TyUnit
  | TmFix(fi, t1) ->
      let tyT1 = typeof ctx t1 in
      (match simplifyty ctx tyT1 with
           TyArr(tyT11,tyT12) ->
             if tyeqv ctx tyT12 tyT11 then tyT12
             else error fi "result of body not compatible with domain"
         | _ -> error fi "arrow type expected")