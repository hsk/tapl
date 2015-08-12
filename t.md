# プログラミング言語としてのTAPL

TAPLは型システムの教科書です。
型の理論を勉強し、OCamlを使って様々なプログラミング言語を作ります。

TAPLの書籍自体は難しいのですが、TAPLには複数の実装があり、テストプログラムも存在しています。
動くプログラムがあるので、使ってみない手はありません。
テストプログラムと実行結果からどのような言語を作る本なのかを見て行きましょう。

この文章は、プログラミング言語の入門書のようなものです。

TAPLのプログラムはわりと、OCamlで作成するプログラミング言語のオーソドックスなスタイルで作成されています。

再帰的に式を評価するプログラムは、ビックステップ評価器といい、
項を一カ所だけ書き換える方式をワンステップ評価器といいます。

筆者はビックステップ評価機のほうが分かりやすいと思うのですが、TAPLはワンステップ評価器を採用しているので、気持ち悪いと感じる人がいるかもしれません。

型検査、型推論のアルゴリズムは再帰的に求めるので型検査部分だけ見る分にはそれほどきにならないはずです。

# 第 I 部 部型無しの計算体系

## arith

まず、arith言語です。arith言語は算術式を扱う事が出来ます。

./arith/test.fを見ると以下のテストプログラムがあります。


    /* Examples for testing */
    
    true;
    if false then true else false; 
    
    0; 
    succ (pred 0);
    iszero (pred (succ (succ 0))); 
    succ(succ (pred (succ 0)));
    
<center>arith/test.f</center>

このプログラムから、/**/のコメントを使う事が出来る事が分かります。
式は;で終わり複数書く事が出来ます。
実行すると以下の結果が得られます。

### output

    true
    false
    0
    1
    false
    2

true、falseのboolが使えて、if then elseが使えて、0や、関数 pred succ izzeroがあります。
succは1を足す関数で、predは1を引く関数、iszeroはゼロ判定をする関数です。

arithの自然数はzeroとsuccだけで表すペアノ自然数で実装されています。
ペアノ自然数は、数学的に何の定義もない状態から、数の概念を構築する場合に用いられます。
CoqやAgdaといった定理証明系の言語等ではペアノ自然数を使った足し算やかけ算等を定義する事で、定理や証明を書く事が出来るようになります。
単に遅いだけではないのです。

## untyped

untyped言語は型無しのλ計算が出来る言語です。
変数とラムダ式があって、並べて書く事で評価できます。

    /* Examples for testing */
    
    x/;
    x;
    
    lambda x. x;
    (lambda x. x) (lambda x. x x); 
    
<center>untyped/test.f</center>

