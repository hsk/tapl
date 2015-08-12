(* module Core

   Core typechecking and evaluation functions
*)

open Syntax
open Support.Error

val bigstep : bool ref
val eval : context -> term -> term 
type constr
type uvargenerator
val uvargen : uvargenerator
val prconstr : constr -> unit
val emptyconstr : constr
val unify : info -> context -> string -> constr -> constr
val recon : context -> uvargenerator -> term -> (ty * uvargenerator * constr)
val combineconstr : constr -> constr -> constr
val applysubst : constr -> ty -> ty
