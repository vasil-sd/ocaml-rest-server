module Var :
  sig
    type vars
    val get : vars -> string -> string option
  end
type t
val from_string : Core.String.t -> t
val append : t -> t -> t
val match_path : t -> t -> Var.vars option
