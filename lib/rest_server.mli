module Path : sig
  module Var : sig
    type vars

    val get : vars -> string -> string option
  end

  type t

  val from_string : Core.String.t -> t

  val match_path : t -> t -> Var.vars option
end

module Http_json : sig
  val response_error :
       ?error:Httpaf.Status.standard
    -> ?text:string
    -> 'a Httpaf.Reqd.t
    -> unit

  val response_ok : 'a Httpaf.Reqd.t -> unit

  val response_json :
    'a Httpaf.Reqd.t -> Yojson.Safe.json -> unit

  val request_json :
       'a Httpaf.Reqd.t
    -> ('a Httpaf.Reqd.t -> Yojson.Safe.json -> unit)
    -> unit
end

module Api : sig
  type response =
    { response_error:
           ?error:Httpaf.Status.standard
        -> ?text:string
        -> unit
        -> unit
    ; response_ok: unit -> unit
    ; response_json: Yojson.Safe.json -> unit
    ; get_path_var: Core.String.t -> Core.String.t option
    }

  type 'a handlers

  val empty : 'a handlers

  val register :
       Httpaf.Method.t
    -> Core.String.t
    -> ('a Httpaf.Reqd.t -> Path.Var.vars -> unit)
    -> 'a handlers
    -> 'a handlers

  val get :
       Core.String.t
    -> (response -> unit)
    -> 'a handlers
    -> 'a handlers

  val put :
       Core.String.t
    -> (response -> Yojson.Safe.json -> unit)
    -> 'a handlers
    -> 'a handlers

  val post :
       Core.String.t
    -> (response -> Yojson.Safe.json -> unit)
    -> 'a handlers
    -> 'a handlers

  val delete :
       Core.String.t
    -> (response -> unit)
    -> 'a handlers
    -> 'a handlers
end

val main : Async.Fd.t Api.handlers -> unit