### output

    x 
    x
    (lambda x'. x')
    (lambda x'. x' x')

このプログラムで謎なのが `x/` という式でしょう。この式は変数の宣言をします。
lamda式は無名関数です。
lamda x. xはjavascriptで書くとfunction(x) { return x;}の事です。
lamda x -> xのように、.は->だと思うと分かりやすいかもしれません。

## fulluntyped

fulluntyped言語は型無しλ計算のフル実装です。
ラムダ式以外に、bool,int,floatが使え、if then else文があり、レコードと文字列があります。また、let in式もあります。

    /* Examples for testing */
    
    true;
    if false then true else false; 
    
    x/;
    x;
    
    x = true;
    x;
    if x then false else x; 
    
    lambda x. x;
    (lambda x. x) (lambda x. x x); 
    
    {x=lambda x.x, y=(lambda x.x)(lambda x.x)}; 
    {x=lambda x.x, y=(lambda x.x)(lambda x.x)}.x; 
    
    "hello";
    
    timesfloat (timesfloat 2.0 3.0) (timesfloat 4.0 5.0);
    
    0; 
    succ (pred 0);
    iszero (pred (succ (succ 0))); 
    
    let x=true in x;
    
<center>fulluntyped/test.f</center>

### output

    true
    false
    x 
    x
    x = true
    true
    false
    (lambda x'. x')
    (lambda x'. x' x')
    {x=lambda x'.x', y=lambda x'.x'}
    (lambda x'. x')
    "hello"
    120.
    0
    1
    false
    true

型無し演算は、いわば、動的型システムであると言えるでしょう。


# 第 II 部 単純型
    
## tyarith

tyarithはarithに型を付けた言語です。

    /* Examples for testing */
    
    true;
    if false then true else false; 
    
    0; 
    succ (pred 0);
    iszero (pred (succ (succ 0))); 
    succ(succ (pred (succ 0)));
    
<center>tyarith/test.f</center>

### output

    true : Bool
    false : Bool
    0 : Nat
    1 : Nat
    false : Bool
    2 : Nat

実行すると型も表示されます。
型をかかなくても型が求まるのが面白い所です。

## 型検査器

TAPLで初めて出て来た型検査器が、typeof関数です。

    let rec typeof t =
      match t with
        TmTrue(fi) -> 
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

構文木を再帰的に走査していき型を求めます。TmTrue,TmFalseは直ぐに型が分かります。
Ifの場合は、t1はboolのはずです。また、t2,t3は同じ型のはずです。そして、if全体の型はt2の型になります。
TmZero,TmSucc,TmPredの３つの型はNatのはずで、型チェックは再帰的に中味の式もチェックします。
TmIsZeroの型はboolで中味はNatのはずです。

このようにもっとも簡単な型チェックは再帰的に構文木を走査する事で求める事が出来ます。

## simplebool

simplebool言語はシンプルなbool値のみが存在する型付きλ計算です。
関数の変数の後ろに`: 型`として型を書く事が出来ます。

    /* Examples for testing */
    
     lambda x:Bool. x;
     (lambda x:Bool->Bool. if x false then true else false) 
       (lambda x:Bool. if x then false else true); 
    
<center>simplebool/test.f</center>

### output

    (lambda x:Bool. x) : Bool -> Bool
    true : Bool

`Bool` がブール型で、`A -> B` が 関数の型になります。

### 型検査

λ計算の型検査では、bool値とif式の型検査は先ほど同じです。
変数の型検査は、環境から変数の型を取り出して返します。
λ式の型は、TyArrで、変数の型をバインドした環境を作って、関数本体の式を型検査して求めます。
関数の評価式は、２つの式を型チェックし、関数の型と、呼び出す値の型をチェックして、
関数が返す型を返します。

単純な型付きλ計算の場合は、変数が現れた時点で型を必ず指定することで、型検査を再帰的に行う事が出来ます。


    let rec typeof ctx t =
      match t with
        TmVar(fi,i,_) -> getTypeFromContext fi ctx i
      | TmAbs(fi,x,tyT1,t2) ->
          let ctx' = addbinding ctx x (VarBind(tyT1)) in
          let tyT2 = typeof ctx' t2 in
          TyArr(tyT1, tyT2)
      | TmApp(fi,t1,t2) ->
          let tyT1 = typeof ctx t1 in
          let tyT2 = typeof ctx t2 in
          (match tyT1 with
              TyArr(tyT11,tyT12) ->
                if (=) tyT2 tyT11 then tyT12
                else error fi "parameter type mismatch"
            | _ -> error fi "arrow type expected")
      | TmTrue(fi) -> 
          TyBool
      | TmFalse(fi) -> 
          TyBool
      | TmIf(fi,t1,t2,t3) ->
         if (=) (typeof ctx t1) TyBool then
           let tyT2 = typeof ctx t2 in
           if (=) tyT2 (typeof ctx t3) then tyT2
           else error fi "arms of conditional have different types"
         else error fi "guard of conditional not a boolean"




## fullsimple

fullsimpleは型付きλ計算のフル実装です。
:の後ろに型をかく事が出来ます。

    /* Examples for testing */
    
      
    lambda x:<a:Bool,b:Bool>. x;
     
    
    "hello";
    
    unit;
    
    lambda x:A. x;
    
    let x=true in x;
    
    timesfloat 2.0 3.14159;
    
    {x=true, y=false}; 
    {x=true, y=false}.x;
    {true, false}; 
    {true, false}.1; 
    
    
    lambda x:Bool. x;
    (lambda x:Bool->Bool. if x false then true else false) 
      (lambda x:Bool. if x then false else true); 
    
    lambda x:Nat. succ x;
    (lambda x:Nat. succ (succ x)) (succ 0); 
    
    T = Nat->Nat;
    lambda f:T. lambda x:Nat. f (f x);
    
    
<center>fullsimple/test.f</center>

### output

    (lambda x:<a:Bool,b:Bool>. x)
      : <a:Bool,b:Bool> -> <a:Bool, b:Bool>
    "hello" : String
    unit : Unit
    (lambda x:A. x) : A -> A
    true : Bool
    6.28318 : Float
    {x=true, y=false} : {x:Bool, y:Bool}
    true : Bool
    {true, false} : {Bool, Bool}
    true : Bool
    (lambda x:Bool. x) : Bool -> Bool
    true : Bool
    (lambda x:Nat. (succ x)) : Nat -> Nat
    3 : Nat
    T :: *
    (lambda f:T. lambda x:Nat. f (f x)) : T -> Nat -> Nat


型検査機は大きくなりますが、simpleboolと同じような構造で、より多くのデータ型をサポートしています。
代数的データ型もあります。

    let istyabb ctx i = 
      match getbinding dummyinfo ctx i with
        TyAbbBind(tyT) -> true
      | _ -> false

    let gettyabb ctx i = 
      match getbinding dummyinfo ctx i with
        TyAbbBind(tyT) -> tyT
      | _ -> raise NoRuleApplies

    let rec computety ctx tyT = match tyT with
        TyVar(i,_) when istyabb ctx i -> gettyabb ctx i
      | _ -> raise NoRuleApplies

    let rec simplifyty ctx tyT =
      try
        let tyT' = computety ctx tyT in
        simplifyty ctx tyT' 
      with NoRuleApplies -> tyT

    let rec tyeqv ctx tyS tyT =
      let tyS = simplifyty ctx tyS in
      let tyT = simplifyty ctx tyT in
      match (tyS,tyT) with
        (TyString,TyString) -> true
      | (TyUnit,TyUnit) -> true
      | (TyId(b1),TyId(b2)) -> b1=b2
      | (TyFloat,TyFloat) -> true
      | (TyVar(i,_), _) when istyabb ctx i ->
          tyeqv ctx (gettyabb ctx i) tyT
      | (_, TyVar(i,_)) when istyabb ctx i ->
          tyeqv ctx tyS (gettyabb ctx i)
      | (TyVar(i,_),TyVar(j,_)) -> i=j
      | (TyArr(tyS1,tyS2),TyArr(tyT1,tyT2)) ->
           (tyeqv ctx tyS1 tyT1) && (tyeqv ctx tyS2 tyT2)
      | (TyBool,TyBool) -> true
      | (TyNat,TyNat) -> true
      | (TyRecord(fields1),TyRecord(fields2)) -> 
           List.length fields1 = List.length fields2
           &&                                         
           List.for_all 
             (fun (li2,tyTi2) ->
                try let (tyTi1) = List.assoc li2 fields1 in
                    tyeqv ctx tyTi1 tyTi2
                with Not_found -> false)
             fields2
      | (TyVariant(fields1),TyVariant(fields2)) ->
           (List.length fields1 = List.length fields2)
           && List.for_all2
                (fun (li1,tyTi1) (li2,tyTi2) ->
                   (li1=li2) && tyeqv ctx tyTi1 tyTi2)
                fields1 fields2
      | _ -> false

    (* ------------------------   TYPING  ------------------------ *)

    let rec typeof ctx t =
      match t with
        TmInert(fi,tyT) ->
          tyT
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
      | TmVar(fi,i,_) -> getTypeFromContext fi ctx i
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
      | TmLet(fi,x,t1,t2) ->
         let tyT1 = typeof ctx t1 in
         let ctx' = addbinding ctx x (VarBind(tyT1)) in         
         typeShift (-1) (typeof ctx' t2)
      | TmFix(fi, t1) ->
          let tyT1 = typeof ctx t1 in
          (match simplifyty ctx tyT1 with
               TyArr(tyT11,tyT12) ->
                 if tyeqv ctx tyT12 tyT11 then tyT12
                 else error fi "result of body not compatible with domain"
             | _ -> error fi "arrow type expected")
      | TmString _ -> TyString
      | TmUnit(fi) -> TyUnit
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
      | TmFloat _ -> TyFloat
      | TmTimesfloat(fi,t1,t2) ->
          if tyeqv ctx (typeof ctx t1) TyFloat
          && tyeqv ctx (typeof ctx t2) TyFloat then TyFloat
          else error fi "argument of timesfloat is not a number"
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


## fullref

fullrefは参照の機能を追加した言語です。

    x = ref 5; x := 8; !x;

と書くと、

    x : Ref Nat
    unit : Unit
    8 : Nat

と書き換える事が出来ます。

    /* Examples for testing */
    
     lambda x:Bot. x;
     lambda x:Bot. x x; 
    
     
    lambda x:<a:Bool,b:Bool>. x;
    
    
    lambda x:Top. x;
     (lambda x:Top. x) (lambda x:Top. x);
    (lambda x:Top->Top. x) (lambda x:Top. x);
    
    
    (lambda r:{x:Top->Top}. r.x r.x) 
      {x=lambda z:Top.z, y=lambda z:Top.z}; 
    
    
    "hello";
    
    unit;
    
    lambda x:A. x;
    
    let x=true in x;
    
    {x=true, y=false}; 
    {x=true, y=false}.x;
    {true, false}; 
    {true, false}.1; 
    
    
    if true then {x=true,y=false,a=false} else {y=false,x={},b=false};
    
    timesfloat 2.0 3.14159;
    
    
    
    
    lambda x:Bool. x;
    (lambda x:Bool->Bool. if x false then true else false) 
      (lambda x:Bool. if x then false else true); 
    
    lambda x:Nat. succ x;
    (lambda x:Nat. succ (succ x)) (succ 0); 
    
    T = Nat->Nat;
    lambda f:T. lambda x:Nat. f (f x);
    x = ref 5; x := 8; !x;
    
    
<center>fullref/test.f</center>

### output

    (lambda x:Bot. x) : Bot -> Bot
    (lambda x:Bot. x x) : Bot -> Bot
    (lambda x:<a:Bool,b:Bool>. x)
      : <a:Bool,b:Bool> -> <a:Bool, b:Bool>
    (lambda x:Top. x) : Top -> Top
    (lambda x:Top. x) : Top
    (lambda x:Top. x) : Top -> Top
    (lambda z:Top. z) : Top
    "hello" : String
    unit : Unit
    (lambda x:A. x) : A -> A
    true : Bool
    {x=true, y=false} : {x:Bool, y:Bool}
    true : Bool
    {true, false} : {Bool, Bool}
    true : Bool
    {x=true, y=false, a=false} : {x:Top, y:Bool}
    6.28318 : Float
    (lambda x:Bool. x) : Bool -> Bool
    true : Bool
    (lambda x:Nat. (succ x)) : Nat -> Nat
    3 : Nat
    T :: *
    (lambda f:T. lambda x:Nat. f (f x)) : T -> Nat -> Nat
    x : Ref Nat
    unit : Unit
    8 : Nat


## fullerror

fullerrorはエラーを処理するようにした言語です。

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
    
    
<center>fullerror/test.f</center>

### output

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

# 第 III 部 部分型付け

ScalaでいうAnyとNothingをTop,Botという型で表し、その簡単な型システムをλ計算状に構築します。

## bot

bot言語は単純な部分型付けが出来るλ計算が出来る言語です。

    /* Examples for testing */
    
     lambda x:Top. x;
      (lambda x:Top. x) (lambda x:Top. x);
     (lambda x:Top->Top. x) (lambda x:Top. x);
     
    
    lambda x:Bot. x;
    lambda x:Bot. x x; 
    
<center>bot/test.f</center>


### output

    (lambda x:Top. x) : Top -> Top
    (lambda x:Top. x) : Top
    (lambda x:Top. x) : Top -> Top
    (lambda x:Bot. x) : Bot -> Bot
    (lambda x:Bot. x x) : Bot -> Bot

(lambda x:Top. x)の型はTop -> Topです。
(ScalaのAnyや、JavaのObjectのように)Topは何でも含まれる型なので
(lambda x:Top. x)の型はTopでも有り得ます。

Botは逆に全ての型の部分型です。



### 部分型付け

    let rec subtype tyS tyT =
       (=) tyS tyT ||
       match (tyS,tyT) with
         (_,TyTop) -> 
           true
       | (TyBot,_) -> 
           true
       | (TyArr(tyS1,tyS2),TyArr(tyT1,tyT2)) ->
           (subtype tyT1 tyS1) && (subtype tyS2 tyT2)
       | (_,_) -> 
           false

### 型付け

    let rec typeof ctx t =
      match t with
        TmVar(fi,i,_) -> getTypeFromContext fi ctx i
      | TmAbs(fi,x,tyT1,t2) ->
          let ctx' = addbinding ctx x (VarBind(tyT1)) in
          let tyT2 = typeof ctx' t2 in
          TyArr(tyT1, tyT2)
      | TmApp(fi,t1,t2) ->
          let tyT1 = typeof ctx t1 in
          let tyT2 = typeof ctx t2 in
          (match tyT1 with
              TyArr(tyT11,tyT12) ->
                if subtype tyT2 tyT11 then tyT12
                else error fi "parameter type mismatch" 
            | TyBot -> TyBot
            | _ -> error fi "arrow type expected")

## rcdsubbot

レコードによる部分型付けシステムです。

    /* Examples for testing */
    
     lambda x:Top. x;
      (lambda x:Top. x) (lambda x:Top. x);
     (lambda x:Top->Top. x) (lambda x:Top. x);
     
    
    (lambda r:{x:Top->Top}. r.x r.x) 
      {x=lambda z:Top.z, y=lambda z:Top.z}; 
    
    
    lambda x:Bot. x;
    lambda x:Bot. x x; 
    
<center>rcdsubbot/test.f</center>

### output

    (lambda x:Top. x) : Top -> Top
    (lambda x:Top. x) : Top
    (lambda x:Top. x) : Top -> Top
    (lambda z:Top. z) : Top
    (lambda x:Bot. x) : Bot -> Bot
    (lambda x:Bot. x x) : Bot -> Bot
    
## fullsub

部分型付けシステムの付いたフル実装です。タプルも使えます。

    /* Examples for testing */
    
     lambda x:Top. x;
      (lambda x:Top. x) (lambda x:Top. x);
     (lambda x:Top->Top. x) (lambda x:Top. x);
     
    
    (lambda r:{x:Top->Top}. r.x r.x) 
      {x=lambda z:Top.z, y=lambda z:Top.z}; 
    
    
    "hello";
    
    unit;
    
    lambda x:A. x;
    
    let x=true in x;
    
    {x=true, y=false}; 
    {x=true, y=false}.x;
    {true, false}; 
    {true, false}.1; 
    
    
    if true then {x=true,y=false,a=false} else {y=false,x={},b=false};
    
    timesfloat 2.0 3.14159;
    
    lambda x:Bool. x;
    (lambda x:Bool->Bool. if x false then true else false) 
      (lambda x:Bool. if x then false else true); 
    
    lambda x:Nat. succ x;
    (lambda x:Nat. succ (succ x)) (succ 0); 
    
    T = Nat->Nat;
    lambda f:T. lambda x:Nat. f (f x);
    
    
<center>fullsub/test.f</center>

### output

    (lambda x:Top. x) : Top -> Top
    (lambda x:Top. x) : Top
    (lambda x:Top. x) : Top -> Top
    (lambda z:Top. z) : Top
    "hello" : String
    unit : Unit
    (lambda x:A. x) : A -> A
    true : Bool
    {x=true, y=false} : {x:Bool, y:Bool}
    true : Bool
    {true, false} : {Bool, Bool}
    true : Bool
    {x=true, y=false, a=false} : {x:Top, y:Bool}
    6.28318 : Float
    (lambda x:Bool. x) : Bool -> Bool
    true : Bool
    (lambda x:Nat. (succ x)) : Nat -> Nat
    3 : Nat
    T :: *
    (lambda f:T. lambda x:Nat. f (f x)) : T -> Nat -> Nat

# 第 IV 部 再帰型

## equirec

    /* Examples for testing */
    
     lambda x:A. x;
    
    
    lambda f:Rec X.A->A. lambda x:A. f x;
    
    
<center>equirec/test.f</center>

### output

    (lambda x:A. x) : A -> A
    (lambda f:Rec X. A->A. lambda x:A. f x) : (Rec X. A->A) -> A -> A
        
## fullequirec

    /* Examples for testing */
    
     "hello";
    
    lambda x:A. x;
    
    timesfloat 2.0 3.14159;
    
    lambda x:Bool. x;
    (lambda x:Bool->Bool. if x false then true else false) 
      (lambda x:Bool. if x then false else true); 
    
    lambda x:Nat. succ x;
    (lambda x:Nat. succ (succ x)) (succ 0); 
    
    T = Nat->Nat;
    lambda f:T. lambda x:Nat. f (f x);
    
    
    
    lambda f:Rec X.A->A. lambda x:A. f x;
    
    
    {x=true, y=false}; 
    {x=true, y=false}.x;
    {true, false}; 
    {true, false}.1; 
    
    
     
    lambda x:<a:Bool,b:Bool>. x;
    
    
    
    Counter = Rec P. {get:Nat, inc:Unit->P}; 
    
    p = 
    let create = 
      fix 
        (lambda cr: {x:Nat}->Counter.
          lambda s: {x:Nat}.
            {get = s.x,
             inc = lambda _:Unit. cr {x=succ(s.x)}})
    in
      create {x=0};
    
    p1 = p.inc unit;
    p1.get;
    
    get = lambda p:Counter. p.get;
    inc = lambda p:Counter. p.inc;
    
    Hungry = Rec A. Nat -> A;
    
    f0 =
    fix 
      (lambda f: Nat->Hungry.
       lambda n:Nat.
         f);
    
    f1 = f0 0;
    f2 = f1 2;
    
    T = Nat;
      
    fix_T = 
    lambda f:T->T.
      (lambda x:(Rec A.A->T). f (x x))
      (lambda x:(Rec A.A->T). f (x x));
    
    D = Rec X. X->X;
    
    fix_D = 
    lambda f:D->D.
      (lambda x:(Rec A.A->D). f (x x))
      (lambda x:(Rec A.A->D). f (x x));
    
    diverge_D = lambda _:Unit. fix_D (lambda x:D. x);
    
    lam = lambda f:D->D. f;
    ap = lambda f:D. lambda a:D. f a;
    
    myfix = lam (lambda f:D.
                 ap (lam (lambda x:D. ap f (ap x x))) 
                    (lam (lambda x:D. ap f (ap x x))));
    
    
    let x=true in x;
    
    unit;
    
     
    NatList = Rec X. <nil:Unit, cons:{Nat,X}>; 
    
    nil = <nil=unit> as NatList;
    
    cons = lambda n:Nat. lambda l:NatList. <cons={n,l}> as NatList;
    
    isnil = lambda l:NatList. 
    case l of
    <nil=u> ==> true
    | <cons=p> ==> false;
    
    hd = lambda l:NatList. 
    case l of
    <nil=u> ==> 0
    | <cons=p> ==> p.1;
    
    tl = lambda l:NatList. 
    case l of
    <nil=u> ==> l
    | <cons=p> ==> p.2;
    
    plus = fix (lambda p:Nat->Nat->Nat. 
    lambda m:Nat. lambda n:Nat. 
    if iszero m then n else succ (p (pred m) n));
    
    sumlist = fix (lambda s:NatList->Nat. lambda l:NatList.
    if isnil l then 0 else plus (hd l) (s (tl l)));
    
    mylist = cons 2 (cons 3 (cons 5 nil));
    
    sumlist mylist;
    
    
    
<center>fullequirec/test.f</center>

### output

    "hello" : String
    (lambda x:A. x) : A -> A
    6.28318 : Float
    (lambda x:Bool. x) : Bool -> Bool
    true : Bool
    (lambda x:Nat. (succ x)) : Nat -> Nat
    3 : Nat
    T :: *
    (lambda f:T. lambda x:Nat. f (f x)) : T -> Nat -> Nat
    (lambda f:Rec X. A->A. lambda x:A. f x) : (Rec X. A->A) -> A -> A
    {x=true, y=false} : {x:Bool, y:Bool}
    true : Bool
    {true, false} : {Bool, Bool}
    true : Bool
    (lambda x:<a:Bool,b:Bool>. x)
      : <a:Bool,b:Bool> -> <a:Bool, b:Bool>
    Counter :: *
    p : {get:Nat, inc:Unit->Counter}
    p1 : Counter
    1 : Nat
    get : Counter -> Nat
    inc : Counter -> Unit -> (Rec P. {get:Nat, inc:Unit->P})
    Hungry :: *
    f0 : Nat -> Nat -> Hungry
    f1 : Nat -> Hungry
    f2 : Hungry
    T :: *
    fix_T : (T->T) -> T
    D :: *
    fix_D : (D->D) -> D
    diverge_D : Unit -> D
    lam : (D->D) -> D -> D
    ap : D -> D -> (Rec X. X -> X)
    myfix : D -> D
    true : Bool
    unit : Unit
    NatList :: *
    nil : NatList
    cons : Nat -> NatList -> NatList
    isnil : NatList -> Bool
    hd : NatList -> Nat
    tl : NatList -> NatList
    plus : Nat -> Nat -> Nat
    sumlist : NatList -> Nat
    mylist : NatList
    10 : Nat
    
## fullisorec

同型再帰型

    /* Examples for testing */
    
     "hello";
    
    unit;
    
    lambda x:A. x;
    
    let x=true in x;
    
    timesfloat 2.0 3.14159;
    
    {x=true, y=false}; 
    {x=true, y=false}.x;
    {true, false}; 
    {true, false}.1; 
    
    
    lambda x:Bool. x;
    (lambda x:Bool->Bool. if x false then true else false) 
      (lambda x:Bool. if x then false else true); 
    
    lambda x:Nat. succ x;
    (lambda x:Nat. succ (succ x)) (succ 0); 
    
     
    lambda x:<a:Bool,b:Bool>. x;
    
    
    
    Counter = Rec P. {get:Nat, inc:Unit->P}; 
    p = 
    let create = 
      fix 
        (lambda cr: {x:Nat}->Counter.
          lambda s: {x:Nat}.
            fold [Counter]
              {get = s.x,
               inc = lambda _:Unit. cr {x=succ(s.x)}})
    in
      create {x=0};
    p1 = (unfold [Counter] p).inc unit;
    (unfold [Counter] p1).get;
    
    
    T = Nat->Nat;
    lambda f:T. lambda x:Nat. f (f x);
    
    
<center>fullisorec/test.f</center>

### output

    "hello" : String
    unit : Unit
    (lambda x:A. x) : A -> A
    true : Bool
    6.28318 : Float
    {x=true, y=false} : {x:Bool, y:Bool}
    true : Bool
    {true, false} : {Bool, Bool}
    true : Bool
    (lambda x:Bool. x) : Bool -> Bool
    true : Bool
    (lambda x:Nat. (succ x)) : Nat -> Nat
    3 : Nat
    (lambda x:<a:Bool,b:Bool>. x)
      : <a:Bool,b:Bool> -> <a:Bool, b:Bool>
    Counter :: *
    p : Counter
    p1 : Counter
    1 : Nat
    T :: *
    (lambda f:T. lambda x:Nat. f (f x)) : T -> Nat -> Nat


# 第 V 部 多相性
    
## reconbase

    /* Examples for testing */
    
     lambda x:A. x;
    
    lambda x:Bool. x;
    (lambda x:Bool->Bool. if x false then true else false) 
      (lambda x:Bool. if x then false else true); 
    
    lambda x:Nat. succ x;
    (lambda x:Nat. succ (succ x)) (succ 0); 
    
<center>reconbase/test.f</center>

### output

    (lambda x:A. x) : A -> A
    (lambda x:Bool. x) : Bool -> Bool
    true : Bool
    (lambda x:Nat. (succ x)) : Nat -> Nat
    3 : Nat
    
## recon

型再構築

    /* Examples for testing */
    
     lambda x:Bool. x;
     (lambda x:Bool->Bool. if x false then true else false) 
       (lambda x:Bool. if x then false else true); 
    
    lambda x:Nat. succ x;
    (lambda x:Nat. succ (succ x)) (succ 0); 
    
    lambda x:A. x;
    
    
    (lambda x:X. lambda y:X->X. y x);
    (lambda x:X->X. x 0) (lambda y:Nat. y); 
    
    
<center>recon/test.f</center>

### output

    (lambda x:Bool. x) : Bool -> Bool
    true : Bool
    (lambda x:Nat. (succ x)) : Nat -> Nat
    3 : Nat
    (lambda x:A. x) : A -> A
    (lambda x:X. lambda y:X->X. y x) : X -> (X->X) -> X
    0 : Nat
        
## fullrecon

型推論もあるよと。

    /* Examples for testing */
    
     let x=true in x;
    
    lambda x:Bool. x;
    (lambda x:Bool->Bool. if x false then true else false) 
      (lambda x:Bool. if x then false else true); 
    
    lambda x:Nat. succ x;
    (lambda x:Nat. succ (succ x)) (succ 0); 
    
    lambda x:A. x;
    
    
    (lambda x:X. lambda y:X->X. y x);
    (lambda x:X->X. x 0) (lambda y:Nat. y); 
    
    
    
    (lambda x. x 0);
    let f = lambda x. x in (f f) (f 0);
    let g = lambda x. 1 in g (g g);
    
    
<center>fullrecon/test.f</center>

### output

    true : Bool
    (lambda x:Bool. x) : Bool -> Bool
    true : Bool
    (lambda x:Nat. (succ x)) : Nat -> Nat
    3 : Nat
    (lambda x:A. x) : A -> A
    (lambda x:X. lambda y:X->X. y x) : X -> (X->X) -> X
    0 : Nat
    (lambda x. x 0) : (Nat->?X7) -> ?X7
    0 : Nat
    1 : Nat

## fullpoly

全称型、存在型


    /* Examples for testing */
    
     "hello";
    
    unit;
    
    lambda x:A. x;
    
    let x=true in x;
    
    timesfloat 2.0 3.14159;
    
    lambda x:Bool. x;
    (lambda x:Bool->Bool. if x false then true else false) 
      (lambda x:Bool. if x then false else true); 
    
    lambda x:Nat. succ x;
    (lambda x:Nat. succ (succ x)) (succ 0); 
    
    T = Nat->Nat;
    lambda f:T. lambda x:Nat. f (f x);
    
    
    lambda X. lambda x:X. x; 
    (lambda X. lambda x:X. x) [All X.X->X]; 
    
     {*All Y.Y, lambda x:(All Y.Y). x} as {Some X,X->X};
    
    
    {x=true, y=false}; 
    {x=true, y=false}.x;
    {true, false}; 
    {true, false}.1; 
    
    
    {*Nat, {c=0, f=lambda x:Nat. succ x}}
      as {Some X, {c:X, f:X->Nat}};
    let {X,ops} = {*Nat, {c=0, f=lambda x:Nat. succ x}}
                  as {Some X, {c:X, f:X->Nat}}
    in (ops.f ops.c);
    
    
<center>fullpoly/test.f</center>

### output

    "hello" : String
    unit : Unit
    (lambda x:A. x) : A -> A
    true : Bool
    6.28318 : Float
    (lambda x:Bool. x) : Bool -> Bool
    true : Bool
    (lambda x:Nat. (succ x)) : Nat -> Nat
    3 : Nat
    T :: *
    (lambda f:T. lambda x:Nat. f (f x)) : T -> Nat -> Nat
    (lambda X. lambda x:X. x) : All X. X -> X
    (lambda x:All X. X->X. x) : (All X. X->X) -> (All X. X -> X)
    {*All Y. Y, lambda x:All Y. Y.x} as {Some X, X->X}
      : {Some X, X->X}
    {x=true, y=false} : {x:Bool, y:Bool}
    true : Bool
    {true, false} : {Bool, Bool}
    true : Bool
    {*Nat, {c=0,f=lambda x:Nat. (succ x)}} as {Some X, {c:X,f:X->Nat}}
      : {Some X, {c:X,f:X->Nat}}
    1 : Nat

# 第 VI 部 高階の型システム

## fullomega

    /* Examples for testing */
    
     "hello";
    
    unit;
    
    lambda x:A. x;
    
    let x=true in x;
    
    timesfloat 2.0 3.14159;
    
    lambda x:Bool. x;
    (lambda x:Bool->Bool. if x false then true else false) 
      (lambda x:Bool. if x then false else true); 
    
    lambda x:Nat. succ x;
    (lambda x:Nat. succ (succ x)) (succ 0); 
    
    T = Nat->Nat;
    lambda f:T. lambda x:Nat. f (f x);
    
    
    lambda X. lambda x:X. x; 
    (lambda X. lambda x:X. x) [All X.X->X]; 
    
     {*All Y.Y, lambda x:(All Y.Y). x} as {Some X,X->X};
    
    
    {x=true, y=false}; 
    {x=true, y=false}.x;
    {true, false}; 
    {true, false}.1; 
    
    
    {*Nat, {c=0, f=lambda x:Nat. succ x}}
      as {Some X, {c:X, f:X->Nat}};
    let {X,ops} = {*Nat, {c=0, f=lambda x:Nat. succ x}}
                  as {Some X, {c:X, f:X->Nat}}
    in (ops.f ops.c);
    
    
    
    Pair = lambda X. lambda Y. All R. (X->Y->R) -> R;
    
    pair = lambda X.lambda Y.lambda x:X.lambda y:Y.lambda R.lambda p:X->Y->R.p x y;
    
    f = lambda X.lambda Y.lambda f:Pair X Y. f;
    
    fst = lambda X.lambda Y.lambda p:Pair X Y.p [X] (lambda x:X.lambda y:Y.x);
    snd = lambda X.lambda Y.lambda p:Pair X Y.p [Y] (lambda x:X.lambda y:Y.y);
    
    pr = pair [Nat] [Bool] 0 false;
    fst [Nat] [Bool] pr;
    snd [Nat] [Bool] pr;
    
    List = lambda X. All R. (X->R->R) -> R -> R; 
    
    diverge =
    lambda X.
      lambda _:Unit.
      fix (lambda x:X. x);
    
    nil = lambda X.
          (lambda R. lambda c:X->R->R. lambda n:R. n)
          as List X; 
    
    cons = 
    lambda X.
      lambda hd:X. lambda tl: List X.
         (lambda R. lambda c:X->R->R. lambda n:R. c hd (tl [R] c n))
         as List X; 
    
    isnil =  
    lambda X. 
      lambda l: List X. 
        l [Bool] (lambda hd:X. lambda tl:Bool. false) true; 
    
    head = 
    lambda X. 
      lambda l: List X. 
        (l [Unit->X] (lambda hd:X. lambda tl:Unit->X. lambda _:Unit. hd) (diverge [X]))
        unit; 
    
    tail =  
    lambda X.  
      lambda l: List X. 
        (fst [List X] [List X] ( 
          l [Pair (List X) (List X)]
            (lambda hd: X. lambda tl: Pair (List X) (List X). 
              pair [List X] [List X] 
                (snd [List X] [List X] tl)  
                (cons [X] hd (snd [List X] [List X] tl))) 
            (pair [List X] [List X] (nil [X]) (nil [X]))))
        as List X; 
    
    
<center>fullomega/test.f</center>

### output

    "hello" : String
    unit : Unit
    (lambda x:A. x) : A -> A
    true : Bool
    6.28318 : Float
    (lambda x:Bool. x) : Bool -> Bool
    true : Bool
    (lambda x:Nat. (succ x)) : Nat -> Nat
    3 : Nat
    T :: *
    (lambda f:T. lambda x:Nat. f (f x)) : T -> Nat -> Nat
    (lambda X. lambda x:X. x) : All X. X -> X
    (lambda x:All X. X->X. x) : (All X. X->X) -> (All X. X -> X)
    {*All Y. Y, lambda x:All Y. Y.x} as {Some X, X->X}
      : {Some X, X->X}
    {x=true, y=false} : {x:Bool, y:Bool}
    true : Bool
    {true, false} : {Bool, Bool}
    true : Bool
    {*Nat, {c=0,f=lambda x:Nat. (succ x)}} as {Some X, {c:X,f:X->Nat}}
      : {Some X, {c:X,f:X->Nat}}
    1 : Nat
    Pair :: * => * => *
    pair : All X. All Y. X -> Y -> (All R. (X->Y->R) -> R)
    f : All X. All Y. Pair X Y -> Pair X Y
    fst : All X. All Y. Pair X Y -> X
    snd : All X. All Y. Pair X Y -> Y
    pr : All R. (Nat->Bool->R) -> R
    0 : Nat
    false : Bool
    List :: * => *
    diverge : All X. Unit -> X
    nil : All X. List X
    cons : All X. X -> List X -> List X
    isnil : All X. List X -> Bool
    head : All X. List X -> X
    tail : All X. List X -> List X
    
## fullfomsub

    /* Examples for testing */
    
     lambda x:Top. x;
      (lambda x:Top. x) (lambda x:Top. x);
     (lambda x:Top->Top. x) (lambda x:Top. x);
     
    
    (lambda r:{x:Top->Top}. r.x r.x) 
      {x=lambda z:Top.z, y=lambda z:Top.z}; 
    
    
    "hello";
    
    unit;
    
    lambda x:A. x;
    
    let x=true in x;
    
    {x=true, y=false}; 
    {x=true, y=false}.x;
    {true, false}; 
    {true, false}.1; 
    
    
    if true then {x=true,y=false,a=false} else {y=false,x={},b=false};
    
    timesfloat 2.0 3.14159;
    
    lambda X. lambda x:X. x; 
    (lambda X. lambda x:X. x) [All X.X->X]; 
    
    lambda X<:Top->Top. lambda x:X. x x; 
    
    
    lambda x:Bool. x;
    (lambda x:Bool->Bool. if x false then true else false) 
      (lambda x:Bool. if x then false else true); 
    
    lambda x:Nat. succ x;
    (lambda x:Nat. succ (succ x)) (succ 0); 
    
    T = Nat->Nat;
    lambda f:T. lambda x:Nat. f (f x);
    
    
     {*All Y.Y, lambda x:(All Y.Y). x} as {Some X,X->X};
    
    
    {*Nat, {c=0, f=lambda x:Nat. succ x}}
      as {Some X, {c:X, f:X->Nat}};
    let {X,ops} = {*Nat, {c=0, f=lambda x:Nat. succ x}}
                  as {Some X, {c:X, f:X->Nat}}
    in (ops.f ops.c);
    
    
    
    Pair = lambda X. lambda Y. All R. (X->Y->R) -> R;
    
    pair = lambda X.lambda Y.lambda x:X.lambda y:Y.lambda R.lambda p:X->Y->R.p x y;
    
    f = lambda X.lambda Y.lambda f:Pair X Y. f;
    
    fst = lambda X.lambda Y.lambda p:Pair X Y.p [X] (lambda x:X.lambda y:Y.x);
    snd = lambda X.lambda Y.lambda p:Pair X Y.p [Y] (lambda x:X.lambda y:Y.y);
    
    pr = pair [Nat] [Bool] 0 false;
    fst [Nat] [Bool] pr;
    snd [Nat] [Bool] pr;
    
    List = lambda X. All R. (X->R->R) -> R -> R; 
    
    diverge =
    lambda X.
      lambda _:Unit.
      fix (lambda x:X. x);
    
    nil = lambda X.
          (lambda R. lambda c:X->R->R. lambda n:R. n)
          as List X; 
    
    cons = 
    lambda X.
      lambda hd:X. lambda tl: List X.
         (lambda R. lambda c:X->R->R. lambda n:R. c hd (tl [R] c n))
         as List X; 
    
    isnil =  
    lambda X. 
      lambda l: List X. 
        l [Bool] (lambda hd:X. lambda tl:Bool. false) true; 
    
    head = 
    lambda X. 
      lambda l: List X. 
        (l [Unit->X] (lambda hd:X. lambda tl:Unit->X. lambda _:Unit. hd) (diverge [X]))
        unit; 
    
    tail =  
    lambda X.  
      lambda l: List X. 
        (fst [List X] [List X] ( 
          l [Pair (List X) (List X)]
            (lambda hd: X. lambda tl: Pair (List X) (List X). 
              pair [List X] [List X] 
                (snd [List X] [List X] tl)  
                (cons [X] hd (snd [List X] [List X] tl))) 
            (pair [List X] [List X] (nil [X]) (nil [X]))))
        as List X; 
    
    
<center>fullfomsub/test.f</center>

### output

    (lambda x:Top. x) : Top -> Top
    (lambda x:Top. x) : Top
    (lambda x:Top. x) : Top -> Top
    (lambda z:Top. z) : Top
    "hello" : String
    unit : Unit
    (lambda x:A. x) : A -> A
    true : Bool
    {x=true, y=false} : {x:Bool, y:Bool}
    true : Bool
    {true, false} : {Bool, Bool}
    true : Bool
    {x=true, y=false, a=false} : {x:Top, y:Bool}
    6.28318 : Float
    (lambda X. lambda x:X. x) : All X. X -> X
    (lambda x:All X. X->X. x) : (All X. X->X) -> (All X. X -> X)
    (lambda X<:Top->Top. lambda x:X. x x) : All X<:Top->Top. X -> Top
    (lambda x:Bool. x) : Bool -> Bool
    true : Bool
    (lambda x:Nat. (succ x)) : Nat -> Nat
    3 : Nat
    T :: *
    (lambda f:T. lambda x:Nat. f (f x)) : T -> Nat -> Nat
    {*All Y. Y, lambda x:All Y. Y.x} as {Some X, X->X}
      : {Some X, X->X}
    {*Nat, {c=0,f=lambda x:Nat. (succ x)}} as {Some X, {c:X,f:X->Nat}}
      : {Some X, {c:X,f:X->Nat}}
    1 : Nat
    Pair :: * => * => *
    pair : All X. All Y. X -> Y -> (All R. (X->Y->R) -> R)
    f : All X. All Y. Pair X Y -> Pair X Y
    fst : All X. All Y. Pair X Y -> X
    snd : All X. All Y. Pair X Y -> Y
    pr : All R. (Nat->Bool->R) -> R
    0 : Nat
    false : Bool
    List :: * => *
    diverge : All X. Unit -> X
    nil : All X. List X
    cons : All X. X -> List X -> List X
    isnil : All X. List X -> Bool
    head : All X. List X -> X
    tail : All X. List X -> List X
    
## purefsub

    /* Examples for testing */
    
     lambda X. lambda x:X. x; 
     (lambda X. lambda x:X. x) [All X.X->X]; 
    
    lambda x:Top. x;
     (lambda x:Top. x) (lambda x:Top. x);
    (lambda x:Top->Top. x) (lambda x:Top. x);
    
    
    lambda X<:Top->Top. lambda x:X. x x; 
    
    
<center>purefsub/test.f</center>

### output

    (lambda X. lambda x:X. x) : All X. X -> X
    (lambda x:All X. X->X. x) : (All X. X->X) -> (All X. X -> X)
    (lambda x:Top. x) : Top -> Top
    (lambda x:Top. x) : Top
    (lambda x:Top. x) : Top -> Top
    (lambda X<:Top->Top. lambda x:X. x x) : All X<:Top->Top. X -> Top
    
## fullfsub

    /* Examples for testing */
    
     lambda x:Top. x;
      (lambda x:Top. x) (lambda x:Top. x);
     (lambda x:Top->Top. x) (lambda x:Top. x);
     
    
    (lambda r:{x:Top->Top}. r.x r.x) 
      {x=lambda z:Top.z, y=lambda z:Top.z}; 
    
    
    "hello";
    
    unit;
    
    lambda x:A. x;
    
    let x=true in x;
    
    {x=true, y=false}; 
    {x=true, y=false}.x;
    {true, false}; 
    {true, false}.1; 
    
    
    if true then {x=true,y=false,a=false} else {y=false,x={},b=false};
    
    timesfloat 2.0 3.14159;
    
    lambda X. lambda x:X. x; 
    (lambda X. lambda x:X. x) [All X.X->X]; 
    
    lambda X<:Top->Top. lambda x:X. x x; 
    
    
    lambda x:Bool. x;
    (lambda x:Bool->Bool. if x false then true else false) 
      (lambda x:Bool. if x then false else true); 
    
    lambda x:Nat. succ x;
    (lambda x:Nat. succ (succ x)) (succ 0); 
    
    T = Nat->Nat;
    lambda f:T. lambda x:Nat. f (f x);
    
    
     {*All Y.Y, lambda x:(All Y.Y). x} as {Some X,X->X};
    
    
    {*Nat, {c=0, f=lambda x:Nat. succ x}}
      as {Some X, {c:X, f:X->Nat}};
    let {X,ops} = {*Nat, {c=0, f=lambda x:Nat. succ x}}
                  as {Some X, {c:X, f:X->Nat}}
    in (ops.f ops.c);
    
    
<center>fullfsub/test.f</center>

### output

    (lambda x:Top. x) : Top -> Top
    (lambda x:Top. x) : Top
    (lambda x:Top. x) : Top -> Top
    (lambda z:Top. z) : Top
    "hello" : String
    unit : Unit
    (lambda x:A. x) : A -> A
    true : Bool
    {x=true, y=false} : {x:Bool, y:Bool}
    true : Bool
    {true, false} : {Bool, Bool}
    true : Bool
    {x=true, y=false, a=false} : {x:Top, y:Bool}
    6.28318 : Float
    (lambda X. lambda x:X. x) : All X. X -> X
    (lambda x:All X. X->X. x) : (All X. X->X) -> (All X. X -> X)
    (lambda X<:Top->Top. lambda x:X. x x) : All X<:Top->Top. X -> Top
    (lambda x:Bool. x) : Bool -> Bool
    true : Bool
    (lambda x:Nat. (succ x)) : Nat -> Nat
    3 : Nat
    T :: *
    (lambda f:T. lambda x:Nat. f (f x)) : T -> Nat -> Nat
    {*All Y. Y, lambda x:All Y. Y.x} as {Some X, X->X}
      : {Some X, X->X}
    {*Nat, {c=0,f=lambda x:Nat. (succ x)}} as {Some X, {c:X,f:X->Nat}}
      : {Some X, {c:X,f:X->Nat}}
    1 : Nat
    
## fullfomsubref

    /* Examples for testing */
    
     lambda x:Bot. x;
     lambda x:Bot. x x; 
    
     
    lambda x:<a:Bool,b:Bool>. x;
    
    
    lambda x:Top. x;
     (lambda x:Top. x) (lambda x:Top. x);
    (lambda x:Top->Top. x) (lambda x:Top. x);
    
    
    (lambda r:{x:Top->Top}. r.x r.x) 
      {x=lambda z:Top.z, y=lambda z:Top.z}; 
    
    
    "hello";
    
    unit;
    
    lambda x:A. x;
    
    let x=true in x;
    
    {x=true, y=false}; 
    {x=true, y=false}.x;
    {true, false}; 
    {true, false}.1; 
    
    
    if true then {x=true,y=false,a=false} else {y=false,x={},b=false};
    
    timesfloat 2.0 3.14159;
    
    lambda X. lambda x:X. x; 
    (lambda X. lambda x:X. x) [All X.X->X]; 
    
    lambda X<:Top->Top. lambda x:X. x x; 
    
    
    lambda x:Bool. x;
    (lambda x:Bool->Bool. if x false then true else false) 
      (lambda x:Bool. if x then false else true); 
    
    if error then true else false;
    
    
    error true;
    (lambda x:Bool. x) error;
    
    
    
    
    
    lambda x:Nat. succ x;
    (lambda x:Nat. succ (succ x)) (succ 0); 
    
    T = Nat->Nat;
    lambda f:T. lambda x:Nat. f (f x);
    
    
    
    
    /* Alternative object encodings */
    
    CounterRep = {x: Ref Nat};
    
    SetCounter = {get:Unit->Nat, set:Nat->Unit, inc:Unit->Unit}; 
    
    setCounterClass =
    lambda r:CounterRep.
    lambda self: Unit->SetCounter.
    lambda _:Unit.
    {get = lambda _:Unit. !(r.x),
    set = lambda i:Nat.  r.x:=i,
    inc = lambda _:Unit. (self unit).set (succ((self unit).get unit))} 
        as SetCounter;
    
    newSetCounter = 
    lambda _:Unit.
    let r = {x=ref 1} in
    fix (setCounterClass r) unit;
    
    c = newSetCounter unit;
    c.get unit;
    
    InstrCounter = {get:Unit->Nat, 
    set:Nat->Unit, 
    inc:Unit->Unit,
    accesses:Unit->Nat};
    
    InstrCounterRep = {x: Ref Nat, a: Ref Nat};
    
    instrCounterClass =
    lambda r:InstrCounterRep.
    lambda self: Unit->InstrCounter.
    lambda _:Unit.
    let super = setCounterClass r self unit in
    {get = super.get,
    set = lambda i:Nat. (r.a:=succ(!(r.a)); super.set i),
    inc = super.inc,
    accesses = lambda _:Unit. !(r.a)} as InstrCounter;
    
    newInstrCounter = 
    lambda _:Unit.
    let r = {x=ref 1, a=ref 0} in
    fix (instrCounterClass r) unit;
    
    ic = newInstrCounter unit;
    
    ic.get unit;
    
    ic.accesses unit;
    
    ic.inc unit;
    
    ic.get unit;
    
    ic.accesses unit;
    
    /* ------------ */
    
    instrCounterClass =
    lambda r:InstrCounterRep.
    lambda self: Unit->InstrCounter.
    lambda _:Unit.
    let super = setCounterClass r self unit in
    {get = lambda _:Unit. (r.a:=succ(!(r.a)); super.get unit),
    set = lambda i:Nat. (r.a:=succ(!(r.a)); super.set i),
    inc = super.inc,
    accesses = lambda _:Unit. !(r.a)} as InstrCounter;
    
    ResetInstrCounter = {get:Unit->Nat, set:Nat->Unit, 
    inc:Unit->Unit, accesses:Unit->Nat,
    reset:Unit->Unit};
    
    resetInstrCounterClass =
    lambda r:InstrCounterRep.
    lambda self: Unit->ResetInstrCounter.
    lambda _:Unit.
    let super = instrCounterClass r self unit in
    {get = super.get,
    set = super.set,
    inc = super.inc,
    accesses = super.accesses,
    reset = lambda _:Unit. r.x:=0} 
    as ResetInstrCounter;
    
    BackupInstrCounter = {get:Unit->Nat, set:Nat->Unit, 
    inc:Unit->Unit, accesses:Unit->Nat,
    backup:Unit->Unit, reset:Unit->Unit};
    
    BackupInstrCounterRep = {x: Ref Nat, a: Ref Nat, b: Ref Nat};
    
    backupInstrCounterClass =
    lambda r:BackupInstrCounterRep.
    lambda self: Unit->BackupInstrCounter.
    lambda _:Unit.
    let super = resetInstrCounterClass r self unit in
    {get = super.get,
    set = super.set,
    inc = super.inc,
    accesses = super.accesses,
    reset = lambda _:Unit. r.x:=!(r.b),
    backup = lambda _:Unit. r.b:=!(r.x)} 
    as BackupInstrCounter;
    
    newBackupInstrCounter = 
    lambda _:Unit.
    let r = {x=ref 1, a=ref 0, b=ref 0} in
    fix (backupInstrCounterClass r) unit;
    
    ic = newBackupInstrCounter unit;
    
    (ic.inc unit; ic.get unit);
    
    (ic.backup unit; ic.get unit);
    
    (ic.inc unit; ic.get unit);
    
    (ic.reset unit; ic.get unit);
    
    ic.accesses unit;
    
    
    
    
    /*
    SetCounterMethodTable =  
    {get: Ref <none:Unit, some:Unit->Nat>, 
    set: Ref <none:Unit, some:Nat->Unit>, 
    inc: Ref <none:Unit, some:Unit->Unit>}; 
    
    packGet = 
    lambda f:Unit->Nat. 
    <some = f> as <none:Unit, some:Unit->Nat>;
    
    unpackGet = 
    lambda mt:SetCounterMethodTable.
    case !(mt.get) of
    <none=x> ==> error
    | <some=f> ==> f;
    
    packSet = 
    lambda f:Nat->Unit. 
    <some = f> as <none:Unit, some:Nat->Unit>;
    
    unpackSet = 
    lambda mt:SetCounterMethodTable.
    case !(mt.set) of
    <none=x> ==> error
    | <some=f> ==> f;
    
    packInc = 
    lambda f:Unit->Unit. 
    <some = f> as <none:Unit, some:Unit->Unit>;
    
    unpackInc = 
    lambda mt:SetCounterMethodTable.
    case !(mt.inc) of
    <none=x> ==> error
    | <some=f> ==> f;
    
    setCounterClass =
    lambda r:CounterRep.
    lambda self: SetCounterMethodTable.
    (self.get := packGet (lambda _:Unit. !(r.x));
    self.set := packSet (lambda i:Nat.  r.x:=i);
    self.inc := packInc (lambda _:Unit. unpackSet self (succ (unpackGet self unit))));
    */
    
    /* This diverges...
    
    setCounterClass =
    lambda R<:CounterRep.
    lambda self: R->SetCounter.
    lambda r: R.
    {get = lambda _:Unit. !(r.x),
    set = lambda i:Nat.  r.x:=i,
    inc = lambda _:Unit. (self r).set (succ((self r).get unit))} 
        as SetCounter;
    
    newSetCounter = 
    lambda _:Unit.
    let r = {x=ref 1} in
    fix (setCounterClass [CounterRep]) r;
    
    InstrCounter = {get:Unit->Nat, 
    set:Nat->Unit, 
    inc:Unit->Unit,
    accesses:Unit->Nat};
    
    InstrCounterRep = {x: Ref Nat, a: Ref Nat};
    
    instrCounterClass =
    lambda R<:InstrCounterRep.
    lambda self: R->InstrCounter.
    let super = setCounterClass [R] self in
    lambda r:R.
    {get = (super r).get,
    set = lambda i:Nat. (r.a:=succ(!(r.a)); (super r).set i),
    inc = (super r).inc,
    accesses = lambda _:Unit. !(r.a)} as InstrCounter;
    
    
    newInstrCounter = 
    lambda _:Unit.
    let r = {x=ref 1, a=ref 0} in
    fix (instrCounterClass [InstrCounterRep]) r;
    
    SET traceeval;
    
    ic = newInstrCounter unit;
    
    ic.get unit;
    
    ic.accesses unit;
    
    ic.inc unit;
    
    ic.get unit;
    
    ic.accesses unit;
    */
    
    /* This is cool...
    
    setCounterClass =
    lambda M<:SetCounter.
    lambda R<:CounterRep.
    lambda self: Ref(R->M).
    lambda r: R.
    {get = lambda _:Unit. !(r.x),
    set = lambda i:Nat.  r.x:=i,
    inc = lambda _:Unit. (!self r).set (succ((!self r).get unit))} 
          as SetCounter;
    
    
    newSetCounter = 
    lambda _:Unit.
    let m = ref (lambda r:CounterRep. error as SetCounter) in
    let m' = setCounterClass [SetCounter] [CounterRep] m in
    (m := m';
    let r = {x=ref 1} in
    m' r);
    
    c = newSetCounter unit;
    
    c.get unit;
    
    c.set 3;
    
    c.inc unit;
    
    c.get unit;
    
    setCounterClass =
    lambda M<:SetCounter.
    lambda R<:CounterRep.
    lambda self: Ref(R->M).
    lambda r: R.
    {get = lambda _:Unit. !(r.x),
    set = lambda i:Nat.  r.x:=i,
    inc = lambda _:Unit. (!self r).set (succ((!self r).get unit))} 
          as SetCounter;
    
    InstrCounter = {get:Unit->Nat, 
    set:Nat->Unit, 
    inc:Unit->Unit,
    accesses:Unit->Nat};
    
    InstrCounterRep = {x: Ref Nat, a: Ref Nat};
    
    instrCounterClass =
    lambda M<:InstrCounter.
    lambda R<:InstrCounterRep.
    lambda self: Ref(R->M).
    lambda r: R.
    let super = setCounterClass [M] [R] self in
    {get = (super r).get,
    set = lambda i:Nat. (r.a:=succ(!(r.a)); (super r).set i),
    inc = (super r).inc,
    accesses = lambda _:Unit. !(r.a)}     as InstrCounter;
    
    newInstrCounter = 
    lambda _:Unit.
    let m = ref (lambda r:InstrCounterRep. error as InstrCounter) in
    let m' = instrCounterClass [InstrCounter] [InstrCounterRep] m in
    (m := m';
    let r = {x=ref 1, a=ref 0} in
    m' r);
    
    ic = newInstrCounter unit;
    
    ic.get unit;
    
    ic.accesses unit;
    
    ic.inc unit;
    
    ic.get unit;
    
    ic.accesses unit;
    */
    
    /* James Reily's alternative: */
    
    Counter = {get:Unit->Nat, inc:Unit->Unit};
    inc3 = lambda c:Counter. (c.inc unit; c.inc unit; c.inc unit);
    
    SetCounter = {get:Unit->Nat, set:Nat->Unit, inc:Unit->Unit};
    InstrCounter = {get:Unit->Nat, set:Nat->Unit, inc:Unit->Unit, accesses:Unit->Nat};
    
    CounterRep = {x: Ref Nat};
    InstrCounterRep = {x: Ref Nat, a: Ref Nat};
    
    dummySetCounter =
    {get = lambda _:Unit. 0,
    set = lambda i:Nat.  unit,
    inc = lambda _:Unit. unit}
    as SetCounter;
    dummyInstrCounter =
    {get = lambda _:Unit. 0,
    set = lambda i:Nat.  unit,
    inc = lambda _:Unit. unit,
    accesses = lambda _:Unit. 0}
    as InstrCounter;
    
    setCounterClass =
    lambda r:CounterRep.
    lambda self: Source SetCounter.     
    {get = lambda _:Unit. !(r.x),
    set = lambda i:Nat. r.x:=i,
    inc = lambda _:Unit. (!self).set (succ ((!self).get unit))}
    as SetCounter;
    newSetCounter =
    lambda _:Unit. let r = {x=ref 1} in
    let cAux = ref dummySetCounter in
    (cAux :=
    (setCounterClass r cAux);
    !cAux);
    
    instrCounterClass =
    lambda r:InstrCounterRep.
    lambda self: Source InstrCounter.       /* NOT Ref */
    let super = setCounterClass r self in
    {get = super.get,
    set = lambda i:Nat. (r.a:=succ(!(r.a)); super.set i),
    inc = super.inc,
    accesses = lambda _:Unit. !(r.a)}
    as InstrCounter;
    newInstrCounter =
    lambda _:Unit. let r = {x=ref 1, a=ref 0} in
    let cAux = ref dummyInstrCounter in
    (cAux :=
    (instrCounterClass r cAux);
    !cAux);
    
    c = newInstrCounter unit;
    (inc3 c; c.get unit);
    (c.set(54); c.get unit);
    (c.accesses unit);
    
    
    
    
<center>fullfomsubref/test.f</center>

### output

    (lambda x:Bot. x) : Bot -> Bot
    (lambda x:Bot. x x) : Bot -> Bot
    (lambda x:<a:Bool,b:Bool>. x)
      : <a:Bool,b:Bool> -> <a:Bool, b:Bool>
    (lambda x:Top. x) : Top -> Top
    (lambda x:Top. x) : Top
    (lambda x:Top. x) : Top -> Top
    (lambda z:Top. z) : Top
    "hello" : String
    unit : Unit
    (lambda x:A. x) : A -> A
    true : Bool
    {x=true, y=false} : {x:Bool, y:Bool}
    true : Bool
    {true, false} : {Bool, Bool}
    true : Bool
    {x=true, y=false, a=false} : {x:Top, y:Bool}
    6.28318 : Float
    (lambda X. lambda x:X. x) : All X. X -> X
    (lambda x:All X. X->X. x) : (All X. X->X) -> (All X. X -> X)
    (lambda X<:Top->Top. lambda x:X. x x) : All X<:Top->Top. X -> Top
    (lambda x:Bool. x) : Bool -> Bool
    true : Bool
    error : Bool
    error : Bot
    error : Bool
    (lambda x:Nat. (succ x)) : Nat -> Nat
    3 : Nat
    T :: *
    (lambda f:T. lambda x:Nat. f (f x)) : T -> Nat -> Nat
    CounterRep :: *
    SetCounter :: *
    setCounterClass : CounterRep ->
                      (Unit->SetCounter) -> Unit -> SetCounter
    newSetCounter : Unit -> SetCounter
    c : SetCounter
    1 : Nat
    InstrCounter :: *
    InstrCounterRep :: *
    instrCounterClass : InstrCounterRep ->
                        (Unit->InstrCounter) -> Unit -> InstrCounter
    newInstrCounter : Unit -> InstrCounter
    ic : InstrCounter
    1 : Nat
    0 : Nat
    unit : Unit
    2 : Nat
    1 : Nat
    instrCounterClass : InstrCounterRep ->
                        (Unit->InstrCounter) -> Unit -> InstrCounter
    ResetInstrCounter :: *
    resetInstrCounterClass : InstrCounterRep ->
                             (Unit->ResetInstrCounter) ->
                             Unit -> ResetInstrCounter
    BackupInstrCounter :: *
    BackupInstrCounterRep :: *
    backupInstrCounterClass : BackupInstrCounterRep ->
                              (Unit->BackupInstrCounter) ->
                              Unit -> BackupInstrCounter
    newBackupInstrCounter : Unit -> BackupInstrCounter
    ic : BackupInstrCounter
    2 : Nat
    2 : Nat
    3 : Nat
    2 : Nat
    8 : Nat
    Counter :: *
    inc3 : Counter -> Unit
    SetCounter :: *
    InstrCounter :: *
    CounterRep :: *
    InstrCounterRep :: *
    dummySetCounter : SetCounter
    dummyInstrCounter : InstrCounter
    setCounterClass : CounterRep -> (Source SetCounter) -> SetCounter
    newSetCounter : Unit -> SetCounter
    instrCounterClass : InstrCounterRep ->
                        (Source InstrCounter) -> InstrCounter
    newInstrCounter : Unit -> InstrCounter
    c : InstrCounter
    4 : Nat
    54 : Nat
    4 : Nat
    
## fomega

    /* Examples for testing */
    
     lambda X. lambda x:X. x; 
     (lambda X. lambda x:X. x) [All X.X->X]; 
    
<center>fomega/test.f</center>

### output

    (lambda X. lambda x:X. x) : All X. X -> X
    (lambda x:All X. X->X. x) : (All X. X->X) -> (All X. X -> X)
    
## fomsub

    /* Examples for testing */
    
     lambda X. lambda x:X. x; 
     (lambda X. lambda x:X. x) [All X.X->X]; 
    
    lambda x:Top. x;
     (lambda x:Top. x) (lambda x:Top. x);
    (lambda x:Top->Top. x) (lambda x:Top. x);
    
    
    lambda X<:Top->Top. lambda x:X. x x; 
    
    
<center>fomsub/test.f</center>

### output

    (lambda X. lambda x:X. x) : All X. X -> X
    (lambda x:All X. X->X. x) : (All X. X->X) -> (All X. X -> X)
    (lambda x:Top. x) : Top -> Top
    (lambda x:Top. x) : Top
    (lambda x:Top. x) : Top -> Top
    (lambda X<:Top->Top. lambda x:X. x x) : All X<:Top->Top. X -> Top
    
## fullfsubref

    /* Examples for testing */
    
     lambda x:Bot. x;
     lambda x:Bot. x x; 
    
     
    lambda x:<a:Bool,b:Bool>. x;
    
    
    lambda x:Top. x;
     (lambda x:Top. x) (lambda x:Top. x);
    (lambda x:Top->Top. x) (lambda x:Top. x);
    
    
    (lambda r:{x:Top->Top}. r.x r.x) 
      {x=lambda z:Top.z, y=lambda z:Top.z}; 
    
    
    "hello";
    
    unit;
    
    lambda x:A. x;
    
    let x=true in x;
    
    {x=true, y=false}; 
    {x=true, y=false}.x;
    {true, false}; 
    {true, false}.1; 
    
    
    if true then {x=true,y=false,a=false} else {y=false,x={},b=false};
    
    timesfloat 2.0 3.14159;
    
    lambda X. lambda x:X. x; 
    (lambda X. lambda x:X. x) [All X.X->X]; 
    
    lambda X<:Top->Top. lambda x:X. x x; 
    
    
    lambda x:Bool. x;
    (lambda x:Bool->Bool. if x false then true else false) 
      (lambda x:Bool. if x then false else true); 
    
    if error then true else false;
    
    
    error true;
    (lambda x:Bool. x) error;
    
    
    
    
    
    lambda x:Nat. succ x;
    (lambda x:Nat. succ (succ x)) (succ 0); 
    
    T = Nat->Nat;
    lambda f:T. lambda x:Nat. f (f x);
    
    
    
    
    /* Alternative object encodings */
    
    CounterRep = {x: Ref Nat};
    
    SetCounter = {get:Unit->Nat, set:Nat->Unit, inc:Unit->Unit}; 
    
    setCounterClass =
    lambda r:CounterRep.
    lambda self: Unit->SetCounter.
    lambda _:Unit.
    {get = lambda _:Unit. !(r.x),
    set = lambda i:Nat.  r.x:=i,
    inc = lambda _:Unit. (self unit).set (succ((self unit).get unit))} 
        as SetCounter;
    
    newSetCounter = 
    lambda _:Unit.
    let r = {x=ref 1} in
    fix (setCounterClass r) unit;
    
    c = newSetCounter unit;
    c.get unit;
    
    InstrCounter = {get:Unit->Nat, 
    set:Nat->Unit, 
    inc:Unit->Unit,
    accesses:Unit->Nat};
    
    InstrCounterRep = {x: Ref Nat, a: Ref Nat};
    
    instrCounterClass =
    lambda r:InstrCounterRep.
    lambda self: Unit->InstrCounter.
    lambda _:Unit.
    let super = setCounterClass r self unit in
    {get = super.get,
    set = lambda i:Nat. (r.a:=succ(!(r.a)); super.set i),
    inc = super.inc,
    accesses = lambda _:Unit. !(r.a)} as InstrCounter;
    
    newInstrCounter = 
    lambda _:Unit.
    let r = {x=ref 1, a=ref 0} in
    fix (instrCounterClass r) unit;
    
    ic = newInstrCounter unit;
    
    ic.get unit;
    
    ic.accesses unit;
    
    ic.inc unit;
    
    ic.get unit;
    
    ic.accesses unit;
    
    /* ------------ */
    
    instrCounterClass =
    lambda r:InstrCounterRep.
    lambda self: Unit->InstrCounter.
    lambda _:Unit.
    let super = setCounterClass r self unit in
    {get = lambda _:Unit. (r.a:=succ(!(r.a)); super.get unit),
    set = lambda i:Nat. (r.a:=succ(!(r.a)); super.set i),
    inc = super.inc,
    accesses = lambda _:Unit. !(r.a)} as InstrCounter;
    
    ResetInstrCounter = {get:Unit->Nat, set:Nat->Unit, 
    inc:Unit->Unit, accesses:Unit->Nat,
    reset:Unit->Unit};
    
    resetInstrCounterClass =
    lambda r:InstrCounterRep.
    lambda self: Unit->ResetInstrCounter.
    lambda _:Unit.
    let super = instrCounterClass r self unit in
    {get = super.get,
    set = super.set,
    inc = super.inc,
    accesses = super.accesses,
    reset = lambda _:Unit. r.x:=0} 
    as ResetInstrCounter;
    
    BackupInstrCounter = {get:Unit->Nat, set:Nat->Unit, 
    inc:Unit->Unit, accesses:Unit->Nat,
    backup:Unit->Unit, reset:Unit->Unit};
    
    BackupInstrCounterRep = {x: Ref Nat, a: Ref Nat, b: Ref Nat};
    
    backupInstrCounterClass =
    lambda r:BackupInstrCounterRep.
    lambda self: Unit->BackupInstrCounter.
    lambda _:Unit.
    let super = resetInstrCounterClass r self unit in
    {get = super.get,
    set = super.set,
    inc = super.inc,
    accesses = super.accesses,
    reset = lambda _:Unit. r.x:=!(r.b),
    backup = lambda _:Unit. r.b:=!(r.x)} 
    as BackupInstrCounter;
    
    newBackupInstrCounter = 
    lambda _:Unit.
    let r = {x=ref 1, a=ref 0, b=ref 0} in
    fix (backupInstrCounterClass r) unit;
    
    ic = newBackupInstrCounter unit;
    
    (ic.inc unit; ic.get unit);
    
    (ic.backup unit; ic.get unit);
    
    (ic.inc unit; ic.get unit);
    
    (ic.reset unit; ic.get unit);
    
    ic.accesses unit;
    
    
    
    
    /*
    SetCounterMethodTable =  
    {get: Ref <none:Unit, some:Unit->Nat>, 
    set: Ref <none:Unit, some:Nat->Unit>, 
    inc: Ref <none:Unit, some:Unit->Unit>}; 
    
    packGet = 
    lambda f:Unit->Nat. 
    <some = f> as <none:Unit, some:Unit->Nat>;
    
    unpackGet = 
    lambda mt:SetCounterMethodTable.
    case !(mt.get) of
    <none=x> ==> error
    | <some=f> ==> f;
    
    packSet = 
    lambda f:Nat->Unit. 
    <some = f> as <none:Unit, some:Nat->Unit>;
    
    unpackSet = 
    lambda mt:SetCounterMethodTable.
    case !(mt.set) of
    <none=x> ==> error
    | <some=f> ==> f;
    
    packInc = 
    lambda f:Unit->Unit. 
    <some = f> as <none:Unit, some:Unit->Unit>;
    
    unpackInc = 
    lambda mt:SetCounterMethodTable.
    case !(mt.inc) of
    <none=x> ==> error
    | <some=f> ==> f;
    
    setCounterClass =
    lambda r:CounterRep.
    lambda self: SetCounterMethodTable.
    (self.get := packGet (lambda _:Unit. !(r.x));
    self.set := packSet (lambda i:Nat.  r.x:=i);
    self.inc := packInc (lambda _:Unit. unpackSet self (succ (unpackGet self unit))));
    */
    
    /* This diverges...
    
    setCounterClass =
    lambda R<:CounterRep.
    lambda self: R->SetCounter.
    lambda r: R.
    {get = lambda _:Unit. !(r.x),
    set = lambda i:Nat.  r.x:=i,
    inc = lambda _:Unit. (self r).set (succ((self r).get unit))} 
        as SetCounter;
    
    newSetCounter = 
    lambda _:Unit.
    let r = {x=ref 1} in
    fix (setCounterClass [CounterRep]) r;
    
    InstrCounter = {get:Unit->Nat, 
    set:Nat->Unit, 
    inc:Unit->Unit,
    accesses:Unit->Nat};
    
    InstrCounterRep = {x: Ref Nat, a: Ref Nat};
    
    instrCounterClass =
    lambda R<:InstrCounterRep.
    lambda self: R->InstrCounter.
    let super = setCounterClass [R] self in
    lambda r:R.
    {get = (super r).get,
    set = lambda i:Nat. (r.a:=succ(!(r.a)); (super r).set i),
    inc = (super r).inc,
    accesses = lambda _:Unit. !(r.a)} as InstrCounter;
    
    
    newInstrCounter = 
    lambda _:Unit.
    let r = {x=ref 1, a=ref 0} in
    fix (instrCounterClass [InstrCounterRep]) r;
    
    SET traceeval;
    
    ic = newInstrCounter unit;
    
    ic.get unit;
    
    ic.accesses unit;
    
    ic.inc unit;
    
    ic.get unit;
    
    ic.accesses unit;
    */
    
    /* This is cool...
    
    setCounterClass =
    lambda M<:SetCounter.
    lambda R<:CounterRep.
    lambda self: Ref(R->M).
    lambda r: R.
    {get = lambda _:Unit. !(r.x),
    set = lambda i:Nat.  r.x:=i,
    inc = lambda _:Unit. (!self r).set (succ((!self r).get unit))} 
          as SetCounter;
    
    
    newSetCounter = 
    lambda _:Unit.
    let m = ref (lambda r:CounterRep. error as SetCounter) in
    let m' = setCounterClass [SetCounter] [CounterRep] m in
    (m := m';
    let r = {x=ref 1} in
    m' r);
    
    c = newSetCounter unit;
    
    c.get unit;
    
    c.set 3;
    
    c.inc unit;
    
    c.get unit;
    
    setCounterClass =
    lambda M<:SetCounter.
    lambda R<:CounterRep.
    lambda self: Ref(R->M).
    lambda r: R.
    {get = lambda _:Unit. !(r.x),
    set = lambda i:Nat.  r.x:=i,
    inc = lambda _:Unit. (!self r).set (succ((!self r).get unit))} 
          as SetCounter;
    
    InstrCounter = {get:Unit->Nat, 
    set:Nat->Unit, 
    inc:Unit->Unit,
    accesses:Unit->Nat};
    
    InstrCounterRep = {x: Ref Nat, a: Ref Nat};
    
    instrCounterClass =
    lambda M<:InstrCounter.
    lambda R<:InstrCounterRep.
    lambda self: Ref(R->M).
    lambda r: R.
    let super = setCounterClass [M] [R] self in
    {get = (super r).get,
    set = lambda i:Nat. (r.a:=succ(!(r.a)); (super r).set i),
    inc = (super r).inc,
    accesses = lambda _:Unit. !(r.a)}     as InstrCounter;
    
    newInstrCounter = 
    lambda _:Unit.
    let m = ref (lambda r:InstrCounterRep. error as InstrCounter) in
    let m' = instrCounterClass [InstrCounter] [InstrCounterRep] m in
    (m := m';
    let r = {x=ref 1, a=ref 0} in
    m' r);
    
    ic = newInstrCounter unit;
    
    ic.get unit;
    
    ic.accesses unit;
    
    ic.inc unit;
    
    ic.get unit;
    
    ic.accesses unit;
    */
    
    /* James Reily's alternative: */
    
    Counter = {get:Unit->Nat, inc:Unit->Unit};
    inc3 = lambda c:Counter. (c.inc unit; c.inc unit; c.inc unit);
    
    SetCounter = {get:Unit->Nat, set:Nat->Unit, inc:Unit->Unit};
    InstrCounter = {get:Unit->Nat, set:Nat->Unit, inc:Unit->Unit, accesses:Unit->Nat};
    
    CounterRep = {x: Ref Nat};
    InstrCounterRep = {x: Ref Nat, a: Ref Nat};
    
    dummySetCounter =
    {get = lambda _:Unit. 0,
    set = lambda i:Nat.  unit,
    inc = lambda _:Unit. unit}
    as SetCounter;
    dummyInstrCounter =
    {get = lambda _:Unit. 0,
    set = lambda i:Nat.  unit,
    inc = lambda _:Unit. unit,
    accesses = lambda _:Unit. 0}
    as InstrCounter;
    
    setCounterClass =
    lambda r:CounterRep.
    lambda self: Source SetCounter.     
    {get = lambda _:Unit. !(r.x),
    set = lambda i:Nat. r.x:=i,
    inc = lambda _:Unit. (!self).set (succ ((!self).get unit))}
    as SetCounter;
    newSetCounter =
    lambda _:Unit. let r = {x=ref 1} in
    let cAux = ref dummySetCounter in
    (cAux :=
    (setCounterClass r cAux);
    !cAux);
    
    instrCounterClass =
    lambda r:InstrCounterRep.
    lambda self: Source InstrCounter.       /* NOT Ref */
    let super = setCounterClass r self in
    {get = super.get,
    set = lambda i:Nat. (r.a:=succ(!(r.a)); super.set i),
    inc = super.inc,
    accesses = lambda _:Unit. !(r.a)}
    as InstrCounter;
    newInstrCounter =
    lambda _:Unit. let r = {x=ref 1, a=ref 0} in
    let cAux = ref dummyInstrCounter in
    (cAux :=
    (instrCounterClass r cAux);
    !cAux);
    
    c = newInstrCounter unit;
    (inc3 c; c.get unit);
    (c.set(54); c.get unit);
    (c.accesses unit);
    
    
    
    
<center>fullfsubref/test.f</center>

### output

    (lambda x:Bot. x) : Bot -> Bot
    (lambda x:Bot. x x) : Bot -> Bot
    (lambda x:<a:Bool,b:Bool>. x)
      : <a:Bool,b:Bool> -> <a:Bool, b:Bool>
    (lambda x:Top. x) : Top -> Top
    (lambda x:Top. x) : Top
    (lambda x:Top. x) : Top -> Top
    (lambda z:Top. z) : Top
    "hello" : String
    unit : Unit
    (lambda x:A. x) : A -> A
    true : Bool
    {x=true, y=false} : {x:Bool, y:Bool}
    true : Bool
    {true, false} : {Bool, Bool}
    true : Bool
    {x=true, y=false, a=false} : {x:Top, y:Bool}
    6.28318 : Float
    (lambda X. lambda x:X. x) : All X. X -> X
    (lambda x:All X. X->X. x) : (All X. X->X) -> (All X. X -> X)
    (lambda X<:Top->Top. lambda x:X. x x) : All X<:Top->Top. X -> Top
    (lambda x:Bool. x) : Bool -> Bool
    true : Bool
    error : Bool
    error : Bot
    error : Bool
    (lambda x:Nat. (succ x)) : Nat -> Nat
    3 : Nat
    T :: *
    (lambda f:T. lambda x:Nat. f (f x)) : T -> Nat -> Nat
    CounterRep :: *
    SetCounter :: *
    setCounterClass : CounterRep ->
                      (Unit->SetCounter) -> Unit -> SetCounter
    newSetCounter : Unit -> SetCounter
    c : SetCounter
    1 : Nat
    InstrCounter :: *
    InstrCounterRep :: *
    instrCounterClass : InstrCounterRep ->
                        (Unit->InstrCounter) -> Unit -> InstrCounter
    newInstrCounter : Unit -> InstrCounter
    ic : InstrCounter
    1 : Nat
    0 : Nat
    unit : Unit
    2 : Nat
    1 : Nat
    instrCounterClass : InstrCounterRep ->
                        (Unit->InstrCounter) -> Unit -> InstrCounter
    ResetInstrCounter :: *
    resetInstrCounterClass : InstrCounterRep ->
                             (Unit->ResetInstrCounter) ->
                             Unit -> ResetInstrCounter
    BackupInstrCounter :: *
    BackupInstrCounterRep :: *
    backupInstrCounterClass : BackupInstrCounterRep ->
                              (Unit->BackupInstrCounter) ->
                              Unit -> BackupInstrCounter
    newBackupInstrCounter : Unit -> BackupInstrCounter
    ic : BackupInstrCounter
    2 : Nat
    2 : Nat
    3 : Nat
    2 : Nat
    8 : Nat
    Counter :: *
    inc3 : Counter -> Unit
    SetCounter :: *
    InstrCounter :: *
    CounterRep :: *
    InstrCounterRep :: *
    dummySetCounter : SetCounter
    dummyInstrCounter : InstrCounter
    setCounterClass : CounterRep -> (Source SetCounter) -> SetCounter
    newSetCounter : Unit -> SetCounter
    instrCounterClass : InstrCounterRep ->
                        (Source InstrCounter) -> InstrCounter
    newInstrCounter : Unit -> InstrCounter
    c : InstrCounter
    4 : Nat
    54 : Nat
    4 : Nat
    
## fullupdate

    /* Examples for testing */
    
     lambda x:Top. x;
      (lambda x:Top. x) (lambda x:Top. x);
     (lambda x:Top->Top. x) (lambda x:Top. x);
     
    
    (lambda r:{x:Top->Top}. r.x r.x) 
      {x=lambda z:Top.z, y=lambda z:Top.z}; 
    
    
    "hello";
    
    unit;
    
    lambda x:A. x;
    
    let x=true in x;
    
    {x=true, y=false}; 
    {x=true, y=false}.x;
    {true, false}; 
    {true, false}.1; 
    
    
    if true then {x=true,y=false,a=false} else {y=false,x={},b=false};
    
    timesfloat 2.0 3.14159;
    
    lambda X. lambda x:X. x; 
    (lambda X. lambda x:X. x) [All X.X->X]; 
    
    lambda X<:Top->Top. lambda x:X. x x; 
    
    
    lambda x:Bool. x;
    (lambda x:Bool->Bool. if x false then true else false) 
      (lambda x:Bool. if x then false else true); 
    
    lambda x:Nat. succ x;
    (lambda x:Nat. succ (succ x)) (succ 0); 
    
    T = Nat->Nat;
    lambda f:T. lambda x:Nat. f (f x);
    
    
     {*All Y.Y, lambda x:(All Y.Y). x} as {Some X,X->X};
    
    
    {*Nat, {c=0, f=lambda x:Nat. succ x}}
      as {Some X, {c:X, f:X->Nat}};
    let {X,ops} = {*Nat, {c=0, f=lambda x:Nat. succ x}}
                  as {Some X, {c:X, f:X->Nat}}
    in (ops.f ops.c);
    
    
    
    Pair = lambda X. lambda Y. All R. (X->Y->R) -> R;
    
    pair = lambda X.lambda Y.lambda x:X.lambda y:Y.lambda R.lambda p:X->Y->R.p x y;
    
    f = lambda X.lambda Y.lambda f:Pair X Y. f;
    
    fst = lambda X.lambda Y.lambda p:Pair X Y.p [X] (lambda x:X.lambda y:Y.x);
    snd = lambda X.lambda Y.lambda p:Pair X Y.p [Y] (lambda x:X.lambda y:Y.y);
    
    pr = pair [Nat] [Bool] 0 false;
    fst [Nat] [Bool] pr;
    snd [Nat] [Bool] pr;
    
    List = lambda X. All R. (X->R->R) -> R -> R; 
    
    diverge =
    lambda X.
      lambda _:Unit.
      fix (lambda x:X. x);
    
    nil = lambda X.
          (lambda R. lambda c:X->R->R. lambda n:R. n)
          as List X; 
    
    cons = 
    lambda X.
      lambda hd:X. lambda tl: List X.
         (lambda R. lambda c:X->R->R. lambda n:R. c hd (tl [R] c n))
         as List X; 
    
    isnil =  
    lambda X. 
      lambda l: List X. 
        l [Bool] (lambda hd:X. lambda tl:Bool. false) true; 
    
    head = 
    lambda X. 
      lambda l: List X. 
        (l [Unit->X] (lambda hd:X. lambda tl:Unit->X. lambda _:Unit. hd) (diverge [X]))
        unit; 
    
    tail =  
    lambda X.  
      lambda l: List X. 
        (fst [List X] [List X] ( 
          l [Pair (List X) (List X)]
            (lambda hd: X. lambda tl: Pair (List X) (List X). 
              pair [List X] [List X] 
                (snd [List X] [List X] tl)  
                (cons [X] hd (snd [List X] [List X] tl))) 
            (pair [List X] [List X] (nil [X]) (nil [X]))))
        as List X; 
    
    
<center>fullupdate/test.f</center>

### output

    (lambda x:Top. x) : Top -> Top
    (lambda x:Top. x) : Top
    (lambda x:Top. x) : Top -> Top
    (lambda z:Top. z) : Top
    "hello" : String
    unit : Unit
    (lambda x:A. x) : A -> A
    true : Bool
    {x=true, y=false} : {x:Bool, y:Bool}
    true : Bool
    {true, false} : {Bool, Bool}
    true : Bool
    {x=true, y=false, a=false} : {x:Top, y:Bool}
    6.28318 : Float
    (lambda X. lambda x:X. x) : All X. X -> X
    (lambda x:All X. X->X. x) : (All X. X->X) -> (All X. X -> X)
    (lambda X<:Top->Top. lambda x:X. x x) : All X<:Top->Top. X -> Top
    (lambda x:Bool. x) : Bool -> Bool
    true : Bool
    (lambda x:Nat. (succ x)) : Nat -> Nat
    3 : Nat
    T :: *
    (lambda f:T. lambda x:Nat. f (f x)) : T -> Nat -> Nat
    {*All Y. Y, lambda x:All Y. Y.x} as {Some X, X->X}
      : {Some X, X->X}
    {*Nat, {c=0,f=lambda x:Nat. (succ x)}} as {Some X, {c:X,f:X->Nat}}
      : {Some X, {c:X,f:X->Nat}}
    1 : Nat
    Pair :: * => * => *
    pair : All X. All Y. X -> Y -> (All R. (X->Y->R) -> R)
    f : All X. All Y. Pair X Y -> Pair X Y
    fst : All X. All Y. Pair X Y -> X
    snd : All X. All Y. Pair X Y -> Y
    pr : All R. (Nat->Bool->R) -> R
    0 : Nat
    false : Bool
    List :: * => *
    diverge : All X. Unit -> X
    nil : All X. List X
    cons : All X. X -> List X -> List X
    isnil : All X. List X -> Bool
    head : All X. List X -> X
    tail : All X. List X -> List X
    
