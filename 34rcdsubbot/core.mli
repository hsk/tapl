(* module Core

   Core typechecking and evaluation functions
*)

open Syntax
open Support.Error

val bigstep : bool ref
val eval : context -> term -> term 
val typeof : context -> term -> ty
val subtype : ty -> ty -> bool
