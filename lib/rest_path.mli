module Var :
  sig
    type vars
    val get : vars -> string -> string option
  end
type t
val convert : Core.String.t -> t
val match_path : t -> t -> Var.vars option
