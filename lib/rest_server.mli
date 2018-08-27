module Path : sig
  module Var : sig
    type vars

    val get : vars -> string -> string option
  end

  type t

  val convert : Core.String.t -> t

  val match_path : t -> t -> Var.vars option
end

module Http_json : sig
  val response_error :
       ?error:Httpaf.Status.standard
    -> ?text:string
    -> 'a Httpaf.Reqd.t
    -> unit

  val response_ok : 'a Httpaf.Reqd.t -> unit

  val http_send_json_response :
    'a Httpaf.Reqd.t -> Yojson.Safe.json -> unit

  val http_receive_json_request :
       'a Httpaf.Reqd.t
    -> Httpaf.Request.t
    -> (   'a Httpaf.Reqd.t
        -> Httpaf.Request.t
        -> Yojson.Safe.json
        -> unit)
    -> unit
end

module Api : sig
  exception Path_Conflict

  type 'a handlers

  val empty : 'a handlers

  val register :
       Httpaf.Method.t
    -> Core.String.t
    -> (   'a Httpaf.Reqd.t
        -> Httpaf.Request.t
        -> Path.Var.vars
        -> unit)
    -> 'a handlers
    -> 'a handlers

  val get :
       Core.String.t
    -> (   'a Httpaf.Reqd.t
        -> Httpaf.Request.t
        -> Path.Var.vars
        -> unit)
    -> 'a handlers
    -> 'a handlers

  val put :
       Core.String.t
    -> (   'a Httpaf.Reqd.t
        -> Httpaf.Request.t
        -> Path.Var.vars
        -> unit)
    -> 'a handlers
    -> 'a handlers

  val post :
       Core.String.t
    -> (   'a Httpaf.Reqd.t
        -> Httpaf.Request.t
        -> Path.Var.vars
        -> unit)
    -> 'a handlers
    -> 'a handlers

  val delete :
       Core.String.t
    -> (   'a Httpaf.Reqd.t
        -> Httpaf.Request.t
        -> Path.Var.vars
        -> unit)
    -> 'a handlers
    -> 'a handlers

end

val main : Async.Fd.t Api.handlers -> unit
